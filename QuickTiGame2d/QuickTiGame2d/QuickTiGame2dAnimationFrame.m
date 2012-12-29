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
#import "QuickTiGame2dAnimationFrame.h"
#import "QuickTiGame2dEngine.h"

@implementation QuickTiGame2dAnimationFrame
@synthesize name, nameAsInt;
@synthesize start, count, loop, interval;
@synthesize lastOnAnimationInterval;
@synthesize frames;

- (id)init {
    self = [super init];
    if (self != nil) {
        start      = 0;
        count      = 1;
        interval   = 0;
        loop       = 0;
        currentLoopCount = 0;
        currentCount = 0;
        lastOnAnimationInterval = [QuickTiGame2dEngine uptime];
        frames = nil;
        nameAsInt  = -1;
    }
    return self;
}

-(BOOL)isFinished {
	return (loop >= 0 && currentLoopCount > loop);
}

-(void)initializeIndividualFrames {
    if (frames != nil) free(frames);
    frames = (NSInteger *)malloc(sizeof(NSInteger) * count);
    for (int i = 0; i < count; i++) {
        frames[i] = 0;
    }
}

-(void)setFrame:(NSInteger)index withValue:(NSInteger)value {
    frames[index] = value;
}

-(NSInteger)current {
    if (frames != nil) {
        return frames[currentCount];
    } else {
        return currentCount + start;
    }
}

-(NSInteger)getNextIndex:(NSInteger)frameCount withIndex:(NSInteger)currentIndex {
	
	if ([self isFinished]) {
		return currentIndex;
	}
	
	currentCount++;
	
	if (currentCount >= count) {
		currentCount = 0;
		if (loop >= 0) {
			currentLoopCount++;
		}
	}
	
	if ([self isFinished]) {
		return currentIndex;
	} else if (currentCount + start >= frameCount) {
		currentCount = 0;
	}
	
    if (frames != nil) {
        return frames[currentCount];
    } else {
        return currentCount + start;
	}
}

-(NSTimeInterval)getLastOnAnimationDelta:(NSTimeInterval)uptime {
	return (uptime - lastOnAnimationInterval) * 1000;
}

-(void)updateNameAsInt {
    nameAsInt = [name intValue];
}

-(void)dealloc {
	[name release];
    if (frames != nil) free(frames);
    
	[super dealloc];
}

@end
