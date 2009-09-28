//
//  SingletonSoundManager.h
//  Tutorial1
//
//  Created by Michael Daley on 22/05/2009.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
// This sound engine class has been created based on the OpenAL tutorial at
// http://benbritten.com/blog/2008/11/06/openal-sound-on-the-iphone/
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
#import <OpenAL/al.h>
#import <OpenAL/alc.h>
#import <AudioToolbox/AudioToolbox.h>
#import <OpenGLES/ES1/gl.h>
#import <AVFoundation/AVFoundation.h>

// Define the maximum number of sources we can use
#define kMaxSources 32

typedef struct _Vector2f {
	GLfloat x;
	GLfloat y;
} Vector2f;


@interface SingletonSoundManager : NSObject <AVAudioPlayerDelegate, AVAudioSessionDelegate> {
	
	// OpenAL context for playing sounds
	ALCcontext *context;
	
	// The device we are going to use to play sounds
	ALCdevice *device;
	
	// Array to store the OpenAL buffers we create to store sounds we want to play
	NSMutableArray *soundSources;
	NSMutableDictionary *soundLibrary;
	NSMutableDictionary *musicLibrary;
	
	// AVAudioPlayer responsible for playing background music
	AVAudioPlayer *backgroundMusicPlayer;
	
	// Background music volume which is remembered between tracks
	ALfloat backgroundMusicVolume;

}

+ (SingletonSoundManager *)sharedSoundManager;

- (id)init;
- (NSUInteger) playSoundWithKey:(NSString*)theSoundKey gain:(ALfloat)theGain pitch:(ALfloat)thePitch location:(Vector2f)theLocation shouldLoop:(BOOL)theShouldLoop;
- (void) playAVSoundEffectWithKey:(NSString *)theSoundKey;
- (void) loadSoundWithKey:(NSString*)theSoundKey fileName:(NSString*)theFileName fileExt:(NSString*)theFileExt frequency:(NSUInteger)theFrequency;
- (void) playMusicWithKey:(NSString*)theMusicKey timesToRepeat:(NSUInteger)theTimesToRepeat;
- (void) loadBackgroundMusicWithKey:(NSString*)theMusicKey fileName:(NSString*)theFileName fileExt:(NSString*)theFileExt;
- (void) setBackgroundMusicVolume:(ALfloat)theVolume;
- (void) stopPlayingMusic;
- (void) shutdownSoundManager;

@end
