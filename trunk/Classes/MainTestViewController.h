//
//  MainTestViewController.h
//  TwitterGame
//
//  Created by Amanda Wixted on 6/27/09.
//  Copyright 2009 Zynga. All rights reserved.
//

// NOTE: This is our crazy UIKit prototype!  See the switch in TwitterGame_Prefix.pch!

#import <UIKit/UIKit.h>

#define kUpdateFrequency 60.0f
#define kGravityAcceleration -0.8
#define kJumpyAcceleration 0.016

@interface MainTestViewController : UIViewController<UIAccelerometerDelegate> {
	UIImageView *imgView;
	
	NSTimeInterval	touchStartTime;
	CGPoint			touchStartPoint;
	
	NSMutableArray *platforms;
	
	CGFloat yVelocity;
	
	BOOL canJump;
}

@property (nonatomic, retain) UIImageView *imgView;

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;

@end
