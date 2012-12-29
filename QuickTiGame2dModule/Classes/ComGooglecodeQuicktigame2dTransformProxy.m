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
#import "ComGooglecodeQuicktigame2dTransformProxy.h"
#import "QuickTiGame2dEngine.h"
#import "QuickTiGame2dConstant.h"
#import "TiUtils.h"

@implementation ComGooglecodeQuicktigame2dTransformProxy

- (id)init {
    self = [super init];
    if (self != nil) {
        transform = [[QuickTiGame2dTransform alloc] init];
        
        [[QuickTiGame2dEngine sharedNotificationCenter] 
            addObserver:self selector:@selector(onNotification:) name:@"onStartTransform" object:transform];
        [[QuickTiGame2dEngine sharedNotificationCenter] 
            addObserver:self selector:@selector(onNotification:) name:@"onCompleteTransform" object:transform];
        
        notificationEventCache = [[NSMutableDictionary alloc] init];

        bezierConfigCache = nil;
    }
    return self;
}

- (void)dealloc {
    [[QuickTiGame2dEngine sharedNotificationCenter] removeObserver:self];

    RELEASE_TO_NIL(notificationEventCache);
    RELEASE_TO_NIL(bezierConfigCache);
    RELEASE_TO_NIL(transform);
    [super dealloc];
}

- (QuickTiGame2dTransform*)transformer {
    return transform;
}

- (void)onNotification:(NSNotification*)notification {
    
    [notificationEventCache setObject:self forKey:@"source"];
    
    if ([notification.name isEqualToString:@"onStartTransform"]) {
        [notificationEventCache setObject:@"start" forKey:@"type"];
        [self fireEvent:@"start" withObject:notificationEventCache propagate:NO];
    } else if ([notification.name isEqualToString:@"onCompleteTransform"]) {
        [notificationEventCache setObject:@"complete" forKey:@"type"];
        [self fireEvent:@"complete" withObject:notificationEventCache propagate:NO];
    }
}

#pragma Public APIs

-(void)dispose:(id)args {
    RELEASE_TO_NIL(transform);
}

-(void)show:(id)args {
    transform.alpha = [NSNumber numberWithFloat:1];
}

-(void)hide:(id)args {
    transform.alpha = [NSNumber numberWithFloat:0];
}

-(void)move:(id)args {
    if ([args count] >= 2) {
        [transform move:
              [[args objectAtIndex:0] floatValue]
            y:[[args objectAtIndex:1] floatValue]
         ];
    } else {
        NSLog(@"[ERROR] Too few arguments for transform.move(x, y)");
    }
}

-(void)rotate:(id)args {
    [transform rotate:[[args objectAtIndex:0] floatValue]];
}

-(void)rotateFrom:(id)args {
    if ([args count] >= 3) {
        [transform rotate:
         [[args objectAtIndex:0] floatValue]
               centerX:[[args objectAtIndex:1] floatValue]
               centerY:[[args objectAtIndex:2] floatValue]
         ];
    } else {
        NSLog(@"[ERROR] Too few arguments for transform.rotateFrom(angle, centerX, centerY)");
    }
}

-(void)rotateX:(id)args {
    ENSURE_SINGLE_ARG(args, NSNumber);
    [transform rotateX:[args floatValue]];
}

-(void)rotateY:(id)args {
    ENSURE_SINGLE_ARG(args, NSNumber);
    [transform rotateY:[args floatValue]];
}

-(void)rotateZ:(id)args {
    ENSURE_SINGLE_ARG(args, NSNumber);
    [transform rotateZ:[args floatValue]];
}

-(void)scale:(id)args {
    if ([args count] >= 2) {
        [transform scale:
         [[args objectAtIndex:0] floatValue]
               scaleY:[[args objectAtIndex:1] floatValue]
         ];
    } else {
        NSLog(@"[ERROR] Too few arguments for transform.scale(scaleX, scaleY)");
    }
}

-(void)color:(id)args {
    if ([args count] == 3) {
        [transform color:
         [[args objectAtIndex:0] floatValue]
                green:[[args objectAtIndex:1] floatValue]
                 blue:[[args objectAtIndex:2] floatValue]
         ];
    } else if ([args count] >= 4) {
        [transform color:
         [[args objectAtIndex:0] floatValue]
                green:[[args objectAtIndex:1] floatValue]
                 blue:[[args objectAtIndex:2] floatValue]
                alpha:[[args objectAtIndex:3] floatValue]
         ];
    } else {
        NSLog(@"[ERROR] Too few arguments for transform.color(red, green, blue, alpha)");
    }
}

- (id)x {
    return transform.x;
}

- (void)setX:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.x = value;
}

- (id)y {
    return transform.y;
}

- (void)setY:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.y = value;
}

- (id)z {
    return transform.z;
}

- (void)setZ:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.z = value;
}

- (id)width {
    return transform.width;
}

- (void)setWidth:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.width = value;
}

- (id)height {
    return transform.height;
}

- (void)setHeight:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.height = value;
}

- (id)frameIndex {
    return transform.frameIndex;
}

- (void)setFrameIndex:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.frameIndex = value;
}

- (id)red {
    return transform.red;
}

- (void)setRed:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.red = value;
}
- (id)green {
    return transform.green;
}

- (void)setGreen:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.green = value;
}
- (id)blue {
    return transform.blue;
}

- (void)setBlue:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.blue = value;
}

- (id)alpha {
    return transform.alpha;
}

- (void)setAlpha:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.alpha = value;
}

- (id)angle {
    return transform.angle;
}

- (void)setAngle:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.angle = value;
}

- (id)rotate_axis {
    return transform.rotate_axis;
}

- (void)setRotate_axis:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.rotate_axis = value;
}

- (id)rotate_centerX {
    return transform.rotate_centerX;
}

- (void)setRotate_centerX:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.rotate_centerX = value;
}

- (id)rotate_centerY {
    return transform.rotate_centerY;
}

- (void)setRotate_centerY:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.rotate_centerY = value;
}

- (id)scaleX {
    return transform.scaleX;
}

- (void)setScaleX:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.scaleX = value;
}

- (id)scaleY {
    return transform.scaleY;
}

- (void)setScaleY:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.scaleY = value;
}

- (id)scale_centerX {
    return transform.scale_centerX;
}

- (void)setScale_centerX:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.scale_centerX = value;
}

- (id)scale_centerY {
    return transform.scale_centerY;
}

- (void)setScale_centerY:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.scale_centerY = value;
}

- (id)delay {
    return NUMINT(transform.delay);
}

- (void)setDelay:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.delay = [value intValue];
}

- (id)duration {
    return NUMINT(transform.duration);
}

- (void)setDuration:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.duration = [value intValue];
}

- (id)repeat {
    return NUMINT(transform.repeat);
}

- (void)setRepeat:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.repeat = [value intValue];
}

- (id)easing {
    return NUMINT(transform.easing);
}

- (void)setEasing:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.easing = [value intValue];
}

- (id)autoreverse {
    return NUMBOOL(transform.autoreverse);
}

- (void)setAutoreverse:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.autoreverse = [value boolValue];
}

- (id)lookAt_centerX {
    return transform.rotate_centerX;
}

- (void)setLookAt_centerX:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.rotate_centerX = value;
}

- (id)lookAt_centerY {
    return transform.rotate_centerY;
}

- (void)setLookAt_centerY:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.rotate_centerY = value;
}

- (id)lookAt_eyeX {
    return transform.x;
}

- (void)setLookAt_eyeX:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.x = value;
}

- (id)lookAt_eyeY {
    return transform.y;
}

- (void)setLookAt_eyeY:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.y = value;
}

- (id)lookAt_eyeZ {
    return transform.z;
}

- (void)setLookAt_eyeZ:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.z = value;
}

- (id)bezier {
    return NUMBOOL(transform.useBezier);
}

- (void)setBezier:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    transform.useBezier = [value boolValue];
}

- (id)bezierConfig {
    if (bezierConfigCache == nil) {
        bezierConfigCache = [[NSMutableDictionary alloc] init];
    }
    
    [bezierConfigCache setValue:transform.bezierCurvePoint1_X forKey:@"cx1"];
    [bezierConfigCache setValue:transform.bezierCurvePoint1_Y forKey:@"cy1"];
    [bezierConfigCache setValue:transform.bezierCurvePoint2_X forKey:@"cx2"];
    [bezierConfigCache setValue:transform.bezierCurvePoint2_Y forKey:@"cy2"];
    
    return bezierConfigCache;
}

- (void)setBezierConfig:(id)args {
    ENSURE_SINGLE_ARG(args, NSDictionary);
    float cx1  = [TiUtils floatValue:@"cx1"  properties:args  def:0];
    float cy1  = [TiUtils floatValue:@"cy1"  properties:args  def:0];
    float cx2  = [TiUtils floatValue:@"cx2"  properties:args  def:0];
    float cy2  = [TiUtils floatValue:@"cy2"  properties:args  def:0];

    if ([args objectForKey:@"cx1"] == nil) {
        NSLog(@"[WARN] Transform.bezierConfig cx1 is missing, assume value equals 0.");
    }
    if ([args objectForKey:@"cy1"] == nil) {
        NSLog(@"[WARN] Transform.bezierConfig cy1 is missing, assume value equals 0.");
    }
    if ([args objectForKey:@"cx2"] == nil) {
        NSLog(@"[WARN] Transform.bezierConfig cx2 is missing, assume value equals 0.");
    }
    if ([args objectForKey:@"cy2"] == nil) {
        NSLog(@"[WARN] Transform.bezierConfig cy2 is missing, assume value equals 0.");
    }
    
    [transform updateBezierCurvePoint:cx1 cy1:cy1 cx2:cx2 cy2:cy2];
}
@end
