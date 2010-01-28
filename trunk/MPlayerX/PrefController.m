/*
 * MPlayerX - PrefController.m
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

#import "def.h"
#import	"LocalizedStrings.h"
#import "PrefController.h"
#import "PlayerController.h"
#import "RootLayerView.h"
#import "ControlUIView.h"

#define PrefToolBarItemIdGeneral	(@"TBIGeneral")
#define PrefToolBarItemIdVideo		(@"TBIVideo")
#define PrefToolBarItemIdAudio		(@"TBIAudio")
#define PrefToolBarItemIdSubtitle	(@"TBISubtitle")
#define PrefToolbarItemIdNetwork	(@"TBINetwork")

#define PrefTBILabelGeneral			(kMPXStringTBILabelGeneral)
#define PrefTBILabelVideo			(kMPXStringTBILabelVideo)
#define PrefTBILabelAudio			(kMPXStringTBILabelAudio)
#define PrefTBILabelSubtitle		(kMPXStringTBILabelSubtitle)
#define PrefTBILabelNetwork			(kMPXStringTBILabelNetwork)

@implementation PrefController

@synthesize prefWin;

+(void) initialize
{
	[[NSUserDefaults standardUserDefaults] registerDefaults:
	 [NSDictionary dictionaryWithObjectsAndKeys:
	  [NSNumber numberWithInt:0], kUDKeySelectedPrefView,
	  nil]];
}

-(id) init
{
	if (self = [super init]) {
		ud = [NSUserDefaults standardUserDefaults];

		nibLoaded = NO;
		prefViews = nil;
	}
	return self;
}

-(IBAction) showUI:(id)sender
{
	if (!nibLoaded) {
		[NSBundle loadNibNamed:@"Pref" owner:self];

		prefViews = [[NSArray alloc] initWithObjects:viewGeneral, viewVideo, viewAudio, viewSub, viewNetwork, nil];
		
		NSToolbarItem *tbi = [[prefToolbar items] objectAtIndex:[ud integerForKey:kUDKeySelectedPrefView]];
		
		if (tbi) {
			[prefToolbar setSelectedItemIdentifier:[tbi itemIdentifier]];
			
			[self switchViews:tbi];
		}
		
		[prefWin setLevel:NSMainMenuWindowLevel];
		
		// 可以选择 透明度
		[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];
		
		nibLoaded = YES;
	}
	[prefWin makeKeyAndOrderFront:nil];
}

-(void) dealloc
{
	[prefViews release];
	[super release];
}

-(IBAction) switchViews:(id)sender
{
	NSView *viewToShow = [prefViews objectAtIndex:[sender tag]];
	
	if (viewToShow && ([prefWin contentView] != viewToShow)) {
		
		[prefToolbar setSelectedItemIdentifier:[sender itemIdentifier]];
		
		NSRect rc = [prefWin frameRectForContentRect:[viewToShow bounds]];
		NSRect winFrm = [prefWin frame];
		
		rc.origin = winFrm.origin;
		rc.origin.y -= (rc.size.height - winFrm.size.height);
		
		[prefWin setContentView: viewToShow];
		[prefWin setFrame:rc display:YES animate:YES];

		[prefWin setTitle:[sender label]];
		
		[ud setInteger:[sender tag] forKey:kUDKeySelectedPrefView];
	}
}

- (IBAction)multiThreadChanged:(id)sender
{
	[playerController setMultiThreadMode:[ud boolForKey:kUDKeyEnableMultiThread]];
}

- (IBAction)onTopModeChanged:(id)sender
{
	[dispView setPlayerWindowLevel];
}

- (IBAction)hintTimeModeChanged:(id)sender
{
	[controlUI setHintTimePrsOnAbs:[ud boolForKey:kUDKeySwitchTimeHintPressOnAbusolute]];
}

- (IBAction)timeTextModeChanged:(id)sender
{
	[controlUI setTimeTextPrsOnRmn:[ud boolForKey:kUDKeySwitchTimeTextPressOnRemain]];
}

-(IBAction) controlUIAppearanceChanged:(id)sender
{
	[controlUI refreshAutoHideTimer];
	[controlUI refreshBackgroundAlpha];
	[controlUI showUp];
}

-(IBAction) osdSetChanged:(id)sender
{
	[controlUI refreshOSDSetting];
}

-(IBAction) checkCacheFormat:(id)sender
{
	float cache = [ud floatForKey:kUDKeyCacheSize];
	
	if (cache < 0) { cache = 0; }

	[ud setInteger:((unsigned int)cache) forKey:kUDKeyCacheSize];
}

/////////////////////////////Toolbar Delegate/////////////////////
/*
 * 如何添加新的Pref View
 * 1. 在Pref.xib添加一个新的View，并将这个View设置为与ContentView的尺寸绑定
 * 2. 在PrefController中添加新的Outlet来代表这个View
 * 3. 根据新的View添加ToolbarItem的Indentifier和Name
 * 4. prefViews的初始化中，添加新View的outlet到其中
 * 5. toolbarAllowedItemIdentifiers中加入新Identifier
 * 6. 在toobar: itemForItemIdentifier :willBeInsertedIntoToolbar中创建相应的Item
 * (注意需要相应的图片资源等)
 */
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
	return [NSArray arrayWithObjects:PrefToolBarItemIdGeneral, PrefToolBarItemIdVideo, PrefToolBarItemIdAudio,
									PrefToolBarItemIdSubtitle, PrefToolbarItemIdNetwork, nil];
}
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
	return [self toolbarAllowedItemIdentifiers:toolbar];
}
- (NSArray *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
	return [self toolbarAllowedItemIdentifiers:toolbar];
}
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
	
	if ([itemIdentifier isEqualToString:PrefToolBarItemIdGeneral]) {
		[item setLabel:PrefTBILabelGeneral];
		[item setImage:[NSImage imageNamed:NSImageNamePreferencesGeneral]];
		[item setTarget:self];
		[item setAction:@selector(switchViews:)];
		[item setAutovalidates:NO];
		[item setTag:0];
		
	} else if ([itemIdentifier isEqualToString:PrefToolBarItemIdVideo]) {
		[item setLabel:PrefTBILabelVideo];
		[item setImage:[NSImage imageNamed:@"toolbar_video"]];
		[item setTarget:self];
		[item setAction:@selector(switchViews:)];
		[item setAutovalidates:NO];
		[item setTag:1];
		
	} else if ([itemIdentifier isEqualToString:PrefToolBarItemIdAudio]) {
		[item setLabel:PrefTBILabelAudio];
		[item setImage:[NSImage imageNamed:@"toolbar_audio"]];
		[item setTarget:self];
		[item setAction:@selector(switchViews:)];
		[item setAutovalidates:NO];
		[item setTag:2];
		
	} else if ([itemIdentifier isEqualToString:PrefToolBarItemIdSubtitle]) {
		[item setLabel:PrefTBILabelSubtitle];
		[item setImage:[NSImage imageNamed:NSImageNameFontPanel]];
		[item setTarget:self];
		[item setAction:@selector(switchViews:)];
		[item setAutovalidates:NO];
		[item setTag:3];
		
	} else if ([itemIdentifier isEqualToString:PrefToolbarItemIdNetwork]) {
		[item setLabel:PrefTBILabelNetwork];
		[item setImage:[NSImage imageNamed:NSImageNameNetwork]];
		[item setTarget:self];
		[item setAction:@selector(switchViews:)];
		[item setAutovalidates:NO];
		[item setTag:4];
		
	} else {
		[item release];
		return nil;
	}
	return [item autorelease];
}

@end
