/*
 * MPlayerX - CocoaAppendix.h
 *
 * Copyright (C) 2009 Zongyao QU
 * 
 * MPlayerX is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 2
 * of the License, or (at your option) any later version.
 * 
 * MPlayerX is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with MPlayerX; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

#import <Cocoa/Cocoa.h>

#define SAFERELEASE(x)		{if(x) {[x release];x = nil;}}

void MPLog(NSString *format, ...);
void MPSetLogEnable(BOOL en);

@interface NSMenu (CharsetListAppend)
-(void) appendCharsetList;
@end

@interface NSColor (MPXAdditional)
-(uint32) hexValue;
@end

@interface NSString (MPXAdditional)
-(unsigned int)hexValue;
@end

@interface NSEvent (MPXAdditional)
+(NSEvent*) makeKeyDownEvent:(NSString*)str modifierFlags:(NSUInteger)flags;
@end