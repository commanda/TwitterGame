//
//  ADAvatar.m
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


#import "ADAvatar.h"
#import "ADGameController.h"
#import "ADPlatformFactory.h"
#import "ADTwitterDatasource.h"
#import "SingletonSoundManager.h"

#define AVATAR_SIZE 64.0
#define AVATAR_HALF_SIZE (.5 * AVATAR_SIZE)

@implementation ADAvatar

@synthesize nextPosition;
@synthesize isCollidingWithSpammer;


#pragma mark NSObject

-(id) init
{
	NSLog(@"avatar init");
	if(self = [super initWithUIImage:[[ADTwitterDatasource sharedDatasource] userAvatar] size:CGSizeMake(AVATAR_SIZE, AVATAR_SIZE)])
	{
		position = CGPointMake(50.0, 480.0);
	}
	return self;
}


#pragma mark API 

-(void) doJumpWithSpeed:(float)swipeSpeed
{
	yVelocity = fminf(swipeSpeed * kJumpyAcceleration, 20.0);

	[[SingletonSoundManager sharedSoundManager] 
	 playAVSoundEffectWithKey:@"jump"];
}

-(void) doRunWithForce:(float)force
{
	position.x += 8.0 * force;

	if(position.x < 0.0) {
		position.x = 0.0;
	}
	if(position.x > 320.0) {
		position.x = 320.0;
	}

}

-(BOOL) isBelowViewableFrame:(CGRect)viewable
{
	return (self.bottomLeft.y < CGRectGetMinY(viewable));
}

- (CGPoint)bottomLeft
{
	return CGPointMake(self.position.x - AVATAR_HALF_SIZE, self.position.y);
}
- (CGPoint)bottomRight
{
	return CGPointMake(self.position.x + AVATAR_HALF_SIZE, self.position.y);
}
- (CGPoint)nextBottomLeft
{
	return CGPointMake(self.nextPosition.x - AVATAR_HALF_SIZE, self.nextPosition.y);
}
- (CGPoint)nextBottomRight
{
	return CGPointMake(self.nextPosition.x + AVATAR_HALF_SIZE, self.nextPosition.y);
}


#pragma mark ADUpdater

-(void) update
{
	// First, determine nextPosition if we are in free-fall.
	yVelocity += kGravityAcceleration;
	nextPosition.x = position.x;
	nextPosition.y = position.y + yVelocity;
	
	// Check to see if nextPosition causes us to hit any barriers.
	ADPlatform *standingOn = [[ADPlatformFactory sharedFactory] 
							  didCollideWithAvatar:self];
	if(standingOn && (yVelocity < 0.0))
	{
		nextPosition.y = CGRectGetMaxY(standingOn.frame);
		yVelocity = 0.0;
	}
	// After calculating what the next position would be 
	// if there were nothing in our way, set the avatar's 
	// position to it.
	position = nextPosition;
}



@end
