//
//  EAGLView.m
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




#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGLDrawable.h>

#import "EAGLView.h"
#import "ADGameController.h"
#import "SingletonSoundManager.h"

#define USE_DEPTH_BUFFER 0

// A class extension to declare private methods
@interface EAGLView ()

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) NSTimer *animationTimer;

- (BOOL) createFramebuffer;
- (void) destroyFramebuffer;

@end


@implementation EAGLView

@synthesize context;
@synthesize animationTimer;
@synthesize animationInterval;


#pragma mark NSObject

//The GL view is stored in the nib file. When it's unarchived it's sent -initWithCoder:
- (id)initWithCoder:(NSCoder*)coder {
    
    if ((self = [super initWithCoder:coder])) {
        // Get the layer
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = YES;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
        
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        
        if (!context || ![EAGLContext setCurrentContext:context]) {
            [self release];
            return nil;
        }
        
        animationInterval = 1.0 / 60.0;
		
		
		// Init sound
		SingletonSoundManager *sharedSoundManager = [SingletonSoundManager sharedSoundManager];
		[sharedSoundManager loadSoundWithKey:@"jump" fileName:@"jump" fileExt:@"mp3" frequency:22050];
		[sharedSoundManager loadSoundWithKey:@"bump" fileName:@"bump" fileExt:@"mp3" frequency:22050];
		[sharedSoundManager loadSoundWithKey:@"end" fileName:@"end" fileExt:@"mp3" frequency:22050];
		[sharedSoundManager loadSoundWithKey:@"hit" fileName:@"hit" fileExt:@"mp3" frequency:22050];
		[sharedSoundManager loadSoundWithKey:@"star" fileName:@"star" fileExt:@"mp3" frequency:22050];
		
		[sharedSoundManager loadBackgroundMusicWithKey:@"theme" fileName:@"theme" fileExt:@"mp3"];
    }
    return self;
}

- (void)dealloc {
    
    [self stopAnimation];
    
    if ([EAGLContext currentContext] == context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];  
	[gameController release];
	
    [super dealloc];
}



// You must implement this method
+ (Class)layerClass {
    return [CAEAGLLayer class];
}


#pragma mark API 

- (void) initializeGame
{
	gameController = [[ADGameController alloc] init];
	[[SingletonSoundManager sharedSoundManager] playMusicWithKey:@"theme" timesToRepeat:-1];
}


- (void)mainLoop {
	
	[gameController update];
    
	// OpenGL pre-rendering stuff
	{
		
		glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
		glViewport(0, 0, backingWidth, backingHeight);
		
		//#9AE4E8 the twitter default background color
		glClearColor(0.59f, 0.89f, 0.90f, 1.0f);
		glClear(GL_COLOR_BUFFER_BIT);
		
		glMatrixMode(GL_PROJECTION);
		glLoadIdentity();
		glOrthof(0.0, 320.0, 0.0, 480.0, -1.0, 1.0);

		glEnable(GL_BLEND);
		glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
	}

	[gameController draw];
	
	// OpenGL rendering stuff
	{		
		glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
		[context presentRenderbuffer:GL_RENDERBUFFER_OES];
	}
}


- (void)startGameLoop {
	[EAGLContext setCurrentContext:context];
	self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval 
														   target:self 
														 selector:@selector(mainLoop) 
														 userInfo:nil 
														  repeats:YES];
}


- (void)stopAnimation {
    self.animationTimer = nil;
}


- (void)setAnimationTimer:(NSTimer *)newTimer {
    [animationTimer invalidate];
    animationTimer = newTimer;
}


#pragma mark UIView

- (void)layoutSubviews {
    [EAGLContext setCurrentContext:context];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self mainLoop];
}


#pragma mark UIResponder

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event {
	
	UITouch *touch = [touches anyObject];
	
	CGPoint touchStartPoint = [touch locationInView:self];
	[gameController touchBegan:touch atPoint:touchStartPoint];
	
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event {
	UITouch *touch = [touches anyObject];
	CGPoint touchEnd = [touch locationInView:self];
	
	[gameController touchEnded:touch atPoint:touchEnd];
}


#pragma mark EAGLView boilerplate

- (BOOL)createFramebuffer {
    
    glGenFramebuffersOES(1, &viewFramebuffer);
    glGenRenderbuffersOES(1, &viewRenderbuffer);
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, viewFramebuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, viewRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, viewRenderbuffer);
    
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);
    
    if (USE_DEPTH_BUFFER) {
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
    }
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}


- (void)destroyFramebuffer {
    
    glDeleteFramebuffersOES(1, &viewFramebuffer);
    viewFramebuffer = 0;
    glDeleteRenderbuffersOES(1, &viewRenderbuffer);
    viewRenderbuffer = 0;
    
    if(depthRenderbuffer) {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
}


@end
