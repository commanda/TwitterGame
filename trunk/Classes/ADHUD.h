//
//  ADHUD.h
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


#import <Foundation/Foundation.h>

#define HEART_SIZE 32
#define STAR_SIZE 32
#define SPACE_BTWN_HEARTS 12

@class GLTexture;

@interface ADHUD : NSObject {
	GLTexture *heartTexture;
	GLTexture *emptyHeartTexture;
	GLTexture *starTexture;
	CGPoint firstHeartLoc;
	CGPoint firstStarLoc;	
}


-(void)drawWithNumHearts:(int)numHearts totalNumHearts:(int)totalNumHearts numStars:(int)numStars;


@end
