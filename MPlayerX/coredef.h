/*
 * MPlayerX - coredef.h
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

// 指定两种arch的mplayer路径时所用的key
extern NSString * const kI386Key;
extern NSString * const kX86_64Key;

typedef enum
{
	kSubFileNameRuleExactMatch = 0,
	kSubFileNameRuleContain = 1,
	kSubFileNameRuleAny = 2
} SUBFILE_NAMERULE;

#define kPlayerWindowCornerRadius	(6.0)

// letterBox显示模式
#define kPMLetterBoxModeNotDisplay	(0)
#define kPMLetterBoxModeBottomOnly	(1)
#define kPMLetterBoxModeBoth		(2)

// KVO观测的属性的KeyPath
extern NSString * const kKVOPropertyKeyPathCurrentTime;
extern NSString * const kKVOPropertyKeyPathLength;
extern NSString * const kKVOPropertyKeyPathSeekable;
extern NSString * const kKVOPropertyKeyPathSubInfo;
extern NSString * const kKVOPropertyKeyPathCachingPercent;

extern NSString * const kKVOPropertyKeyPathVideoInfo;
extern NSString * const kKVOPropertyKeyPathAudioInfo;
