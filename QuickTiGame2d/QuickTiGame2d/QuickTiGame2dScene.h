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
#import "QuickTiGame2dSprite.h"
#import "QuickTiGame2dTransform.h"

@class QuickTiGame2dEngine;

@interface QuickTiGame2dScene : NSObject {
    NSString* name;
    float color[4];
    BOOL loaded;
    BOOL snapshot;
    NSMutableArray* sprites;
    NSMutableArray* waitingForAddSprites;
    NSMutableArray* waitingForRemoveSprites;
    NSArray* spritesToDraw;
    
    BOOL debug;
    BOOL sortOrderDirty;
    
    GLint srcBlendFactor;
    GLint dstBlendFactor;
    
    QuickTiGame2dTransform* transform;
    
    BOOL isHUD;
}
@property (readwrite, copy) NSString* name;
@property (readonly) BOOL loaded;
@property (readwrite) BOOL debug;
@property (readwrite) BOOL snapshot;
@property (readwrite) GLint srcBlendFactor;
@property (readwrite) GLint dstBlendFactor;
@property (readwrite) BOOL isHUD;
@property (readwrite) float alpha;

-(void)addSprite:(QuickTiGame2dSprite*)sprite;
-(void)removeSprite:(QuickTiGame2dSprite*)sprite;
-(void)addWaitingSprites;
-(void)removeWaitingSprites;
-(void)color:(float)red green:(float)green blue:(float)blue;
-(void)color:(float)red green:(float)green blue:(float)blue alpha:(float)alpha;

-(void)onChangeSpriteZOrder:(NSNotification*)notification;
-(void)onLoad;
-(void)drawFrame:(QuickTiGame2dEngine*)engine;
-(void)onDeactivate;
-(void)onDispose;

-(BOOL)hasSprite;

-(void)transform:(QuickTiGame2dTransform*) _transform;
@end
