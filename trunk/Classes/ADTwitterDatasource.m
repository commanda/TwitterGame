//
//  ADTwitterDatasource.m
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

#import "ADTwitterDatasource.h"


@implementation ADTweet

@synthesize text, isFavorited, tweetID;

@end




// private properties
@interface ADTwitterDatasource ()
@property (nonatomic, retain) NSString *statusRequestConnID;
@property (nonatomic, retain) NSString *favoriteTweetConnID;
@property (nonatomic, retain) NSString *avatarImgConnID;
@property (nonatomic, retain) NSString *userInfoConnID;
@end


static ADTwitterDatasource *sharedDatasource = nil;




@implementation ADTwitterDatasource

@synthesize tweets, userAvatar, username, password, userInfo, statusRequestConnID, favoriteTweetConnID, avatarImgConnID, userInfoConnID;


#pragma mark NSObject


- (void)dealloc 
{
	
	[tweets release];
	[twitterEngine release];
	[userInfo release];
	[statusRequestConnID release];
	[favoriteTweetConnID release];
	[avatarImgConnID release];
	[userInfoConnID release];
	
	[super dealloc];
}


#pragma mark API 

+ (ADTwitterDatasource*)sharedDatasource
{
	if(!sharedDatasource)
	{
		sharedDatasource = [[ADTwitterDatasource alloc] init];
	}
	
	return sharedDatasource;
}

- (ADTweet*)tweetForTweetID:(unsigned long)tweetID
{
	for(ADTweet *tweet in tweets)
	{
		if(tweet.tweetID == tweetID)
		{
			return tweet;
		}
	}
	
	return nil;
}

-(void) toggleFavorite:(ADTweet *)tweetToFavorite 
{
	self.favoriteTweetConnID = [twitterEngine markUpdate:tweetToFavorite.tweetID asFavorite:!tweetToFavorite.isFavorited];
	tweetToFavorite.isFavorited = !tweetToFavorite.isFavorited;
}


-(void) printRequestIDs
{

	NSLog(@"favoriteTweetConnID: %@", self.favoriteTweetConnID);
	NSLog(@"statusRequestConnID: %@", self.statusRequestConnID);
	NSLog(@"avatarImgConnID: %@", self.avatarImgConnID);
	NSLog(@"userInfoConnID: %@", self.userInfoConnID);
}


// Return both the text of the tweet and the current index
// (TODO: this might not be thread-safe because it's possible that statusesReceived is changing the tweets array)
- (ADTweet *)nextTweet
{
	if(currentIndex >= [tweets count])
	{
		return nil;
	}
	
	ADTweet *tweet =[tweets objectAtIndex:currentIndex];
	currentIndex++;

	// TODO: implement pulling down more tweets
	// If we are three-quarters the way through our current batch of tweets, fetch a new set
//	if(currentIndex == floor(NUM_TWEETS_TO_FETCH * .75))
//	{
//		[self fetchUserTimeline];
//	}
	
	return tweet;
}

- (void) startAvatarImageDL
{
	NSLog(@"startAvatarImageDL");
	self.avatarImgConnID = [twitterEngine getImageAtURL:[self.userInfo objectForKey:@"profile_image_url"]];
}
	
- (void) getUserInformation
{
	NSLog(@"getUserInformation");
	self.userInfoConnID = [twitterEngine getUserInformationFor:username];
}

- (void) loginWithUsername:(NSString *)theusername password:(NSString *)thepassword
{
	NSLog(@"loginWithUsername");
	if([theusername length] == 0)
	{
		theusername = defaultUsername;
	}
	if([thepassword length] == 0)
	{
		thepassword = defaultPassword;
	}
	self.username = theusername;
	self.password = thepassword;
    
	
    // Create a TwitterEngine and set our login details.
    twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
    [twitterEngine setUsername:username password:password];
    
	// Notify listeners that login has happened
	[[NSNotificationCenter defaultCenter] postNotificationName:@"loggedIn" object:self];
	
	// Get the user's information so we have it on hand for the rest of the app lifetime
	[self getUserInformation];
}



- (void) fetchUserTimeline
{
	NSLog(@"fetchUserTimeline");
    // Get updates from people the authenticated user follows.
	

	// If we have already fetched tweets, we will get the timeline going further back in time
	if([tweets count] > 0)
	{
		self.statusRequestConnID = [twitterEngine getFollowedTimelineSinceID:0 startingAtPage:++lastPageFetched count:NUM_TWEETS_TO_FETCH];
	}
	else 
	{
		lastPageFetched = 0;
		self.statusRequestConnID = [twitterEngine getFollowedTimelineSinceID:0 startingAtPage:0 count:NUM_TWEETS_TO_FETCH];
	}
}


#pragma mark MGTwitterEngineDelegate methods

// MGTwitterEngineDelegate methods


- (void)requestFailed:(NSString *)requestIdentifier withError:(NSError *)error
{
	
    NSLog(@"Twitter request failed! (requestIdentifier: %@) Error: %@ (%@)", 
          requestIdentifier, 
          [error localizedDescription], 
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	
	[self printRequestIDs];
	

	// if we're in test user mode (using the default test account), make pretend tweets
	if([self.statusRequestConnID isEqualToString:requestIdentifier] && [self.username isEqualToString:defaultUsername])
	{
		NSMutableArray *fakeStatuses = [NSMutableArray arrayWithCapacity:100];
		for(int i = 0; i < 100; i++)
		{
			NSMutableDictionary *fakeDict = [NSMutableDictionary dictionaryWithCapacity:5];
			
			NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithCapacity:1];
			[userDict setObject:@"fakeUser" forKey:@"screen_name"];
			
			[fakeDict setObject:userDict forKey:@"user"];
			[fakeDict setObject:@"fail whale fail whale fail whale" forKey:@"text"];
			[fakeDict setObject:[NSNumber numberWithLongLong:0] forKey:@"id"];
			[fakeDict setObject:@"false" forKey:@"favorited"];
			
			[fakeStatuses addObject:fakeDict];
		}
		[self statusesReceived:fakeStatuses forRequest:self.statusRequestConnID];
	}
	else if(([requestIdentifier isEqualToString:self.userInfoConnID]) 
			|| ([requestIdentifier isEqualToString:self.avatarImgConnID])
			)
	{
		// Regardless of whether they're trying to log in with a real account or the default,
		// give them David's avatar pic.
		[self imageReceived:[UIImage imageNamed:@"Picture_3.png"] forRequest:requestIdentifier];
	}
	else 
	{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"requestFailed" object:self];
	}
}

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
}



- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier
{
	NSLog(@"statusesReceived");
	
	//@synchronized(tweets)
	{
			
		NSLog(@"identifier: %@", identifier);
		[self printRequestIDs];
		
		if([identifier isEqualToString:self.statusRequestConnID])
		{
			
			
			// Store them in the tweets collection
			self.tweets = [[NSMutableArray alloc] initWithCapacity:100];
			currentIndex = 0;
			
			for(NSDictionary *dict in statuses)
			{
				NSString *message = [NSString stringWithFormat:@"%@: %@", [[dict objectForKey:@"user"] objectForKey:@"screen_name"],[dict objectForKey:@"text"]];
				
				// Strip out all the \n's (lookin at you, @biorhythmist!).
				NSString *strippedString = [message stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
				ADTweet *newTweet = [[ADTweet alloc] init];
				[newTweet setText:strippedString];
				[newTweet setTweetID:[[dict objectForKey:@"id"] longLongValue]];
				[newTweet setIsFavorited:[[dict objectForKey:@"favorited"] isEqualToString:@"true"]];
				[tweets addObject:newTweet];
				[newTweet release];
			}
			
			// TODO: find out whether this needs to be forced to run in the main thread
			[self performSelectorOnMainThread:@selector(_postNotification) withObject:nil waitUntilDone:NO];
		}
	}
}


- (void)userInfoReceived:(NSArray *)theUserInfo forRequest:(NSString *)identifier
{
	
    NSLog(@"Got user info");
	
	self.userInfo = [theUserInfo objectAtIndex:0];
	
	
	// Start the user's avatar downloading
	[self performSelectorOnMainThread:@selector(startAvatarImageDL) withObject:nil waitUntilDone:NO];
}


- (void)imageReceived:(UIImage *)image forRequest:(NSString *)identifier
{
	
    NSLog(@"Got an image");
	
	self.userAvatar = image;
	
	// Notify listeners that the profile image has arrived
	[[NSNotificationCenter defaultCenter] postNotificationName:ADImageReceivedNotificationName object:self];
	
}



#pragma mark private

- (void)_postNotification {
	[[NSNotificationCenter defaultCenter] postNotificationName:ADStatusesReceivedNotificationName object:self];
}

NSString *ADStatusesReceivedNotificationName = @"statusesReceived";
NSString *ADImageReceivedNotificationName = @"imageReceived";
NSString *defaultUsername = @"rmrfstar";
NSString *defaultPassword = @"tooobvious";

@end



