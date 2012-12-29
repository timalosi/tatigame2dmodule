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
#import "QuickTiGame2dScene.h"
#import "QuickTiGame2dUtil.h"
#import "QuickTiGame2dEngine.h"

@interface QuickTiGame2dScene (PrivateMethods)
-(void)onTransform;
-(void)applyTransform;
-(void)completeTransform;
@end

@implementation QuickTiGame2dScene
@synthesize loaded;
@synthesize name;
@synthesize snapshot;
@synthesize debug, isHUD;
@synthesize srcBlendFactor, dstBlendFactor;

- (id)init {
    self = [super init];
    if (self != nil) {
		color[0] = 0;
		color[1] = 0;
		color[2] = 0;
		color[3] = 1;
        
        sprites = [[NSMutableArray alloc] init];
        waitingForAddSprites = [[NSMutableArray alloc] init];
        waitingForRemoveSprites = [[NSMutableArray alloc] init];
        spritesToDraw = [[NSArray alloc] init];
        
        snapshot = FALSE;
        
        srcBlendFactor = GL_ONE;
        dstBlendFactor = GL_ONE_MINUS_SRC_ALPHA;
        
        sortOrderDirty = TRUE;
        
        transform = nil;
        
        isHUD = FALSE;
    }
    return self;
}

- (void)onChangeSpriteZOrder:(NSNotification*)notification {
    sortOrderDirty = TRUE;
}

-(void)onLoad {
    if (loaded) return;
    loaded = TRUE; 
    
    [[QuickTiGame2dEngine sharedNotificationCenter] addObserver:self 
            selector:@selector(onChangeSpriteZOrder:) name:@"onChangeSpriteZOrder" object:nil];
}

-(void)drawFrame:(QuickTiGame2dEngine*)engine {
    if (!loaded) return;
    
    @synchronized (transform) {
        [self onTransform];
    }

    if (!isHUD) {
        glClearColor(color[0], color[1], color[2], color[3]);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }
    
    [self addWaitingSprites];
    [self removeWaitingSprites];
    
    if (sortOrderDirty) {
		[spritesToDraw release];
		spritesToDraw = [[sprites sortedArrayUsingSelector:@selector(compareZ:)] retain];
		sortOrderDirty = FALSE;
    }
    
    for (int i = 0; i < [spritesToDraw count]; i++) {
        QuickTiGame2dSprite* sprite = [spritesToDraw objectAtIndex:i];
        if (!sprite.loaded) {
            [sprite onLoad];
        }
        if ((srcBlendFactor != sprite.srcBlendFactor) ||
            (dstBlendFactor != sprite.dstBlendFactor)) {
            srcBlendFactor = sprite.srcBlendFactor;
            dstBlendFactor = sprite.dstBlendFactor;
            glBlendFunc(srcBlendFactor, dstBlendFactor);
        }
        [sprite drawFrame:engine];
    }
}

-(void)addWaitingSprites {
    @synchronized(waitingForAddSprites) {
        if (!snapshot && [waitingForAddSprites count] > 0) {
            for (QuickTiGame2dSprite* sprite in waitingForAddSprites) {
                if (debug) NSLog(@"[DEBUG] addSprite: %@", sprite.image);
                [sprites addObject:sprite];
            }
            [waitingForAddSprites removeAllObjects];
            sortOrderDirty = TRUE;
        }
    }
}
-(void)removeWaitingSprites {
    @synchronized(waitingForRemoveSprites) {
        if (!snapshot && [waitingForRemoveSprites count] > 0) {
            for (QuickTiGame2dSprite* sprite in waitingForRemoveSprites) {
                if (debug) NSLog(@"[DEBUG] removeSprite: %@", sprite.image);
                [sprites removeObject:sprite];
            }
            [waitingForRemoveSprites removeAllObjects];
            sortOrderDirty = TRUE;
        }
    }
}

-(void)onDeactivate {
    [self removeWaitingSprites];
}

-(void)onDispose {
    if (!loaded) return;

    [sprites removeAllObjects];
    [waitingForRemoveSprites removeAllObjects];
    [waitingForAddSprites removeAllObjects];
    
    [[QuickTiGame2dEngine sharedNotificationCenter] removeObserver:self];
    
    loaded = FALSE;
}

-(void)dealloc {
    [spritesToDraw release];
    [sprites release];
    [waitingForAddSprites release];
    [waitingForRemoveSprites release];
    [transform release];
    [super dealloc];
}

-(void)addSprite:(QuickTiGame2dSprite*)sprite {
    @synchronized(waitingForAddSprites) {
        [waitingForAddSprites addObject:sprite];
    }
}

-(void)removeSprite:(QuickTiGame2dSprite*)sprite {
    @synchronized(waitingForRemoveSprites) {
        [waitingForRemoveSprites addObject:sprite];
    }
}

-(BOOL)hasSprite {
    return [sprites count] > 0 || [waitingForAddSprites count] > 0;
}

-(float)alpha {
    return color[3];
}

-(void)setAlpha:(float)alpha {
    color[3] = alpha;
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

-(void)onTransform {
    if (transform == nil) return;
    if (transform.completed) return;
    
    // waiting for delay
    if (![transform hasStarted]) return;
    
    if ([transform hasExpired]) {
        // if transform has been completed, finish the transformation
        if (transform.repeatCount >= transform.repeat) {
            if (transform.autoreverse && !transform.reversing) {
                // no nothing
            } else {
                [self applyTransform];
                [self completeTransform];
                return;
            }
        }
        
        if (transform.autoreverse) {
            [transform reverse];
        } else {
            [transform restart];
        }
    }
    
    [self applyTransform];
}

-(void)transform:(QuickTiGame2dTransform*) _transform {
    @synchronized (transform) {
        
        if (transform != nil) {
            [transform release];
            transform = nil;
        }
        
        transform = [_transform retain];
        
        // save initial state
        transform.start_red   = color[0];
        transform.start_green = color[1];
        transform.start_blue  = color[2];
        transform.start_alpha = color[3];
        
        [transform start];
    }
    
    [[QuickTiGame2dEngine sharedNotificationCenter]
     postNotificationName:@"onStartTransform" object:transform];
}


-(void)applyTransform {
    [transform apply];
    
    if (transform.red    != nil) color[0] = transform.current_red;
    if (transform.green  != nil) color[1] = transform.current_green;
    if (transform.blue   != nil) color[2] = transform.current_blue;
    if (transform.alpha  != nil) color[3] = transform.current_alpha;
}

-(void)completeTransform {

    transform.completed = TRUE;
    
    [[QuickTiGame2dEngine sharedNotificationCenter]
     postNotificationName:@"onCompleteTransform" object:transform];
    
}

@end
