//
//  ADPlatformFactory.m
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


#import "ADPlatformFactory.h"
#import <OpenGLES/ES1/gl.h>
#import "ADPlatform.h"
#import "ADAvatar.h"
#import "ADTwitterDatasource.h"

static ADPlatformFactory *sharedFactory = nil;

BOOL linesIntersect(CGPoint a1, CGPoint a2, CGPoint b1, CGPoint b2);



@implementation ADPlatformFactory

@synthesize platforms;




#pragma mark NSObject

- (id)init
{
	if(self = [super init])
	{
		srandom(time(NULL));
		
		platforms = [[NSMutableArray alloc] initWithCapacity:10];
		
		// The first platform is the floor
		ADPlatform *floor = [[[ADPlatform alloc] initWithFrame:CGRectMake(0, 0, 320, 10) withMessage:nil withFont:nil] autorelease];
		[platforms addObject:floor];
		
		
		// Set up initial state.
		ADPlatform *lastPlatform = floor;
		for(NSInteger i = 0; i < 5; i++)
		{
			ADPlatform *platform = [[[ADPlatform alloc] initRelativeToSiblingFrame:lastPlatform.frame] autorelease];
			lastPlatform = platform;
			// Add to the collection.
			[platforms addObject:platform];
		}
		
		star = [[ADCharacter alloc] initWithUIImage:[UIImage imageNamed:@"star.png"] size:CGSizeMake(100, 100)];
		
	}
	
	return self;
}

- (void)dealloc
{
	[platforms release];
	
	[super dealloc];
}


#pragma mark API 

+ (ADPlatformFactory*)sharedFactory
{
	if(!sharedFactory)
	{
		sharedFactory = [[ADPlatformFactory alloc] init];
	}
	
	return sharedFactory;
}

- (void)updateForViewableFrame:(CGRect)rect
{
	// Create new platforms that are coming on the screen 
	// Delete old ones that are now off the screen
	// Update all the platforms' positions
	
	// Add/remove platforms from the list as necessary.
	
	// Pretend the viewable rect (passed in) is bigger than it really is, so we can delete the platforms when they're way off screen
	// (so they don't pop)
	
	CGRect bigRect = CGRectMake(rect.origin.x, rect.origin.y - 60, rect.size.width, rect.size.height + 120); 
	
	// Remove an unviewable platform
	if(([platforms count] > 0) && !CGRectIntersectsRect([[platforms objectAtIndex:0] frame], bigRect))
	{
		[platforms removeObjectAtIndex:0];
	}
	
	// If there are no platforms above the currently viewable frame, add another offscreen platform 
	if(CGRectIntersectsRect([[platforms lastObject] frame], bigRect))
	{
		ADPlatform *lastPlatform = [platforms lastObject];
		ADPlatform *newPlatform = [[[ADPlatform alloc] initRelativeToSiblingFrame:[lastPlatform frame]] autorelease];
		[platforms addObject:newPlatform];
	}
	
}

- (unsigned long)didTouchPlatformAtPoint:(CGPoint)touchPoint
{
	for(ADPlatform *platform in platforms)
	{
		if(CGRectContainsPoint(platform.frame, touchPoint))
		{
			return [[platform tweet] tweetID];
		}
	}
	return -1;
}

// Find which, if any, of the platforms the avatar collided with
// where collision = avatar's bottom line crossed over the top 
// line of one of our platforms
- (ADPlatform *)didCollideWithAvatar:(ADAvatar *)avatar
{	
	CGPoint avatarLeft = avatar.bottomLeft;
	CGPoint avatarRight = avatar.bottomRight;
	CGPoint avatarNextLeft = avatar.nextBottomLeft;
	CGPoint avatarNextRight = avatar.nextBottomRight;
	
	for(ADPlatform *platform in platforms)
	{
		// Get the line between the avatar's last position and its 
		// current position
		// if that line intersects the top line of this platform, 
		// we have an intersection
		CGPoint platformLeft = CGPointMake(platform.frame.origin.x, 
										   CGRectGetMaxY(platform.frame));
		CGPoint platformRight = CGPointMake(CGRectGetMaxX(platform.frame), 
											CGRectGetMaxY(platform.frame));
		
		if(linesIntersect(avatarLeft, avatarNextLeft, platformLeft, platformRight) 
		   || linesIntersect(avatarRight, avatarNextRight, platformLeft, platformRight))
		{
			return platform;
		}
	}
	return nil;
}

- (void)draw
{
	glColor4f(1.0, 1.0, 1.0, 1.0);
	glEnableClientState(GL_VERTEX_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	for(ADPlatform *platform in platforms)
	{

		[platform drawPlatform];
		
		// If the tweet has been favorited, draw a star over it here
		if(platform.tweet.isFavorited)
		{
			star.position = platform.frame.origin;
			[star draw];
		}
	}
}

#pragma mark Private

BOOL linesIntersect(CGPoint a1, CGPoint a2, CGPoint b1, CGPoint b2)
{
	// NOTE: This line intersection algorithm is from http://local.wasp.uwa.edu.au/~pbourke/geometry/lineline2d/ !!!
	
	float denom = ((a1.y - a2.y) * (b2.x - b1.x)) -
	((a1.x - a2.x) * (b2.y - b1.y));
	
	float nume_a = ((a1.x - a2.x) * (b1.y - a2.y)) -
	((a1.y - a2.y) * (b1.x - a2.x));
	
	float nume_b = ((b2.x - b1.x) * (b1.y - a2.y)) -
	((b2.y - b1.y) * (b1.x - a2.x));
	
	if(denom == 0.0f)
	{
		if(nume_a == 0.0f && nume_b == 0.0f)
		{
			return YES;
		}
		
		// parallel - they don't intersect
		return NO;
	}
	
	float ua = nume_a / denom;
	float ub = nume_b / denom;
	
	if(ua >= 0.0f && ua <= 1.0f && ub >= 0.0f && ub <= 1.0f)
	{
		return YES;
	}
	
	return NO;
}

@end
