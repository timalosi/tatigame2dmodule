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
#import "TiProxy.h"
#import "QuickTiGame2dSprite.h"

@interface ComGooglecodeQuicktigame2dSpriteProxy : TiProxy {
    QuickTiGame2dSprite* sprite;
    NSMutableDictionary* centerInfoCache;
    NSMutableDictionary* rotationCenterInfoCache;
    NSMutableDictionary* scaleCenterInfoCache;
}
@property (nonatomic, readwrite, assign) id image;
@property (nonatomic, readwrite, assign) id data;
@property (nonatomic, readwrite, assign) id tag;
@property (nonatomic, readwrite, assign) id width;
@property (nonatomic, readwrite, assign) id height;
@property (nonatomic, readwrite, assign) id x;
@property (nonatomic, readwrite, assign) id y;
@property (nonatomic, readwrite, assign) id z;
@property (nonatomic, readwrite, assign) id angle;
@property (nonatomic, readwrite, assign) id alpha;
@property (nonatomic, readwrite, assign) id scaleX;
@property (nonatomic, readwrite, assign) id scaleY;
@property (nonatomic, readwrite, assign) id center;
@property (nonatomic, readwrite, assign) id rotationCenter;
@property (nonatomic, readwrite, assign) id scaleCenter;
@property (nonatomic, readwrite, assign) id followParentTransformPosition;
@property (nonatomic, readwrite, assign) id followParentTransformRotation;
@property (nonatomic, readwrite, assign) id followParentTransformRotationCenter;
@property (nonatomic, readwrite, assign) id followParentTransformScale;
@property (nonatomic, readwrite, assign) id followParentTransformSize;
@property (nonatomic, readwrite, assign) id followParentTransformColor;
@property (nonatomic, readwrite, assign) id followParentTransformFrameIndex;

- (QuickTiGame2dSprite*)sprite;
- (void)onNotification:(NSString*)type userInfo:(NSDictionary*)userInfo;

- (void)onAdd;
- (void)onRemove;

-(void)loadTextureByBlobWithName:(id)args;
-(void)loadTextureByBlob:(id)args;

-(void)dispose:(id)args;
-(void)show:(id)args;
-(void)hide:(id)args;
-(id)collidesWith:(id)args;
-(id)contains:(id)args;

- (void)rotate:(id)args;
- (void)rotateFrom:(id)args;
- (void)rotateX:(id)args;
- (void)rotateY:(id)args;
- (void)rotateZ:(id)args;
- (void)rotateFromAxis:(id)args;
- (void)scale:(id)args;
- (void)scaleBy:(id)args;
- (void)scaleFromCenter:(id)args;
- (void)color:(id)args;
- (void)move:(id)args;

- (void)blendFunc:(id)args;
- (void)transform:(id)args;
- (void)clearTransforms:(id)args;
- (void)clearTransform:(id)args;

- (void)addChild:(id)args;
- (void)removeChild:(id)args;

- (void)addTransformChild:(id)args;
- (void)removeTransformChild:(id)args;
- (void)addTransformChildWithRelativePosition:(id)args;
@end
