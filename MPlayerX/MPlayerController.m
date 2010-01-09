/*
 * MPlayerX - MPlayerController.m
 *
 * Copyright (C) 2009 Zongyao QU
 * 
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import "MPlayerController.h"
#import <sys/mman.h>
#import "coredef_private.h"

#define kPollingTimeForTimePos	(1)

#define SAFERELEASE(x)			{if(x) {[x release]; x = nil;}}
#define SAFECLOSESHM(x)			{if(x != -1) {close(x); x = -1;}}
#define SAFEUNMAP(x, sz)		{if(x) {munmap(x, sz); x = NULL; sz = 0;}} 
#define SAFERELEASETIMER(x)		{if(x) {[x invalidate]; [x release]; x = nil;}}

// the Distant Protocol from mplayer binary
@protocol MPlayerOSXVOProto
- (int) startWithWidth: (bycopy int)width withHeight: (bycopy int)height withBytes: (bycopy int)bytes withAspect: (bycopy int)aspect;
- (void) stop;
- (void) render;
- (void) toggleFullscreen;
- (void) ontop;
@end

/// 内部方法声明
@interface MPlayerController (MPlayerOSXVOProto)
- (int) startWithWidth: (bycopy int)width withHeight: (bycopy int)height withBytes: (bycopy int)bytes withAspect: (bycopy int)aspect;
- (void) stop;
- (void) render;
- (void) toggleFullscreen;
- (void) ontop;
@end

@interface MPlayerController (MPlayerControllerInternal)
-(void) getCurrentTime:(NSTimer *)theTimer;
-(void) playerTaskTerminatedOnMainThread:(NSDictionary*)info;
@end

@implementation MPlayerController

@synthesize state;
@synthesize dispDelegate;
@synthesize pm;
@synthesize movieInfo;
@synthesize mpPathPair;
@synthesize la;

///////////////////////////////////////////Init/Dealloc////////////////////////////////////////////////////////
-(id) init
{
	if (self = [super init]) {
		state = kMPCStoppedState;
		
		pm = [[ParameterManager alloc] init];
		movieInfo = [[MovieInfo alloc] init];

		la = [[LogAnalyzer alloc] initWithDelegate:movieInfo];
		[movieInfo resetWithParameterManager:pm];
		
		playerCore = [[PlayerCore alloc] init];
		[playerCore setDelegate:self];
		mpPathPair = nil;

		imageData = NULL;
		imageSize = 0;
		sharedBufferName = nil;
		shMemID = -1;
		
		dispDelegate = nil;
		
		pollingTimer = nil;
	}
	return self;
}

-(void) setMpPathPair:(NSDictionary *) dict
{
	if (dict) {
		if ([dict objectForKey:kI386Key] && [dict objectForKey:kX86_64Key]) {
			[mpPathPair release];
			mpPathPair = [dict retain];
		}		
	}
	else {
		[mpPathPair release];
		mpPathPair = nil;
	}
}

-(void) dealloc
{
	SAFERELEASE(movieInfo);
	SAFERELEASE(la);
	SAFERELEASE(pm);
	SAFERELEASE(playerCore);
	SAFERELEASE(mpPathPair);
	SAFERELEASE(sharedBufferName);
	SAFERELEASETIMER(pollingTimer);
	
	[super dealloc];
}

//////////////////////////////////////////////Hack to get communicate with mplayer/////////////////////////////////////////////
-(BOOL) conformsToProtocol:(Protocol *)aProtocol
{
	if (aProtocol == @protocol(MPlayerOSXVOProto)) {
		return YES;
	}
	return [super conformsToProtocol: aProtocol];
}

//////////////////////////////////////////////comunication with playerCore/////////////////////////////////////////////////////
-(void) playerTaskTerminated: (BOOL) byForce from:(id)sender
{
	state = kMPCStoppedState;

	// 这个Delegate方法，可能发生在主线程（当调用playerCore的terminate方法），也可能发生在Player线程（播放过程结束）
	// 而这里需要销毁的东西，会在主线程里读写，因此，销毁工作必须放在主线程里进行
	// 要保证执行顺序，需要waitUntilDone为YES

	// 在MplayerController的playerStopped的方法里面，会根据playing状态设定window level
	// 因此要先设定state再通知
	[self performSelectorOnMainThread:@selector(playerTaskTerminatedOnMainThread:)
						   withObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:byForce], kMPCPlayStoppedByForceKey,
																				 [[[movieInfo.playingInfo currentTime] retain] autorelease], kMPCPlayStoppedTimeKey, nil]
						waitUntilDone:YES];
	NSLog(@"term:%d", byForce);
}

-(void) playerTaskTerminatedOnMainThread:(NSDictionary*)info
{
	// Timer是在主线程上创建的，所以要在主线程上销毁
	SAFERELEASETIMER(pollingTimer);
	[la stop];
	[movieInfo resetWithParameterManager:pm];
	SAFERELEASE(sharedBufferName);
	
	[[NSNotificationCenter defaultCenter] postNotificationName:kMPCPlayStoppedNotification 
														object:self
													  userInfo:info];	
}

- (BOOL) outputAvailable: (NSData*) outData from:(id)sender
{
	[la analyzeData:outData];
	return NO;
}

- (BOOL) errorHappened: (NSData*) errData from:(id)sender
{
	NSString *log = [[NSString alloc] initWithData:errData encoding:NSUTF8StringEncoding];
	
	NSLog(@"ERR:%@", log);
	[log release];
	return NO;	
}

//////////////////////////////////////////////protocol for render/////////////////////////////////////////////////////
- (int) startWithWidth: (bycopy int)width withHeight: (bycopy int)height withBytes: (bycopy int)bytes withAspect: (bycopy int)aspect
{
	// NSLog(@"start");
	if (dispDelegate && sharedBufferName) {
		// 打开shmem
		shMemID = shm_open([sharedBufferName UTF8String], O_RDONLY, S_IRUSR);
		if (shMemID == -1) {
			NSLog(@"shm_open Failed!");
			return 0;
		}
		
		imageSize = width* height* bytes;
		imageData = mmap(NULL, imageSize, PROT_READ, MAP_SHARED, shMemID, 0);
		
		if (imageData == MAP_FAILED) {
			imageData = NULL;
			SAFECLOSESHM(shMemID);
			NSLog(@"mmap Failed");
			return 0;
		}
		return [dispDelegate startWithWidth:width 
									 height:height 
								pixelFormat:((bytes == 4)? k32ARGBPixelFormat: kYUVSPixelFormat) 
									 aspect:aspect
									   from:self];
	}
	return 0;
}

- (void) stop
{
	if (dispDelegate) {
		[dispDelegate stop: self];
		SAFEUNMAP(imageData, imageSize);
		SAFECLOSESHM(shMemID);
	}
	// NSLog(@"stop");
}

- (void) render
{
	if (dispDelegate) {
		[dispDelegate draw:imageData from:self];
	}
	//NSLog(@"render");
}

- (void) toggleFullscreen {/* This function should be realized at up-level */}
- (void) ontop {/* This function should be realized at up-level */ }

//////////////////////////////////////////////playing thing/////////////////////////////////////////////////////
-(void) playMedia: (NSString*) moviePath
{
	// 如果pm的guessSubCP为YES的话，那么应该主动调用pm的getsubcp的方法，并将这个值带到subCP中
	static unsigned int cnt = 1;

	// 如果正在放映，那么现强制停止
	if (state != kMPCStoppedState) {
		[self performStop];
	}

	// 如果有delegate想要图像数据，那么就建立DistantObject
	if (dispDelegate) {
		sharedBufferName = [[NSString alloc] initWithFormat:@"MPlayerX_%X%d", self, cnt++];
		[[NSConnection serviceConnectionWithName:sharedBufferName rootObject:self] runInNewThread];
	} else {
		// 如果没有人想要图像数据，那么将这个参数设置为nil，会使得mplayer的corevideo放弃生成shmem（ParameterManager里面实现的）
		sharedBufferName = nil;
	}

	// 如果想要自动获得字幕文件的codepage，需要调用这个函数
	if ([pm guessSubCP]) {
		[pm getCPFromMoviePath:moviePath withOptions: kParameterManagerSetSubCPIfGuessedOut];
	}

	// 重置影片信息，同步PlayingInfo
	[movieInfo resetWithParameterManager:pm];
	
	NSLog(@"%@", [pm arrayOfParametersWithName:sharedBufferName]);
	
	if ( [playerCore playMedia:moviePath 
					  withExec:[mpPathPair objectForKey:(pm.prefer64bMPlayer)?kX86_64Key:kI386Key] 
					withParams:[pm arrayOfParametersWithName:sharedBufferName]]
	   ) {
		state = kMPCPlayingState;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:kMPCPlayStartedNotification object:self];
		
		// 这里需要打开Timer去Polling播放时间，然后定期发送现在的播放时间
		pollingTimer = [[NSTimer timerWithTimeInterval:kPollingTimeForTimePos
											    target:self
										 	  selector:@selector(getCurrentTime:)
											  userInfo:nil
											   repeats:YES] retain];
		[[NSRunLoop currentRunLoop] addTimer:pollingTimer forMode:NSDefaultRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:pollingTimer forMode:NSModalPanelRunLoopMode];
		[[NSRunLoop currentRunLoop] addTimer:pollingTimer forMode:NSEventTrackingRunLoopMode];
	} else {
		// 如果没有成功打开媒体文件
		SAFERELEASE(sharedBufferName);
	}
}

-(void) getCurrentTime:(NSTimer*)theTimer
{
	if (state == kMPCPlayingState) {
		// 发这个命令会自动让mplayer退出pause状态，而用keep_pause的perfix会得不到任何返回,因此只有在没有pause的时候会polling播放时间
		[playerCore sendStringCommand: [NSString stringWithFormat:@"%@ %@\n", kMPCGetPropertyPreFix, kMPCTimePos]];
	}
}

-(void) performStop
{
	// 直接停止core，因为self是core的delegate，
	// terminate方法会调用delegate，然后在那里进行相关的清理工作，所以不在这里做
	SAFERELEASETIMER(pollingTimer);
	[playerCore terminate];
}

-(void) togglePause
{
	if (state != kMPCStoppedState) {
		// 如果不是停止状态
		[playerCore sendStringCommand: kMPCTogglePauseCmd];

		if (state == kMPCPlayingState) {
			state = kMPCPausedState;
		} else {
			state = kMPCPlayingState;
		}
	}
}

-(void) performFrameStep
{
	if (state != kMPCStoppedState) {
		// 如果不是停止状态
		[playerCore sendStringCommand:kMPCFrameStepCmd];
		state = kMPCPausedState;
	}
}

-(void) setSpeed: (float) speed
{
	speed = MAX(speed, 0.1);
	if ([playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %f\n", kMPCSetPropertyPreFixPauseKeep, kMPCSpeed, speed]]) {
		[movieInfo.playingInfo setSpeed:[NSNumber numberWithFloat: speed]];
	}
}

-(void) setChapter: (int) chapter
{
	if ([playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %d\n", kMPCSetPropertyPreFix, kMPCChapter, chapter]]) {
		[movieInfo.playingInfo setCurrentChapter: chapter];
	}
}

-(float) setTimePos: (float) time
{
	time = MAX(time, 0);
	if ([playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %f\n", kMPCSetPropertyPreFixPauseKeep, kMPCTimePos, time]]) {
		[movieInfo.playingInfo setCurrentTime:[NSNumber numberWithFloat:time]];
		return time;
	}
	return -1;
}

-(float) setVolume: (float) vol
{
	vol = MIN(100, MAX(vol, 0));
	if ([playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %f\n", kMPCSetPropertyPreFixPauseKeep, kMPCVolume, GetRealVolume(vol)]]) {
		[movieInfo.playingInfo setVolume: vol];
	}
	return vol;
}

-(void) setBalance: (float) bal
{
	bal = MIN(1, MAX(bal, -1));
	if ([playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %f\n", kMPCSetPropertyPreFix, kMPCAudioBalance, bal]]) {
		[movieInfo.playingInfo setAudioBalance: bal];
	}
}

-(BOOL) setMute: (BOOL) mute
{
	if ([playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %d\n", kMPCSetPropertyPreFixPauseKeep, kMPCMute, (mute)?1:0]]) {
		[movieInfo.playingInfo setMute:mute];
	} else {
		[movieInfo.playingInfo setMute:NO];
		mute = NO;
	}
	return mute;
}

-(void) setAudioDelay: (float) delay
{
	if ([playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %f\n", kMPCSetPropertyPreFixPauseKeep, kMPCAudioDelay, delay]]) {
		[movieInfo.playingInfo setAudioDelay: [NSNumber numberWithFloat: delay]];
	}
}

-(void) setSwitchAudio: (unsigned char) audioID
{
	[playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %d\n", kMPCSetPropertyPreFix, kMPCSwitchAudio, audioID]];	
}

-(void) setSub: (int) subID
{
	[playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %d\n", kMPCSetPropertyPreFixPauseKeep, kMPCSub, subID]];
}

-(void) setSubDelay: (float) delay
{
	if ([playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %f\n", kMPCSetPropertyPreFixPauseKeep, kMPCSubDelay, delay]]) {
		[movieInfo.playingInfo setSubDelay:[NSNumber numberWithFloat: delay]];
	}
}

-(void) setSubPos: (int) pos
{
	pos = MIN(100, MAX(pos, 0));
	if ([playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %d\n", kMPCSetPropertyPreFix, kMPCSubPos, pos]]) {
		[movieInfo.playingInfo setSubPos:pos];
	}
}

-(void) setSubScale: (float) scale
{
	scale = MAX(0.1, MIN(scale, 100));

	if ([playerCore sendStringCommand:[NSString stringWithFormat:@"%@ %@ %f\n", kMPCSetPropertyPreFixPauseKeep, kMPCSubScale, scale]]) {
		[movieInfo.playingInfo setSubScale:[NSNumber numberWithFloat:scale]];
	}
}

-(void) simulateKeyDown: (char) keyCode
{
	[playerCore sendStringCommand: [NSString stringWithFormat:@"%@ %d\n", kMPCKeyEventCmd, keyCode]];
}

@end