/*
 * MPlayerX - SubConverter.h
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
#import "coredef_private.h"

@interface SubConverter : NSObject
{
	NSSet *textSubFileExts;
	NSString *workDirectory;
}

-(void) setWorkDirectory:(NSString *)wd;

/** 返回根据subEncDict的文件名和编码信息，将各个文件转换成UTF-8编码之后的文件群，需要调用clearWorkDirectory清空 */
-(NSArray*) convertTextSubsAndEncodings:(NSDictionary*)subEncDict;

-(NSDictionary*) getCPFromMoviePath:(NSString*)moviePath nameRule:(SUBFILE_NAMERULE)nameRule alsoFindVobSub:(NSString**)vobPath;

-(void) clearWorkDirectory;

@end