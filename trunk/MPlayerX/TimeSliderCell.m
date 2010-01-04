//
//  BGHUDSliderCell.m
//  BGHUDAppKit
//
//  Created by BinaryGod on 5/30/08.
//
//  Copyright (c) 2008, Tim Davis (BinaryMethod.com, binary.god@gmail.com)
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//		Redistributions of source code must retain the above copyright notice, this
//	list of conditions and the following disclaimer.
//
//		Redistributions in binary form must reproduce the above copyright notice,
//	this list of conditions and the following disclaimer in the documentation and/or
//	other materials provided with the distribution.
//
//		Neither the name of the BinaryMethod.com nor the names of its contributors
//	may be used to endorse or promote products derived from this software without
//	specific prior written permission.
//
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS AND
//	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
//	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
//	IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
//	INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
//	BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
//	OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
//	WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
//	POSSIBILITY OF SUCH DAMAGE.

#import "TimeSliderCell.h"

@interface TimeSliderCell (SliderCellInternal)
-(NSColor *)sliderTrackColor;
-(NSColor *)strokeColor;
-(NSColor *)disabledSliderTrackColor;
-(NSColor *)disabledStrokeColor;
-(NSShadow *)focusRing;
-(NSShadow *)dropShadow;
-(NSGradient *)highlightKnobColor;
-(NSGradient *)knobColor;
-(NSGradient *)disabledKnobColor;
-(CGFloat)alphaValue;
-(CGFloat)disabledAlphaValue;
@end


@implementation TimeSliderCell

@synthesize themeKey;

#pragma mark Init/Dealloc

-(id)init {
	
	self = [super init];
	
	if(self) {
		
		self.themeKey = @"gradientTheme";
	}
	
	return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
	
	self = [super initWithCoder: aDecoder];
	
	if(self) {
		
		if([aDecoder containsValueForKey: @"themeKey"]) {
			
			self.themeKey = [aDecoder decodeObjectForKey: @"themeKey"];
		} else {
			self.themeKey = @"gradientTheme";
		}
	}
	
	return self;
}

-(void)encodeWithCoder: (NSCoder *)coder {
	
	[super encodeWithCoder: coder];
	
	[coder encodeObject: self.themeKey forKey: @"themeKey"];
}

-(void)dealloc {
	
	[super dealloc];
}

#pragma mark -
#pragma mark Drawing Methods

- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped {
	
	if([self sliderType] == NSLinearSlider) {
		
		if(![self isVertical]) {
			
			[self drawHorizontalBarInFrame: aRect];
		} else {
			
			[self drawVerticalBarInFrame: aRect];
		}
	} else {
		
		//Placeholder for when I figure out how to draw NSCircularSlider
	}
}

- (void)drawKnob:(NSRect)aRect {
	
	if([self sliderType] == NSLinearSlider) {
		
		if(![self isVertical]) {
			
			[self drawHorizontalKnobInFrame: aRect];
		} else {
			
			[self drawVerticalKnobInFrame: aRect];
		}
	} else {
		
		//Place holder for when I figure out how to draw NSCircularSlider
	}
}

- (void)drawHorizontalBarInFrame:(NSRect)frame {
	
	// Adjust frame based on ControlSize
	switch ([self controlSize]) {
			
		case NSRegularControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				if([self tickMarkPosition] == NSTickMarkBelow) {
					
					frame.origin.y += 4;
				} else {
					
					frame.origin.y += frame.size.height - 10;
				}
			} else {
				
				frame.origin.y = frame.origin.y + (((frame.origin.y + frame.size.height) /2) - 2.5f);
			}
			
			frame.origin.x += 2.5f;
			frame.origin.y += 0.5f;
			frame.size.width -= 5;
			frame.size.height = 5;
			break;
			
		case NSSmallControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				if([self tickMarkPosition] == NSTickMarkBelow) {
					
					frame.origin.y += 2;
				} else {
					
					frame.origin.y += frame.size.height - 8;
				}
			} else {
				
				frame.origin.y = frame.origin.y + (((frame.origin.y + frame.size.height) /2) - 2.5f);
			}
			
			frame.origin.x += 0.5f;
			frame.origin.y += 0.5f;
			frame.size.width -= 1;
			frame.size.height = 5;
			break;
			
		case NSMiniControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				if([self tickMarkPosition] == NSTickMarkBelow) {
					
					frame.origin.y += 2;
				} else {
					
					frame.origin.y += frame.size.height - 6;
				}
			} else {
				
				frame.origin.y = frame.origin.y + (((frame.origin.y + frame.size.height) /2) - 2);
			}
			
			frame.origin.x += 0.5f;
			frame.origin.y += 0.5f;
			frame.size.width -= 1;
			frame.size.height = 3;
			break;
	}
	
	//Draw Bar
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect: frame xRadius: 2 yRadius: 2];
	
	if([self isEnabled]) {
		
		[[self sliderTrackColor] set];
		[path fill];
		
		[[self strokeColor] set];
		[path stroke];
	} else {
		
		[[self disabledSliderTrackColor] set];
		[path fill];
		
		[[self disabledStrokeColor] set];
		[path stroke];
	}
}

- (void)drawVerticalBarInFrame:(NSRect)frame {
	
	//Vertical Scroller
	switch ([self controlSize]) {
			
		case NSRegularControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				if([self tickMarkPosition] == NSTickMarkRight) {
					
					frame.origin.x += 4;
				} else {
					
					frame.origin.x += frame.size.width - 9;
				}
			} else {
				
				frame.origin.x = frame.origin.x + (((frame.origin.x + frame.size.width) /2) - 2.5f);
			}
			
			frame.origin.x += 0.5f;
			frame.origin.y += 2.5f;
			frame.size.height -= 6;
			frame.size.width = 5;
			break;
			
		case NSSmallControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				if([self tickMarkPosition] == NSTickMarkRight) {
					
					frame.origin.x += 3;
				} else {
					
					frame.origin.x += frame.size.width - 8;
				}
				
			} else {
				
				frame.origin.x = frame.origin.x + (((frame.origin.x + frame.size.width) /2) - 2.5f);
			}
			
			frame.origin.y += 0.5f;
			frame.size.height -= 1;
			frame.origin.x += 0.5f;
			frame.size.width = 5;
			break;
			
		case NSMiniControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				if([self tickMarkPosition] == NSTickMarkRight) {
					
					frame.origin.x += 2.5f;
				} else {
					
					frame.origin.x += frame.size.width - 6.5f;
				}
			} else {
				
				frame.origin.x = frame.origin.x + (((frame.origin.x + frame.size.width) /2) - 2);
			}
			
			frame.origin.x += 1;
			frame.origin.y += 0.5f;
			frame.size.height -= 1;
			frame.size.width = 3;
			break;
	}
	
	//Draw Bar
	NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect: frame xRadius: 2 yRadius: 2];
	
	[[self sliderTrackColor] set];
	[path fill];
	
	[[self strokeColor] set];
	[path stroke];
}

- (void)drawHorizontalKnobInFrame:(NSRect)frame {
	
	NSRect rcBounds = [[self controlView] bounds];
	NSBezierPath *path;
	
	switch ([self controlSize]) {
			
		case NSRegularControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				if([self tickMarkPosition] == NSTickMarkAbove) {
					
					frame.origin.y += 2;
				}
				
				frame.origin.x += 2;
				frame.size.height = 19.0f;
				frame.size.width = 15.0f;
			} else {
				
				frame.origin.x += 3;
				frame.origin.y += 3;
				frame.size.height = 15;
				frame.size.width = 15;
			}
			break;
			
		case NSSmallControlSize:
			rcBounds.origin.y = rcBounds.origin.y + (((rcBounds.origin.y + rcBounds.size.height) /2) - 2.5f);
			rcBounds.origin.x += 0.5f;
			rcBounds.origin.y += 0.5f;
			rcBounds.size.width -= 1;
			rcBounds.size.height = 5;
			
			rcBounds.size.width *= ([self floatValue]/[self maxValue]);
			
			path = [NSBezierPath bezierPathWithRoundedRect:rcBounds xRadius:2 yRadius:2];
			
			if([self isEnabled]) {
				[[self strokeColor] set];
			} else {
				[[self disabledStrokeColor] set];
			}
			[path fill];
			break;
			
		case NSMiniControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				frame.origin.x += 1;
				frame.size.height = 11.0f;
				frame.size.width = 9.0f;
			} else {
				
				frame.origin.x += 2;
				frame.origin.y += 1;
				frame.size.height = 9;
				frame.size.width = 9;
			}
			break;
	}
}

- (void)drawVerticalKnobInFrame:(NSRect)frame {
	
	switch ([self controlSize]) {
			
		case NSRegularControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				if([self tickMarkPosition] == NSTickMarkRight) {
					
					frame.origin.x -= 3;
				}
				
				frame.origin.x += 3;
				frame.origin.y += 2;
				frame.size.height = 15;
				frame.size.width = 19;
			} else {
				
				frame.origin.x += 3;
				frame.origin.y += 3;
				frame.size.height = 15;
				frame.size.width = 15;
			}
			break;
			
			case NSSmallControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				frame.origin.x += 1;
				frame.origin.y += 1;
				frame.size.height = 11;
				frame.size.width = 13;
			} else {
				
				frame.origin.x += 2;
				frame.origin.y += 2;
				frame.size.height = 11;
				frame.size.width = 11;
			}
			break;
			
			case NSMiniControlSize:
			
			if([self numberOfTickMarks] != 0) {
				
				frame.origin.y += 1;
				frame.size.height = 9;
				frame.size.width = 11;
			} else {
				
				frame.origin.x += 1;
				frame.origin.y += 1;
				frame.size.height = 9;
				frame.size.width = 9;
			}
			break;
	}
	
	NSBezierPath *pathOuter = [[NSBezierPath alloc] init];
	NSBezierPath *pathInner = [[NSBezierPath alloc] init];
	NSPoint pointsOuter[7];
	NSPoint pointsInner[7];
	
	if([self numberOfTickMarks] != 0) {
		
		if([self tickMarkPosition] == NSTickMarkRight) {
			
			pointsOuter[0] = NSMakePoint(NSMinX(frame), NSMinY(frame) + 2);
			pointsOuter[1] = NSMakePoint(NSMinX(frame) + 2, NSMinY(frame));
			pointsOuter[2] = NSMakePoint(NSMidX(frame) + 2, NSMinY(frame));
			pointsOuter[3] = NSMakePoint(NSMaxX(frame), NSMidY(frame));
			pointsOuter[4] = NSMakePoint(NSMidX(frame) + 2, NSMaxY(frame));
			pointsOuter[5] = NSMakePoint(NSMinX(frame) + 2, NSMaxY(frame));
			pointsOuter[6] = NSMakePoint(NSMinX(frame), NSMaxY(frame) - 2);
			
			[pathOuter appendBezierPathWithPoints: pointsOuter count: 7];
			
		} else {
			
			pointsOuter[0] = NSMakePoint(NSMinX(frame), NSMidY(frame));
			pointsOuter[1] = NSMakePoint(NSMidX(frame) - 2, NSMinY(frame));
			pointsOuter[2] = NSMakePoint(NSMaxX(frame) - 2, NSMinY(frame));
			pointsOuter[3] = NSMakePoint(NSMaxX(frame), NSMinY(frame) + 2);
			pointsOuter[4] = NSMakePoint(NSMaxX(frame), NSMaxY(frame) - 2);
			pointsOuter[5] = NSMakePoint(NSMaxX(frame) - 2, NSMaxY(frame));
			pointsOuter[6] = NSMakePoint(NSMidX(frame) - 2, NSMaxY(frame));
			
			[pathOuter appendBezierPathWithPoints: pointsOuter count: 7];
		}
		
		frame = NSInsetRect(frame, 1, 1);
		
		if([self tickMarkPosition] == NSTickMarkRight) {
			
			pointsInner[0] = NSMakePoint(NSMinX(frame), NSMinY(frame) + 2);
			pointsInner[1] = NSMakePoint(NSMinX(frame) + 2, NSMinY(frame));
			pointsInner[2] = NSMakePoint(NSMidX(frame) + 2, NSMinY(frame));
			pointsInner[3] = NSMakePoint(NSMaxX(frame), NSMidY(frame));
			pointsInner[4] = NSMakePoint(NSMidX(frame) + 2, NSMaxY(frame));
			pointsInner[5] = NSMakePoint(NSMinX(frame) + 2, NSMaxY(frame));
			pointsInner[6] = NSMakePoint(NSMinX(frame), NSMaxY(frame) - 2);
			
			[pathInner appendBezierPathWithPoints: pointsInner count: 7];
			
		} else {
			
			pointsInner[0] = NSMakePoint(NSMinX(frame), NSMidY(frame));
			pointsInner[1] = NSMakePoint(NSMidX(frame) - 2, NSMinY(frame));
			pointsInner[2] = NSMakePoint(NSMaxX(frame) - 2, NSMinY(frame));
			pointsInner[3] = NSMakePoint(NSMaxX(frame), NSMinY(frame) + 2);
			pointsInner[4] = NSMakePoint(NSMaxX(frame), NSMaxY(frame) - 2);
			pointsInner[5] = NSMakePoint(NSMaxX(frame) - 2, NSMaxY(frame));
			pointsInner[6] = NSMakePoint(NSMidX(frame) - 2, NSMaxY(frame));
			
			[pathInner appendBezierPathWithPoints: pointsInner count: 7];
		}
	
	} else {
		
		[pathOuter appendBezierPathWithOvalInRect: frame];
		
		frame = NSInsetRect(frame, 1, 1);
		
		[pathInner appendBezierPathWithOvalInRect: frame];
	}
	
	//I use two NSBezierPaths here to create the border because doing a simple
	//[path stroke] leaves ghost lines when the knob is moved.
	
	//Draw Base Layer
	if([self isEnabled]) {
		
		[NSGraphicsContext saveGraphicsState];
		
		if([self isHighlighted] && ([self focusRingType] == NSFocusRingTypeDefault ||
									[self focusRingType] == NSFocusRingTypeExterior)) {
			
			[[self focusRing] set];
		} else {
			
			[[self dropShadow] set];
		}
		
		[[self strokeColor] set];
		[pathOuter fill];
		
		[NSGraphicsContext restoreGraphicsState];
	} else {
		
		[[self disabledStrokeColor] set];
		[pathOuter fill];
	}
	
	//Draw Inner Layer
	if([self isEnabled]) {
		
		if([self isHighlighted]) {
			
			[[self highlightKnobColor] drawInBezierPath: pathInner angle: 90];
		} else {
			
			[[self knobColor] drawInBezierPath: pathInner angle: 90];
		}
	} else {
		
		[[self disabledKnobColor] drawInBezierPath: pathInner angle: 90];
	}
	
	[pathOuter release];
	[pathInner release];
}

#pragma mark -
#pragma mark Overridden Methods

- (BOOL)_usesCustomTrackImage {
	
	return YES;
}

#pragma mark -

#pragma mark internal
-(NSColor *)sliderTrackColor {
	
	//return [NSColor colorWithDeviceRed: 0.318f green: 0.318f blue: 0.318f alpha: [self alphaValue]];
	return [NSColor colorWithDeviceRed: 0 green: 0 blue: 0 alpha: [self alphaValue]];
}

-(NSColor *)strokeColor {
	
	return [NSColor colorWithDeviceRed: 0.749f green: 0.761f blue: 0.788f alpha: 1.0f];
}

-(NSColor *)disabledSliderTrackColor {
	
	//return [NSColor colorWithDeviceRed: 0.318f green: 0.318f blue: 0.318f alpha: [self disabledAlphaValue]];
	return [NSColor colorWithDeviceRed: 0 green: 0 blue: 0 alpha: [self disabledAlphaValue]];
}

-(NSColor *)disabledStrokeColor {
	
	return [NSColor colorWithDeviceRed: 0.749f green: 0.761f blue: 0.788f alpha: [self disabledAlphaValue]];
}

-(NSShadow *)focusRing {
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor: [NSColor whiteColor]];
	[shadow setShadowBlurRadius: 3];
	[shadow setShadowOffset: NSMakeSize( 0, 0)];
	
	return [shadow autorelease];
}

-(NSShadow *)dropShadow {
	
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor: [NSColor blackColor]];
	[shadow setShadowBlurRadius: 2];
	[shadow setShadowOffset: NSMakeSize( 0, -1)];
	
	return [shadow autorelease];
}

-(NSGradient *)highlightKnobColor {
	
	return [[[NSGradient alloc] initWithStartingColor: [NSColor colorWithDeviceRed: 0.451f green: 0.451f blue: 0.455f alpha: 1.0f]
										  endingColor: [NSColor colorWithDeviceRed: 0.318f green: 0.318f blue: 0.318f alpha: 1.0f]] autorelease];
}

-(NSGradient *)knobColor {
	
	return [[[NSGradient alloc] initWithStartingColor: [NSColor colorWithDeviceRed: 0.251f green: 0.251f blue: 0.255f alpha: 1.0f]
										  endingColor: [NSColor colorWithDeviceRed: 0.118f green: 0.118f blue: 0.118f alpha: 1.0f]] autorelease];
}

-(NSGradient *)disabledKnobColor {
	
	return [[[NSGradient alloc] initWithStartingColor: [NSColor colorWithDeviceRed: 0.251f green: 0.251f blue: 0.255f alpha: 1.0f]
										  endingColor: [NSColor colorWithDeviceRed: 0.118f green: 0.118f blue: 0.118f alpha: 1.0f]] autorelease];
}
-(CGFloat)alphaValue {
	
	return 1.0f;
}

-(CGFloat)disabledAlphaValue {
	
	return 0.2f;
}

@end
