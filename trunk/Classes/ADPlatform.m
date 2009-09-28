//
//  ADPlatform.m
//  TwitterGame
//
//Copyright (C) 2009 Amanda Wixted and David Cairns
//
//This program is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//This program is distributed in the hope that it will be
//useful, but WITHOUT ANY WARRANTY; without even the implied
//warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//See the GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program.  If not, see <http://www.gnu.org/licenses/>.


#import "ADPlatform.h"
#import "ADAvatar.h"
#import "ADTwitterDatasource.h"

const CGFloat kTextPad = 4.0;

@interface ADPlatform ()
- (void)_generateTextureFromTweet:(NSString*)message withFont:(UIFont *)font;
@end


@implementation ADPlatform

@synthesize frame, tweet;


#pragma mark NSObject

- (void)dealloc
{
	[texture release];
	[tweet release];
	
	[super dealloc];
}


#pragma mark API 

-(id) initWithFrame:(CGRect)theFrame withMessage:(NSString *)message withFont:(UIFont *)font
{
	if(self = [super init])
	{
		frame = theFrame;
		
		// Lower-left
		geometry[0].x = frame.origin.x;
		geometry[0].y = frame.origin.y;
	    geometry[0].uv = 0.0;
		geometry[0].uy = 0.0;
		
		
		// Lower-right
		geometry[1].x = frame.origin.x + frame.size.width;
		geometry[1].y = frame.origin.y;
		geometry[1].uv = 1.0;
		geometry[1].uy = 0.0;
		
		
		// Upper-right
		geometry[2].x = frame.origin.x + frame.size.width;
		geometry[2].y = frame.origin.y + frame.size.height;
		geometry[2].uv = 1.0;
		geometry[2].uy = 1.0;
		
		// Upper-left
		geometry[3].x = frame.origin.x;
		geometry[3].y = frame.origin.y + frame.size.height;
		geometry[3].uv = 0.0;
		geometry[3].uy = 1.0;
		
		
		// Generate a texture from the text of our tweet.
		[self _generateTextureFromTweet:message withFont:font];
	}
	
	return self;
}

-(id) initRelativeToSiblingFrame:(CGRect)siblingFrame
{
	// Set up the frame first, then call the initWithFrame
	
	// Get the most recently created platform and base our position on it
	CGFloat siblingsY = siblingFrame.origin.y;
	
	// Get the size of the tweet message so we can make the frame size to accomodate it
	
	// Grab the text of the next tweet.
	self.tweet = [[ADTwitterDatasource sharedDatasource] nextTweet];
	NSString *message = [tweet text];
	
	// Determine the drawing size of the text.
	UIFont *font = [UIFont boldSystemFontOfSize:10.0];
	
	CGSize size = [message sizeWithFont:font 
					  constrainedToSize:CGSizeMake(MAX_PLATFORM_W, MAX_PLATFORM_H) 
						  lineBreakMode:UILineBreakModeWordWrap];
	
	CGFloat myX = random() % (int)(320 - size.width);
	
	CGFloat distance = (random() % 160) + 60;
	
	CGRect rect = CGRectMake(myX, siblingsY + distance, size.width + 2.0 * kTextPad, size.height + 2.0 * kTextPad);
	
	return [self initWithFrame:rect withMessage:message withFont:font];
}


- (void)drawPlatform
{
	// TODO Draw a rounded rect on top of this quad. --DRC
	
	[texture bind];
	
	glVertexPointer(2, GL_FLOAT, sizeof(VertData), &geometry[0].x);
	glTexCoordPointer(2, GL_FLOAT, sizeof(VertData), &geometry[0].uv);
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}


#pragma mark Private API 

- (void)_generateTextureFromTweet:(NSString*)message withFont:(UIFont *)font
{
	// Allocate some space which will serve as the backing for our bitmap context.
	size_t width = NextPowerOfTwo((int)self.frame.size.width + 2 * kTextPad);
	size_t height = NextPowerOfTwo((int)self.frame.size.height + 2 * kTextPad);
	const size_t bitsPerComponent = 8;
	const size_t numComponents = 4;
	const size_t bytesPerRow = numComponents * width;
	unsigned char *buffer = (unsigned char*)malloc(bytesPerRow * height * sizeof(unsigned char));
	memset(buffer, 0, bytesPerRow * height * sizeof(unsigned char));
	
	// Create a CGBitmapContext.
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(buffer, 
												 width, height, 
												 bitsPerComponent, bytesPerRow, 
												 colorspace, 
												 kCGImageAlphaNoneSkipLast);
	assert(context);
	
	UIGraphicsPushContext(context);
	[[UIColor whiteColor] set];
	
	
	// Load the background image and draw it at an arbitrary point to the upper left of where we're drawing the texture
	// This is so that each platform background will be unique.
	UIImage *backgroundImage = [UIImage imageNamed:@"apple-birch-small.jpg"];
	NSAssert(backgroundImage, @"ERROR: background image doesn't exist.");
	CGPoint backgroundSourcePoint = CGPointMake(0.0 - random() % (int)(fabsf(backgroundImage.size.width - frame.size.width)), 
												0.0 - random() % (int)(fabsf(backgroundImage.size.height - frame.size.height)));
	[backgroundImage drawAtPoint:backgroundSourcePoint];
	
	if(message)
	{
		[message drawInRect:CGRectMake(kTextPad, kTextPad, self.frame.size.width - 2.0 * kTextPad, self.frame.size.height - 2.0 * kTextPad) 
				   withFont:font 
			  lineBreakMode:UILineBreakModeWordWrap 
				  alignment:UITextAlignmentLeft];
	}
	
	// Get the context we just drew to
	UIGraphicsPopContext();
	
	texture = [[GLTexture alloc] initWithBuffer:buffer width:width height:height];
	
	// Set our tex coords.
	// Use ratios (instead of 1.0) because the size of the drawn text is variable within the size of the next highest power of 2
	GLfloat texWidthRatio = self.frame.size.width / (CGFloat)width;
	GLfloat texHeightRatio = self.frame.size.height / (CGFloat)height;
	
	// Lower-left
	geometry[0].uv = 0.0;
	// Use 1.0 - because we are drawing with respect to the lower lefthand corner, not the upper.
	geometry[0].uy = 1.0 - texHeightRatio;
	
	// Lower-right
	geometry[1].uv = texWidthRatio;
	geometry[1].uy = 1.0 - texHeightRatio;
	
	// Upper-right
	geometry[2].uv = texWidthRatio;
	geometry[2].uy = 1.0;
	
	// Upper-left
	geometry[3].uv = 0.0;
	geometry[3].uy = 1.0;
}


@end
