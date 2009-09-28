//
//  ADParticle.m
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


#import "ADParticle.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>


@implementation ADParticle

@synthesize alive;


#pragma mark API 

- (id) initWithPosition:(CGPoint)startPosition withVelocity:(CGPoint)startVelocity withColor:(float[3])color
{
	if(self = [super init])
	{			
		position = startPosition;
		velocity = startVelocity;
		r = color[0];
		g = color[1];
		b = color[2];
		alpha = 1.0f;
	}

	return self;
}


#pragma mark ADUpdater

- (void) update
{
	position.x += velocity.x;
	position.y += velocity.y;
	alpha -= 0.01f;
	alive = alpha >= 0.0f;
}

- (void) draw
{
	glColor4f(r, g, b, alpha);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	glBindTexture(GL_TEXTURE_2D, 0);
	
	const float size = 2.0f;
	
	float vertexData[] = { 
		position.x, position.y,
		position.x + size, position.y,
		position.x, position.y + size,
		position.x + size, position.y + size
	};
	
	
	glVertexPointer(2, GL_FLOAT, sizeof(float) * 2, vertexData);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
