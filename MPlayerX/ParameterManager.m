/*
 * MPlayerX - ParameterManager.m
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

#import "coredef_private.h"
#import "ParameterManager.h"
#import <UniversalDetector/UniversalDetector.h>

#define kPMDefaultFontPath			(@"/System/Library/Fonts/HelveticaNeue.ttc")

#define kPMDefaultSubFontPathChs	(@"/System/Library/Fonts/华文黑体.ttf")
#define kPMDefaultSubFontPathCht	(@"/System/Library/Fonts/儷黑 Pro.ttf")
#define kPMDefaultSubFontPathJpn	(@"/Library/Fonts/Osaka.ttf")

#define kPMDefaultAudioOutput		(@"coreaudio") 
#define kPMNoAudio					(@"null")
#define kPMDefaultVideoOutput		(@"corevideo") 
#define kPMNoVideo					(@"null") 
#define kPMDefaultSubLang			(@"en,eng,ch,chs,cht,ja,jpn")

#define kPMSubCPRuleExactMatchName	(0)
#define kPMSubCPRuleContainName		(1)
#define kPMSubCPRuleAnyName			(2)

#define kPMThreadsNumMax	(8)

@implementation ParameterManager

@synthesize prefer64bMPlayer;
@synthesize guessSubCP;
@synthesize startTime;
@synthesize volume;
@synthesize subPos;
@synthesize subAlign;
@synthesize subScale;
@synthesize subFont;
@synthesize subCP;
@synthesize threads;
@synthesize textSubs;
@synthesize vobSub;

#pragma mark Init/Dealloc
-(id) init
{
	if (self = [super init])
	{
		textSubFileExts = [[NSSet alloc] initWithObjects:@"utf", @"utf8", @"srt", @"ass", @"smi", @"rt", @"txt", @"ssa", nil];
		subEncodeLangDict = [[NSDictionary alloc] initWithObjectsAndKeys:@"CHS", @"GB18030",
																		 @"CHS", @"GBK",
																		 @"CHS", @"EUC-CN",
							 											 @"CHT", @"BIG5",
							 											 @"JPN", @"SHIFT_JIS",
							 											 @"JPN", @"ISO-2022-JP",
																		 nil];
		subLangDefaultSubFontDict = [[NSDictionary alloc] initWithObjectsAndKeys:kPMDefaultSubFontPathChs, @"CHS",
																				 kPMDefaultSubFontPathCht, @"CHT",
																				 kPMDefaultSubFontPathJpn, @"JPN",
																				 nil];
		autoSync = 30;
		frameDrop = YES;
		osdLevel = 0;
		subFuzziness = kPMSubCPRuleContainName;
		font = [[NSString alloc] initWithString:kPMDefaultFontPath]; // Everyone Should have this font
		ao = [[NSString alloc] initWithString:kPMDefaultAudioOutput];
		vo = [[NSString alloc] initWithString:kPMDefaultVideoOutput];
		subPreferedLanguage = [[NSString alloc] initWithString:kPMDefaultSubLang];
		
		ass.enabled = YES;
		ass.frontColor = 0xFFFFFF00; //RRGGBBAA
		ass.fontScale = 1.5;
		ass.borderColor = 0x0000000F; //RRGGBBAA
		ass.forceStyle = [NSString stringWithString:@"BorderStyle=1,Outline=1"];

		prefer64bMPlayer = YES;
		guessSubCP = YES;
		startTime = -1;
		volume = 100;
		subPos = 100;
		subAlign = 2;
		subScale = 4;
		subFont = nil;
		subCP = nil;
		threads = 1;
		textSubs = nil;
		vobSub = nil;
	}
	return self;
}

-(void) dealloc
{
	[textSubFileExts release];
	
	[subEncodeLangDict release];
	[subLangDefaultSubFontDict release];
	
	[font release];
	[ao release];
	[vo release];
	[subPreferedLanguage release];
	[subFont release];
	[subCP release];
	[textSubs release];
	[vobSub release];
	
	[super dealloc];
}

-(void) setThreads:(unsigned int) th
{
	threads = MIN(kPMThreadsNumMax, th);
}

-(float) subScaleInternal
{
	return (ass.enabled)?ass.fontScale:subScale;
}

-(void) setSubFontColor:(NSColor*)col
{
	col = [col colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	ass.frontColor = (((unsigned char)(255 * [col redComponent]))  <<24) + 
					 (((unsigned char)(255 * [col greenComponent]))<<16) + 
					 (((unsigned char)(255 * [col blueComponent])) <<8);
}

-(void) setSubFontBorderColor:(NSColor*)col
{
	col = [col colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	ass.borderColor = (((unsigned char)(255 * [col redComponent]))  <<24) + 
					  (((unsigned char)(255 * [col greenComponent]))<<16) + 
					  (((unsigned char)(255 * [col blueComponent])) <<8) + 0x0F;
	
}

-(NSArray *) arrayOfParametersWithName:(NSString*) name
{
	NSMutableArray *paramArray = [[NSMutableArray alloc] init];
	
	[paramArray addObject:@"-msglevel"];
	[paramArray addObject:@"all=-1:global=4:cplayer=4:identify=4"];
	
	[paramArray addObject:@"-autosync"];
	[paramArray addObject:[NSString stringWithFormat: @"%d", autoSync]];
	
	[paramArray addObject:@"-slave"];
	
	if (frameDrop) {
		[paramArray addObject:@"-framedrop"];
	}
	
	[paramArray addObject:@"-osdlevel"];
	[paramArray addObject: [NSString stringWithFormat: @"%d",osdLevel]];
	
	[paramArray addObject:@"-sub-fuzziness"];
	[paramArray addObject:[NSString stringWithFormat: @"%d",subFuzziness]];
	
	if (font) {
		[paramArray addObject:@"-font"];
		[paramArray addObject:font];
	}
	
	if (ao) {
		[paramArray addObject:@"-ao"];
		[paramArray addObject:ao];
	}
	
	if (vo) {
		[paramArray addObject:@"-vo"];
		if (([vo isEqualToString:kPMDefaultVideoOutput]) && name) {
			[paramArray addObject: [NSString stringWithFormat: @"%@:shared_buffer:buffer_name=%@", vo, name]];
		} else {
			[paramArray addObject:vo];
		}
	}
	
	if (subPreferedLanguage) {
		[paramArray addObject:@"-slang"];
		[paramArray addObject:[NSString stringWithFormat: @"%@",subPreferedLanguage]];		
	}
	
	if (startTime > 0) {
		[paramArray addObject:@"-ss"];
		[paramArray addObject:[NSString stringWithFormat: @"%.1f",startTime]];
	}
	
	[paramArray addObject:@"-volume"];
	[paramArray addObject:[NSString stringWithFormat: @"%.1f",GetRealVolume(volume)]];
	
	[paramArray addObject:@"-subpos"];
	[paramArray addObject:[NSString stringWithFormat: @"%d",subPos]];
	
	[paramArray addObject:@"-subalign"];
	[paramArray addObject:[NSString stringWithFormat: @"%d",subAlign]];
	
	[paramArray addObject:@"-subfont-osd-scale"];
	[paramArray addObject:[NSString stringWithFormat: @"%.1f",subScale]];
	
	[paramArray addObject:@"-subfont-text-scale"];
	[paramArray addObject:[NSString stringWithFormat: @"%.1f",subScale]];
	
	if (subFont && (![subFont isEqualToString:@""])) {
		[paramArray addObject:@"-subfont"];
		[paramArray addObject:subFont];
	} else {
		NSString *lang, *fontFB;
		if ((lang = [subEncodeLangDict objectForKey:subCP]) && (fontFB = [subLangDefaultSubFontDict objectForKey:lang])) {
			[paramArray addObject:@"-subfont"];
			[paramArray addObject:fontFB];
		}
	}

	if (subCP && (![subCP isEqualToString:@""])) {
		[paramArray addObject:@"-subcp"];
		[paramArray addObject:subCP];
	}
	
	if (threads >= 2) {
		[paramArray addObject:@"-lavdopts"];
		[paramArray addObject:[NSString stringWithFormat: @"threads=%d", threads]];
	}

	if (ass.enabled) {
		[paramArray addObject:@"-ass"];
		
		[paramArray addObject:@"-ass-color"];
		[paramArray addObject:[NSString stringWithFormat: @"%X", ass.frontColor]];
		
		[paramArray addObject:@"-ass-font-scale"];
		[paramArray addObject:[NSString stringWithFormat: @"%f", ass.fontScale]];
		
		[paramArray addObject:@"-ass-border-color"];
		[paramArray addObject:[NSString stringWithFormat: @"%X", ass.borderColor]];
		
		[paramArray addObject:@"-ass-force-style"];
		[paramArray addObject:[NSString stringWithFormat: @"%@", ass.forceStyle]];
	}
	
	if (textSubs && [textSubs count]) {
		[paramArray addObject:@"-noautosub"];
		[paramArray addObject:@"-sub"];
		
		NSString *str = [textSubs objectAtIndex:0];
		
		NSUInteger i;
		NSUInteger cnt = [textSubs count];
		for (i = 1; i < cnt; i++) {
			str = [str stringByAppendingFormat:@",%@", [textSubs objectAtIndex:i]];
		}
		[paramArray addObject:str];
	}
	
	if (vobSub && (![vobSub isEqualToString:@""])) {
		[paramArray addObject:@"-vobsub"];
		[paramArray addObject:vobSub];
	}

	return [paramArray autorelease];
}

-(NSDictionary*) getCPFromMoviePath:(NSString*)moviePath alsoFindVobSub:(NSString**)vobPath
{
	NSString *cpStr = nil;
	NSString *subPath = nil;
	NSMutableDictionary *subEncDict = [[NSMutableDictionary alloc] initWithCapacity:2];

	if (vobPath) {
		*vobPath = nil;
	}

	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	UniversalDetector *dt = [[UniversalDetector alloc] init];
	
	// 文件夹路径
	NSString *directoryPath = [moviePath stringByDeletingLastPathComponent];
	// 播放文件名称
	NSString *movieName = [[moviePath lastPathComponent] stringByDeletingPathExtension];
	
	NSDirectoryEnumerator *directoryEnumerator = [[NSFileManager defaultManager] enumeratorAtPath:directoryPath];
	
	// 遍历播放文件所在的目录
	for (NSString *path in directoryEnumerator)
	{
		NSDictionary *fileAttr = [directoryEnumerator fileAttributes];
		
		if ([fileAttr objectForKey:NSFileType] == NSFileTypeDirectory) { //不遍历子目录
			[directoryEnumerator skipDescendants];
			
		} else if ([[fileAttr objectForKey:NSFileType] isEqualToString: NSFileTypeRegular]) {
			// 如果是普通文件
			switch (subFuzziness) {
				case kPMSubCPRuleExactMatchName:
					if (![movieName isEqualToString:[path stringByDeletingPathExtension]]) continue; // exact match
					break;
				case kPMSubCPRuleAnyName:
					break; // any sub file is OK
				case kPMSubCPRuleContainName:
					if ([path rangeOfString: movieName].location == NSNotFound) continue; // contain the movieName
					break;
				default:
					break;
			}
			
			subPath = [NSString stringWithFormat:@"%@/%@", directoryPath, path];

			NSString *ext = [path pathExtension];
			
			if ([textSubFileExts containsObject: ext]) {
				// 如果是文本字幕文件
				[dt analyzeContentsOfFile: subPath];
				
				cpStr = [dt MIMECharset];
				
				if (cpStr) {
					// 如果猜出来了，不管有多少的确认率
					[subEncDict setObject:[cpStr uppercaseString] forKey:subPath];
				} else {
					// 如果没有猜出来，那么设为空
					[subEncDict setObject:@"" forKey:subPath];
				}
				[dt reset];				
			} else if ([[ext uppercaseString] isEqualToString:@"SUB"]) {
				// 如果是vobsub并且设定要寻找vobsub
				if (vobPath) {
					[*vobPath release];
					*vobPath = [[subPath stringByDeletingPathExtension] retain];
				}
			}
		}
	}
	[dt release];
	[pool release];

	if (vobPath) {
		[*vobPath autorelease];
	}

	return [subEncDict autorelease];	
}
@end
