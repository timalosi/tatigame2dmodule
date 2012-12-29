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
#import "ComGooglecodeQuicktigame2dSceneProxy.h"
#import "ComGooglecodeQuicktigame2dSpriteProxy.h"
#import "ComGooglecodeQuicktigame2dTransformProxy.h"
#import "TiUtils.h"

@implementation ComGooglecodeQuicktigame2dSceneProxy
- (id)init {
    self = [super init];
    if (self != nil) {
        scene = [[QuickTiGame2dScene alloc] init];
        spriteStack = [[ArrayStackQueue alloc] init];
    }
    return self;
}

- (void)dealloc {
    [scene release];
    [spriteStack release];
    [super dealloc];
}

- (QuickTiGame2dScene*)scene {
    return scene;
}

/*
 * notification event that is issued by game engine
 * onload, ongainedfocus, enterframe, onlostfocus, ondispose
 */
- (void)onNotification:(NSString*)type userInfo:(NSDictionary*)userInfo {
    [self fireEvent:type withObject:userInfo propagate:NO];
    
    @synchronized(spriteStack) {
        for (ComGooglecodeQuicktigame2dSpriteProxy* sprite in spriteStack) {
            [sprite onNotification:type userInfo:userInfo];
        }
    }
}

- (void)onActivate {
    [self fireEvent:@"activated" withObject:nil propagate:NO];
}

- (void)onDeactivate {
    [self fireEvent:@"deactivated" withObject:nil propagate:NO];
}

#pragma Public APIs

-(void)dispose:(id)args {
    RELEASE_TO_NIL(scene)
}

- (void)color:(id)args {
    if ([args count] == 3) {
        [scene color:
         [[args objectAtIndex:0] floatValue]
                green:[[args objectAtIndex:1] floatValue]
                 blue:[[args objectAtIndex:2] floatValue]
         ];
    } else if ([args count] >= 4) {
        [scene color:
         [[args objectAtIndex:0] floatValue]
                green:[[args objectAtIndex:1] floatValue]
                 blue:[[args objectAtIndex:2] floatValue]
                alpha:[[args objectAtIndex:3] floatValue]
         ];
    } else {
        NSLog(@"[ERROR] Too few arguments for scene.color(red, green, blue, alpha)");
    }
}

-(id)alpha {
    return NUMFLOAT(scene.alpha);
}

- (void)setAlpha:(id)args {
    ENSURE_SINGLE_ARG(args, NSNumber);
    scene.alpha = [args floatValue];
}

-(void)setName:(id)value {
    scene.name = [[[TiUtils stringValue:value] copy] autorelease];
}

-(id)name {
    return scene.name;
}

-(id)add:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dSpriteProxy);
    @synchronized(spriteStack) {
        [spriteStack push:args];
    }
    [args onAdd];
    
    [scene addSprite:[args sprite]];
    return args;
}

-(void)remove:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dSpriteProxy);
    [args onRemove];
    @synchronized(spriteStack) {
        [spriteStack removeObject:args];
    }
    
    [scene removeSprite:[args sprite]];
}

- (void)transform:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dTransformProxy);
    [scene transform:[args transformer]];
}

@end
