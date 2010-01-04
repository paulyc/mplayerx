/*
 * MPlayerX - VideoInfo.h
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

#import <Cocoa/Cocoa.h>


@interface VideoInfo : NSObject
{
	NSString *codec;
	int format;
	int bitRate;
	int width;
	int height;
	float fps;
	float aspect;
}

@property (retain, readwrite) NSString *codec;
@property (assign, readwrite) int format;
@property (assign, readwrite) int bitRate;
@property (assign, readwrite) int width;
@property (assign, readwrite) int height;
@property (assign, readwrite) float fps;
@property (assign, readwrite) float aspect;

@end
