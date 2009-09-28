//
//  ADTwitterLoginPage.m
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


#import "ADTwitterLoginPage.h"
#import "ADTwitterDatasource.h"


@implementation ADTwitterLoginPage

#pragma mark NSObject

- (id)init;
{
	return [super initWithNibName:@"ADTwitterLoginPage" bundle:nil];
}

- (void)dealloc;
{
	self.view = nil;
    [super dealloc];
}


#pragma mark UIViewController

- (void)setView:(UIView *)view;
{
	if (!view) {
		self.passwordField = nil;
		self.spinner = nil;
		self.usernameField = nil;
	}
	[super setView:view];
}


#pragma mark protocol UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	NSLog(@"- (BOOL)textFieldShouldReturn: %@", textField.text);
	if(textField == self.usernameField)
		[self.passwordField becomeFirstResponder];
	
	else if(textField == self.passwordField) {
		[self.passwordField resignFirstResponder];
		
		[self.spinner startAnimating];
		// TODO: run this in the bg?
		// finished entering username/pw, send creds to the twitter handler and tell it to log in
		[[ADTwitterDatasource sharedDatasource] loginWithUsername:self.usernameField.text password:self.passwordField.text];
		[[ADTwitterDatasource sharedDatasource] fetchUserTimeline];
	}
	
	return YES;
}


#pragma mark API

@synthesize passwordField = _passwordField, spinner = _spinner, usernameField = _usernameField;


@end
