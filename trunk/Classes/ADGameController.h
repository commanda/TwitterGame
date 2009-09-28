//
//  ADGameController.h
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
#import "ADUpdater.h"

@class ADSpammer;
@class ADAvatar;
@class ADHUD;

#define kUpdateFrequency (60.0f)
#define kGravityAcceleration (-0.8f)
#define kJumpyAcceleration (0.016f)

#define SPEED (30.0f)
#define NUM_SPAMMERS_PER_STAR (5)

@interface ADGameController : NSObject <UIAccelerometerDelegate>
{
	ADHUD *hud;
	
	ADAvatar *avatar;
	
	NSMutableArray *spammers;
	NSMutableArray<ADUpdater> *updateList;
	
	NSTimeInterval	touchStartTime;
	CGPoint			touchStartPoint;
	
	NSTimeInterval	touchEndTime;
	CGPoint			touchEndPoint;
	
	BOOL handleTouchInput;
	
	// The y-value of the bottom of the viewport
	CGFloat			currentHeight;
	
//	BOOL			paused;
	
	int				numLives;
	int				totalNumLives;
	int				numSpammersKilled;
}
@property float currentHeight;
@property (readonly) NSInteger numStars;

- (void)draw;
- (void)update;
- (void)touchBegan:(UITouch *)touch atPoint:(CGPoint)point;
- (void)touchEnded:(UITouch *)touch atPoint:(CGPoint)point;


@end
