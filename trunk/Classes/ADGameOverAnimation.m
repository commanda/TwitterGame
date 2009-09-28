//
//  ADGameOverAnimation.m
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


#import "ADGameOverAnimation.h"


@implementation ADGameOverAnimation

@synthesize gameText, overText;


#pragma mark NSObject

- (void)dealloc 
{
    [super dealloc];
}


#pragma mark UIViewController

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	// Set up the animation
	
	[UIView beginAnimations:@"comeIn" context:nil];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceUp)];
	[UIView setAnimationDuration:0.7f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
	
	gameText.center = CGPointMake(320/2, 100);
	overText.center = CGPointMake(320/2, 200);
	
	[UIView commitAnimations];
}

- (void)didReceiveMemoryWarning 
{
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	self.gameText = nil;
	self.overText = nil;
}


#pragma mark Animation actions

- (void)bounceUp
{
	[UIView beginAnimations:@"bounceUp" context:nil];
	
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceBackIn)];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	gameText.center = CGPointMake(320/2, gameText.center.y - 40);
	overText.center = CGPointMake(320/2, overText.center.y + 40);
	
	[UIView commitAnimations];
}

- (void)bounceBackIn
{
	
	[UIView beginAnimations:@"bounceBackIn" context:nil];
	
	[UIView setAnimationDuration:0.2f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	
	gameText.center = CGPointMake(320/2, gameText.center.y + 40);
	overText.center = CGPointMake(320/2, overText.center.y - 40);
	
	[UIView commitAnimations];
}


@end
