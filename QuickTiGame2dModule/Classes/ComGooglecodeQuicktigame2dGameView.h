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
#import "TiUIView.h"
#import "QuickTiGame2dEngine.h"

@interface ComGooglecodeQuicktigame2dGameView : TiUIView {
    EAGLContext* context;
    CADisplayLink *displayLink;
    
    // The pixel dimensions of the CAEAGLLayer.
    GLint framebufferWidth;
    GLint framebufferHeight;
    
    // The OpenGL ES names for the framebuffer and renderbuffer used to render to this view.
    GLuint defaultFramebuffer, colorRenderbuffer, depthRenderbuffer;
    
    NSInteger displayLinkInterval;
    
    NSTimer* animationTimer;
    NSTimeInterval animationTimerInterval;
    
    NSInteger timerType;
    BOOL currentlyAnimating;
    BOOL layoutSubviewsDone;
    
    QuickTiGame2dEngine* game;
    
    BOOL enableMultiTouchEvents;
}
@property (readonly) GLint framebufferWidth;
@property (readonly) GLint framebufferHeight;
@property (nonatomic, readwrite) BOOL debug;
@property (readwrite) NSInteger gamewidth;
@property (readwrite) NSInteger gameheight;
@property (readwrite) NSInteger gameviewportWidth;
@property (readwrite) NSInteger gameviewportHeight;
@property (readwrite) float fps;
@property (nonatomic, readonly) QuickTiGame2dEngine* game;
@property (readwrite) BOOL enableOnDrawFrameEvent;
@property (readonly) struct CGRect gamebounds;
@property (readwrite) BOOL enableOnFpsEvent;
@property (readwrite) NSInteger onFpsInterval;
@property (readwrite) NSInteger timerType;
@property (readwrite) BOOL usePerspective;
@property (readwrite) float alpha;

- (void)attachContext;
- (void)detachContext;

- (void)start;
- (void)stop;
- (void)pause;

- (QuickTiGame2dScene*)pushScene:(QuickTiGame2dScene*)scene;
- (QuickTiGame2dScene*)popScene;
- (QuickTiGame2dScene*)replaceScene:(QuickTiGame2dScene*)scene;

-(CameraInfo)getCamera;
-(void)setCamera:(CameraInfo)camera;
-(void)resetCamera;
-(void)moveCamera:(QuickTiGame2dTransform*) transform;

-(void)color:(float)red green:(float)green blue:(float)blue;
-(void)color:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

-(void)addHUD:(QuickTiGame2dSprite*)sprite;
-(void)removeHUD:(QuickTiGame2dSprite*)sprite;

-(GLint)textureFilter;
-(void)setTextureFilter:(GLint)filter;
-(GLenum)correctionHint;
-(void)setCorrectionHint:(GLenum)hint;
-(UIImage*)toImage;

-(void)registerForMultiTouch;
-(void)startCurrentScene;
@end
