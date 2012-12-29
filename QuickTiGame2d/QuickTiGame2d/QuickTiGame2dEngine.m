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
#import "QuickTiGame2dEngine.h"
#import "QuickTiGame2dConstant.h"

@interface QuickTiGame2dEngine (PrivateMethods)
- (void)updateViewport;
- (void)loadSquareVBOPointer;
- (void)fireOnLoadEvent;
- (void)updateCameraInfo;

- (void)updateHUDViewport;

- (void)applyTransformCamera;
- (void)completeTransformCamera;
- (void)onTransformCamera;
- (void)applyTransformCamera:(QuickTiGame2dTransform*)transform;
- (void)completeTransformCamera:(QuickTiGame2dTransform*) transform;
- (void)clearTransformCameras;
- (void)clearTransformCamera:(QuickTiGame2dTransform*)transform;
+ (void)unloadTexture:(NSString*)name tag:(NSString*)tag;
+ (void)unloadAllTextures;

- (void)prepareScreenShot;
- (void)finishScreenShot;

@end

@implementation QuickTiGame2dEngine
@synthesize enableOnDrawFrameEvent, enableOnFpsEvent;
@synthesize onFpsInterval;
@synthesize usePerspective;

static NSMutableDictionary* textureCache;
static NSMutableDictionary* textureTagCache;
static ArrayStackQueue* beforeCommandQueue;
static ArrayStackQueue* afterCommandQueue;
static GLuint squareVBOPointerCache[2];
static NSDate* startTime;
static BOOL debug;
static GLenum correctionHint = GL_NICEST;
static GLint  textureFilter  = GL_NEAREST;

- (id)init {
    self = [super init];
    if (self != nil) {
        sceneStack   = [[ArrayStackQueue alloc] init];
        textureCache = [[NSMutableDictionary alloc] init];
        textureTagCache = [[NSMutableDictionary alloc] init];
        notificationEventCache = [[NSMutableDictionary alloc] init];
        fpsNotificationEventCache = [[NSMutableDictionary alloc] init];
        sceneNotificationEventCache = [[NSMutableDictionary alloc] init];
        
        dirty  = TRUE;
        loaded = FALSE;
        usePerspective = TRUE;
        useCustomCamera = FALSE;
        
        // set default background color
        color[0] = 0;
        color[1] = 0;
        color[2] = 0;
        color[3] = 1;
        
        status = GAME_STOPPED;
        
        startTime = [[NSDate alloc] init];
        lastOnDrawTime = 0;
        
        orientation = UIInterfaceOrientationPortrait;

        takeSnapshot    = FALSE;
        snapshotTexture = [[QuickTiGame2dTexture alloc] init];
        snapshotSprite  = nil;
        
        beforeCommandQueue = [[ArrayStackQueue alloc] init];
        afterCommandQueue  = [[ArrayStackQueue alloc] init];
        
        enableOnDrawFrameEvent = TRUE;
        
        cameraTransforms = [[NSMutableArray alloc] init];
        cameraTransformsToBeRemoved = [[NSMutableArray alloc] init];
        
        hudScene = [[QuickTiGame2dScene alloc] init];
        hudScene.isHUD = TRUE;
        
        enableOnFpsEvent = FALSE;
        onFpsInterval    = DEFAULT_ONFPS_INTERVAL;
        lastOnFpsTime    = 0;
        fpsFrameCount    = 0;
        
        previousScene = nil;
    }
    return self;
}

-(void)dealloc {
    
    [textureCache release];
    textureCache = nil;

    [textureTagCache release];
    textureTagCache = nil;
    
    [beforeCommandQueue release];
    [afterCommandQueue release];
    
    beforeCommandQueue = nil;
    afterCommandQueue  = nil;
    
    [sceneStack release];
    [notificationEventCache release];
    [fpsNotificationEventCache release];
    [sceneNotificationEventCache release];
    [snapshotTexture release];
    [snapshotSprite release];
    [cameraTransforms release];
    [cameraTransformsToBeRemoved release];
    [hudScene release];
    
    [startTime release];
    
    [super dealloc];
}

- (void)updateCameraInfo {
    float zfar = fmaxf(width, height) * 4;
    
    defaultPortraitCamera.eyeX = width  * 0.5;
    defaultPortraitCamera.eyeY = height * 0.5;
    defaultPortraitCamera.eyeZ = height * 0.5;
    defaultPortraitCamera.centerX = width * 0.5;
    defaultPortraitCamera.centerY = height * 0.5;
    defaultPortraitCamera.centerZ = 0;
    defaultPortraitCamera.upX = 0;
    defaultPortraitCamera.upY = 1;
    defaultPortraitCamera.upZ = 0;
    defaultPortraitCamera.zNear = 1;
    defaultPortraitCamera.zFar  = zfar;
    defaultPortraitCamera.loaded = TRUE;

    defaultLandscapeCamera.eyeX = width  * 0.5;
    defaultLandscapeCamera.eyeY = height * 0.5;
    defaultLandscapeCamera.eyeZ = width  * 0.5;
    defaultLandscapeCamera.centerX = width * 0.5;
    defaultLandscapeCamera.centerY = height * 0.5;
    defaultLandscapeCamera.centerZ = 0;
    defaultLandscapeCamera.upX = 1;
    defaultLandscapeCamera.upY = 0;
    defaultLandscapeCamera.upZ = 0;
    defaultLandscapeCamera.zNear = 1;
    defaultLandscapeCamera.zFar  = zfar;
    defaultLandscapeCamera.loaded = TRUE;
}

- (CameraInfo)getCamera {
    if (useCustomCamera && customCamera.loaded) {
        return customCamera;
    }
    
    [self  updateCameraInfo];
    
    if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
        return defaultLandscapeCamera;
    } else {
        return defaultPortraitCamera;
    }
}

- (void)setCamera:(CameraInfo)camera {
    useCustomCamera = TRUE;
    customCamera    = camera;
    customCamera.loaded = TRUE;
    dirty = TRUE;
}

- (void)resetCamera {
    useCustomCamera = FALSE;
    dirty = TRUE;
}

- (void)updateHUDViewport {
    glViewport(0, 0, framebufferWidth, framebufferHeight);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    float zFar = defaultPortraitCamera.zFar;
    
    glOrthof(0, width, height, 0, -zFar, zFar);
}

- (void)updateOrthoViewport {
    glViewport(0, 0, framebufferWidth, framebufferHeight);
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    
    float zFar = defaultPortraitCamera.zFar;
    
    glOrthof(0, width, height, 0, -zFar, zFar);
}

- (void)forceUpdateViewport {
    dirty = TRUE;
    [self updateViewport];
}

- (void)updateViewport {
    if (dirty) {
        glViewport(0, 0, framebufferWidth, framebufferHeight); 
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        
        if (shouldRotateOrientation) {
            NSInteger _width = width;
            width  = height;
            height = _width;
            shouldRotateOrientation = FALSE;
        }
        
        [self  updateCameraInfo];
        
        if (usePerspective) {
            float ratio = framebufferWidth / (float)framebufferHeight;
        
            CameraInfo camera = defaultPortraitCamera;
            
            if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
                glFrustumf(ratio, -ratio, -1, 1, camera.zNear, camera.zFar);
            } else if (orientation == UIInterfaceOrientationLandscapeLeft) {
                camera = defaultLandscapeCamera;
                glFrustumf(ratio, -ratio, -1, 1, camera.zNear, camera.zFar);
            } else if (orientation == UIInterfaceOrientationLandscapeRight) {
                camera = defaultLandscapeCamera;
                glFrustumf(-ratio, ratio, 1, -1, camera.zNear, camera.zFar);
            } else {
                glFrustumf(-ratio, ratio, 1, -1, camera.zNear, camera.zFar);
            }
            
            if (useCustomCamera) {
                camera.eyeX = customCamera.eyeX;
                camera.eyeY = customCamera.eyeY;
                camera.eyeZ = customCamera.eyeZ;
                
                camera.centerX = customCamera.centerX;
                camera.centerY = customCamera.centerY;
                camera.centerZ = customCamera.centerZ;
            }
            
            gluLookAt(camera.eyeX,    camera.eyeY,    camera.eyeZ, 
                      camera.centerX, camera.centerY, camera.centerZ,
                      camera.upX,     camera.upY,     camera.upZ);
        } else {
            glOrthof(0, width, height, 0, -100, 100);
        }
        
        dirty = FALSE;
    }
}

- (void)prepareScreenShot {
    if (!takeSnapshot && releaseSnapshot) {
        if (debug) NSLog(@"[DEBUG] QuickTiGame2dEngine:releaseSnapshot");
        [snapshotSprite onDispose];
        [snapshotSprite release];
        snapshotSprite = nil;
        releaseSnapshot = FALSE;
    }
    
    if (takeSnapshot) {
        if (debug) NSLog(@"[DEBUG] QuickTiGame2dEngine:takeSnapshot start");
        
        GLint framebufferOldId;
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &framebufferOldId);
        snapshotTexture.framebufferOldId = framebufferOldId;
        
        glBindFramebuffer(GL_FRAMEBUFFER, snapshotTexture.framebufferId);
        
        dirty = TRUE;
    }
}

- (void)finishScreenShot {
    if (takeSnapshot) {
        if(snapshotTexture.framebufferOldId > 0) {
            glBindFramebuffer(GL_FRAMEBUFFER, snapshotTexture.framebufferOldId);
            snapshotTexture.framebufferOldId = 0;
            
            [snapshotSprite release];
            snapshotSprite  = [[QuickTiGame2dSprite alloc] init];
            snapshotSprite.image  = @SNAPSHOT_TEXTURE_NAME;
            snapshotSprite.width  = width;
            snapshotSprite.height = height;
            snapshotSprite.x      = 0;
            snapshotSprite.y      = 0;
            snapshotSprite.z      = 99.5f;
        }
        takeSnapshot = FALSE;
        if (debug) NSLog(@"[DEBUG] QuickTiGame2dEngine:takeSnapshot end");
    }
}

- (void)drawFrame {
    [QuickTiGame2dEngine restoreGLState:TRUE];

    @synchronized(beforeCommandQueue) {
        while ([beforeCommandQueue count] > 0) {
            ((CommandBlock)[beforeCommandQueue poll])();
        }
    }
    
    QuickTiGame2dScene* scene = [self topScene];
    
    if (!takeSnapshot && previousScene != nil) {
        if (previousScene != scene) {
            [previousScene onDeactivate];
        }
        previousScene = nil;
    }
    
    if (scene != nil && status != GAME_STOPPED) {
        
        [self prepareScreenShot];
        
        @synchronized (cameraTransforms) {
            [self onTransformCamera];
        }
        
        [self updateViewport];
        
        scene.debug    = debug;
        scene.snapshot = takeSnapshot;
        
        if (!scene.loaded) {
            [scene onLoad];
        }

        int delta = ([QuickTiGame2dEngine uptime] - lastOnDrawTime) * 1000;
        if (enableOnDrawFrameEvent) {
            [notificationEventCache setObject:[NSNumber numberWithInt:delta] forKey:@"delta"];
            [notificationEventCache setObject:[NSNumber numberWithDouble:[QuickTiGame2dEngine uptime]] forKey:@"uptime"];
            [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onDrawFrame" object:self userInfo:notificationEventCache];
        }
        lastOnDrawTime = [QuickTiGame2dEngine uptime];
        
        if (enableOnFpsEvent) {
            fpsFrameCount++;
            int fpsdelta = ([QuickTiGame2dEngine uptime] - lastOnFpsTime) * 1000;
            if (fpsdelta > onFpsInterval) {
                [fpsNotificationEventCache setObject:[NSNumber numberWithInt:fpsdelta] forKey:@"delta"];
                [fpsNotificationEventCache setObject:[NSNumber numberWithDouble:[QuickTiGame2dEngine uptime]] forKey:@"uptime"];
                [fpsNotificationEventCache setObject:[NSNumber numberWithDouble:fpsFrameCount / (fpsdelta / 1000.0f)] forKey:@"fps"];
                [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onFps"
                                                                object:self userInfo:fpsNotificationEventCache];
                lastOnFpsTime = [QuickTiGame2dEngine uptime];
                fpsFrameCount = 0;
            }
        }
        
        [scene drawFrame:self];
        
        if ([hudScene hasSprite]) {
            [self updateHUDViewport];
            
            hudScene.debug    = debug;
            hudScene.snapshot = takeSnapshot;
            if (!hudScene.loaded) {
                [hudScene onLoad];
            }
            [hudScene drawFrame:self];
            
            dirty = TRUE;
        }
        
        [self finishScreenShot];
        
        scene.snapshot = takeSnapshot;
        [scene removeWaitingSprites];
        
    }  else {
        glClearColor(color[0], color[1], color[2], color[3]);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
    
    if (snapshotSprite != nil) {
        [snapshotSprite onLoad];
        [snapshotSprite drawFrame:self];
    }
    
    @synchronized(afterCommandQueue) {
        while ([beforeCommandQueue count] == 0 && [afterCommandQueue count] > 0) {
            ((CommandBlock)[afterCommandQueue poll])();
        }
    }
        
    [QuickTiGame2dEngine restoreGLState:FALSE];
}

-(void)onLoad:(int)_framebufferWidth height:(int)_framebufferHeight {
    framebufferWidth  = _framebufferWidth;
    framebufferHeight = _framebufferHeight;
    
    if (width  == 0) width  = framebufferWidth;
    if (height == 0) height = framebufferHeight;
    
    [QuickTiGame2dEngine restoreGLState:TRUE];
    
    [self loadSquareVBOPointer];

    if ([snapshotTexture onLoadSnapshot:framebufferWidth height:framebufferHeight]) {
        QuickTiGame2dTexture* texture = [textureCache objectForKey:snapshotTexture.name];
        if (texture != nil) {
            [texture onDispose];
            [textureCache removeObjectForKey:snapshotTexture.name];
        }
        [textureCache setObject:snapshotTexture forKey:snapshotTexture.name];
    }
    
    [self fireOnLoadEvent];
    
    [QuickTiGame2dEngine restoreGLState:FALSE];
}

- (void)onActivateScene:(QuickTiGame2dScene*)scene {
    if (scene == nil) return;
    
    [sceneNotificationEventCache setObject:[NSNumber numberWithDouble:[QuickTiGame2dEngine uptime]] forKey:@"uptime"];
    [sceneNotificationEventCache setObject:scene forKey:@"source"];
    [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onActivateScene" object:self userInfo:sceneNotificationEventCache];
}

- (void)onDeactivateScene:(QuickTiGame2dScene*)scene {
    if (scene == nil) return;
    
    [sceneNotificationEventCache setObject:[NSNumber numberWithDouble:[QuickTiGame2dEngine uptime]] forKey:@"uptime"];
    [sceneNotificationEventCache setObject:scene forKey:@"source"];
    [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onDeactivateScene" object:self userInfo:sceneNotificationEventCache];
}

- (void)onGainedFocus {
    [notificationEventCache setObject:[NSNumber numberWithDouble:[QuickTiGame2dEngine uptime]] forKey:@"uptime"];
    [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onGainedFocus" object:self userInfo:notificationEventCache];
}

- (void)onLostFocus {
    [notificationEventCache setObject:[NSNumber numberWithDouble:[QuickTiGame2dEngine uptime]] forKey:@"uptime"];
    [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onLostFocus" object:self userInfo:notificationEventCache];
}

- (void)onDispose {
    if (!loaded) return;
    loaded = FALSE;
    
    [notificationEventCache setObject:[NSNumber numberWithDouble:[QuickTiGame2dEngine uptime]] forKey:@"uptime"];
    [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onDispose" object:self userInfo:notificationEventCache];
    
    for (int i = 0; i < [sceneStack count]; i++) {
        [[sceneStack objectAtIndex:i] onDispose];
    }
    [sceneStack removeAllObjects];
    
    [hudScene onDispose];
    
    [QuickTiGame2dEngine unloadAllTextures];
    
    glDeleteBuffers(2, squareVBOPointerCache);
}

/*
 * Param name should not be null. tag can be null.
 * If tag equals not null, cache tag with texture name
 */
+(void)loadTexture:(NSString*)name tag:(NSString*)tag {
    if (debug && name == nil) {
        NSLog(@"[WARN] QuickTiGame2dEngine:loadTexture name should not be nil!");
        return;
    }
    @synchronized(textureCache) {
        if ([textureCache objectForKey:name] == nil) {
            QuickTiGame2dTexture* texture = [[QuickTiGame2dTexture alloc] init];
            [texture setName:name];
            if ([texture onLoad]) {
                [textureCache setObject:texture forKey:name];
                [texture freeData];
            }
            [texture release];
        }
    }
    
    if (tag != nil && [tag length] > 0) {
        @synchronized(textureTagCache) {
            [textureTagCache setObject:name forKey:tag];
        }
    }
}

/*
 * Param name should not be null. tag can be null.
 * If tag equals not null, cache tag with texture name
 */
+(void)loadTexture:(NSString*)name texture:(QuickTiGame2dTexture*)texture tag:(NSString*)tag {
    if (debug && name == nil) {
        NSLog(@"[WARN] QuickTiGame2dEngine:loadTexture name should not be nil!");
        return;
    }
    @synchronized(textureCache) {
        if ([textureCache objectForKey:name] == nil) {
            [textureCache setObject:texture forKey:name];
        }
    }
    
    if (tag != nil && [tag length] > 0) {
        @synchronized(textureTagCache) {
            [textureTagCache setObject:name forKey:tag];
        }
    }
}


+(void)loadTexture:(NSString*)name data:(NSData*)data tag:(NSString*)tag {
    QuickTiGame2dTexture* texture = [[QuickTiGame2dTexture alloc] init];
    texture.name = name;
    
    if ([texture onLoad:data]) {
        [QuickTiGame2dEngine loadTexture:texture.name texture:texture tag:tag];
    }
    
    [texture freeData];
    [texture release];
}

/*
 * Param name or tag can be null,
 * If tag equals not null, search for name by tag from cache
 */
+(void)unloadTexture:(NSString*)name tag:(NSString *)tag {
    
    @synchronized(textureTagCache) {
        if (name == nil && tag != nil && [tag length] > 0) {
            name = [textureTagCache objectForKey:tag];
            if (name != nil) {
                [textureTagCache removeObjectForKey:tag];
            }
        }
    }
    
    if (debug && name == nil && tag == nil) {
        NSLog(@"[WARN] QuickTiGame2dEngine:unloadTexture both name and tag equals nil!");
        return;
    }
    
    @synchronized(textureCache) {
        QuickTiGame2dTexture* texture = [textureCache objectForKey:name];
        if (texture != nil) {
            [texture onDispose];
            [textureCache removeObjectForKey:name];
        }
    }
    
}

+(void)unloadAllTextures {
    @synchronized(textureCache) {
        for (id key in textureCache) {
            [[textureCache objectForKey:key] onDispose];
        }
    
        [textureCache removeAllObjects];
    }
    
    @synchronized(textureTagCache) {
        [textureTagCache removeAllObjects];
    }
}

+(void)commitLoadTexture:(NSString*)name tag:(NSString*)tag {
    @synchronized(beforeCommandQueue) {
        CommandBlock command = [^{
            [QuickTiGame2dEngine loadTexture:name tag:tag];
        } copy];
        
        [beforeCommandQueue push:command];
        [command release];
    }
}

+(void)commitLoadTexture:(NSString*)name texture:(QuickTiGame2dTexture*)texture tag:(NSString*)tag {
    @synchronized(beforeCommandQueue) {
        CommandBlock command = [^{
            [QuickTiGame2dEngine loadTexture:name texture:texture tag:tag];
            [texture freeData];
        } copy];
        
        [beforeCommandQueue push:command];
        [command release];
    }
}

+(void)commitLoadTexture:(NSString*)name data:(NSData*)data tag:(NSString*)tag {
    @synchronized(beforeCommandQueue) {
        CommandBlock command = [^{
            [QuickTiGame2dEngine loadTexture:name data:data tag:tag];
        } copy];
        
        [beforeCommandQueue push:command];
        [command release];
    }
}

+(void)commitUnloadTexture:(NSString*)name tag:(NSString*)tag {
    @synchronized(afterCommandQueue) {
        CommandBlock command = [^{
            [QuickTiGame2dEngine unloadTexture:name tag:tag];
        } copy];
        
        [afterCommandQueue push:command];
        [command release];
    }
}

+(NSMutableDictionary*)sharedTextureCache {
    return textureCache;
}

+(GLuint)sharedPositionPointer {
    return squareVBOPointerCache[0];
}

+(GLuint)sharedIndexPointer {
    return squareVBOPointerCache[1];
}

+(void)restoreGLState:(BOOL)enabled {
    if (enabled) {
        glDisable(GL_LIGHTING);
        glDisable(GL_MULTISAMPLE);
        glDisable(GL_DITHER);
        glDisable(GL_CULL_FACE);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_ALPHA_TEST);
        
        glEnable(GL_TEXTURE_2D);
        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        
        glHint(GL_POINT_SMOOTH_HINT, correctionHint);
        glHint(GL_LINE_SMOOTH_HINT,  correctionHint);
        glHint(GL_PERSPECTIVE_CORRECTION_HINT, correctionHint);
        
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        glDisableClientState(GL_COLOR_ARRAY);
    } else {
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindTexture(GL_TEXTURE_2D, 0);
        
        glDisable(GL_ALPHA_TEST);
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_TEXTURE_2D);
        glDisable(GL_BLEND);
        
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
        glDisableClientState(GL_COLOR_ARRAY);
    }
}

+ (NSTimeInterval)uptime {
    if (startTime == nil) return 0;
    return [[NSDate date] timeIntervalSinceDate:startTime];
}

+ (NSNotificationCenter*)sharedNotificationCenter {
    return [NSNotificationCenter defaultCenter];
}

+ (BOOL)debug {
    return debug;
}

+ (void)setDebug:(BOOL)enable {
    debug = enable;
}

+ (GLint)textureFilter {
    return textureFilter;
}

+ (void)setTextureFilter:(GLint)filter {
    textureFilter = filter;
}

+ (GLenum)correctionHint {
    return correctionHint;
}

+ (void)setCorrectionHint:(GLenum)hint {
    correctionHint = hint;
}

-(void)fireOnLoadEvent {
    if (loaded) return;
    loaded = TRUE;

    [notificationEventCache setObject:[NSNumber numberWithInt:width]  forKey:@"width"];
    [notificationEventCache setObject:[NSNumber numberWithInt:height] forKey:@"height"];
    [notificationEventCache setObject:[NSNumber numberWithDouble:[QuickTiGame2dEngine uptime]] forKey:@"uptime"];
    [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onLoad" object:self userInfo:notificationEventCache];
}

- (void)loadSquareVBOPointer {
    squareIndices[0] = 0;
    squareIndices[1] = 1;
    squareIndices[2] = 2;
    squareIndices[3] = 3;
	
    squarePositions[0] = 0;
    squarePositions[1] = 0;
    squarePositions[2] = 0;
	
    squarePositions[3] = 0;
    squarePositions[4] = 1;
    squarePositions[5] = 0;
	
    squarePositions[6] = 1;
    squarePositions[7] = 1;
    squarePositions[8] = 0;
	
    squarePositions[9]  = 1;
    squarePositions[10] = 0;
    squarePositions[11] = 0;
	
    clearGLErrors(@"QuickTiGame2dEngine:loadSquareVBOPointer");
	
    glGenBuffers(2, squareVBOPointerCache);
	
    glBindBuffer(GL_ARRAY_BUFFER, squareVBOPointerCache[0]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 12, squarePositions, GL_STATIC_DRAW);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, squareVBOPointerCache[1]);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(short) * 4, squareIndices, GL_STATIC_DRAW);
	
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
    
	checkGLErrors(@"QuickTiGame2dEngine:Could not create OpenGL buffers");
}

- (QuickTiGame2dScene*)pushScene:(QuickTiGame2dScene*)scene {
    [self snapshot];

    @synchronized(afterCommandQueue) {
        CommandBlock command = [^{
            if (debug) NSLog(@"[DEBUG] QuickTiGame2dEngine:pushScene");
            previousScene = [sceneStack top];
            [self onDeactivateScene:previousScene];
            [sceneStack push:scene];
            [self onActivateScene:[sceneStack top]];
        } copy];
        
        [afterCommandQueue push:command];
        [command release];
    }
    
    
    return scene;
}

- (QuickTiGame2dScene*)popScene {
    [self snapshot];

    @synchronized(afterCommandQueue) {
        CommandBlock command = [^{
            if (debug) NSLog(@"[DEBUG] QuickTiGame2dEngine:popScene");
            previousScene = [sceneStack pop];
            [self onDeactivateScene:previousScene];
            [self onActivateScene:[sceneStack top]];
        } copy];
        
        [afterCommandQueue push:command];
        [command release];
    }

    return [sceneStack top];
}

- (QuickTiGame2dScene*)replaceScene:(QuickTiGame2dScene*)scene {
    [self snapshot];
    
    @synchronized(afterCommandQueue) {
        CommandBlock command = [^{
            if (debug) NSLog(@"[DEBUG] QuickTiGame2dEngine:replaceScene");
            previousScene = [sceneStack pop];
            [self onDeactivateScene:previousScene];
            [sceneStack push:scene];
            [self onActivateScene:[sceneStack top]];
        } copy];
        
        [afterCommandQueue push:command];
        [command release];
    }
    
    return [sceneStack top];
}

- (QuickTiGame2dScene*)topScene {
    return [sceneStack top];
}

- (void)start {
    status = GAME_STARTED;
}

- (void)pause {
    status = GAME_PAUSED;
}

- (void)stop {
    status = GAME_STOPPED;
}

- (void)snapshot {
    if ([self topScene] != nil) {
        @synchronized (beforeCommandQueue) {
            CommandBlock command = [^{ takeSnapshot = TRUE; } copy];
            [beforeCommandQueue push:command];
            [command release];
        }
    }
}

- (void)releaseSnapshot {
    if ([self topScene] != nil) {
        @synchronized (beforeCommandQueue) {
            CommandBlock command = [^{ releaseSnapshot = TRUE; } copy];
            [beforeCommandQueue push:command];
            [command release];
        }
    }
}


-(void)startCurrentScene {
    [self releaseSnapshot];
}

- (GLint)viewportWidth {
    return framebufferWidth;
}

- (void)setViewportWidth:(GLint)value {
    framebufferWidth = value;
}

- (GLint)viewportHeight {
    return framebufferHeight;
}

- (void)setViewportHeight:(GLint)value {
    framebufferHeight = value;
}

- (NSInteger)width {
    return width;
}

- (void)setWidth:(NSInteger)_width {
    width = _width;
    dirty = TRUE;
}

- (NSInteger)height {
    return height;
}

- (void)setHeight:(NSInteger)_height {
    height = _height;
    dirty  = TRUE;
}

- (UIInterfaceOrientation)orientation {
    return orientation;
}

-(void)color:(float)red green:(float)green blue:(float)blue {
    [self color:red green:green blue:blue alpha:color[3]];
}

-(void)color:(float)red green:(float)green blue:(float)blue alpha:(float)alpha {
    color[0] = red;
    color[1] = green;
    color[2] = blue;
    color[3] = alpha;
}

- (void)setOrientation:(UIInterfaceOrientation)_orientation {
    
    if ((orientation == UIInterfaceOrientationPortrait ||
         orientation == UIInterfaceOrientationPortraitUpsideDown) &&
        (_orientation == UIInterfaceOrientationLandscapeLeft|| 
         _orientation == UIInterfaceOrientationLandscapeRight)) {
        shouldRotateOrientation = TRUE;
    } else if ((orientation == UIInterfaceOrientationLandscapeLeft ||
                orientation == UIInterfaceOrientationLandscapeRight) &&
               (_orientation == UIInterfaceOrientationPortrait ||
                _orientation == UIInterfaceOrientationPortraitUpsideDown)) {
        shouldRotateOrientation = TRUE;
    }
    
    orientation = _orientation;
    dirty = TRUE;
}

-(void)onTransformCamera {
    if ([cameraTransforms count] == 0) return;
    
    for (QuickTiGame2dTransform* transform in cameraTransforms) {
        if (transform.completed) {
            [cameraTransformsToBeRemoved addObject:transform];
            continue;
        }
        
        // waiting for delay
        if (![transform hasStarted]) continue;
        
        if ([transform hasExpired]) {
            // if transform has been completed, finish the transformation
            if (transform.repeat >= 0 && transform.repeatCount >= transform.repeat) {
                if (transform.autoreverse && !transform.reversing) {
                    // no nothing
                } else {
                    [self applyTransformCamera:transform];
                    [self completeTransformCamera:transform];
                    continue;
                }
            }
            
            if (transform.autoreverse) {
                [self applyTransformCamera:transform];
                [transform reverse];
            } else if (transform.repeat < 0) {
                // transform.repeat < 0 means infinite loop
                [self applyTransformCamera:transform];
                [transform start];
            } else {
                [self applyTransformCamera:transform];
                [transform restart];
            }
            continue;
        }
        [self applyTransformCamera:transform];
    }
    
    for (QuickTiGame2dTransform* transform in cameraTransformsToBeRemoved) {
        [cameraTransforms removeObject:transform];
    }
    [cameraTransformsToBeRemoved removeAllObjects];
}

-(void)transformCamera:(QuickTiGame2dTransform*)transform {
    @synchronized (cameraTransforms) {
        [cameraTransforms removeObject:transform];
        [cameraTransforms addObject:transform];
        
        CameraInfo camera = [self getCamera];
        
        // save initial state
        transform.start_x = camera.eyeX;
        transform.start_y = camera.eyeY;
        transform.start_z = camera.eyeZ;
        transform.start_rotate_centerX = camera.centerX;
        transform.start_rotate_centerY = camera.centerY;
                
        [transform start];
        
    }
    
    [[QuickTiGame2dEngine sharedNotificationCenter]
     postNotificationName:@"onStartTransform" object:transform];
}


-(void)applyTransformCamera:(QuickTiGame2dTransform*) transform {
    if (transform.completed) return;
    
    [transform apply];
    
    CameraInfo camera = [self getCamera];
    
    if (transform.x != nil) camera.eyeX = transform.current_x;
    if (transform.y != nil) camera.eyeY = transform.current_y;
    if (transform.z != nil) camera.eyeZ = transform.current_z;
    
    if (transform.rotate_centerX != nil) {
        camera.centerX = transform.current_rotate_centerX;
    } else if (transform.x != nil) {
        camera.centerX = transform.current_x;
    }
    
    if (transform.rotate_centerY != nil) {
        camera.centerY = transform.current_rotate_centerY;
    } else if (transform.y != nil) {
        camera.centerY = transform.current_y;
    }
    
    [self setCamera:camera];
}

-(void)completeTransformCamera:(QuickTiGame2dTransform*) transform {
    
    transform.completed = TRUE;
    
    [[QuickTiGame2dEngine sharedNotificationCenter]
     postNotificationName:@"onCompleteTransform" object:transform];
}

-(void)clearTransformCameras {
    @synchronized(cameraTransforms) {
        for (QuickTiGame2dTransform* transform in cameraTransforms) {
            transform.completed = TRUE;
        }
    }
}

-(void)clearTransformCamera:(QuickTiGame2dTransform*)transform {
    @synchronized(cameraTransforms) {
        transform.completed = TRUE;
    }
}

- (void)addHUD:(QuickTiGame2dSprite*)sprite {
    [hudScene addSprite:sprite];
}

- (void)removeHUD:(QuickTiGame2dSprite*)sprite {
    [hudScene removeSprite:sprite];
}

-(void)setAlpha:(float)alpha {
    color[3] = alpha;
}

-(float)alpha {
    return color[3];
}

@end
