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

@interface QuickTiGame2dTransform : NSObject {
    NSNumber* x;
    NSNumber* y;
    NSNumber* z;
    NSNumber* width;
    NSNumber* height;
    NSNumber* frameIndex;
    
    NSNumber* angle;
    NSNumber* rotate_axis;
    NSNumber* rotate_centerX;
    NSNumber* rotate_centerY;
    
    NSNumber* scaleX;
    NSNumber* scaleY;
    NSNumber* scale_centerX;
    NSNumber* scale_centerY;
    
    NSNumber* red;
    NSNumber* green;
    NSNumber* blue;
    NSNumber* alpha;

    float start_x;
    float start_y;
    float start_z;
    NSInteger start_width;
    NSInteger start_height;
    NSInteger start_frameIndex;
    
    float start_angle;
    float start_rotate_axis;
    float start_rotate_centerX;
    float start_rotate_centerY;
    
    float start_scaleX;
    float start_scaleY;
    
    float start_red;
    float start_green;
    float start_blue;
    float start_alpha;

    float current_x;
    float current_y;
    float current_z;
    NSInteger current_width;
    NSInteger current_height;
    NSInteger current_frameIndex;
    
    float current_angle;
    float current_rotate_axis;
    float current_rotate_centerX;
    float current_rotate_centerY;
    
    float current_scaleX;
    float current_scaleY;
    
    float current_red;
    float current_green;
    float current_blue;
    float current_alpha;

    NSTimeInterval startTime;
    
    NSInteger delay;
    NSInteger duration;
    NSInteger repeat;
    
    NSInteger easing;
    NSInteger repeatCount;
    
    BOOL autoreverse;
    BOOL reversing;
    
    BOOL completed;
    BOOL locked;

    // Bezier
    BOOL useBezier;
    NSNumber* bezierCurvePoint1_X;
    NSNumber* bezierCurvePoint1_Y;
    
    NSNumber* bezierCurvePoint2_X;
    NSNumber* bezierCurvePoint2_Y;

}
@property (readwrite, retain) NSNumber* x;
@property (readwrite, retain) NSNumber* y;
@property (readwrite, retain) NSNumber* z;
@property (readwrite, retain) NSNumber* width;
@property (readwrite, retain) NSNumber* height;
@property (readwrite, retain) NSNumber* frameIndex;
@property (readwrite, retain) NSNumber* angle;
@property (readwrite, retain) NSNumber* rotate_axis;
@property (readwrite, retain) NSNumber* rotate_centerX;
@property (readwrite, retain) NSNumber* rotate_centerY;
@property (readwrite, retain) NSNumber* scaleX;
@property (readwrite, retain) NSNumber* scaleY;
@property (readwrite, retain) NSNumber* scale_centerX;
@property (readwrite, retain) NSNumber* scale_centerY;
@property (readwrite, retain) NSNumber* red;
@property (readwrite, retain) NSNumber* green;
@property (readwrite, retain) NSNumber* blue;
@property (readwrite, retain) NSNumber* alpha;

@property (readwrite, retain) NSNumber* bezierCurvePoint1_X;
@property (readwrite, retain) NSNumber* bezierCurvePoint1_Y;
@property (readwrite, retain) NSNumber* bezierCurvePoint2_X;
@property (readwrite, retain) NSNumber* bezierCurvePoint2_Y;

@property (readwrite) float current_x;
@property (readwrite) float current_y;
@property (readwrite) float current_z;
@property (readwrite) NSInteger current_width;
@property (readwrite) NSInteger current_height;
@property (readwrite) NSInteger current_frameIndex;
@property (readwrite) float current_angle;
@property (readwrite) float current_rotate_axis;
@property (readwrite) float current_rotate_centerX;
@property (readwrite) float current_rotate_centerY;
@property (readwrite) float current_scaleX;
@property (readwrite) float current_scaleY;
@property (readwrite) float current_red;
@property (readwrite) float current_green;
@property (readwrite) float current_blue;
@property (readwrite) float current_alpha;

@property (readwrite) float start_x;
@property (readwrite) float start_y;
@property (readwrite) float start_z;
@property (readwrite) NSInteger start_width;
@property (readwrite) NSInteger start_height;
@property (readwrite) NSInteger start_frameIndex;
@property (readwrite) float start_angle;
@property (readwrite) float start_rotate_axis;
@property (readwrite) float start_rotate_centerX;
@property (readwrite) float start_rotate_centerY;
@property (readwrite) float start_scaleX;
@property (readwrite) float start_scaleY;
@property (readwrite) float start_red;
@property (readwrite) float start_green;
@property (readwrite) float start_blue;
@property (readwrite) float start_alpha;

@property (readwrite) NSInteger delay;
@property (readwrite) NSInteger duration;
@property (readwrite) NSInteger repeat;
@property (readwrite) NSInteger easing;
@property (readwrite) NSTimeInterval startTime;
@property (readwrite) NSInteger repeatCount;

@property (readwrite) BOOL autoreverse;
@property (readwrite) BOOL reversing;
@property (readwrite) BOOL completed;
@property (readwrite) BOOL locked;

@property (readwrite) BOOL useBezier;

-(void)start;
-(void)restart;
-(void)reverse;
-(void)apply;
-(void)color:(float)_red green:(float)_green blue:(float)_blue;
-(void)color:(float)_red green:(float)_green blue:(float)_blue alpha:(float)_alpha;
-(void)rotate:(float)_angle;
-(void)rotateZ:(float)_angle;
-(void)rotateY:(float)_angle;
-(void)rotateX:(float)_angle;
-(void)rotate:(float)_angle centerX:(float)_centerX centerY:(float)_centerY;
-(void)scale:(float)scale;
-(void)scale:(float)_scaleX scaleY:(float)_scaleY;
-(void)move:(float)_x y:(float)_y;
-(void)updateBezierCurvePoint:(float)_cx1 cy1:(float)_cy1 cx2:(float)_cx2 cy2:(float)_cy2;

-(BOOL)hasStarted;
-(BOOL)hasExpired;
-(NSInteger)elapsedFromStart;
-(NSInteger)elapsed;

-(float)current:(float)_from to:(float)_to;
-(float)currentBezier_X:(float)_from to:(float)_to;
-(float)currentBezier_Y:(float)_from to:(float)_to;

-(float)ease:(float)_elapsed duration:(float)_duration;

-(float)easingLinear:(float)_elapsed duration:(float)_duration;
-(float)easingCubicIn:(float)_elapsed duration:(float)_duration;
-(float)easingCubicOut:(float)_elapsed duration:(float)_duration;
-(float)easingCubicInOut:(float)_elapsed duration:(float)_duration;
-(float)easingBackIn:(float)_elapsed duration:(float)_duration;
-(float)easingBackOut:(float)_elapsed duration:(float)_duration;
-(float)easingBackInOut:(float)_elapsed duration:(float)_duration;
-(float)easingElasticIn:(float)_elapsed duration:(float)_duration;
-(float)easingElasticOut:(float)_elapsed duration:(float)_duration;
-(float)easingElasticInOut:(float)_elapsed duration:(float)_duration;
-(float)easingBounceOut:(float)_elapsed duration:(float)_duration;
-(float)easingBounceIn:(float)_elapsed duration:(float)_duration;
-(float)easingBounceInOut:(float)_elapsed duration:(float)_duration;
-(float)easingExpoIn:(float)_elapsed duration:(float)_duration;
-(float)easingExpoOut:(float)_elapsed duration:(float)_duration;
-(float)easingExpoInOut:(float)_elapsed duration:(float)_duration;
-(float)easingQuadIn:(float)_elapsed duration:(float)_duration;
-(float)easingQuadOut:(float)_elapsed duration:(float)_duration;
-(float)easingQuadInOut:(float)_elapsed duration:(float)_duration;
-(float)easingSineIn:(float)_elapsed duration:(float)_duration;
-(float)easingSineOut:(float)_elapsed duration:(float)_duration;
-(float)easingSineInOut:(float)_elapsed duration:(float)_duration;
-(float)easingCircIn:(float)_elapsed duration:(float)_duration;
-(float)easingCircOut:(float)_elapsed duration:(float)_duration;
-(float)easingCircInOut:(float)_elapsed duration:(float)_duration;
-(float)easingQuintIn:(float)_elapsed duration:(float)_duration;
-(float)easingQuintOut:(float)_elapsed duration:(float)_duration;
-(float)easingQuintInOut:(float)_elapsed duration:(float)_duration;
-(float)easingQuartIn:(float)_elapsed duration:(float)_duration;
-(float)easingQuartOut:(float)_elapsed duration:(float)_duration;
-(float)easingQuartInOut:(float)_elapsed duration:(float)_duration;

@end
