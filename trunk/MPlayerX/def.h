/*
 * MPlayerX - def.h
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

#import "coredef.h"

// UserDefaults定义
extern NSString * const kUDKeyVolume;
extern NSString * const kUDKeyOnTopMode;
extern NSString * const kUDKeyCtrlUIAutoHideTime;
extern NSString * const kUDKeySpeedStep;
extern NSString * const kUDKeySeekStepLR;
extern NSString * const kUDKeySeekStepUB;
extern NSString * const kUDKeyVolumeStep;
extern NSString * const kUDKeyAutoPlayNext;
extern NSString * const kUDKeySubFontPath;
extern NSString * const kUDKeySnapshotSavePath;
extern NSString * const kUDKeyStartByFullScreen;
extern NSString * const kUDKeySubDelayStepTime;
extern NSString * const kUDKeyAudioDelayStepTime;
extern NSString * const kUDKeyPrefer64bitMPlayer;
extern NSString * const kUDKeyEnableMultiThread;
extern NSString * const kUDKeySubScale;
extern NSString * const kUDKeySubScaleStepValue;
extern NSString * const kUDKeySwitchTimeHintPressOnAbusolute;
extern NSString * const kUDKeyQuitOnClose;
extern NSString * const kUDKeySwitchTimeTextPressOnRemain;
extern NSString * const kUDKeySubFontColor;
extern NSString * const kUDKeySubFontBorderColor;
extern NSString * const kUDKeyCtrlUIBackGroundAlpha;
extern NSString * const kUDKeyForceIndex;
extern NSString * const kUDKeySubFileNameRule;
extern NSString * const kUDKeyDTSPassThrough;
extern NSString * const kUDKeyAC3PassThrough;
extern NSString * const kUDKeyShowOSD;
extern NSString * const kUDKeyOSDFontSizeMax;
extern NSString * const kUDKeyOSDFontSizeMin;
extern NSString * const kUDKeyOSDFrontColor;
extern NSString * const kUDKeyOSDAutoHideTime;
extern NSString * const kUDKeyThreadNum;
extern NSString * const kUDKeyUseEmbeddedFonts;
extern NSString * const kUDKeyCacheSize;
extern NSString * const kUDKeyPreferIPV6;
extern NSString * const kUDKeyCachingLocal;
extern NSString * const kUDKeyFullScreenKeepOther;
extern NSString * const kUDKeyLetterBoxMode;
extern NSString * const kUDKeyLetterBoxModeAlt;
extern NSString * const kUDKeyLetterBoxHeight;
extern NSString * const kUDKeyVideoTunerStepValue;
extern NSString * const kUDKeyARKeyRepeatTimeInterval;
extern NSString * const kUDKeyARKeyRepeatTimeIntervalLong;
extern NSString * const kUDKeyPlayWhenOpened;
extern NSString * const kUDKeyTextSubtitleCharsetConfidenceThresh;
extern NSString * const kUDKeyTextSubtitleCharsetManual;
extern NSString * const kUDKeyTextSubtitleCharsetFallback;

extern NSString * const kUDKeyDebugEnableOpenURL;
extern NSString * const kUDKeySelectedPrefView;
extern NSString * const kUDKeyHelpURL;
extern NSString * const kUDKeyCloseWindowWhenStopped;

#define kSCMSwitchTimeHintKeyModifierMask	(NSFunctionKeyMask)

extern NSString * const kSCMVolumeUpKeyEquivalent;
extern NSString * const kSCMVolumeDownKeyEquivalent;
extern NSString * const kSCMSwitchAudioKeyEquivalent;
extern NSString * const kSCMSwitchSubKeyEquivalent;
extern NSString * const kSCMSnapShotKeyEquivalent;
extern NSString * const kSCMMuteKeyEquivalent;
extern NSString * const kSCMPlayPauseKeyEquivalent;
extern NSString * const kSCMFullScrnKeyEquivalent;
extern NSString * const kSCMFillScrnKeyEquivalent;
extern NSString * const kSCMAcceControlKeyEquivalent;

extern NSString * const kSCMSubScaleIncreaseKeyEquivalent;
#define kSCMSubScaleIncreaseKeyEquivalentModifierFlagMask	(NSCommandKeyMask)
extern NSString * const kSCMSubScaleDecreaseKeyEquivalent;
#define kSCMSubScaleDecreaseKeyEquivalentModifierFlagMask	(NSCommandKeyMask)

extern NSString * const kSCMPlayFromLastStoppedKeyEquivalent;
#define kSCMPlayFromLastStoppedKeyEquivalentModifierFlagMask	(NSShiftKeyMask)

#define kSCMDragSubPosModifierFlagMask			(NSCommandKeyMask)
#define kSCMDragAudioBalanceModifierFlagMask	(NSAlternateKeyMask)

extern NSString * const kSCMToggleLockAspectRatioKeyEquivalent;

extern NSString * const kSCMResetLockAspectRatioKeyEquivalent;
#define kSCMResetLockAspectRatioKeyEquivalentModifierFlagMask		(NSShiftKeyMask)

extern NSString * const kSCMVideoTunerPanelKeyEquivalent;
#define kSCMVideoTunerPanelKeyEquivalentModifierFlagMask	(NSShiftKeyMask|NSCommandKeyMask)

extern NSString * const kSCMToggleLetterBoxKeyEquivalent;
