// DO NOT USE THIS TEXTURE CLASS IN A SHIPPING APP: IT HAS BUGS AND IS FOR DEMO
// PURPOSES ONLY!
// Unless you fix the leaks... then go ahead and use it :-)



//
//  GLTexture.m
//  particleDemo
//
//  Created by Tim Omernick on 5/20/09.
//  Copyright 2009 ngmoco:). All rights reserved.
//

/*
--------

Copyright (c) 2009, ngmoco, Inc.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
   * Neither the name of ngmoco, Inc. nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
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


#import "GLTexture.h"


const int kMaxTextureSizeExp = 10;
#define kMaxTextureSize (1 << kMaxTextureSizeExp)

static inline bool NGIsPowerOfTwo(uint32_t n)
{
	return ((n & (n-1)) == 0);
}

int NextPowerOfTwo(int n)
{
	if (NGIsPowerOfTwo(n))
		return n;
	
	for (int i = kMaxTextureSizeExp - 1; i > 0; i--)
	{
		if (n & (1 << i))
			return (1 << (i+1));
	}
	
	return kMaxTextureSize;
}


@implementation GLTexture



typedef enum
{
	NGTextureStorageFormat_Invalid = 0,
	NGTextureStorageFormat_Raw,
	NGTextureStorageFormat_PNG,
} NGTextureStorageFormat;

static inline NGTextureFormat GetImageFormat(CGImageRef image)
{
	CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image);
	bool hasAlpha = (alpha != kCGImageAlphaNone && alpha != kCGImageAlphaNoneSkipLast && alpha != kCGImageAlphaNoneSkipFirst);
//	CGBitmapInfo info = CGImageGetBitmapInfo(image);	//! ATH TEST
	
	CGColorSpaceRef color = CGImageGetColorSpace(image);
	
	if (color != NULL)
	{
		if (CGColorSpaceGetModel(color) == kCGColorSpaceModelMonochrome)
		{
			return (hasAlpha ? NGTextureFormat_LA88 : NGTextureFormat_A8);
		}
			
		int bpp = CGImageGetBitsPerPixel(image);

		if (bpp == 16)
		{
			return hasAlpha ? NGTextureFormat_RGBA5551 : NGTextureFormat_RGB565;
		}
		
		return hasAlpha ? NGTextureFormat_RGBA8888 : NGTextureFormat_RGB888;
	}
	
	return NGTextureFormat_A8;
}

static inline int GetBPP(NGTextureFormat format)
{
	switch (format)
	{
	case NGTextureFormat_A8:
		return 8;
	case NGTextureFormat_LA88:
	case NGTextureFormat_RGB565:
	case NGTextureFormat_RGBA5551:
		return 16;
	case NGTextureFormat_RGB888:
	case NGTextureFormat_RGBA8888:
		return 32;
	default:
		return 0;
	}
}

static inline int GetGLColor(NGTextureFormat format)
{
	switch (format)
	{
	case NGTextureFormat_RGBA5551:
	case NGTextureFormat_RGBA8888:
		return GL_RGBA;
	case NGTextureFormat_RGB565:
	case NGTextureFormat_RGB888:
		return GL_RGB;
	case NGTextureFormat_A8:
		return GL_ALPHA;
	case NGTextureFormat_LA88:
		return GL_LUMINANCE_ALPHA;
	default:
		return 0;
	}
}

static inline int GetGLFormat(NGTextureFormat format)
{
	switch (format)
	{
	case NGTextureFormat_A8:
	case NGTextureFormat_LA88:
	case NGTextureFormat_RGB888:
	case NGTextureFormat_RGBA8888:
		return GL_UNSIGNED_BYTE;
	case NGTextureFormat_RGBA5551:
		return GL_UNSIGNED_SHORT_5_5_5_1;
	case NGTextureFormat_RGB565:
		return GL_UNSIGNED_SHORT_5_6_5;
	default:
		return 0;
	}
}

uint8_t *GetImageData(CGImageRef image, NGTextureFormat format)
{
	CGContextRef			context = NULL;
	uint8_t*				data = NULL;
	CGColorSpaceRef			colorSpace = NULL;
	unsigned char*			inPixel8 = NULL;
	unsigned int*			inPixel32 = NULL;
	unsigned char*			outPixel8 = NULL;
	unsigned short*			outPixel16 = NULL;
	
	int width = NextPowerOfTwo(CGImageGetWidth(image));
	int height = NextPowerOfTwo(CGImageGetHeight(image));
	
	switch (format)
	{
	case NGTextureFormat_RGBA8888:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 4);
		context = CGBitmapContextCreate(data, 
										width, height, 
										8, 4 * width, 
										colorSpace, 
										kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		break;

	case NGTextureFormat_RGBA5551:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 2);
		context = CGBitmapContextCreate(data, 
										width, height, 
										5, 2 * width, 
										colorSpace, 
										kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder16Little);
		CGColorSpaceRelease(colorSpace);
		break;

	case NGTextureFormat_RGB888:
	case NGTextureFormat_RGB565:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 4);
		context = CGBitmapContextCreate(data, 
										width, height, 
										8, 4 * width, 
										colorSpace, 
										kCGImageAlphaNoneSkipLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		break;

	case NGTextureFormat_A8:
		data = malloc(height * width);
		context = CGBitmapContextCreate(data, width, height, 8, width, NULL, kCGImageAlphaOnly);
		break;

	case NGTextureFormat_LA88:
		colorSpace = CGColorSpaceCreateDeviceRGB();
		data = malloc(height * width * 4);
		context = CGBitmapContextCreate(data, 
										width, height, 
										8, 4 * width, 
										colorSpace, 
										kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
		CGColorSpaceRelease(colorSpace);
		break;

	default:
		break;
	}

	if(context == NULL)
	{
		return NULL;
	}

    CGContextSetBlendMode(context, kCGBlendModeCopy);
	CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);

	//Convert "-RRRRRGGGGGBBBBB" to "RRRRRGGGGGBBBBBA"
	if(format == NGTextureFormat_RGBA5551) {
		outPixel16 = (unsigned short*)data;
		for(int i = 0; i < width * height; ++i, ++outPixel16)
			*outPixel16 = *outPixel16 << 1 | 0x0001;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from ARGB1555 to RGBA5551", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRRRRRGGGGGGGGBBBBBBBB"
	else if(format == NGTextureFormat_RGB888) {
		uint8_t *tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(int i = 0; i < width * height; ++i) {
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			*outPixel8++ = *inPixel8++;
			inPixel8++;
		}
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGB888", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "RRRRRGGGGGGBBBBB"
	else if(format == NGTextureFormat_RGB565) {
		uint8_t *tempData = malloc(height * width * 2);
		inPixel32 = (unsigned int*)data;
		outPixel16 = (unsigned short*)tempData;
		for(int i = 0; i < width * height; ++i, ++inPixel32)
			*outPixel16++ = ((((*inPixel32 >> 0) & 0xFF) >> 3) << 11) 
							| ((((*inPixel32 >> 8) & 0xFF) >> 2) << 5) 
							| ((((*inPixel32 >> 16) & 0xFF) >> 3) << 0);
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to RGB565", NULL);
#endif
	}
	//Convert "RRRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA" to "LLLLLLLLAAAAAAAA"
	else if(format == NGTextureFormat_LA88) {
		uint8_t *tempData = malloc(height * width * 3);
		inPixel8 = (unsigned char*)data;
		outPixel8 = (unsigned char*)tempData;
		for(int i = 0; i < width * height; ++i) {
			*outPixel8++ = *inPixel8++;
			inPixel8 += 2;
			*outPixel8++ = *inPixel8++;
		}
		free(data);
		data = tempData;
#if __DEBUG__
		REPORT_ERROR(@"Falling off fast-path converting pixel data from RGBA8888 to LA88", NULL);
#endif
	}

	CGContextRelease(context);

	return data;
}

- (id)initWithBuffer:(unsigned char*)buffer width:(size_t)width height:(size_t)height
{
	if (!(self = [super init]))
	{
		return nil;
	}
	
	glGenTextures(1, &_textureID);
	glBindTexture(GL_TEXTURE_2D, _textureID);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	
	glTexImage2D(GL_TEXTURE_2D, 
				 0, 
				 GL_RGBA,  
				 width, height, 
				 0, 
				 GL_RGBA, GL_UNSIGNED_BYTE, 
				 buffer);
	
	return self;
}

- (id) initWithUIImage:(UIImage *)uiImage isRounded:(BOOL)isRounded
{
	if (!(self = [super init]))
	{
		return nil;
	}
	
	if(!uiImage)
	{
		return nil;
	}
	
	CGImageRef image;
	if(isRounded)
	{
			
		// Create a new image with the size
		UIGraphicsBeginImageContext(uiImage.size);
		
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		
		//CGFloat radius = uiImage.size/5;
		CGFloat radius = 12;
		
		
		
		// Create the clipping path
		
		// Start at lower left corner
		CGContextMoveToPoint(ctx, radius, 0);
		CGContextAddArcToPoint(ctx, 0, 0, 0, radius, radius);
		// Move to upper left corner
		CGContextAddLineToPoint(ctx, 0, uiImage.size.height - radius);
		CGContextAddArcToPoint(ctx, 0, uiImage.size.height, radius, uiImage.size.height, radius);
		// Move to upper right corner
		CGContextAddLineToPoint(ctx, uiImage.size.width - radius, uiImage.size.height);
		CGContextAddArcToPoint(ctx, uiImage.size.width, uiImage.size.height, uiImage.size.width, uiImage.size.height - radius, radius);
		// Move to lower right corner
		CGContextAddLineToPoint(ctx, uiImage.size.width, radius);
		CGContextAddArcToPoint(ctx, uiImage.size.width, 0, uiImage.size.width-radius, 0, radius);
		// Move back to the starting point
		CGContextAddLineToPoint(ctx, radius, 0);
		
		// Set the clip using the path we just made
		CGContextClip(ctx);
		
		[uiImage drawAtPoint:CGPointZero];
		
		UIImage *clippedImg = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		image = clippedImg.CGImage;
	}
	else
	{
		image = uiImage.CGImage;
	}
	
	// Create rounded rect image
	
	
	if (image != NULL)
	{
		NGTextureFormat format = GetImageFormat(image);
		int width = NextPowerOfTwo(CGImageGetWidth(image));
		int height = NextPowerOfTwo(CGImageGetHeight(image));
		uint8_t *data = GetImageData(image, format);
		
        glGenTextures(1, &_textureID);
		glBindTexture(GL_TEXTURE_2D, _textureID);
		//		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
		//		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
		glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
		
		int glColor = GetGLColor(format);
		int glFormat = GetGLFormat(format);
		
		glTexImage2D(GL_TEXTURE_2D, 0, glColor, width, height, 0, glColor, glFormat, data);
		
		free(data);
	}
	
	return self;
	
}

- (id)initWithName:(NSString *)name isRounded:(BOOL)isRounded
{
	if (!(self = [super init]))
	{
		return nil;
	}
	
	
	return [self initWithUIImage:[UIImage imageNamed:name] isRounded:isRounded];
}

- (void)bind
{
    if (!_textureID)
	{
        return;
	}
	
	glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, _textureID);
}

@end
