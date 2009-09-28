//
//  ADCharacter.m
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


#import "ADCharacter.h"
#import "GLTexture.h"

@implementation ADCharacter

@synthesize position;
@synthesize size;
@synthesize alive;


#pragma mark NSObject

-(void) dealloc
{
	[texture release];
	[super dealloc];
}


#pragma mark API 

-(id)initWithUIImage:(UIImage *)uiImage size:(CGSize)theSize
{
	if(self = [super init])
	{
		texture = [[GLTexture alloc] initWithUIImage:uiImage isRounded:YES];
		alive = true;
		size = theSize;
	}
	
	return self;
}

-(id) initWithTextureName:(NSString*)imgName size:(CGSize)theSize
{
	if(self = [super init])
	{
		texture = [[GLTexture alloc] initWithName:imgName isRounded:YES];
		alive = true;
		size = theSize;
	}
	
	return self;
}

// Pass YES if you want a widened collision rect - for touch, not for sprite collision
-(CGRect) collisionRect:(BOOL)big
{
	if(big)
	{
		return CGRectMake((position.x - .5 * size.width) -10, position.y + 10, size.width + 20, size.height + 20);
	}
	else {
		return CGRectMake(position.x - .5 * size.width, position.y, 
						  size.width, size.height);
	}
}


#pragma mark ADUpdater

// Subclasses are meant to override this. Default implementation does nothing.
-(void) update
{
	
}

-(void) draw
{
	[texture bind];
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	CGFloat halfWidth	= .5 * size.width;
	
	VertData lowerLeft = { position.x - halfWidth,		position.y,						0.0,	1.0};
	VertData lowerRight = { position.x + halfWidth,		position.y,						1.0,	1.0};
	VertData upperLeft	 = { position.x - halfWidth,	position.y + size.height,		0.0,	0.0};
	VertData upperRight = { position.x + halfWidth,		position.y + size.height,		1.0,	0.0};
	
	
	VertData vertexData[] = {
		
		lowerLeft,
		lowerRight,
		
		upperRight,
		upperLeft,
	};
	
	glVertexPointer(2, GL_FLOAT, sizeof(VertData), &vertexData[0].x);
	glTexCoordPointer(2, GL_FLOAT, sizeof(VertData), &vertexData[0].uv);
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

@end
