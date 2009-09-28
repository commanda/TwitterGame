//
//  ADTwitterDatasource.h
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
#import "MGTwitterEngine.h"

#define NUM_TWEETS_TO_FETCH (100)

@class ADTweet;

@interface ADTwitterDatasource : NSObject <MGTwitterEngineDelegate> {
	NSMutableArray *tweets;
	MGTwitterEngine *twitterEngine;
	NSInteger currentIndex;
	UIImage *userAvatar;
	NSString *username;
	NSString *password;
	NSDictionary *userInfo;
	
	NSInteger lastPageFetched;
	
	// Connection identifiers
	NSString *favoriteTweetConnID;
	NSString *statusRequestConnID;
	NSString *avatarImgConnID;
	NSString *userInfoConnID;
}

@property (nonatomic, retain) NSMutableArray *tweets;
@property (nonatomic, retain) UIImage *userAvatar;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *password;
@property (nonatomic, retain) NSDictionary *userInfo;



+ (ADTwitterDatasource*)sharedDatasource;
- (ADTweet*)nextTweet;
- (void) loginWithUsername:(NSString *)username password:(NSString *)password;
- (void) fetchUserTimeline;
- (ADTweet*)tweetForTweetID:(unsigned long)tweetID;
-(void) toggleFavorite:(ADTweet *)tweetToFavorite;

 
extern NSString *ADStatusesReceivedNotificationName, *ADImageReceivedNotificationName, *defaultUsername, *defaultPassword;

@end


@interface ADTweet : NSObject
{
	NSString *text;
	BOOL isFavorited;
	unsigned long tweetID;
}

@property (nonatomic, copy) NSString *text;
@property BOOL isFavorited;
@property unsigned long tweetID;


@end
