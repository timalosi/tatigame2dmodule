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
#import "QuickTiGame2dTransform.h"

@interface ComGooglecodeQuicktigame2dTransformProxy : TiProxy {
    QuickTiGame2dTransform* transform;
    NSMutableDictionary* notificationEventCache;
    NSMutableDictionary* bezierConfigCache;
}
@property (nonatomic, readwrite, assign) id x;
@property (nonatomic, readwrite, assign) id y;
@property (nonatomic, readwrite, assign) id z;
@property (nonatomic, readwrite, assign) id width;
@property (nonatomic, readwrite, assign) id height;
@property (nonatomic, readwrite, assign) id frameIndex;

@property (nonatomic, readwrite, assign) id angle;
@property (nonatomic, readwrite, assign) id rotate_axis;
@property (nonatomic, readwrite, assign) id rotate_centerX;
@property (nonatomic, readwrite, assign) id rotate_centerY;
@property (nonatomic, readwrite, assign) id scaleX;
@property (nonatomic, readwrite, assign) id scaleY;
@property (nonatomic, readwrite, assign) id scale_centerX;
@property (nonatomic, readwrite, assign) id scale_centerY;

@property (nonatomic, readwrite, assign) id red;
@property (nonatomic, readwrite, assign) id green;
@property (nonatomic, readwrite, assign) id blue;
@property (nonatomic, readwrite, assign) id alpha;

@property (nonatomic, readwrite, assign) id delay;
@property (nonatomic, readwrite, assign) id duration;
@property (nonatomic, readwrite, assign) id repeat;
@property (nonatomic, readwrite, assign) id easing;

@property (nonatomic, readwrite, assign) id autoreverse;

@property (nonatomic, readwrite, assign) id lookAt_eyeX;
@property (nonatomic, readwrite, assign) id lookAt_eyeY;
@property (nonatomic, readwrite, assign) id lookAt_eyeZ;
@property (nonatomic, readwrite, assign) id lookAt_centerX;
@property (nonatomic, readwrite, assign) id lookAt_centerY;

@property (nonatomic, readwrite, assign) id bezier;
@property (nonatomic, readwrite, assign) id bezierConfig;

- (QuickTiGame2dTransform*)transformer;

-(void)dispose:(id)args;
-(void)show:(id)args;
-(void)hide:(id)args;
-(void)move:(id)args;

-(void)rotate:(id)args;
-(void)rotateFrom:(id)args;
-(void)rotateX:(id)args;
-(void)rotateY:(id)args;
-(void)rotateZ:(id)args;
-(void)scale:(id)args;
-(void)color:(id)args;

@end
