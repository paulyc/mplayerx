/*
 * MPlayerX - PlayingInfo.m
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

#import "PlayingInfo.h"


@implementation PlayingInfo

@synthesize	currentChapter;
@synthesize	currentTime;
@synthesize	currentAudio;
@synthesize	currentVideo;
@synthesize	currentSub;

@synthesize	volume;
@synthesize	audioBalance;
@synthesize	mute;
@synthesize	audioDelay;
@synthesize	subDelay;
@synthesize	subPos;
@synthesize	subVisibility;
@synthesize	subScale;
@synthesize speed;

-(id) init
{
	if (self = [super init]) {
		currentChapter = 0;
		currentTime = nil;
		currentAudio = 0;
		currentVideo = 0;
		currentSub = 0;
		volume = 100;
		audioBalance = 0;
		mute = NO;
		audioDelay = [[NSNumber alloc] initWithFloat:0];
		subDelay = [[NSNumber alloc] initWithFloat:0];
		subPos = 100;
		subVisibility = YES;
		subScale = [[NSNumber alloc] initWithFloat:3];
		speed = [[NSNumber alloc] initWithFloat:1.0];
	}
	return self;
}

-(void) dealloc
{
	[currentTime release];
	[audioDelay release];
	[subDelay release];
	[speed release];
	[subScale release];
	
	[super dealloc];
}

-(void) reset
{
	[currentTime release];
	[audioDelay release];
	[subDelay release];
	[speed release];
	[subScale release];
	
	currentChapter = 0;
	currentTime = nil;
	currentAudio = 0;
	currentVideo = 0;
	currentSub = 0;
	volume = 100;
	audioBalance = 0;
	mute = NO;
	audioDelay = [[NSNumber alloc] initWithFloat:0];
	subDelay = [[NSNumber alloc] initWithFloat:0];
	subPos = 100;
	subVisibility = YES;
	subScale = [[NSNumber alloc] initWithFloat:3];
	speed = [[NSNumber alloc] initWithFloat:1.0];
}
@end