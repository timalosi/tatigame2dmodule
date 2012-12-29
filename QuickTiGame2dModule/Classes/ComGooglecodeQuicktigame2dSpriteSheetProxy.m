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
#import "ComGooglecodeQuicktigame2dSpriteSheetProxy.h"
#import "QuickTiGame2dUtil.h"
#import "TiUtils.h"

@implementation ComGooglecodeQuicktigame2dSpriteSheetProxy

- (id)init {
    self = [super init];
    if (self != nil) {
        sprite.hasSheet = TRUE;
    }
    return self;
}

#pragma Public APIs

- (void)animate:(id)args {
    if ([args count] >= 2 && [[args objectAtIndex:0] isKindOfClass:[NSArray class]]) {
        NSArray* frames    = [args objectAtIndex:0];
        NSInteger interval = [[args objectAtIndex:1] intValue];

        if ([args count] == 2) {
            [sprite animate:frames interval:interval];
        } else {
            [sprite animate:frames interval:interval loop:[[args objectAtIndex:2] intValue]];
        }
        return;
    }
    
    if ([args count] < 3) {
        NSLog(@"Too few arguments for sprite.animate(start, count, interval, loop)");
        return;
    }
    
    NSInteger start = [[args objectAtIndex:0] intValue];
    NSInteger count = [[args objectAtIndex:1] intValue];
    NSInteger interval = [[args objectAtIndex:2] intValue];
        
    if ([args count] == 3) {
        [sprite animate:start count:count interval:interval];
    } else {
        NSInteger loop = [[args objectAtIndex:3] intValue];
        [sprite animate:start count:count interval:interval loop:loop];
    }
}

- (void)stop:(id)args {
    [sprite stop];
}

- (void)pause:(id)args {
    [sprite pause];
}

- (void)pauseAt:(id)args {
    ENSURE_SINGLE_ARG(args, NSNumber);
    [sprite pauseAt:[args intValue]];
}

- (void)selectFrame:(id)args {
    ENSURE_SINGLE_ARG(args, NSString);
    [sprite selectFrame:[TiUtils stringValue:args]];
}

- (void)setFrame:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [sprite setFrameIndex:[value intValue]];
}

- (id)frame {
    return NUMINT(sprite.frameIndex);
}

- (id)frameCount {
    return NUMINT(sprite.frameCount);
}

- (id)border {
    return NUMINT(sprite.border);
}

- (void)setBorder:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    sprite.border = [value intValue];
}

- (id)margin {
    return NUMINT(sprite.margin);
}

- (void)setMargin:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    sprite.margin = [value intValue];
}

- (id)isAnimationFinished:(id)args {
    return NUMBOOL([sprite isAnimationFinished]);
}
@end
