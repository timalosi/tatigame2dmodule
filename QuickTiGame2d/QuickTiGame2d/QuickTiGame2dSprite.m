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
#import "QuickTiGame2dSprite.h"
#import "QuickTiGame2dEngine.h"
#import "ParticleDataReader.h"
#import "math.h"

@interface QuickTiGame2dSprite (PrivateMethods)
-(BOOL)setFrameIndex:(NSInteger)index force:(BOOL)force;
-(BOOL)setFrameIndex:(NSInteger)index;
-(float)getTexCoordStartX;
-(float)getTexCoordEndX;
-(float)getTexCoordStartY;
-(float)getTexCoordEndY;
-(NSInteger)tex_coord_frame_startX;
-(NSInteger)tex_coord_frame_startY;
-(void)fireOnChangeSpriteZOrder;
-(void)fireOnUnloadSprite;
- (NSComparisonResult) compareZ:(QuickTiGame2dSprite*)other;

-(void)applyTransform:(QuickTiGame2dTransform*)transform;
-(void)applyTransform:(QuickTiGame2dTransform*)transform child:(BOOL)isChild;
-(void)completeTransform:(QuickTiGame2dTransform*) transform;
@end

@implementation QuickTiGame2dSprite
@synthesize loaded;
@synthesize hasTexture, hasSheet;
@synthesize image, tag;
@synthesize frameCount, frameIndex, border, margin;
@synthesize width, height;
@synthesize x, y;
@synthesize isPackedAtlas;
@synthesize selectedFrameName;
@synthesize srcBlendFactor, dstBlendFactor;
@synthesize relativeToTransformParent, relativeToTransformParentX, relativeToTransformParentY;
@synthesize followParentTransformPosition, followParentTransformRotationCenter, followParentTransformScale,
            followParentTransformSize, followParentTransformColor, followParentTransformFrameIndex;
@synthesize textureData;

- (id)init {
    self = [super init];
    if (self != nil) {
        x = 0;
        y = 0;
        z = 0;
        width  = 0;
        height = 0;
        
        hasTexture = FALSE;
        loaded     = FALSE;
        hasSheet   = FALSE;
        animating = FALSE;
        isPackedAtlas = FALSE;
        
        // color param RGBA
        param_color[0] = 1.0f;
        param_color[1] = 1.0f;
        param_color[2] = 1.0f;
        param_color[3] = 1.0f;
        
        // rotate angle, center x, center y, center z, axis
        param_rotate[0] = 0;
        param_rotate[1] = 0;
        param_rotate[2] = 0;
        param_rotate[3] = 0;
        param_rotate[4] = AXIS_Z;
        
        // scale param x, y, z, center x, center y, center z
        param_scale[0] = 1;
        param_scale[1] = 1;
        param_scale[2] = 1;
        param_scale[3] = 0;
        param_scale[4] = 0;
        param_scale[5] = 0;
        
        frameCount  = 1;
        frameIndex = 0;
        border      = 0;
        margin      = 0;
        
        nextFrameIndex    = 0;
        frameIndexChanged = FALSE;
        animations = [[NSMutableDictionary alloc] init];
        currentAnimationFrame = nil;
        
        orthFactorX = 1.0;
        orthFactorY = 1.0;
        
        imagepacks = [[NSMutableDictionary alloc]init];
        imagepacks_names = [[NSMutableArray alloc]init];
        
        srcBlendFactor = GL_ONE;
        dstBlendFactor = GL_ONE_MINUS_SRC_ALPHA;
        
        transforms = [[NSMutableArray alloc] init];
        transformsToBeRemoved = [[NSMutableArray alloc] init];
        
        children = [[NSMutableArray alloc] init];
        relativeToTransformParent = FALSE;
        relativeToTransformParentX = 0;
        relativeToTransformParentY = 0;
        
        followParentTransformPosition = TRUE;
        followParentTransformRotation = TRUE;
        followParentTransformScale    = TRUE;
        followParentTransformSize     = TRUE;
        followParentTransformColor    = TRUE;
        followParentTransformFrameIndex = FALSE;
        followParentTransformRotationCenter = TRUE;
        
        tag = @"";
        
        beforeCommandQueue = [[ArrayStackQueue alloc] init];
        afterCommandQueue  = [[ArrayStackQueue alloc] init];
        
        textureData = nil;
    }
    return self;
}

-(CGPoint)center {
    return CGPointMake((x + (width * 0.5)), y + (height * 0.5));
}

-(CGRect)bounds {
    return CGRectMake(x, y, width, height);
}

-(CGPoint)rotationCenter {
    return CGPointMake(param_rotate[1], param_rotate[2]);
}

-(void)setRotationCenter:(struct CGPoint)value {
    param_rotate[1] = value.x;
    param_rotate[2] = value.y;
}

-(CGPoint)scaleCenter {
    return CGPointMake(param_scale[3], param_scale[4]);
}

-(void)setScaleCenter:(struct CGPoint)value {
    param_scale[3] = value.x;
    param_scale[4] = value.y;
}

-(BOOL)followParentTransformRotation {
    return followParentTransformRotation;
}

-(void)setFollowParentTransformRotation:(BOOL)value {
    followParentTransformRotation       = value;
    followParentTransformRotationCenter = value;
}

-(QuickTiGame2dTexture*)texture {
    return [[QuickTiGame2dEngine sharedTextureCache] objectForKey:image];
}

-(BOOL)loadTexture:(NSString*)name base64string:(NSString*)base64string {
    return [self loadTexture:name data:[ParticleDataReader dataWithBase64EncodedString:base64string]];
}

-(BOOL)loadTexture:(NSString*)name data:(NSData*)data {
    self.image = name;
    self.textureData = data;
    
    return TRUE;
}

-(void)onLoad {
    if (loaded) return;

    if (self.textureData != nil) {
        [QuickTiGame2dEngine loadTexture:self.image data:self.textureData tag:self.tag];
        self.textureData = nil;
    }
    
    QuickTiGame2dTexture* aTexture = [[QuickTiGame2dEngine sharedTextureCache] objectForKey:image];
    
    // if texture is not yet cached, try to load texture here
    if (aTexture == nil && image != nil) {
        [QuickTiGame2dEngine loadTexture:image tag:self.tag];
        aTexture =[[QuickTiGame2dEngine sharedTextureCache] objectForKey:image];
    }
    
    if (aTexture != nil) {
        hasTexture = TRUE;
        
        if (width  == 0) width  = aTexture.width;
        if (height == 0) height = aTexture.height;
        
        if (hasSheet && !isPackedAtlas) {
            frameCount = (int)floor(aTexture.width / (float)(width  + border)) 
                                * floor(aTexture.height /(float)(height + border));
        }
    } else {
        hasTexture = FALSE;
        hasSheet   = FALSE;
        isPackedAtlas = FALSE;
    }
    
    [self createTextureBuffer];
    [self bindVertex];
    
	if (animating && currentAnimationFrame != nil) {
        [self setFrameIndex:[currentAnimationFrame current]];
    }
    
    loaded = TRUE;
    
    if (isPackedAtlas && self.selectedFrameName != nil) {
        [self selectFrame:self.selectedFrameName];
    }
    
    if ([QuickTiGame2dEngine debug] && hasTexture) {
        if (!aTexture.isSnapshot) {
            NSLog(@"[DEBUG] load Sprite: %@", image);
        }
    }

    if (hasTexture && !aTexture.isSnapshot) {
        [self fireOnLoadSprite];
    }
}

-(void)fireOnLoadSprite {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:image, @"name", tag, @"tag", nil];
    [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onLoadSprite" object:self userInfo:userInfo];
}

-(void)fireOnUnloadSprite {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObjectsAndKeys:image, @"name", tag, @"tag", nil];
    [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onUnloadSprite" object:self userInfo:userInfo];
}

-(void)fireOnChangeSpriteZOrder {
    [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onChangeSpriteZOrder" object:self];
}

/*
 * returns whether Y axis of texture should flipped or not
 */
-(BOOL)flipY {
    return hasTexture &&  self.texture.isSnapshot;
}

-(void)bindVertex {
    vertex_tex_coords[0] = [self getTexCoordStartX];
    vertex_tex_coords[1] = [self flipY] ? [self getTexCoordStartY] : [self getTexCoordEndY];
	
    vertex_tex_coords[2] = [self getTexCoordStartX];
    vertex_tex_coords[3] = [self flipY] ? [self getTexCoordEndY] : [self getTexCoordStartY];
	
    vertex_tex_coords[4] = [self getTexCoordEndX];
    vertex_tex_coords[5] = [self flipY] ? [self getTexCoordEndY] : [self getTexCoordStartY];
	
    vertex_tex_coords[6] = [self getTexCoordEndX];
    vertex_tex_coords[7] = [self flipY] ? [self getTexCoordStartY] : [self getTexCoordEndY];
	
	if (frames_vbos[frameIndex] == 0) {
		glGenBuffers (1, &frames_vbos[frameIndex]);
	}
	
	glEnable(GL_TEXTURE_2D);
    glBindBuffer(GL_ARRAY_BUFFER, frames_vbos[frameIndex]);
    glBufferData(GL_ARRAY_BUFFER, sizeof(float) * 8, vertex_tex_coords, GL_STATIC_DRAW);
	
	checkGLErrors(@"QuickTiGame2dSprite: Could not create OpenGL vertex");
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

-(void)drawFrame:(QuickTiGame2dEngine*)engine {
    if (!loaded) return;
	
    @synchronized(beforeCommandQueue) {
        while ([beforeCommandQueue count] > 0) {
            ((CommandBlock)[beforeCommandQueue poll])();
        }
    }
    
	if (frameIndexChanged) {
		frameIndex = nextFrameIndex;
		frameIndexChanged = FALSE;
	}
	
	if (animating && currentAnimationFrame != nil) {
		QuickTiGame2dAnimationFrame* animation = currentAnimationFrame;
		NSTimeInterval delta = [animation getLastOnAnimationDelta:[QuickTiGame2dEngine uptime]];
		if (delta >= animation.interval) {
			[self setFrameIndex:[animation getNextIndex:frameCount withIndex:frameIndex]];
			animation.lastOnAnimationInterval = [QuickTiGame2dEngine uptime];
		}
	}
    
	if (frames_vbos[frameIndex] <= 0) {
		[self bindVertex];
	}

    @synchronized (transforms) {
        [self onTransform];
    }
    
    glMatrixMode (GL_MODELVIEW);
    glLoadIdentity (); 
	
    // update colors
    if (srcBlendFactor == GL_ONE && dstBlendFactor == GL_ONE_MINUS_SRC_ALPHA) {
        glColor4f(param_color[0] * param_color[3],
                  param_color[1] * param_color[3],
                  param_color[2] * param_color[3], param_color[3]);
    } else {
        glColor4f(param_color[0], param_color[1], param_color[2], param_color[3]);
    }
	
    // update position
    glTranslatef(x * orthFactorX, y * orthFactorY, 0);
	
    // rotate angle, center x, center y, center z, axis
    glTranslatef(param_rotate[1], param_rotate[2], param_rotate[3]);
    if (param_rotate[4] == AXIS_X) {
        glRotatef(param_rotate[0], 1, 0, 0);
    } else if (param_rotate[4] == AXIS_Y) {
        glRotatef(param_rotate[0], 0, 1, 0);
    } else {
        glRotatef(param_rotate[0], 0, 0, 1);
    }
    glTranslatef(-param_rotate[1], -param_rotate[2], -param_rotate[3]);
	
    // scale param x, y, z, center x, center y, center z
    glTranslatef(param_scale[3], param_scale[4], param_scale[5]);
    glScalef(param_scale[0], param_scale[1], param_scale[2]);
    glTranslatef(-param_scale[3], -param_scale[4], -param_scale[5]);
	
    // update width and height
    glScalef(width, height, 1);
	
    // bind vertex positions
    glBindBuffer(GL_ARRAY_BUFFER, [QuickTiGame2dEngine sharedPositionPointer]);
    glVertexPointer(3, GL_FLOAT, 0, 0);
	
	// bind a texture
    if (hasTexture) {
		glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, self.texture.textureId);
        
        // bind texture coords
        glBindBuffer(GL_ARRAY_BUFFER, frames_vbos[frameIndex]);
        glTexCoordPointer(2, GL_FLOAT, 0, 0);
	} else {
		glDisable(GL_TEXTURE_2D);
	}
    
    // bind indices
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, [QuickTiGame2dEngine sharedIndexPointer]);
	
    // draw sprite
    glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_SHORT, 0);
    
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindTexture(GL_TEXTURE_2D, 0);
    
    @synchronized(afterCommandQueue) {
        while ([beforeCommandQueue count] == 0 && [afterCommandQueue count] > 0) {
            ((CommandBlock)[afterCommandQueue poll])();
        }
    }
}

-(void)onDispose {
    if (!loaded) return;
    
    if (frames_vbos != NULL) {
        for (int i = 0; i < frameCount; i++) {
            if (frames_vbos[i] > 0) {
                glDeleteBuffers(1, &frames_vbos[i]);
            }
        }
        free(frames_vbos);
    }
        
    loaded = FALSE;
    
    if (hasTexture && !self.texture.isSnapshot) {
        [self fireOnUnloadSprite];
    }
}
-(void)dealloc {
    if ([QuickTiGame2dEngine debug]) {
        if (!self.texture.isSnapshot) {
            NSLog(@"[DEBUG] dealloc Sprite: %@", image);
        }
    }
    [self onDispose];
    
    [image release];
    [imagepacks release];
    [imagepacks_names release];
    [animations release];
    [selectedFrameName release];
    [transforms release];
    [transformsToBeRemoved release];
    [children release];
    [beforeCommandQueue release];
    [afterCommandQueue release];
    
    [super dealloc];
}

-(void)createTextureBuffer {
    frames_vbos = (GLuint *)malloc(sizeof(GLuint) * frameCount);
	
	for (int i = 0; i < frameCount; i++) {
		frames_vbos[i] = 0;
	}
	glGenBuffers (1, &frames_vbos[frameIndex]);
}

-(BOOL)setFrameIndex:(NSInteger)index force:(BOOL)force {
	if (loaded && frameCount <= index) {
		return FALSE;
	}
    if (force) {
        frameIndex = index;
    } else {
        nextFrameIndex = index;
        frameIndexChanged = TRUE;
    }
    
    if (isPackedAtlas) {
        QuickTiGame2dImagePackInfo* info = [self getImagePack:[imagepacks_names objectAtIndex:index]];
        self.width  = info.width;
        self.height = info.height;
    }
    
	return TRUE;
}

-(BOOL)setFrameIndex:(NSInteger)index {
    return [self setFrameIndex:index force:FALSE];
}

-(BOOL)pauseAt:(NSInteger)index {
	if (![self setFrameIndex:index]) {
		return FALSE;
	}
	animating = FALSE;
	
	return TRUE;
}
-(void)pause {
	animating = FALSE;
}
-(void)stop {
	animating = FALSE;
	[self setFrameIndex:0];
}

-(NSInteger)tex_coord_frame_startX {
    if (isPackedAtlas && ![self flipY]) {
        return [self getImagePack:[imagepacks_names objectAtIndex:frameIndex]].x;
    } else if (isPackedAtlas) {
        return self.texture.height - height - [self getImagePack:[imagepacks_names objectAtIndex:frameIndex]].y;
    }
	int xcount = (int)round((self.texture.width - (margin * 2) + border) / (float)(width  + border));
	int xindex = frameIndex % xcount;
	return ((border + width) * xindex) + margin;
}

-(NSInteger) tex_coord_frame_startY {
    if (isPackedAtlas) {
        return [self getImagePack:[imagepacks_names objectAtIndex:frameIndex]].y;
    }
	int xcount = (int)round((self.texture.width - (margin * 2) + border) / (float)(width  + border));
	int ycount = (int)round((self.texture.height - (margin * 2) + border) / (float)(height + border));
	int yindex = [self flipY] ? ycount - (frameIndex / xcount) - 1 : (frameIndex / xcount);
	return ((border + height) * yindex) + margin;
}

-(float) getTexelHalfX {
    if (hasTexture) {
        return (1.0 / self.texture.glWidth) * 0.5;
    } else {
        return 0;
    }   
}   

-(float) getTexelHalfY {
    if (hasTexture) {
        return (1.0 / self.texture.glHeight) * 0.5;
    } else {
        return 0;
    }   
}   

-(float)getTexCoordStartX {
	if (hasSheet) {
        return [self tex_coord_frame_startX] / (float)self.texture.glWidth + [self getTexelHalfX];
    } else {
        return [self getTexelHalfX];
    }
}

-(float)getTexCoordEndX {
	if (!hasTexture) {
		return 1 - [self getTexelHalfX];
    } else if (hasSheet) {
        return (float)([self tex_coord_frame_startX] + width) / (float)self.texture.glWidth - [self getTexelHalfX];
    } else {
        return (float)self.texture.width / (float)self.texture.glWidth - [self getTexelHalfX];
    }
}

-(float)getTexCoordStartY {
	if (!hasTexture) {
		return 1 - [self getTexelHalfY];
	} else if (hasSheet) {
        return (float)([self tex_coord_frame_startY] + height) / (float)self.texture.glHeight - [self getTexelHalfY];
    } else {
        return (float)self.texture.height / (float)self.texture.glHeight - [self getTexelHalfY];
    }
}

-(float)getTexCoordEndY {
    if (hasSheet) {
        return [self tex_coord_frame_startY] / (float)self.texture.glHeight + [self getTexelHalfY];
    } else {
        return [self getTexelHalfY];
    }
}

-(void)addAnimation:(QuickTiGame2dAnimationFrame*)animation {
	[animations setObject:animation forKey:animation.name];
}

-(BOOL)setAnimation:(NSString*)_name {
	if ([self getAnimation:_name] == nil) {
		animationName = nil;
		return FALSE;
	} else {
		animationName = _name;
	}
	return TRUE;
}

-(QuickTiGame2dAnimationFrame*)getAnimation:(NSString*)_name {
    QuickTiGame2dAnimationFrame* animation = [animations objectForKey:_name];
    if (animation == nil || ![animation isKindOfClass:[QuickTiGame2dAnimationFrame class]]) {
        return nil;
    }
    return animation;
}

-(BOOL)deleteAnimation:(NSString*)_name {
	QuickTiGame2dAnimationFrame* animation = [self getAnimation:_name];
    
	if (animation == nil) return FALSE;
	
	[animations removeObjectForKey:_name];
	
	return TRUE;
}

-(void)deleteAnimations {
	[animations removeAllObjects];
}

-(BOOL)enableAnimation:(BOOL)enable {
	animating = enable;
	
	currentAnimationFrame = nil;
	
	if (enable) {
		if (animationName == nil) return FALSE;
		QuickTiGame2dAnimationFrame* animation = [self getAnimation:animationName];
		if (animation == nil) {
			return FALSE;
		} else {
			currentAnimationFrame = animation;
			animation.lastOnAnimationInterval = [QuickTiGame2dEngine uptime];
			[self setFrameIndex:animation.start];
		}
	}
	return TRUE;
}

-(BOOL)isAnimationFinished {
	if (animating && currentAnimationFrame != nil) {
		return [currentAnimationFrame isFinished];
	}
	return TRUE;
}

-(void)animate:(NSInteger)start count:(NSInteger)count interval:(NSInteger)interval {
    [self animate:start count:count interval:interval loop:0];
}

-(void)animate:(NSInteger)start count:(NSInteger)count interval:(NSInteger)interval loop:(NSInteger)loop {
    QuickTiGame2dAnimationFrame* animation = [[QuickTiGame2dAnimationFrame alloc] init];
    
    animation.name  = @DEFAULT_ANIMATION_NAME;
    animation.start = start;
    animation.count = count;
    animation.interval = interval;
    animation.loop     = loop;

    [self addAnimation:animation];
    [self setAnimation:animation.name];
    [self enableAnimation:TRUE];
    
    [animation release];
}

-(void)animate:(NSArray*)frames interval:(NSInteger)interval {
    [self animate:frames interval:interval loop:0];
}

-(void)animate:(NSArray*)frames interval:(NSInteger)interval loop:(NSInteger)loop {
    QuickTiGame2dAnimationFrame* animation = [[QuickTiGame2dAnimationFrame alloc] init];
    
    animation.name  = @DEFAULT_ANIMATION_NAME;
    animation.count = [frames count];
    animation.interval = interval;
    animation.loop     = loop;

    if ([frames count] > 0) {
        animation.start = [[frames objectAtIndex:0] intValue];
    }
    
    [animation initializeIndividualFrames];
    for (int i = 0; i < [frames count]; i++) {
        [animation setFrame:i withValue:[[frames objectAtIndex:i] intValue]];
    }
    
    [self addAnimation:animation];
    [self setAnimation:animation.name];
    [self enableAnimation:TRUE];
    
    [animation release];
}

-(void)move:(float)_x y:(float)_y {
    [self move:_x y:_y z:z];
}

-(void)move:(float)_x y:(float)_y z:(float)_z {
    x = _x;
    y = _y;
    z = _z;
}

-(void)moveCenter:(float)_x y:(float)_y {
    [self move:_x - (width * 0.5) y:_y - (height * 0.5)];
}

-(float)angle {
    return param_rotate[0];
}

-(void)setAngle:(float)angle {
    param_rotate[0] = angle;
}

-(float)alpha {
    return param_color[3];
}

-(void)setAlpha:(float)alpha {
    param_color[3] = alpha;
}

-(void)color:(float)red green:(float)green blue:(float)blue {
    [self color:red green:green blue:blue alpha:param_color[3]];
}

-(void)color:(float)red green:(float)green blue:(float)blue alpha:(float)alpha {
    param_color[0] = red;
    param_color[1] = green;
    param_color[2] = blue;
    param_color[3] = alpha;
}

-(void)rotate:(float)angle {
    [self rotate:angle centerX:(width * 0.5) centerY:(height * 0.5)];
}

-(void)rotateZ:(float)angle {
    [self rotate:angle];
    param_rotate[4] = AXIS_Z;
}

-(void)rotateY:(float)angle {
    [self rotate:angle];
    param_rotate[4] = AXIS_Y;
}

-(void)rotateX:(float)angle {
    [self rotate:angle];
    param_rotate[4] = AXIS_X;
}

-(void)rotate:(float)angle centerX:(float)centerX centerY:(float)centerY {
    [self rotate:angle centerX:centerX centerY:centerY axis:AXIS_Z];
}

-(void)rotate:(float)angle centerX:(float)centerX centerY:(float)centerY axis:(float)axis {
    param_rotate[0] = angle;
    param_rotate[1] = centerX;
    param_rotate[2] = centerY;
    param_rotate[3] = 0;
    param_rotate[4] = axis;
}

-(void)scale:(float)scaleXY {
    [self scale:scaleXY scaleY:scaleXY];
}

-(void)scale:(float)scaleX scaleY:(float)scaleY {
    param_scale[0] = scaleX;
    param_scale[1] = scaleY;
    param_scale[2] = 1;
    param_scale[3] = width  * 0.5;
    param_scale[4] = height * 0.5;
    param_scale[5] = 0;
}

-(void)scale:(float)scaleX scaleY:(float)scaleY centerX:(float)centerX centerY:(float)centerY {
    param_scale[0] = scaleX;
    param_scale[1] = scaleY;
    param_scale[2] = 1;
    param_scale[3] = centerX;
    param_scale[4] = centerY;
    param_scale[5] = 0;
}

-(float)scaleX {
    return param_scale[0]; 
}

-(void)setScaleX:(float)value{
    param_scale[0] = value; 
}

-(float)scaleY {
    return param_scale[1]; 
}

-(void)setScaleY:(float)value{
    param_scale[1] = value; 
}

-(BOOL)loadPackedAtlasXml:(NSInteger)initialFrameIndex {
    // check if the length is shorter than the length of ".xml"
    if ([image length] <= 4) return FALSE;

    NSString* path = [[NSBundle mainBundle] pathForResource:image ofType:nil];
    // if resource is not found, search for the module assets directory
    if (path == nil) {
        path = [[NSBundle mainBundle] pathForResource:
                [NSString stringWithFormat:@"modules/%@/%@", @SHARED_MODULE_NAME, image] ofType:nil];
    }
    if (path == nil) {
        NSLog(@"[WARN] Requested resource is not found: %@", image);
        return FALSE;
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    QuickTiGame2dImagePackParser* pack = [[QuickTiGame2dImagePackParser alloc]init];
    pack.sprite = self;
    pack.frameIndex = initialFrameIndex;
    
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:pack];
    [parser parse];
    [parser release];
    
    [pack release];
    
    frameCount = [imagepacks_names count];
    
    return TRUE;
}

-(BOOL)selectFrame:(NSString*)_name {
    if (!isPackedAtlas) return FALSE;
    
    self.selectedFrameName = _name;
    
    QuickTiGame2dImagePackInfo* info = [self getImagePack:_name];
    if (info == nil) return FALSE;
    
    return [self setFrameIndex:info.index];
}

-(void)addImagePack:(QuickTiGame2dImagePackInfo*) info {
	[self deleteImagePack:info.name];
	[imagepacks setObject:info forKey:info.name];
    [imagepacks_names addObject:info.name];
}

-(QuickTiGame2dImagePackInfo*)getImagePack:(NSString*)_name {
	return [imagepacks objectForKey:_name];
}

-(BOOL)deleteImagePack:(NSString*)_name {
	QuickTiGame2dImagePackInfo* info = [self getImagePack:_name];
    
	if (info == nil) return FALSE;
	
	[imagepacks removeObjectForKey:_name];
	
	return TRUE;
}

-(void)deleteImagePacks {
	[imagepacks removeAllObjects];
}

-(void)updateImageSize {
    if ([image hasSuffix:@".xml"]) {
        isPackedAtlas = TRUE;
        hasSheet      = TRUE;
        
        if (![self loadPackedAtlasXml:frameIndex]) {
            NSLog(@"[WARN] packed atlas loading failed: %@", image);
        }
        
    } else if (width == 0 && height == 0) {
        loadImageSize(image, &width, &height);
    }
}

-(float)z {
    return z;
}

-(void)setZ:(float)_z {
    z = _z;
    
    if (loaded) {
        [self fireOnChangeSpriteZOrder];
    }
}

- (NSComparisonResult) compareZ:(QuickTiGame2dSprite*)other {
	if (self.z < other.z) {
		return NSOrderedAscending;
	} else if (self.z > other.z) {
		return NSOrderedDescending;
	} else {
		return NSOrderedSame;
	}
}


-(void)onTransform {
    if ([transforms count] == 0) return;

    for (QuickTiGame2dTransform* transform in transforms) {
        if (transform.completed) {
            [transformsToBeRemoved addObject:transform];
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
                    [self applyTransform:transform];
                    [self completeTransform:transform];
                    continue;
                }
            }
            
            if (transform.autoreverse) {
                [self applyTransform:transform];
                [transform reverse];
            } else if (transform.repeat < 0) {
                // transform.repeat < 0 means infinite loop
                [self applyTransform:transform];
                [transform start];
            } else {
                [self applyTransform:transform];
                [transform restart];
            }
            continue;
        }
        [self applyTransform:transform];
    }

    for (QuickTiGame2dTransform* transform in transformsToBeRemoved) {
        [transforms removeObject:transform];
    }
    [transformsToBeRemoved removeAllObjects];
}

-(void)transform:(QuickTiGame2dTransform*)transform {
    @synchronized(children) {
        for (QuickTiGame2dSprite* child in children) {
            if (child.relativeToTransformParent) {
                child.relativeToTransformParentX = child.x - self.x;
                child.relativeToTransformParentY = child.y - self.y;
            }
        }
    }
    
    @synchronized (transforms) {
        [transforms removeObject:transform];
        [transforms addObject:transform];
        
        // save initial state
        transform.start_x = x;
        transform.start_y = y;
        transform.start_z = z;
        transform.start_width  = width;
        transform.start_height = height;
        transform.start_frameIndex = frameIndex;
        transform.start_angle = param_rotate[0];
        transform.start_rotate_axis = param_rotate[4];
        transform.start_rotate_centerX = param_rotate[1];
        transform.start_rotate_centerY = param_rotate[2];
        
        transform.start_scaleX = param_scale[0];
        transform.start_scaleY = param_scale[1];
        transform.start_red   = param_color[0];
        transform.start_green = param_color[1];
        transform.start_blue  = param_color[2];
        transform.start_alpha = param_color[3];
        
        [transform start];
        
    }
    
    [[QuickTiGame2dEngine sharedNotificationCenter]
        postNotificationName:@"onStartTransform" object:transform];
}


-(void)applyTransform:(QuickTiGame2dTransform*)transform {
    [self applyTransform:transform child:FALSE];
}

-(void)applyTransform:(QuickTiGame2dTransform*)transform child:(BOOL)isChild {

    if (transform.completed) return;
    
    transform.locked = isChild;

    [transform apply];
    
    if (isChild && relativeToTransformParent) {
        if (transform.x != nil && (!isChild || followParentTransformPosition)) x = transform.current_x + relativeToTransformParentX;
        if (transform.y != nil && (!isChild || followParentTransformPosition)) y = transform.current_y + relativeToTransformParentY;
    } else {
        if (transform.x != nil && (!isChild || followParentTransformPosition)) x = transform.current_x;
        if (transform.y != nil && (!isChild || followParentTransformPosition)) y = transform.current_y;
    }
    
    if (transform.z != nil && (!isChild || followParentTransformPosition)) z = transform.current_z;
    if (transform.width  != nil && (!isChild || followParentTransformSize)) width  = transform.current_width;
    if (transform.height != nil && (!isChild || followParentTransformSize)) height = transform.current_height;
    if (transform.frameIndex != nil && (!isChild || followParentTransformFrameIndex)) frameIndex = transform.current_frameIndex;
    
    if (transform.angle != nil && (!isChild || followParentTransformRotation)) {
        if (transform.rotate_centerX == nil && transform.rotate_centerY == nil) {
            [self rotate:transform.current_angle];
        } else {
            [self setAngle:transform.current_angle];
        }
    }
    
    if (transform.rotate_axis != nil && (!isChild || followParentTransformRotation)) {
        param_rotate[4] = [transform.rotate_axis intValue];
    }
    if (transform.rotate_centerX != nil && (!isChild || followParentTransformRotationCenter)) {
        param_rotate[1] = [transform.rotate_centerX floatValue];
    }
    
    if (transform.rotate_centerY != nil && (!isChild || followParentTransformRotationCenter)) {
        param_rotate[2] = [transform.rotate_centerY floatValue];
    }
    
    if (transform.scaleX != nil && (!isChild || followParentTransformScale)) {
        [self scale:transform.current_scaleX];
    }
    if (transform.scaleY != nil && (!isChild || followParentTransformScale)) {
        [self scale:param_scale[0] scaleY:transform.current_scaleY];
    }
    if (transform.scale_centerX != nil && transform.scale_centerY != nil && (!isChild || followParentTransformScale)) {
        param_scale[3] = [transform.scale_centerX floatValue];
        param_scale[4] = [transform.scale_centerY floatValue];
    }
    
    if (transform.red    != nil && (!isChild || followParentTransformColor)) param_color[0] = transform.current_red;
    if (transform.green  != nil && (!isChild || followParentTransformColor)) param_color[1] = transform.current_green;
    if (transform.blue   != nil && (!isChild || followParentTransformColor)) param_color[2] = transform.current_blue;
    if (transform.alpha  != nil && (!isChild || followParentTransformColor)) param_color[3] = transform.current_alpha;
    
    @synchronized(children) {
        for (QuickTiGame2dSprite* child in children) {
            [child applyTransform:transform child:TRUE];
        }
    }
}

-(void)completeTransform:(QuickTiGame2dTransform*) transform {
    
    transform.completed = TRUE;
    
    [[QuickTiGame2dEngine sharedNotificationCenter]
        postNotificationName:@"onCompleteTransform" object:transform];
}

-(void)clearTransforms {
    @synchronized(transforms) {
        for (QuickTiGame2dTransform* transform in transforms) {
            transform.completed = TRUE;
        }
    }
}

-(void)clearTransform:(QuickTiGame2dTransform*)transform {
    @synchronized(transforms) {
        transform.completed = TRUE;
    }
}

-(void)addChild:(QuickTiGame2dSprite*)child {
    @synchronized(children) {
        child.relativeToTransformParent  = FALSE;
        child.relativeToTransformParentX = 0;
        child.relativeToTransformParentY = 0;
        [children addObject:child];
    }
}

-(void)addChildWithRelativePosition:(QuickTiGame2dSprite*)child {
    @synchronized(children) {
        child.relativeToTransformParent = TRUE;
        [children addObject:child];
    }
}

-(void)removeChild:(QuickTiGame2dSprite*)child {
    @synchronized(children) {
        [children removeObject:child];
    }
}

-(float)scaledWidth {
    return self.width * self.scaleX;
}

-(float)scaledHeight {
    return self.height * self.scaleY;
}
@end

@implementation QuickTiGame2dImagePackInfo 
@synthesize name;
@synthesize x, y, width, height, index;
-(void)dealloc {
    [name release];
    [super dealloc];
}
@end

@implementation QuickTiGame2dImagePackParser
@synthesize sprite;
@synthesize frameIndex;

- (id)init {
    self = [super init];
    if (self != nil) {
        itemCount  = 0;
        frameIndex = 0;
    }
    return self;
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"Imageset"] || [elementName isEqualToString:@"TextureAtlas"]) {
        for (id key in attributeDict) {
            if ([key isEqualToString:@"Imagefile"] || [key isEqualToString:@"imagePath"]) {
                sprite.image = [attributeDict objectForKey:key];
                break;
            }
        }
    } else if ([elementName isEqualToString:@"Image"] || [elementName isEqualToString:@"SubTexture"]) {
        QuickTiGame2dImagePackInfo* info = [[QuickTiGame2dImagePackInfo alloc]init];
        
        for (id key in attributeDict) {
            if ([key isEqualToString:@"name"] || [key isEqualToString:@"Name"]) {
                info.name = [attributeDict objectForKey:key];
            } else if ([key isEqualToString:@"x"] || [key isEqualToString:@"XPos"]) {
                info.x = [[attributeDict objectForKey:key] intValue];
            } else if ([key isEqualToString:@"y"] || [key isEqualToString:@"YPos"]) {
                info.y = [[attributeDict objectForKey:key] intValue];
            } else if ([key isEqualToString:@"width"] || [key isEqualToString:@"Width"]) {
                info.width = [[attributeDict objectForKey:key] intValue];
            } else if ([key isEqualToString:@"height"] || [key isEqualToString:@"Height"]) {
                info.height = [[attributeDict objectForKey:key] intValue];
            }
        }
        if ([info.name length] > 0) {
            info.index = itemCount;
            if (info.index == frameIndex) {
                sprite.width  = info.width;
                sprite.height = info.height;
                sprite.margin = 0;
                sprite.border = 0;
            }
            [sprite addImagePack:info];
            itemCount++;
        }
        [info release];
    }
}

@end

