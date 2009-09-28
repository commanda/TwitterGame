//
//  MainTestViewController.m
//  TwitterGame
//
//  Created by Amanda Wixted on 6/27/09.
//  Copyright 2009 Zynga. All rights reserved.
//
//	This class is our quick proof-of-concept for a profile-view platform game.
//  Turn on USE_UIVIEWS in the .pch to see how it worked.

#import "MainTestViewController.h"
#import <CoreGraphics/CGGeometry.h>

@implementation MainTestViewController

@synthesize imgView;


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
#if USE_UIVIEWS
	imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Picture_3.png"]];
	[self.view addSubview:imgView];
	
	imgView.center = CGPointMake(160.0, 100.0);
	
	platforms = [[NSMutableArray alloc] initWithCapacity:5];
	
	// Make the ground platform
	UIView *ground = [[UIView alloc] initWithFrame:CGRectMake(-20, 470, 380, 200)];
	[ground setBackgroundColor:[UIColor magentaColor]];
	[self.view addSubview:ground];
	[platforms addObject:ground];
					  
	
	srandom(time(NULL));
	for(int i = 0; i < 5; i++)
	{
		// Set up a platform.
		CGFloat x, y;
		x = random() % 320;
		y = random() % 480;
		UITextView *platform1 = [[UITextView alloc] initWithFrame:CGRectMake(x, y, 90.0, 40.0)];
		platform1.backgroundColor = [UIColor blackColor];
		[platform1 setTextColor:[UIColor whiteColor]];
		[platform1 setText:@"the poop is coming out"];
		[platform1 setFont:[UIFont boldSystemFontOfSize:8.0]];
		platform1.editable = NO;
		platform1.scrollEnabled = NO;
		
		[self.view addSubview:platform1];
		[platforms addObject:platform1];
	}
	[NSTimer scheduledTimerWithTimeInterval:(1.0 / kUpdateFrequency) 
									 target:self 
								   selector:@selector(update:) 
								   userInfo:nil 
									repeats:YES];
	
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:1.0 / kUpdateFrequency];
	[[UIAccelerometer sharedAccelerometer] setDelegate:self];
#endif
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration
{
	
	CGPoint center = imgView.center;
	center.x += 8.0 * acceleration.x;
	
	if(center.x < 0.0) {
		center.x = 0.0;
	}
	if(center.x > 320.0) {
		center.x = 320.0;
	}
	
	imgView.center = center;
}


- (void)update:(NSTimer*)timer {
	CGPoint center = imgView.center;
	
	for(UIView *platform1 in platforms)
	{
			
		if(CGRectIntersectsRect(platform1.frame, imgView.frame) && yVelocity <= 0.0) {
			center.y = platform1.frame.origin.y - (.5 * imgView.frame.size.height);
			yVelocity = 0.0;
			canJump = YES;
			imgView.center = center;
			return;
		}
	}
	
	yVelocity += kGravityAcceleration;
	center.y -= yVelocity;
	
	
	imgView.center = center;
}


- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch *touch = [touches anyObject];
	touchStartPoint = [touch locationInView:self.view];
	touchStartTime  = [touch timestamp];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchEnd = [touch locationInView:self.view];
	
	float distance = touchStartPoint.y - touchEnd.y;
	float time = touch.timestamp - touchStartTime;
	float swipeSpeed = distance / time;
	
	// If it looks like an upward swipe, do a jump!
	if(distance > 40.0) {
		// Do a jumpy.
		if(canJump) {
			yVelocity = fminf(swipeSpeed * kJumpyAcceleration, 20.0);
			canJump = NO;
		}
	}
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}



- (void)dealloc {
	[imgView release];
	
    [super dealloc];
}


@end
