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
#import "ComGooglecodeQuicktigame2dGameViewProxy.h"
#import "ComGooglecodeQuicktigame2dGameView.h"
#import "ComGooglecodeQuicktigame2dSpriteProxy.h"
#import "ComGooglecodeQuicktigame2dTransformProxy.h"
#import "QuickTiGame2dConstant.h"
#import "QuickTiGame2dEngine.h"

@implementation ComGooglecodeQuicktigame2dGameViewProxy

- (id)init {
    self = [super init];
    if (self != nil) {
        sceneStack = [[ArrayStackQueue alloc] init];
        screenInfoCache = [[NSMutableDictionary alloc] init];
        cameraInfoCache = [[NSMutableDictionary alloc] init];
        orientation = UIInterfaceOrientationPortrait;
        
        previousScene = nil;
    }
    return self;
}

- (void)dealloc {
    [sceneStack release];
    [screenInfoCache release];
    [cameraInfoCache release];
    [super dealloc];
}

-(void)viewDidAttach {
    [(ComGooglecodeQuicktigame2dGameView*)self.view attachContext];
    
    [[QuickTiGame2dEngine sharedNotificationCenter] addObserver:self selector:@selector(onNotification:) name:nil object:nil];
}

-(void)viewWillDetach {
    [(ComGooglecodeQuicktigame2dGameView*)self.view detachContext];
    
    [[QuickTiGame2dEngine sharedNotificationCenter] removeObserver:self];
}

- (void)onNotification:(NSNotification*)notification {
    NSString* lowerCaseEventName = [notification.name lowercaseString];
    if ([notification.name isEqualToString:@"onDrawFrame"]) {
        lowerCaseEventName = @"enterframe";
    }

    if ([notification.name isEqualToString:@"onSuspend"]) {
        [(ComGooglecodeQuicktigame2dGameView*)self.view stop];
    }
    if ([notification.name isEqualToString:@"onResume"]) {
        [(ComGooglecodeQuicktigame2dGameView*)self.view start];
    }
    
    if ([notification.name isEqualToString:@"onActivateScene"]) {
        if ([[sceneStack top] scene] == [notification.userInfo objectForKey:@"source"]) {
            [[sceneStack top] onActivate];
        }
        return;
    }
    if ([notification.name isEqualToString:@"onDeactivateScene"]) {
        if ([previousScene scene] == [notification.userInfo objectForKey:@"source"]) {
            [previousScene onDeactivate];
            previousScene = nil;
        }
        return;
    }
    
    [self fireEvent:lowerCaseEventName withObject:notification.userInfo propagate:NO];
    
    [(ComGooglecodeQuicktigame2dSceneProxy*)[self topScene:nil] onNotification:lowerCaseEventName userInfo:notification.userInfo];
}

#pragma Public APIs

- (void)loadTexture:(id)args {
    ENSURE_SINGLE_ARG(args, NSString);
    NSString* name = [[TiUtils stringValue:args] retain];
    [QuickTiGame2dEngine commitLoadTexture:name tag:nil];
    [name release];
}

- (void)loadTextureWithTag:(id)args {
    NSString* name = [[TiUtils stringValue:[args objectAtIndex:0]] retain];
    NSString* tag  = [[TiUtils stringValue:[args objectAtIndex:1]] retain];
    [QuickTiGame2dEngine commitLoadTexture:name tag:tag];
    [name release];
    [tag release];
}

- (void)unloadTexture:(id)args {
    ENSURE_SINGLE_ARG(args, NSString);
    NSString* name = [[TiUtils stringValue:args] retain];
    [QuickTiGame2dEngine commitUnloadTexture:name tag:nil];
    [name release];
}

- (void)unloadTextureByTag:(id)args {
    ENSURE_SINGLE_ARG(args, NSString);
    NSString* tag = [[TiUtils stringValue:args] retain];
    [QuickTiGame2dEngine commitUnloadTexture:nil tag:tag];
    [tag release];
}

- (id)uptime:(id)args {
    return NUMDOUBLE([QuickTiGame2dEngine uptime]);
}

- (id)pushScene:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dSceneProxy);
    previousScene = [sceneStack top];
    [sceneStack push:args];
    [(ComGooglecodeQuicktigame2dGameView*)self.view pushScene:[args scene]];
    
    return [self topScene:nil];
}

- (id)popScene:(id)args {
    previousScene = [sceneStack pop];
    [(ComGooglecodeQuicktigame2dGameView*)self.view popScene];
    return previousScene;
}

- (id)replaceScene:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dSceneProxy);
    
    previousScene = [sceneStack pop];
    [sceneStack push:args];
    [(ComGooglecodeQuicktigame2dGameView*)self.view replaceScene:[args scene]];
    
    return [self topScene:nil];
}

- (void)startCurrentScene:(id)args {
    [((ComGooglecodeQuicktigame2dGameView*)self.view).game startCurrentScene];
}

- (id)topScene:(id)args {
    return [sceneStack top];
}

-(void)start:(id)args {
    ENSURE_UI_THREAD_0_ARGS;
    [(ComGooglecodeQuicktigame2dGameView*)self.view start];
}

-(void)pause:(id)args {
    [(ComGooglecodeQuicktigame2dGameView*)self.view pause];
}

-(void)stop:(id)args {
    ENSURE_UI_THREAD_0_ARGS;
    [(ComGooglecodeQuicktigame2dGameView*)self.view stop];
}

-(id)screen {
    ComGooglecodeQuicktigame2dGameView* _view = (ComGooglecodeQuicktigame2dGameView*)self.view;
    [screenInfoCache setValue:NUMINT(_view.gamewidth)  forKey:@"width"];
    [screenInfoCache setValue:NUMINT(_view.gameheight) forKey:@"height"];
    [screenInfoCache setValue:NUMINT(_view.framebufferWidth)  forKey:@"framebufferWidth"];
    [screenInfoCache setValue:NUMINT(_view.framebufferHeight) forKey:@"framebufferHeight"];
    [screenInfoCache setValue:NUMINT(_view.gameviewportWidth)  forKey:@"viewportWidth"];
    [screenInfoCache setValue:NUMINT(_view.gameviewportHeight) forKey:@"viewportHeight"];
    return screenInfoCache;
}

-(void)setScreen:(id)args {
    ENSURE_SINGLE_ARG(args, NSDictionary);
    NSInteger width  = [TiUtils intValue:@"width"  properties:args  def:0];
    NSInteger height = [TiUtils intValue:@"height"  properties:args def:0];
    
    NSInteger viewportWidth  = [TiUtils intValue:@"viewportWidth"   properties:args def:0];
    NSInteger viewportHeight = [TiUtils intValue:@"viewportHeight"  properties:args def:0];
    
    if (width  > 0) ((ComGooglecodeQuicktigame2dGameView*)self.view).gamewidth  = width;
    if (height > 0) ((ComGooglecodeQuicktigame2dGameView*)self.view).gameheight = height;
    
    if (viewportWidth  > 0) ((ComGooglecodeQuicktigame2dGameView*)self.view).gameviewportWidth  = viewportWidth;
    if (viewportHeight > 0) ((ComGooglecodeQuicktigame2dGameView*)self.view).gameviewportHeight = viewportHeight;
}

-(id)camera {
    ComGooglecodeQuicktigame2dGameView* _view = (ComGooglecodeQuicktigame2dGameView*)self.view;
    CameraInfo info = [_view getCamera];
    
    [cameraInfoCache setValue:NUMFLOAT(info.eyeX)   forKey:@"eyeX"];
    [cameraInfoCache setValue:NUMFLOAT(info.eyeY)   forKey:@"eyeY"];
    [cameraInfoCache setValue:NUMFLOAT(info.eyeZ)   forKey:@"eyeZ"];
    [cameraInfoCache setValue:NUMFLOAT(info.centerX)   forKey:@"centerX"];
    [cameraInfoCache setValue:NUMFLOAT(info.centerY)   forKey:@"centerY"];
    [cameraInfoCache setValue:NUMFLOAT(info.centerZ)   forKey:@"centerZ"];
    [cameraInfoCache setValue:NUMFLOAT(info.zNear)  forKey:@"zNear"];
    [cameraInfoCache setValue:NUMFLOAT(info.zFar)   forKey:@"zFar"];
    [cameraInfoCache setValue:NUMFLOAT(info.upX)    forKey:@"upX"];
    [cameraInfoCache setValue:NUMFLOAT(info.upY)    forKey:@"upY"];
    [cameraInfoCache setValue:NUMFLOAT(info.upZ)    forKey:@"upZ"];
    
    return cameraInfoCache;
}

-(void)setCamera:(id)args {
    ENSURE_SINGLE_ARG(args, NSDictionary);
    ComGooglecodeQuicktigame2dGameView* _view = (ComGooglecodeQuicktigame2dGameView*)self.view;
    
    float eyeX  = [TiUtils floatValue:@"eyeX" properties:args  def:0];
    float eyeY  = [TiUtils floatValue:@"eyeY" properties:args  def:0];
    float eyeZ  = [TiUtils floatValue:@"eyeZ" properties:args  def:0];
    float centerX  = [TiUtils floatValue:@"centerX" properties:args  def:0];
    float centerY  = [TiUtils floatValue:@"centerY" properties:args  def:0];
    float centerZ  = [TiUtils floatValue:@"centerZ" properties:args  def:0];

    CameraInfo info = [_view getCamera];
    if ([args objectForKey:@"eyeX"] != nil) info.eyeX = eyeX;
    if ([args objectForKey:@"eyeY"] != nil) info.eyeY = eyeY;
    if ([args objectForKey:@"eyeZ"] != nil) info.eyeZ = eyeZ;
    if ([args objectForKey:@"centerX"] != nil) info.centerX = centerX;
    if ([args objectForKey:@"centerY"] != nil) info.centerY = centerY;
    if ([args objectForKey:@"centerZ"] != nil) info.centerZ = centerZ;

    [_view setCamera:info];
}

-(id)opaque {
    return NUMBOOL(self.view.opaque);
}

-(void)setOpaque:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    self.view.opaque = [value boolValue];
    
    ((ComGooglecodeQuicktigame2dGameView *)self.view).alpha = self.view.opaque ? 1 : 0;
}

-(id)debug {
    return NUMBOOL(((ComGooglecodeQuicktigame2dGameView *)[self view]).debug);
}

-(void)setDebug:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((ComGooglecodeQuicktigame2dGameView *)[self view]).debug = [value boolValue];
}

-(id)useFastTimer {
    NSLog(@"[WARN] gameview.useFastTimer is deprecated. Use gameview.timerType instead.");
    return NUMBOOL(((ComGooglecodeQuicktigame2dGameView *)[self view]).timerType == TIMER_DISPLAYLINK);
}

-(void)setUseFastTimer:(id)value {
    NSLog(@"[WARN] gameview.useFastTimer is deprecated. Use gameview.timerType instead.");
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((ComGooglecodeQuicktigame2dGameView *)[self view]).timerType = [value boolValue] ? TIMER_DISPLAYLINK : TIMER_DEFAULT;
}

-(id)timerType {
    return NUMINT(((ComGooglecodeQuicktigame2dGameView *)[self view]).timerType);
}

-(void)setTimerType:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((ComGooglecodeQuicktigame2dGameView *)[self view]).timerType = [value intValue];
}

- (id)fps {
    return NUMFLOAT(((ComGooglecodeQuicktigame2dGameView*)self.view).fps);
}

- (void)setFps:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((ComGooglecodeQuicktigame2dGameView*)self.view).fps = [value floatValue];
}

- (id)orientation {
    // return NUMINT(((ComGooglecodeQuicktigame2dGameView*)self.view).game.orientation);
    
    // do nothing because parent window automatically rotate this view
    return NUMINT(orientation);
}

- (void)setOrientation:(id)_orientation {
    orientation = [_orientation intValue];
}

- (id)correctionHint {
    return NUMINT([((ComGooglecodeQuicktigame2dGameView*)self.view) correctionHint]);
}

- (void)setCorrectionHint:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [((ComGooglecodeQuicktigame2dGameView*)self.view) setCorrectionHint:[value intValue]];
}

- (id)textureFilter {
    return NUMINT([((ComGooglecodeQuicktigame2dGameView*)self.view) textureFilter]);
}

- (void)setTextureFilter:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [((ComGooglecodeQuicktigame2dGameView*)self.view) setTextureFilter:[value intValue]];
}

- (void)color:(id)args {
    ComGooglecodeQuicktigame2dGameView* gview = (ComGooglecodeQuicktigame2dGameView*)self.view;
    if ([args count] == 3) {
        [gview color:
         [[args objectAtIndex:0] floatValue]
               green:[[args objectAtIndex:1] floatValue]
                blue:[[args objectAtIndex:2] floatValue]
         ];
    } else if ([args count] >= 4) {
        [gview color:
         [[args objectAtIndex:0] floatValue]
               green:[[args objectAtIndex:1] floatValue]
                blue:[[args objectAtIndex:2] floatValue]
               alpha:[[args objectAtIndex:3] floatValue]
         ];
    } else {
        NSLog(@"[ERROR] Too few arguments for game.color(red, green, blue, alpha)");
    }
}

- (void)setAlpha:(id)args {
    ENSURE_SINGLE_ARG(args, NSNumber);
    ((ComGooglecodeQuicktigame2dGameView*)self.view).alpha = [args floatValue];
}

- (id)alpha {
    return NUMFLOAT(((ComGooglecodeQuicktigame2dGameView*)self.view).alpha);
}

- (id)usePerspective {
    return NUMBOOL(((ComGooglecodeQuicktigame2dGameView *)[self view]).usePerspective);
}

- (void)setUsePerspective:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((ComGooglecodeQuicktigame2dGameView *)[self view]).usePerspective = [value boolValue];
}

- (id)enableOnDrawFrameEvent {
    return NUMBOOL(((ComGooglecodeQuicktigame2dGameView *)[self view]).enableOnDrawFrameEvent);
}

- (void)setEnableOnDrawFrameEvent:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((ComGooglecodeQuicktigame2dGameView *)[self view]).enableOnDrawFrameEvent = [value boolValue];
}

- (id)enableOnFpsEvent {
    return NUMBOOL(((ComGooglecodeQuicktigame2dGameView *)[self view]).enableOnFpsEvent);
}

- (void)setEnableOnFpsEvent:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((ComGooglecodeQuicktigame2dGameView *)[self view]).enableOnFpsEvent = [value boolValue];
}

- (id)onFpsInterval {
    return NUMINT(((ComGooglecodeQuicktigame2dGameView *)[self view]).onFpsInterval);
}

- (void)setOnFpsInterval:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((ComGooglecodeQuicktigame2dGameView *)[self view]).onFpsInterval = [value intValue];
}

- (void)add:(id)args {
    NSLog(@"[WARN] QuickTiGame2d GameView.add is removed and can not be used from version 0.3");
}

- (void)addHUD:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dSpriteProxy);
    [(ComGooglecodeQuicktigame2dGameView*)self.view addHUD:[args sprite]];
}

- (void)removeHUD:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dSpriteProxy);
    [(ComGooglecodeQuicktigame2dGameView*)self.view removeHUD:[args sprite]];
}

- (void)moveCamera:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dTransformProxy);
    ComGooglecodeQuicktigame2dGameView* _view = (ComGooglecodeQuicktigame2dGameView*)self.view;
    [_view moveCamera:[args transformer]];
}

- (void)resetCamera:(id)args {
    [(ComGooglecodeQuicktigame2dGameView*)self.view resetCamera];
}

-(CGFloat)minimumParentWidthForSize:(CGSize)size {
    CGFloat superWidth = [super minimumParentWidthForSize:size];
    if (superWidth > 0) {
        return superWidth;
    }
    return [self contentWidthForWidth:size.width];
}

-(CGFloat)minimumParentHeightForSize:(CGSize)size {
    CGFloat superHeight = [super minimumParentHeightForSize:size];
    if (superHeight > 0) {
        return superHeight;
    }
    return [self contentHeightForWidth:size.width];
}

-(CGFloat)autoWidthForSize:(CGSize)size {
    CGFloat superWidth = [super autoWidthForSize:size];
    if (superWidth > 0) {
        return superWidth;
    }
    return [self contentWidthForWidth:size.width];
}

-(CGFloat)autoHeightForSize:(CGSize)size {
    CGFloat superHeight = [super autoHeightForSize:size];
    if (superHeight > 0) {
        return superHeight;
    }
    return [self contentHeightForWidth:size.width];
}

-(CGFloat)contentWidthForWidth:(CGFloat)suggestedWidth {
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 768.0f;
        } else {
            return 320.0f;
        }
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 1024.0f;
        } else {
            return 480.0f;
        }
    }
}

-(CGFloat)contentHeightForWidth:(CGFloat)width {
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 1024.0f;
        } else {
            return 480.0f;
        }
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 768.0f;
        } else {
            return 320.0f;
        }
    }
}

/*
 * toImage copied from TiViewProxy
 */
-(TiBlob*)toImage:(id)args {
	KrollCallback *callback = [args count] > 0 ? [args objectAtIndex:0] : nil;
	TiBlob *blob = [[[TiBlob alloc] init] autorelease];
	// we spin on the UI thread and have him convert and then add back to the blob
	// if you pass a callback function, we'll run the render asynchronously, if you
	// don't, we'll do it synchronously
	[self performSelectorOnMainThread:@selector(addImageToBlob:) withObject:[NSArray arrayWithObjects:blob,callback,nil] waitUntilDone:callback==nil ? YES : NO];
	return blob;
}

-(void)addImageToBlob:(NSArray*)args {
	TiBlob *blob = [args objectAtIndex:0];
	UIImage *image = [(ComGooglecodeQuicktigame2dGameView*)self.view toImage];
	[blob setImage:image];
    
	if ([args count] > 1)
	{
		KrollCallback *callback = [args objectAtIndex:1];
		NSDictionary *event = [NSDictionary dictionaryWithObject:blob forKey:@"blob"];
		[self _fireEventToListener:@"blob" withObject:event listener:callback thisObject:nil];
	}
}

- (void)registerForMultiTouch:(id)args {
    [(ComGooglecodeQuicktigame2dGameView*)self.view registerForMultiTouch];
}

@end
