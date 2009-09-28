//
//  ADHUD.m
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


#import "ADHUD.h"
#import <OpenGLES/ES1/gl.h>
#import "GLTexture.h"

@implementation ADHUD

-(id)init
{

	if(self = [super init])
	{
		
		// Load heart image for texture
		heartTexture = [[GLTexture alloc] initWithName:@"heart.png" isRounded:NO];
		emptyHeartTexture = [[GLTexture alloc] initWithName:@"empty_heart.png" isRounded:NO];
		
		firstHeartLoc = CGPointMake(320.0 - 2.0 - (CGFloat)HEART_SIZE, 
									480.0 - 2.0 - (CGFloat)HEART_SIZE);
		
		// Load the star texture TODO: change the filename when we get a star file
		starTexture = [[GLTexture alloc] initWithName:@"star.png" isRounded:NO];
		firstStarLoc = CGPointMake(5.0, 480.0 - 2.0 - (CGFloat)HEART_SIZE);
	}
	
	return self;
}


-(void) dealloc
{
	[heartTexture release];
	[emptyHeartTexture release];
	[starTexture release];
	
	[super dealloc];
}

-(void)drawWithNumHearts:(int)numHearts totalNumHearts:(int)totalNumHearts numStars:(int)numStars
{
	// Before we draw, set an ortho projection matrix.
	glPushMatrix();
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glOrthof(0.0, 320.0, 
			 0.0, 480.0, 
			 -1.0, 1.0);
	
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	// Also set the blend mode.
	glEnable(GL_BLEND);
	glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	glColor4f(1.0, 1.0, 1.0, 1.0);
	
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	
	float verts[] = {
		firstHeartLoc.x,				firstHeartLoc.y,
		firstHeartLoc.x + HEART_SIZE,	firstHeartLoc.y,
		firstHeartLoc.x + HEART_SIZE,	firstHeartLoc.y + HEART_SIZE,
		firstHeartLoc.x,				firstHeartLoc.y + HEART_SIZE,
	};
	float texCoords[] = {
		0.0,	1.0,
		1.0,	1.0,
		1.0,	0.0,
		0.0,	0.0,
	};
	glVertexPointer(2, GL_FLOAT, 0, verts);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	
	// Draw the hearts either empty or full on the right side of the top of the screen
	glPushMatrix();
	for(int i = 0; i < totalNumHearts; i++)
	{
		GLTexture *t = i < numHearts ? heartTexture : emptyHeartTexture;
		[t bind];
		
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		glTranslatef(-1.0 * (HEART_SIZE + SPACE_BTWN_HEARTS), 0.0, 0.0);
	}
	glPopMatrix();
	
	
	// Draw the stars on the left side of the top of the screen
	
	float starVerts[] = {
		firstStarLoc.x,				firstStarLoc.y,
		firstStarLoc.x + STAR_SIZE,	firstStarLoc.y,
		firstStarLoc.x + STAR_SIZE,	firstStarLoc.y + STAR_SIZE,
		firstStarLoc.x,				firstStarLoc.y + STAR_SIZE,
	};	

	glVertexPointer(2, GL_FLOAT, 0, starVerts);
	glTexCoordPointer(2, GL_FLOAT, 0, texCoords);
	
	glPushMatrix();
	[starTexture bind];
	for(int i = 0; i < numStars; i++)
	{
		glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
		glTranslatef(1.0 * (STAR_SIZE + SPACE_BTWN_HEARTS), 0.0, 0.0);
	}	
	glPopMatrix();
	
	// Restore drawing state.
	glDisable(GL_BLEND);
	glPopMatrix();
	
}

@end
