// Copyright (c) 2012 quicktigame2d project
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
// 
// * Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name of the project nor the names of its contributors may be
//   used to endorse or promote products derived from this software without
//   specific prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS 
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
// OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
// WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
// OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
// 
#import "QuartzCore/QuartzCore.h"

#import "QuickTiGame2dViewController.h"
#import "QuickTiGame2dView.h"
#import "QuickTiGame2dScene.h"
#import "QuickTiGame2dSprite.h"
#import "QuickTiGame2dParticles.h"
#import "QuickTiGame2dTransform.h"

@interface QuickTiGame2dViewController ()
- (void)setupTestSuite;
- (void)startAnimation;
- (void)stopAnimation;
- (void)updateTouchId;
- (void)fireMotionEvent:(NSSet *)touches withEvent:(UIEvent *) event withAction:(NSInteger) action;
- (BOOL)onMotionEvent:(float*)params;
- (void)onLoadNotification:(NSNotification*)notification;

@property (nonatomic, retain) EAGLContext *context;
@property (nonatomic, assign) CADisplayLink *displayLink;
@end

@implementation QuickTiGame2dViewController

@synthesize animating, context, displayLink, timerType;

- (void)awakeFromNib
{
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
    
	self.context = aContext;
	[aContext release];
	
	QuickTiGame2dView* eview = (QuickTiGame2dView *)self.view;
	
	[eview enableRetina:TRUE];
    [eview setContext:context];
    [eview setFramebuffer];
        
    animating = FALSE;
    displayLinkInterval = 1;
    self.displayLink = nil;
    
    animationTimerInterval = 1.0 / 60.0;
    
    // if TIMER_DISPLAYLINK, use CADisplayLink instead of NSTimer
    timerType = TIMER_DEFAULT;
	
	// enable user interaction (touch event)
	[self.view setUserInteractionEnabled:TRUE];
	[self.view setMultipleTouchEnabled:TRUE];
	eview.eventDelegate = self;
    touchIdMaster = [[NSMutableDictionary alloc] init];
	nextTouchId = 0;
    
    if (engine == nil) engine = [[QuickTiGame2dEngine alloc] init];


}

- (void)dealloc
{
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
	[touchIdMaster release];
    [engine release];
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
	[super viewDidUnload];

    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
	
	[touchIdMaster removeAllObjects];
	touchIdMaster = nil;
}

- (NSInteger)displayLinkInterval
{
    return displayLinkInterval;
}

- (void)setDisplayLinkInterval:(NSInteger)frameInterval
{
    if (frameInterval >= 1)
    {
        displayLinkInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (NSTimeInterval)animationTimerInterval {
    return animationTimerInterval;
}

- (void)setAnimationTimerInterval:(NSTimeInterval)frameInterval {
    animationTimerInterval = frameInterval;
    
    if (animating)
    {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void)startAnimation
{
    if (!animating)
    {
        if (timerType == TIMER_DISPLAYLINK) {
            CADisplayLink *aDisplayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
            [aDisplayLink setFrameInterval:displayLinkInterval];
            [aDisplayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            self.displayLink = aDisplayLink;
        } else {
            // this code is lifted from cocos2d-iphone
            // it allows the use of adding UIKit views on top of the GLView and having animations still
            // run while the user interacts with the UIKit views
            
            NSAssert( animationTimer == nil, @"animationTimer must be nil. Calling startAnimation twice?");
            
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationTimerInterval target:self selector:@selector(drawFrame) userInfo:nil repeats:YES];
            
            //
            // If you want to attach the opengl view into UIScrollView
            // uncomment this line to prevent 'freezing'.
            // It doesn't work on with the Fast Timer
            //
            [[NSRunLoop currentRunLoop] addTimer:animationTimer
                                         forMode:NSRunLoopCommonModes];            
            
            animating = TRUE;
        }
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (timerType == TIMER_DISPLAYLINK) {
            [self.displayLink invalidate];
            self.displayLink = nil;
        } else {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        animating = FALSE;
    }
}

- (void)drawFrame
{
    [(QuickTiGame2dView *)self.view setFramebuffer];

    [engine drawFrame];
		
    [(QuickTiGame2dView *)self.view presentFramebuffer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)onLoadNotification:(NSNotification*)notification {
    NSLog(@"[INFO] receive notification: %@", notification.name);
}

- (void)setupTestSuite {
    
    [QuickTiGame2dEngine setDebug:TRUE];
            
    [[QuickTiGame2dEngine sharedNotificationCenter] addObserver:self selector:@selector(onLoadNotification:) name:@"onLoad" object:nil];
    
    //engine.width = 320;
    //engine.height = 480;
    
    //[QuickTiGame2dEngine setTextureFilter:GL_NEAREST];
    
    QuickTiGame2dScene* scene = [[QuickTiGame2dScene alloc] init];
    //[scene color:0.62 green:0.66 blue:0.32];
    [engine pushScene:scene];
    
    sprite1 = [[QuickTiGame2dSprite alloc] init];
    sprite1.image = @"control_button_A.png";
    [sprite1 updateImageSize];
    sprite1.x = 50;
    sprite1.y = 200;
    sprite1.z = 1;
    
    sprite2 = [[QuickTiGame2dSprite alloc] init];
    sprite2.image = @"control_button_B.png";
    [sprite2 updateImageSize];
    sprite2.x = 100;
    sprite2.y = 100;
    sprite2.z = 2;

    // sprite2.followParentTransformPosition = FALSE;
    // sprite2.followParentTransformColor    = FALSE;
    // sprite2.followParentTransformRotation = FALSE;
    // sprite2.followParentTransformScale    = FALSE;
    // sprite2.followParentTransformSize     = FALSE;
    
    [sprite1 addChildWithRelativePosition:sprite2];
    
    particle1 = [[QuickTiGame2dParticles alloc] init];
    particle1.image = @"magic.pex";
    [particle1 updateImageSize];
    particle1.x = 300, 
    particle1.y = 300;
    particle1.z = 3;
    
    [scene addSprite:sprite1];
    [scene addSprite:sprite2];
    [scene addSprite:particle1];
    
    [scene release];
}

- (BOOL)onMotionEvent:(float*)params {
    if (params[1] == MOTION_EVENT_ACTION_DOWN) {
        QuickTiGame2dTransform* transform = [[QuickTiGame2dTransform alloc] init];
        
        transform.x = [NSNumber numberWithInt:200];
        transform.y = [NSNumber numberWithInt:200];
        transform.scaleX = [NSNumber numberWithInt:2];
        transform.scaleY = [NSNumber numberWithInt:4];
        [transform rotate:45];
        [transform color:1 green:0 blue:0];
        transform.duration = 1000;
        
        [sprite1 transform:transform];
        
        [transform release];
    }
    if (params[1] == MOTION_EVENT_ACTION_UP) {
        
    }
    return FALSE;
}


- (void)onLoad {
	[engine onLoad:((QuickTiGame2dView*)self.view).width height:((QuickTiGame2dView*)self.view).height];
    [engine start];
    
    [self setupTestSuite];
}

- (void)onGainedFocus {
    [engine onGainedFocus];
    [self startAnimation];
}

- (void)onLostFocus {
    [engine pause];
    [engine onLostFocus];
    [self stopAnimation];
}

- (void)onDispose {
    [sprite1 release];
    [sprite2 release];
    [particle1 release];
    
    [engine stop];
    [engine onDispose];
}

/*
 * Handle touch events
 */
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	for (UITouch *touch in touches) {
		if ([touchIdMaster objectForKey:touch] == nil) {
			[touchIdMaster setObject:[NSNumber numberWithInteger:nextTouchId] forKey:[NSValue valueWithPointer:touch]];
			nextTouchId++;
		}
	}
	[self fireMotionEvent: touches withEvent:event withAction: MOTION_EVENT_ACTION_DOWN];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	[self fireMotionEvent: touches withEvent:event withAction: MOTION_EVENT_ACTION_MOVE];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	[self fireMotionEvent: touches withEvent:event withAction: MOTION_EVENT_ACTION_UP];
	for (UITouch *touch in touches) {
		if ([touchIdMaster objectForKey:[NSValue valueWithPointer:touch]] != nil) {
			[touchIdMaster removeObjectForKey:[NSValue valueWithPointer:touch]];
		}
	}
	[self updateTouchId];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	[self fireMotionEvent: touches withEvent:event withAction: MOTION_EVENT_ACTION_CANCEL];
	for (UITouch *touch in touches) {
		if ([touchIdMaster objectForKey:[NSValue valueWithPointer:touch]] != nil) {
			[touchIdMaster removeObjectForKey:[NSValue valueWithPointer:touch]];
		}
	}
	[self updateTouchId];
}

/*
 * Fire motion event
 */
- (void)fireMotionEvent:(NSSet *)touches withEvent:(UIEvent *)event withAction:(NSInteger) action {
	for (UITouch *touch in touches) {
		NSNumber *touchId = [touchIdMaster objectForKey:[NSValue valueWithPointer:touch]];
		CGPoint location = [touch locationInView:self.view];
		
		if (((QuickTiGame2dView*)self.view).isRetina) {
			location.x = location.x * RETINA_SCALE_FACTOR;
			location.y = location.y * RETINA_SCALE_FACTOR;
		}
		
		NSTimeInterval uptimeSec  = [QuickTiGame2dEngine uptime];
		NSTimeInterval uptimeMsec = (uptimeSec - floor(uptimeSec)) * 1000; 
		touchEventParamCache[0] = [touchId intValue];
		touchEventParamCache[1] = action;
		touchEventParamCache[2] = location.x;
		touchEventParamCache[3] = location.y;
		touchEventParamCache[4] = floor(uptimeSec);  // event time since startup (sec)
		touchEventParamCache[5] = floor(uptimeMsec); // event time since startup (msec)
		touchEventParamCache[6] = 0; // device id
		touchEventParamCache[7] = 0; // source id
		
		[self onMotionEvent:touchEventParamCache];
	}
}

- (void)updateTouchId {
	if ([touchIdMaster count] == 0) {
		nextTouchId = 0;
	}
}
@end
