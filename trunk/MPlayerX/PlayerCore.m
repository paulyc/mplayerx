/*
 * MPlayerX - PlayerCore.m
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
#import "PlayerCore.h"

/** 默认的stdout，stderr的polling时间间隔*/
#define POLLING_TIME	(0.5)

#define kPlayerCoreTermNormal		(0)

@implementation PlayerCore

@synthesize delegate;

#pragma mark Init/Dealloc
-(id) init 
{
	if (self = [super init]) {
		delegate = nil;
		task = nil;
		pollingTimer = nil;
		runningModes = [[NSArray alloc] initWithObjects:NSDefaultRunLoopMode, NSModalPanelRunLoopMode, NSEventTrackingRunLoopMode, nil];
	}
	return self;
}

-(void) dealloc
{
	// terminate函数里面会调用delegate的函数，可能会产生逻辑错误
	delegate = nil;

	[self terminate];
	[runningModes release];
	
	[super dealloc];
}

#pragma mark Function
- (void) terminate
{
	if (task) {
		// 为了防止函数多次运行
		NSTask *backup = task;
		task = nil;
		
		if ([backup isRunning]) {
			[backup terminate];
			[backup waitUntilExit];
		}
		[backup release];
	}
}

- (BOOL) playMedia: (NSString *) moviePath withExec: (NSString *) execPath withParams: (NSArray *) params
{
	if (moviePath && execPath) {
	
		[self terminate];
		
		// 建立task
		task = [[NSTask alloc] init];
		// 关联输入输出
		[task setStandardInput:[NSPipe pipe]];
		[task setStandardOutput:[NSPipe pipe]];
		[task setStandardError: [NSPipe pipe]];
		// 指定运行exec的地址
		[task setLaunchPath: execPath];
		// 创建argv
		if (params) {
			[task setArguments: [params arrayByAddingObject:moviePath]];
		} else {
			[task setArguments: [NSArray arrayWithObject:moviePath]];
		}
		
		// 设置环境参数
		NSMutableDictionary *env = [[[NSProcessInfo processInfo] environment] mutableCopy];
		[env setObject:@"1" forKey:@"DYLD_BIND_AT_LAUNCH"]; //delete the message for DYLD
		[env setObject:@"xterm" forKey:@"TERM"]; // delete the message from mplayer about the "unknown" terminal
		[task setEnvironment:env];
		[env autorelease];
		
		[task setCurrentDirectoryPath:[execPath stringByDeletingLastPathComponent]];
		
		// 建立监听机制
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(readOutput:)
													 name:NSFileHandleReadCompletionNotification
												   object:[[task standardOutput] fileHandleForReading]];
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(readError:)
													 name:NSFileHandleReadCompletionNotification
												   object:[[task standardError] fileHandleForReading]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(taskHasTerminated:)
													 name:NSTaskDidTerminateNotification
												   object:task];
		
		pollingTimer = [[NSTimer timerWithTimeInterval:POLLING_TIME	
												target:self
											  selector:@selector(pollingOutputAndError)
											  userInfo:nil
											   repeats:YES] retain];

		NSRunLoop *rl = [NSRunLoop currentRunLoop];
		[rl addTimer:pollingTimer forMode:NSDefaultRunLoopMode];
		[rl addTimer:pollingTimer forMode:NSModalPanelRunLoopMode];
		[rl addTimer:pollingTimer forMode:NSEventTrackingRunLoopMode];

		// 运行task
		[task launch];
		return YES;
	}
	return NO;
}

-(void) pollingOutputAndError
{
	if (task && [task isRunning]) {
		[[[task standardOutput] fileHandleForReading] readInBackgroundAndNotifyForModes:runningModes];
		[[[task  standardError] fileHandleForReading] readInBackgroundAndNotifyForModes:runningModes];
	}
}

- (BOOL) sendStringCommand: (NSString *) cmd
{
	// 如果task正在运行
	if (task && [task isRunning]) {
		[[[task standardInput] fileHandleForWriting] writeData:[cmd dataUsingEncoding:NSUTF8StringEncoding]];
		return YES;
	}
	return NO;
}

#pragma mark Internal 
- (void) readOutput:(NSNotification *)notification
{
	if (task && [task isRunning]) {
		NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
		
		if (([data length] != 0) && delegate) {
			[delegate playerCore:self outputAvailable:data];
		}
	}
}

- (void) readError:(NSNotification *)notification
{
	if (task && [task isRunning]) {
		NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];

		if (([data length] != 0) && delegate) {
			[delegate playerCore:self errorHappened:data];
		}
	}
}

- (void) taskHasTerminated:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	// 在工作线程上建立的Timer，因此必须在工作线程上销毁
	[pollingTimer invalidate];
	[pollingTimer release];
	pollingTimer = nil;
	
	// 得到返回状态，0是正常退出
	// 这个时候task变量有可能变成nil
	if (delegate) {
		[delegate playerCore:self hasTerminated:([[notification object] terminationStatus] != kPlayerCoreTermNormal)];
	}
}
@end
