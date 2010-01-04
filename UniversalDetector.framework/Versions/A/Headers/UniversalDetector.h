#import <Foundation/Foundation.h>

@interface UniversalDetector:NSObject
{
	void *detector;
	NSString *charset;
	float confidence;
}

+(UniversalDetector *)detector;

-(id)init;
-(void)dealloc;

-(void)analyzeData:(NSData *)data;
-(void)analyzeBytes:(const char *)data length:(int)len;
-(void)analyzeContentsOfFile:(NSString*)filePath;

-(void)reset;

-(BOOL)done;
-(NSString *)MIMECharset;
-(float)confidence;

@end
