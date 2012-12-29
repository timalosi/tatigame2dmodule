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
#import <CoreGraphics/CoreGraphics.h>
#import "QuickTiGame2dUtil.h"
#import "QuickTiGame2dConstant.h"
#import "QuickTiGame2dTexture.h"
#import "QuickTiGame2dAnimationFrame.h"
#import "QuickTiGame2dTransform.h"
#import "ArrayStackQueue.h"

@class QuickTiGame2dEngine;

@interface QuickTiGame2dImagePackInfo : NSObject {
    NSString* name;
    NSInteger x;
    NSInteger y;
    NSInteger width;
    NSInteger height;
    NSInteger index;
}
@property (copy, readwrite) NSString* name;
@property (readwrite) NSInteger x, y, width, height, index;
@end

@interface QuickTiGame2dSprite : NSObject {
    NSString* image;
    NSString* tag;
    
	GLuint* frames_vbos;
	float x;
	float y;
	float z;
	NSInteger width;
	NSInteger height;
	
	BOOL hasTexture;
	BOOL loaded;
	BOOL hasSheet;
    BOOL animating;
    BOOL isPackedAtlas;
	
    float      vertex_tex_coords[8];
	
    float      param_rotate[5];
    float      param_scale[6];
    float      param_color[4];
	
	NSInteger frameCount;
	NSInteger frameIndex;
	NSInteger border;
	NSInteger margin;
	
	NSInteger nextFrameIndex;
	BOOL frameIndexChanged;
	NSMutableDictionary* animations;
	QuickTiGame2dAnimationFrame* currentAnimationFrame;
	NSString* animationName;
    NSString* selectedFrameName;
    
    float orthFactorX;
    float orthFactorY;
    
    NSMutableDictionary* imagepacks;
    NSMutableArray* imagepacks_names;
    
    GLint srcBlendFactor;
    GLint dstBlendFactor;
    
    NSMutableArray* transforms;
    NSMutableArray* transformsToBeRemoved;
    
    NSMutableArray* children;
    
    BOOL  relativeToTransformParent;
    float relativeToTransformParentX;
    float relativeToTransformParentY;
    
    BOOL  followParentTransformPosition;
    BOOL  followParentTransformRotation;
    BOOL  followParentTransformScale;
    BOOL  followParentTransformSize;
    BOOL  followParentTransformColor;
    BOOL  followParentTransformFrameIndex;
    BOOL  followParentTransformRotationCenter;
    
    ArrayStackQueue* beforeCommandQueue;
    ArrayStackQueue* afterCommandQueue;
    
    NSData* textureData;
}
@property (readonly) BOOL hasTexture;
@property (readonly) NSInteger frameCount;
@property (readonly) NSInteger frameIndex;
@property (readonly) BOOL loaded;
@property (readonly) BOOL isPackedAtlas;
@property (readwrite) NSInteger border;
@property (readwrite) NSInteger margin;
@property (readwrite) BOOL hasSheet;
@property (readwrite, copy) NSString* image;
@property (readwrite, copy) NSString* tag;
@property (readwrite) NSInteger width;
@property (readwrite) NSInteger height;
@property (readwrite) float x;
@property (readwrite) float y;
@property (readwrite) float z;
@property (readwrite) float angle;
@property (readwrite) float alpha;
@property (readwrite, copy) NSString* selectedFrameName;
@property (readwrite) GLint srcBlendFactor;
@property (readwrite) GLint dstBlendFactor;
@property (readwrite) float scaleX;
@property (readwrite) float scaleY;
@property (readonly) struct CGPoint center;
@property (readonly) struct CGRect  bounds;
@property (readwrite) struct CGPoint rotationCenter;
@property (readwrite) struct CGPoint scaleCenter;
@property (readwrite) BOOL  relativeToTransformParent;
@property (readwrite) float relativeToTransformParentX;
@property (readwrite) float relativeToTransformParentY;
@property (readonly) QuickTiGame2dTexture* texture;
@property (readwrite) BOOL  followParentTransformPosition;
@property (readwrite) BOOL  followParentTransformRotation;
@property (readwrite) BOOL  followParentTransformRotationCenter;
@property (readwrite) BOOL  followParentTransformScale;
@property (readwrite) BOOL  followParentTransformSize;
@property (readwrite) BOOL  followParentTransformColor;
@property (readwrite) BOOL  followParentTransformFrameIndex;
@property (readonly) float scaledWidth;
@property (readonly) float scaledHeight;
@property (readwrite, retain) NSData* textureData;

-(void)onLoad;
-(void)bindVertex;
-(void)drawFrame:(QuickTiGame2dEngine*)engine;
-(void)onDispose;

-(BOOL)setFrameIndex:(NSInteger)index force:(BOOL)force;
-(BOOL)setFrameIndex:(NSInteger)index;

-(void)addAnimation:(QuickTiGame2dAnimationFrame*)animation;
-(BOOL)setAnimation:(NSString*)_name;
-(QuickTiGame2dAnimationFrame*)getAnimation:(NSString*)_name;
-(BOOL)deleteAnimation:(NSString*)_name;
-(void)deleteAnimations;
-(BOOL)enableAnimation:(BOOL)enable;
-(BOOL)isAnimationFinished;
-(BOOL)pauseAt:(NSInteger)index;
-(void)pause;
-(void)stop;

-(void)animate:(NSInteger)start count:(NSInteger)count interval:(NSInteger)interval;
-(void)animate:(NSInteger)start count:(NSInteger)count interval:(NSInteger)interval loop:(NSInteger)loop;
-(void)animate:(NSArray*)frames interval:(NSInteger)interval;
-(void)animate:(NSArray*)frames interval:(NSInteger)interval loop:(NSInteger)loop;

-(void)color:(float)red green:(float)green blue:(float)blue;
-(void)color:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;
-(void)rotate:(float)angle;
-(void)rotateX:(float)angle;
-(void)rotateY:(float)angle;
-(void)rotateZ:(float)angle;
-(void)rotate:(float)angle centerX:(float)centerX centerY:(float)centerY;
-(void)rotate:(float)angle centerX:(float)centerX centerY:(float)centerY axis:(float)axis;
-(void)scale:(float)scaleXY;
-(void)scale:(float)scaleX scaleY:(float)scaleY;
-(void)scale:(float)scaleX scaleY:(float)scaleY centerX:(float)centerX centerY:(float)centerY;
-(void)move:(float)x y:(float)y;
-(void)move:(float)x y:(float)y z:(float)z;
-(void)moveCenter:(float)x y:(float)y;

-(float)getTexelHalfX;
-(float)getTexelHalfY;

-(void)updateImageSize;
-(BOOL)loadPackedAtlasXml:(NSInteger)initialFrameIndex;
-(BOOL)selectFrame:(NSString*)_name;
-(void)addImagePack:(QuickTiGame2dImagePackInfo*) info;
-(QuickTiGame2dImagePackInfo*)getImagePack:(NSString*)_name;
-(BOOL)deleteImagePack:(NSString*)_name;
-(void)deleteImagePacks;

-(void)onTransform;
-(void)transform:(QuickTiGame2dTransform*)transform;
-(void)clearTransforms;
-(void)clearTransform:(QuickTiGame2dTransform*)transform;

-(void)addChild:(QuickTiGame2dSprite*)child;
-(void)removeChild:(QuickTiGame2dSprite*)child;
-(void)addChildWithRelativePosition:(QuickTiGame2dSprite*)child;

-(void)createTextureBuffer;
-(void)fireOnLoadSprite;

-(BOOL)flipY;

-(BOOL)loadTexture:(NSString*)name base64string:(NSString*)base64string;
-(BOOL)loadTexture:(NSString*)name data:(NSData*)data;
@end

@interface QuickTiGame2dImagePackParser : NSObject <NSXMLParserDelegate> {
    QuickTiGame2dSprite* sprite;
    NSInteger frameIndex;
    NSInteger itemCount;
}
@property (assign, readwrite) QuickTiGame2dSprite* sprite;
@property (readwrite) NSInteger frameIndex;
@end
