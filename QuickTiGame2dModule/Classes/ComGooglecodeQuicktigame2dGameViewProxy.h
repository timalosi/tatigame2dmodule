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
#import "TiUIViewProxy.h"
#import "ComGooglecodeQuicktigame2dSceneProxy.h"
#import "ArrayStackQueue.h"

@interface ComGooglecodeQuicktigame2dGameViewProxy : TiUIViewProxy <LayoutAutosizing> {
    ArrayStackQueue* sceneStack;
    NSMutableDictionary* screenInfoCache;
    NSMutableDictionary* cameraInfoCache;
    NSInteger orientation;
    ComGooglecodeQuicktigame2dSceneProxy* previousScene;
}
@property (nonatomic, readwrite, assign) id debug;
@property (nonatomic, readwrite, assign) id screen;
@property (nonatomic, readwrite, assign) id camera;
@property (nonatomic, readwrite, assign) id fps;
@property (nonatomic, readwrite, assign) id orientation;
@property (nonatomic, readwrite, assign) id enableOnDrawFrameEvent;
@property (nonatomic, readwrite, assign) id enableOnFpsEvent;
@property (nonatomic, readwrite, assign) id onFpsInterval;
@property (nonatomic, readwrite, assign) id correctionHint;
@property (nonatomic, readwrite, assign) id textureFilter;
@property (nonatomic, readwrite, assign) id useFastTimer;
@property (nonatomic, readwrite, assign) id timerType;
@property (nonatomic, readwrite, assign) id opaque;
@property (nonatomic, readwrite, assign) id usePerspective;
@property (nonatomic, readwrite, assign) id alpha;

- (void)onNotification:(NSNotification*)notification;

- (void)loadTexture:(id)args;
- (void)loadTextureWithTag:(id)args;
- (void)unloadTexture:(id)args;
- (void)unloadTextureByTag:(id)args;

- (id)uptime:(id)args;
- (void)start:(id)args;
- (void)pause:(id)args;
- (void)stop:(id)args;
- (id)pushScene:(id)args;
- (id)popScene:(id)args;
- (id)topScene:(id)args;
- (id)replaceScene:(id)args;

- (void)add:(id)args;
- (void)addHUD:(id)args;
- (void)removeHUD:(id)args;

- (void)startCurrentScene:(id)args;

- (void)color:(id)args;

- (void)moveCamera:(id)args;
- (void)resetCamera:(id)args;

- (TiBlob*)toImage:(id)args;
- (void)addImageToBlob:(NSArray*)args;

- (void)registerForMultiTouch:(id)args;
@end
