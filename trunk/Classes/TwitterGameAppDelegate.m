//
//  TwitterGameAppDelegate.m
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



#import "TwitterGameAppDelegate.h"

#import "ADGameOverAnimation.h"
#import "ADTwitterDatasource.h"
#import "ADTwitterLoginPage.h"
#import "EAGLView.h"
#import "MainTestViewController.h"
#import "SingletonSoundManager.h"


@interface TwitterGameAppDelegate ()
@property (nonatomic, retain) ADTwitterLoginPage *loginPage;
- (void)_startAnimationIfReady;
@end


@implementation TwitterGameAppDelegate

#pragma mark NSObject

- (void)dealloc;
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ADStatusesReceivedNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:ADImageReceivedNotificationName object:nil];
	self.loginPage = nil;
	self.window = nil;
	self.glView = nil;
	[super dealloc];
}


#pragma mark protocol UIApplicationDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application;
{
	// Register to be notified when the timeline is finished downloading
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusesReceived:) name:ADStatusesReceivedNotificationName object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(imageReceived:) name:ADImageReceivedNotificationName object:nil];
	
	
	self.loginPage = [[[ADTwitterLoginPage alloc] init] autorelease];
	[self.window addSubview:self.loginPage.view];
}

- (void)applicationWillResignActive:(UIApplication *)application;
{
	self.glView.animationInterval = 1.0 / 5.0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application;
{
	self.glView.animationInterval = 1.0 / 60.0;
}



#pragma mark API

@synthesize glView = _glView, loginPage = _loginPage, window = _window;


- (void)gameOver;
{
	[[SingletonSoundManager sharedSoundManager] playAVSoundEffectWithKey:@"end"];
	
	// Stop the background music
	[[SingletonSoundManager sharedSoundManager] stopPlayingMusic];
	
	
	// Tell the glView to quit the game loop
	[self.glView stopAnimation];
	
	// Put up the gameover view
	ADGameOverAnimation *gameOverAnimation = [[ADGameOverAnimation alloc] initWithNibName:@"ADGameOverAnimation" bundle:nil];
	[self.window addSubview:gameOverAnimation.view];
	[gameOverAnimation release];
}


#pragma mark Private API

- (void)statusesReceived:(NSNotification *)notification;
{
	NSLog(@"statusesReceived notif");
	_statusesReceived = YES;
	[self _startAnimationIfReady];
}

- (void)imageReceived:(NSNotification *)notification;
{
	NSLog(@"imageReceived notif");
	_imageReceived = YES;
	[self _startAnimationIfReady];
}

- (void)_startAnimationIfReady;
{
	if (!_imageReceived || !_statusesReceived)
		return;
	
	[self.loginPage.view removeFromSuperview];
	self.loginPage = nil;
	
	[self.window addSubview:self.glView];
	
	[self.glView initializeGame];
	self.glView.animationInterval = 1.0 / 60.0;
	[self.glView startGameLoop];	
}

@end
