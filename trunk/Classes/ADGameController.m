//
//  ADGameController.m
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


#import "ADGameController.h"

#import "ADAvatar.h"
#import "ADHUD.h"
#import "ADParticle.h"
#import "ADPlatformFactory.h"
#import "ADSpammer.h"
#import "ADTwitterDatasource.h"
#import "SingletonSoundManager.h"
#import "TwitterGameAppDelegate.h"



@interface ADGameController ()
@property (readonly) CGRect viewableFrame;
@property (readonly) float randFloat;
- (void)_updateCamera;
- (void)_handleSpammers;
- (void)_handleTouchInput;
@end


@implementation ADGameController



#pragma mark NSObject

static NSTimeInterval appStartTime;

+ (void)initialize;
{
	appStartTime = [[NSDate date] timeIntervalSinceReferenceDate];
}

- (id)init;
{
	if (!(self = [super init]))
		return nil;
	
	avatar = [[ADAvatar alloc] init];
	spammers = [[NSMutableArray alloc] initWithCapacity:10];
	hud = [[ADHUD alloc] init];
	
	numLives = totalNumLives = 3;
	
	numSpammersKilled = NUM_SPAMMERS_PER_STAR;
	
	updateList = [[NSMutableArray alloc] initWithCapacity:10];
	[updateList addObject:avatar];
	
	// Init the twitter handler
	
#if !USE_UIVIEWS
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / kUpdateFrequency];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
#endif
	return self;
}

- (void)dealloc
{
	[avatar release];
	[spammers release];
	[super dealloc];
}


#pragma mark UIAccelerometerDelegate

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	[avatar doRunWithForce:acceleration.x];
}


#pragma mark API

@synthesize currentHeight;

- (NSInteger) numStars
{
	return (numSpammersKilled / NUM_SPAMMERS_PER_STAR);
}

- (void)update;
{
	/*
	if(handleTouchInput)
	{
		[self _handleTouchInput];
	}
	 */
	
	// Remove any currently drawable objects if they need to be
	NSMutableArray *deadUpdaters = [NSMutableArray array];
	for(id updater in updateList) {
		[updater update];
		if (![updater alive]) 
		{
			[deadUpdaters addObject:updater];
		}
	}
	[updateList removeObjectsInArray:deadUpdaters];

	// Update the current height to scroll the game upwards
	NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
	currentHeight = SPEED * (now - appStartTime);
	
	// Update all the platforms (add new, delete the no longer visible)
	[[ADPlatformFactory sharedFactory] updateForViewableFrame:self.viewableFrame];
	
	// Decide if we should add a new spammer; 
	// remove all the old ones; 
	// update the remaining ones' positions.
	[self _handleSpammers];
	
	// Check to see if we're dead, LOL.
	if(0 == numLives || [avatar isBelowViewableFrame:self.viewableFrame])
	{
		[(TwitterGameAppDelegate*)[[UIApplication sharedApplication] delegate] gameOver];
	}
}


- (void)draw;
{
	[self _updateCamera];
	
	[[ADPlatformFactory sharedFactory] draw];
	
	for (id updater in updateList) 
	{
		[updater draw];
	}
	
	[hud drawWithNumHearts:numLives 
			totalNumHearts:totalNumLives 
				  numStars:self.numStars];
}


- (void)touchBegan:(UITouch *)touch atPoint:(CGPoint)point 
{
	touchStartTime  = [[NSDate date] timeIntervalSinceReferenceDate];//[touch timestamp];
	
	touchStartPoint = CGPointMake(point.x, point.y);
	
	// Translate view-space to game-space
	touchStartPoint.y = 480 - point.y + currentHeight;
	
}

- (void)touchEnded:(UITouch *)touch atPoint:(CGPoint)point 
{
	touchEndTime = [[NSDate date] timeIntervalSinceReferenceDate];//[touch timestamp];
	touchEndPoint = CGPointMake(point.x, point.y);
	// Translate view-space to game-space
	touchEndPoint.y = 480 - point.y + currentHeight;
	handleTouchInput = YES;
	[self _handleTouchInput];
}


#pragma mark Private API

- (CGRect)viewableFrame;
{
	// Returns the frame that is currently viewable in game-space
	return CGRectMake(0, currentHeight, 320, 480);
}

- (float)randFloat
{
	return (arc4random() % 10000) / 10000.0f;
}

- (void)_updateCamera
{
	glMatrixMode(GL_MODELVIEW);
	
	// Create a matrix based on the current viewable frame
	glLoadIdentity();
	glTranslatef(0, -currentHeight, 0);
}


- (void)_handleSpammers
{
	// TODO: Come up with a better equation for when to create a new spammer - make it get harder over time.
	
	//	int chance = arc4random();
	//	int spinner = arc4random() % 
	if((rand() % 10000) < 65)
	{
		CGPoint point = CGPointMake(arc4random() % 320, currentHeight + 540);
		CGPoint velocity = CGPointMake(self.randFloat * 4.0f - 2.0f, -self.randFloat * 1.0f - 0.5f);
		
		ADSpammer *newSpammer = [[[ADSpammer alloc] initWithPosition:point withVelocity:velocity] autorelease];
		[spammers addObject:newSpammer];
		[updateList addObject:newSpammer];
	}
	
	// Delete spammers that are no longer visible that the user decided to avoid and not block
	NSMutableArray *spammersToRemove = [NSMutableArray array];
	for(ADSpammer *spammer in spammers)
	{
		if(spammer.position.y < currentHeight - spammer.size.height)
		{
			[spammersToRemove addObject:spammer];
		}
	}
	[spammers removeObjectsInArray:spammersToRemove];
	[updateList removeObjectsInArray:spammersToRemove];
	
	// Update their positions and check to see if they collided with the avatar
	BOOL collidedWithSpammer = NO;
	for(ADSpammer *spammer in spammers)
	{		
		if(CGRectIntersectsRect([avatar collisionRect:NO], [spammer collisionRect:NO]))
		{
			collidedWithSpammer = YES;
			// TODO: Do a thing.
			if(!avatar.isCollidingWithSpammer)
			{
				numLives--;
				avatar.isCollidingWithSpammer = YES;
				
				// Only play the collision sound if this isn't our last life - that's when the gameover sound plays. 
				if (numLives > 0) {
					[[SingletonSoundManager sharedSoundManager] playAVSoundEffectWithKey:@"bump"];
				}
			}
		}
	}
	
	avatar.isCollidingWithSpammer = collidedWithSpammer;
}

- (void)_handleTouchInput;
{
	handleTouchInput = NO;
	float distance = touchEndPoint.y - touchStartPoint.y;
	float time = touchEndTime - touchStartTime;
	float swipeSpeed = distance / time;
	
	// If it looks like an upward swipe, do a jump!
	if(distance > 40.0) {
		[avatar doJumpWithSpeed:swipeSpeed];
		return;
	}
	
	BOOL killedASpammer = NO;
	// Check to see if you killed a spammer
	for(ADSpammer *spammer in spammers)
	{
		
		if (CGRectContainsPoint([spammer collisionRect:YES], touchEndPoint)) {
			[[SingletonSoundManager sharedSoundManager] playAVSoundEffectWithKey:@"hit"];
			// Create the particles for the explosion of the spammer
			for (int x = 0; x < 50; ++x) {
				
				CGPoint velocity = CGPointMake(self.randFloat * 2.0f - 1.0f, self.randFloat * 2.0f - 1.0f);
				ADParticle* particle = [[ADParticle alloc] initWithPosition:touchEndPoint withVelocity:velocity withColor:(float[]){1.0f, 1.0f, 1.0f}];
				[updateList addObject:particle];						
			}
			
			numSpammersKilled++;
			killedASpammer = YES;
			[spammers removeObject:spammer];
			[updateList removeObject:spammer];
			
			break;
		}
	}
	
	// Only see about favoriting tweets if the user didn't kill a spammer with this touch
	if(!killedASpammer)
	{
		// If the user wasn't swiping, see if their touch began and ended in a platform - see if they favorited a tweet
		unsigned long touchStartTweetIndex = [[ADPlatformFactory sharedFactory] didTouchPlatformAtPoint:touchStartPoint];
		unsigned long touchEndTweetIndex = [[ADPlatformFactory sharedFactory] didTouchPlatformAtPoint:touchEndPoint];
		
		//CGPoint touchInGameSpace = CGPointMake(touchEnd.x, (480 - touchEnd.y) + currentHeight);
		if(-1 != touchStartTweetIndex && touchEndTweetIndex == touchStartTweetIndex)
		{
			
			BOOL canUseStar = self.numStars >= 1;
			
			ADTweet *tappedTweet = [[ADTwitterDatasource sharedDatasource] tweetForTweetID:touchEndTweetIndex];
			if(canUseStar && !tappedTweet.isFavorited)
			{
				// Favorite it
				[[ADTwitterDatasource sharedDatasource] toggleFavorite:tappedTweet];
				
				// Decrement your num stars because you just used one
				numSpammersKilled -= NUM_SPAMMERS_PER_STAR;
				if(numSpammersKilled < 0)
				{
					numSpammersKilled = 0;
				}
				
				// Should we play the sound when you use a star, or when you earn one?
				[[SingletonSoundManager sharedSoundManager] playAVSoundEffectWithKey:@"star"];
				
				
			}
			else if(canUseStar && tappedTweet.isFavorited)
			{
				// Unfavorite
				[[ADTwitterDatasource sharedDatasource] toggleFavorite:tappedTweet];
			}
			else if(!canUseStar && !tappedTweet.isFavorited)
			{
				// do nothing
			}
			else if(!canUseStar && tappedTweet.isFavorited)
			{
				// Unfavorite
				[[ADTwitterDatasource sharedDatasource] toggleFavorite:tappedTweet];
			}
		}
	}
	
	//	else
	//	{
	//		paused = !paused;
	//	}
}


@end
