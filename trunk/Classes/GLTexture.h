// DO NOT USE THIS TEXTURE CLASS IN A SHIPPING APP: IT HAS BUGS AND IS FOR DEMO
// PURPOSES ONLY!
// Unless you fix the leaks... then go ahead and use it :-)



//
//  GLTexture.h
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


#import <Foundation/Foundation.h>
#import <OpenGLES/ES1/gl.h>


typedef struct {
	GLfloat x, y;
	GLfloat uv, uy;
} VertData;

typedef enum
	{
		NGTextureFormat_Invalid = 0,
		NGTextureFormat_A8,
		NGTextureFormat_LA88,
		NGTextureFormat_RGB565,
		NGTextureFormat_RGBA5551,
		NGTextureFormat_RGB888,
		NGTextureFormat_RGBA8888,
		NGTextureFormat_RGB_PVR2,
		NGTextureFormat_RGB_PVR4,
		NGTextureFormat_RGBA_PVR2,
		NGTextureFormat_RGBA_PVR4,
	} NGTextureFormat;

/*
extern inline NGTextureFormat GetImageFormat(CGImageRef image);
extern uint8_t *GetImageData(CGImageRef image, NGTextureFormat format);
 */

extern int NextPowerOfTwo(int n);

@interface GLTexture : NSObject {
    GLuint _textureID;
}

- (id)initWithBuffer:(unsigned char*)buffer width:(size_t)width height:(size_t)height;
- (id)initWithName:(NSString *)name isRounded:(BOOL)isRounded;
- (id) initWithUIImage:(UIImage *)uiImage isRounded:(BOOL)isRounded;

- (void)bind;

@end
