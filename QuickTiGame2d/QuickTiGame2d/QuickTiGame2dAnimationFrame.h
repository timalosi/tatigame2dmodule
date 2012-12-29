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

@interface QuickTiGame2dAnimationFrame : NSObject {
	NSString*   name;
    NSInteger   nameAsInt;
	NSInteger   start;
	NSInteger   count;
	NSInteger   loop;
	NSInteger   interval;
	
	NSInteger   currentLoopCount;
	NSInteger   currentCount;
	
	NSTimeInterval lastOnAnimationInterval;
    
    NSInteger*  frames;
}
@property (copy, readwrite) NSString* name;
@property (readwrite)NSInteger start;
@property (readwrite)NSInteger count;
@property (readwrite)NSInteger loop;
@property (readwrite)NSInteger interval;
@property (readwrite)NSTimeInterval lastOnAnimationInterval;
@property (readonly) NSInteger* frames;
@property (readonly) NSInteger nameAsInt;

-(NSInteger)getNextIndex:(NSInteger)frameCount withIndex:(NSInteger)currentIndex;
-(NSTimeInterval)getLastOnAnimationDelta:(NSTimeInterval)uptime;
-(void)initializeIndividualFrames;
-(void)setFrame:(NSInteger)index withValue:(NSInteger)value;
-(BOOL)isFinished;
-(NSInteger)current;
-(void)updateNameAsInt;
-(NSInteger)nameAsInt;

@end
