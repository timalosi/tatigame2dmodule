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
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "QuickTiGame2dConstant.h"
#import "QuickTiGame2dUtil.h"
#import "QuickTiGame2dScene.h"
#import "QuickTiGame2dTexture.h"
#import "QuickTiGame2dTransform.h"
#import "ArrayStackQueue.h"

typedef struct CameraInfo {
    BOOL    loaded;
	GLfloat eyeX;
	GLfloat eyeY;
	GLfloat eyeZ;
    GLfloat centerX;
    GLfloat centerY;
    GLfloat centerZ;
    GLfloat upX;   // read only
    GLfloat upY;   // read only
    GLfloat upZ;   // read only
    GLfloat zNear; // read only
    GLfloat zFar;  // read only
} CameraInfo;

@interface QuickTiGame2dEngine : NSObject {
    float color[4];
    
    GLint width;
    GLint height;
    
    GLint framebufferWidth;
    GLint framebufferHeight;
    
	short squareIndices[4];
	float squarePositions[12];
    
    NSInteger status;
    BOOL dirty;
    BOOL loaded;
    
    ArrayStackQueue* sceneStack;
    
    NSMutableDictionary* notificationEventCache;
    NSMutableDictionary* fpsNotificationEventCache;
    NSMutableDictionary* sceneNotificationEventCache;
    
    UIInterfaceOrientation orientation;
    BOOL shouldRotateOrientation;
    
    NSTimeInterval lastOnDrawTime;
    
    BOOL usePerspective;
    BOOL useCustomCamera;
    
    BOOL takeSnapshot;
    BOOL releaseSnapshot;
    
    QuickTiGame2dTexture* snapshotTexture;
    QuickTiGame2dSprite*  snapshotSprite;
    
    CameraInfo defaultPortraitCamera;
    CameraInfo defaultLandscapeCamera;
    CameraInfo customCamera;
    
    BOOL enableOnDrawFrameEvent;
    
    BOOL           enableOnFpsEvent;
    NSInteger      fpsFrameCount;
    NSInteger      onFpsInterval;
    NSTimeInterval lastOnFpsTime;
    
    NSMutableArray* cameraTransforms;
    NSMutableArray* cameraTransformsToBeRemoved;
    
    QuickTiGame2dScene* hudScene;
    QuickTiGame2dScene* previousScene;
}
@property (readwrite) GLint viewportWidth;
@property (readwrite) GLint viewportHeight;
@property (readwrite) NSInteger width;
@property (readwrite) NSInteger height;
@property (readwrite) UIInterfaceOrientation orientation;
@property (readwrite) BOOL enableOnDrawFrameEvent;
@property (readwrite) BOOL enableOnFpsEvent;
@property (readwrite) NSInteger onFpsInterval;
@property (readwrite) BOOL usePerspective;
@property (readwrite) float alpha;

- (void)forceUpdateViewport;
- (void)updateOrthoViewport;
- (void)drawFrame;
- (void)onLoad:(GLint)framebufferWidth height:(GLint)framebufferHeight;
- (void)onGainedFocus;
- (void)onLostFocus;
- (void)onDispose;

+(NSTimeInterval)uptime;
+(void)loadTexture:(NSString*)name tag:(NSString*)tag;
+(void)loadTexture:(NSString*)name texture:(QuickTiGame2dTexture*)texture tag:(NSString*)tag;
+(void)loadTexture:(NSString*)name data:(NSData*)data tag:(NSString*)tag;
+(void)commitLoadTexture:(NSString*)name tag:(NSString*)tag;
+(void)commitUnloadTexture:(NSString*)name tag:(NSString*)tag;
+(void)commitLoadTexture:(NSString*)name texture:(QuickTiGame2dTexture*)texture tag:(NSString*)tag;
+(void)commitLoadTexture:(NSString*)name data:(NSData*)data tag:(NSString*)tag;

- (QuickTiGame2dScene*)pushScene:(QuickTiGame2dScene*)scene;
- (QuickTiGame2dScene*)popScene;
- (QuickTiGame2dScene*)topScene;
- (QuickTiGame2dScene*)replaceScene:(QuickTiGame2dScene*)scene;

- (void)start;
- (void)pause;
- (void)stop;
- (void)snapshot;
- (void)releaseSnapshot;
- (void)resetCamera;
- (CameraInfo)getCamera;
- (void)setCamera:(CameraInfo)camera;

+ (void)restoreGLState:(BOOL)enabled;
+ (NSMutableDictionary*)sharedTextureCache;
+ (GLuint)sharedIndexPointer;
+ (GLuint)sharedPositionPointer;
+ (NSNotificationCenter*)sharedNotificationCenter;
+ (BOOL)debug;
+ (void)setDebug:(BOOL)enable;

+ (GLint)textureFilter;
+ (void)setTextureFilter:(GLint)filter;
+ (GLenum)correctionHint;
+ (void)setCorrectionHint:(GLenum)hint;

-(void)color:(float)red green:(float)green blue:(float)blue;
-(void)color:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

-(void)transformCamera:(QuickTiGame2dTransform*) transform;

-(void)addHUD:(QuickTiGame2dSprite*)sprite;
-(void)removeHUD:(QuickTiGame2dSprite*)sprite;

-(void)startCurrentScene;

@end
