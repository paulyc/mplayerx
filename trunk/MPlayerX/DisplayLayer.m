/*
 * MPlayerX - DisplayLayer.m
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

#import "DisplayLayer.h"

#define SAFEFREE(x)						{if(x){free(x); x = NULL;}}
#define SAFERELEASETEXTURECACHE(x)		{if(x){CVOpenGLTextureCacheRelease(x); x=NULL;}}
#define SAFERELEASEOPENGLBUFFER(x)		{if(x){CVOpenGLBufferRelease(x); x=NULL;}}
#define SAFERELEASETEXTURE(x)			{if(x){CVOpenGLTextureRelease(x);x=NULL;}}

@implementation DisplayLayer

@synthesize fillScreen;

//////////////////////////////////////Init/Dealloc/////////////////////////////////////
- (id) init
{
	if (self = [super init]) {
		bufRefs = NULL;
		bufTotal = 0;
		frameNow = -1;

		cache = NULL;

		memset(&fmt, 0, sizeof(fmt));
		fmt.aspect = kDisplayAscpectRatioInvalid;

		fillScreen = NO;
		externalAspectRatio = kDisplayAscpectRatioInvalid;

		[self setDelegate:self];
		// [self setMasksToBounds:YES];
		[self setAutoresizingMask:kCALayerWidthSizable|kCALayerHeightSizable];
	}
	return self;
}

-(id<CAAction>) actionForLayer:(CALayer*)layer forKey:(NSString*)event
{
	return ((id<CAAction>)[NSNull null]);
}

- (void)dealloc
{
	SAFERELEASETEXTURECACHE(cache);
	
	if (bufRefs) {
		for(;bufTotal>0;bufTotal--) {
			SAFERELEASEOPENGLBUFFER(bufRefs[bufTotal-1]);
		}
		free(bufRefs);
	}

	[super dealloc];
}

-(CIImage*) snapshot
{
	if (bufRefs && (frameNow >= 0)) {
		return [CIImage imageWithCVImageBuffer:bufRefs[frameNow]];
	}
	return nil;
}

-(NSSize) displaySize
{
	return NSMakeSize(fmt.width, fmt.height);
}

-(CGFloat) aspectRatio
{
	if (externalAspectRatio > 0) {
		return externalAspectRatio;
	} else if (fmt.aspect > 0) {
		return fmt.aspect;
	}
	return kDisplayAscpectRatioInvalid;
}

-(void) setExternalAspectRatio:(CGFloat)ar
{
	externalAspectRatio = (ar>0)?(ar):(kDisplayAscpectRatioInvalid);
}

-(int) startWithFormat:(DisplayFormat)displayFormat buffer:(char**)data total:(NSUInteger)num
{
	@synchronized(self) {
		fmt = displayFormat;

		if (data && (num > 0)) {
			CVReturn error;
			
			bufRefs = malloc(num * sizeof(CVOpenGLBufferRef));
			
			for (bufTotal=0; bufTotal<num; bufTotal++) {
				error = CVPixelBufferCreateWithBytes(NULL, fmt.width, fmt.height, fmt.pixelFormat, 
													 data[bufTotal], fmt.width * fmt.bytes, 
													 NULL, NULL, NULL, &bufRefs[bufTotal]);
				if (error != kCVReturnSuccess) {
					[self stop];
					NSLog(@"video buffer failed");
					break;
				}				
			}
		}
	}
	return (bufRefs)?0:1;
}

-(void) draw:(NSUInteger)frameNum
{
	frameNow = frameNum;
	[self setNeedsDisplay];
}

-(void) stop
{
	@synchronized(self) {
		frameNow = -1;
		
		if (bufRefs) {
			for(;bufTotal>0;bufTotal--) {
				SAFERELEASEOPENGLBUFFER(bufRefs[bufTotal-1]);
			}
			free(bufRefs);
			bufRefs = NULL;
		}
		
		memset(&fmt, 0, sizeof(fmt));
		fmt.aspect = kDisplayAscpectRatioInvalid;

		[self setNeedsDisplay];
	}
}

//////////////////////////////////////OpenGLLayer inherent/////////////////////////////////////
-(BOOL) asynchronous
{
	return NO;
}

-(CGLContextObj) copyCGLContextForPixelFormat:(CGLPixelFormatObj)pf
{
	GLint i = 1;

	CGLContextObj ctx = [super copyCGLContextForPixelFormat:pf];

	NSLog(@"ctx:%d", (ctx != 0));
	NSLog(@"pfrc:%d", CGLGetPixelFormatRetainCount(pf));
	
	CGLLockContext(ctx);

	CGLSetParameter(ctx, kCGLCPSwapInterval, &i);
	/*
	glEnable(GL_TEXTURE_RECTANGLE_ARB);
	glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_STORAGE_HINT_APPLE, GL_STORAGE_CACHED_APPLE);
	
	glPixelStorei(GL_UNPACK_CLIENT_STORAGE_APPLE, GL_TRUE);
	*/
	CGLEnable(ctx, kCGLCEMPEngine);
	
	SAFERELEASETEXTURECACHE(cache);
	CVReturn error = CVOpenGLTextureCacheCreate(NULL, NULL, ctx, pf, NULL, &cache);
	
	CGLUnlockContext(ctx);
	
	if(error != kCVReturnSuccess) {
		cache = NULL;
		NSLog(@"video cache create failed");
	}
	return ctx;
}

- (void)releaseCGLContext:(CGLContextObj)ctx
{
	SAFERELEASETEXTURECACHE(cache);

	[super releaseCGLContext:ctx];
}

- (void)drawInCGLContext:(CGLContextObj)glContext 
			 pixelFormat:(CGLPixelFormatObj)pixelFormat
			forLayerTime:(CFTimeInterval)timeInterval 
			 displayTime:(const CVTimeStamp *)timeStamp
{
	CGLLockContext(glContext);	
	
	CGLSetCurrentContext(glContext);
	
	if (bufRefs && (frameNow >= 0)) {
	
		CVOpenGLTextureRef tex;
		
		CVReturn error = CVOpenGLTextureCacheCreateTextureFromImage(NULL, cache, bufRefs[frameNow], NULL, &tex);
		
		if (error == kCVReturnSuccess) {
			// draw
			CGRect rc = self.superlayer.bounds;
			CGFloat sAspect = [self aspectRatio];
			
			if (((sAspect * rc.size.height) > rc.size.width) == fillScreen) {
				rc.size.width = rc.size.height * sAspect;
			} else {
				rc.size.height = rc.size.width / sAspect;
			}
			
			[self setBounds:rc];
			
			GLenum target = CVOpenGLTextureGetTarget(tex);

			glEnable(target);
			glBindTexture(target, CVOpenGLTextureGetName(tex));
			
			glBegin(GL_QUADS);
			
			// 直接计算layer需要的尺寸
			glTexCoord2f(		 0,			 0);	glVertex2f(-1,	 1);
			glTexCoord2f(		 0, fmt.height);	glVertex2f(-1,	-1);
			glTexCoord2f(fmt.width, fmt.height);	glVertex2f( 1,	-1);
			glTexCoord2f(fmt.width,			 0);	glVertex2f( 1,	 1);
			
			glEnd();
			
			glDisable(target);
			CVOpenGLTextureRelease(tex);
			goto FLUSH;
		}
	}
	
	glClearColor(0, 0, 0, 0);
	glClear(GL_COLOR_BUFFER_BIT);
	
FLUSH:
	glFlush();
	CGLUnlockContext(glContext);
}
@end
