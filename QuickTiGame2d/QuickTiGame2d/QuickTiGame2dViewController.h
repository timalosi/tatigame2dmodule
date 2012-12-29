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
#import "UIKit/UIKit.h"
#import "OpenGLES/EAGL.h"
#import "OpenGLES/ES1/gl.h"
#import "OpenGLES/ES1/glext.h"

#import "QuickTiGame2dView.h"
#import "QuickTiGame2dConstant.h"
#import "QuickTiGame2dEngine.h"
#import "QuickTiGame2dMapSprite.h"
#import "QuickTiGame2dParticles.h"

@interface QuickTiGame2dViewController : UIViewController <QuickTiGame2dViewEventHandler>
{
    EAGLContext *context;
    
    NSInteger timerType;
    
    BOOL animating;
    NSInteger displayLinkInterval;
    CADisplayLink *displayLink;
    
    NSTimer* animationTimer;
    NSTimeInterval animationTimerInterval;
	
	NSMutableDictionary *touchIdMaster;
	float touchEventParamCache[MOTION_EVENT_PARAMS_SIZE];
	NSInteger nextTouchId;
    
    QuickTiGame2dEngine* engine;
    QuickTiGame2dSprite* sprite1;
    QuickTiGame2dSprite* sprite2;
    QuickTiGame2dParticles* particle1;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger displayLinkInterval;
@property (nonatomic) NSTimeInterval animationTimerInterval;
@property (nonatomic) NSInteger timerType;

- (void)onLoad;
- (void)onGainedFocus;
- (void)onLostFocus;
- (void)onDispose;
@end
