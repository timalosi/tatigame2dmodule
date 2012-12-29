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
#import "ComGooglecodeQuicktigame2dParticlesProxy.h"

@implementation ComGooglecodeQuicktigame2dParticlesProxy

- (id)init {
    self = [super init];
    if (self != nil) {
        // we don't want parent sprite instance so release it here.
        [sprite release];
        
        // create our particles instance
        sprite = [[QuickTiGame2dParticles alloc] init];
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

// ========================= gettters ================================== //

-(id) emitterType {
    return NUMINT(((QuickTiGame2dParticles*)sprite).emitterType);
}

-(id) maxParticles {
    return NUMINT(((QuickTiGame2dParticles*)sprite).maxParticles);
}

-(id) sourcePosition_X {
    return NUMINT(((QuickTiGame2dParticles*)sprite).sourcePosition.x);
}

-(id) sourcePosition_Y {
    return NUMINT(((QuickTiGame2dParticles*)sprite).sourcePosition.y);
}

-(id) sourcePositionVariance_X {
    return NUMINT(((QuickTiGame2dParticles*)sprite).sourcePositionVariance.x);
}

-(id) sourcePositionVariance_Y {
    return NUMINT(((QuickTiGame2dParticles*)sprite).sourcePositionVariance.y);
}

-(id) angle {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).angle);
}

-(id) angleVariance {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).angleVariance);
}

-(id) speed {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).speed);
}

-(id) speedVariance	{
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).speedVariance);
}

-(id) radialAcceleration {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).radialAcceleration);
}

-(id) tangentialAcceleration {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).tangentialAcceleration);
}

-(id) radialAccelVariance {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).radialAccelVariance);
}

-(id) tangentialAccelVariance {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).tangentialAccelVariance);
}

-(id) gravity_X {
    return NUMINT(((QuickTiGame2dParticles*)sprite).gravity.x);
}

-(id) gravity_Y {
    return NUMINT(((QuickTiGame2dParticles*)sprite).gravity.y);
}

-(id) particleLifespan {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).particleLifespan);
}

-(id) particleLifespanVariance {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).particleLifespanVariance);
}

-(id) startColor_red {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).startColor.red);
}
-(id) startColor_green {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).startColor.green);
}
-(id) startColor_blue {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).startColor.blue);
}
-(id) startColor_alpha {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).startColor.alpha);
}

-(id) startColorVariance_red {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).startColorVariance.red);
}
-(id) startColorVariance_green {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).startColorVariance.green);
}
-(id) startColorVariance_blue {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).startColorVariance.blue);
}
-(id) startColorVariance_alpha {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).startColorVariance.alpha);
}

-(id) finishColor_red {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).finishColor.red);
}
-(id) finishColor_green {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).finishColor.green);
}
-(id) finishColor_blue {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).finishColor.blue);
}
-(id) finishColor_alpha {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).finishColor.alpha);
}

-(id) finishColorVariance_red {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).finishColorVariance.red);
}
-(id) finishColorVariance_green {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).finishColorVariance.green);
}
-(id) finishColorVariance_blue {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).finishColorVariance.blue);
}
-(id) finishColorVariance_alpha {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).finishColorVariance.alpha);
}

-(id) startParticleSize {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).startParticleSize);
}

-(id) startParticleSizeVariance {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).startParticleSizeVariance);
}

-(id) finishParticleSize {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).finishParticleSize);
}

-(id) finishParticleSizeVariance {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).finishParticleSizeVariance);
}

-(id) emissionRate {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).emissionRate);
}

-(id) emitCounter {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).emitCounter);
}

-(id) duration {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).duration);
}

-(id) rotationStart {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).rotationStart);
}

-(id) rotationStartVariance {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).rotationStartVariance);
}

-(id) rotationEnd {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).rotationEnd);
}

-(id) rotationEndVariance {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).rotationEndVariance);
}

-(id) maxRadius {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).maxRadius);
}

-(id) maxRadiusVariance {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).maxRadiusVariance);
}

-(id) radiusSpeed {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).radiusSpeed);
}

-(id) minRadius {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).minRadius);
}

-(id) rotatePerSecond {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).rotatePerSecond);
}

-(id) rotatePerSecondVariance {
    return NUMFLOAT(((QuickTiGame2dParticles*)sprite).rotatePerSecondVariance);
}

// ========================= settters ================================== //

-(void) setEmitterType:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).emitterType = [value intValue];
}

-(void) setMaxParticles:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).maxParticles = [value intValue];
}

-(void) setSourcePosition_X:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Vector2f pos = ((QuickTiGame2dParticles*)sprite).sourcePosition;
    pos.x = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).sourcePosition = pos;
}

-(void) setSourcePosition_Y:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    
    Vector2f pos = ((QuickTiGame2dParticles*)sprite).sourcePosition;
    pos.y = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).sourcePosition = pos;
}

-(void) setSourcePositionVariance_X:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Vector2f pos = ((QuickTiGame2dParticles*)sprite).sourcePositionVariance;
    pos.x = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).sourcePositionVariance = pos;
}

-(void) setSourcePositionVariance_Y:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Vector2f pos = ((QuickTiGame2dParticles*)sprite).sourcePositionVariance;
    pos.y = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).sourcePositionVariance = pos;
}

-(void) setAngle:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).angle = [value floatValue];
}

-(void) setAngleVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).angleVariance = [value floatValue];
}

-(void) setSpeed:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).speed = [value floatValue];
}

-(void) setSpeedVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).speedVariance = [value floatValue];
}

-(void) setRadialAcceleration:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).radialAcceleration = [value floatValue];
}

-(void) setTangentialAcceleration:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).tangentialAcceleration = [value floatValue];
}

-(void) setRadialAccelVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).radialAccelVariance = [value floatValue];
}

-(void) setTangentialAccelVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).tangentialAccelVariance = [value floatValue];
}

-(void) setGravity_X:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Vector2f pos = ((QuickTiGame2dParticles*)sprite).gravity;
    pos.x = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).gravity = pos;
}

-(void) setGravity_Y:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Vector2f pos = ((QuickTiGame2dParticles*)sprite).gravity;
    pos.y = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).gravity = pos;
}

-(void) setParticleLifespan:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).particleLifespan = [value floatValue];
}

-(void) setParticleLifespanVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).particleLifespanVariance = [value floatValue];
}

-(void) setStartColor_red:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).startColor;
    color.red = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).startColor = color;
}
-(void) setStartColor_green:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).startColor;
    color.green = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).startColor = color;
}
-(void) setStartColor_blue:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).startColor;
    color.blue = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).startColor = color;
}
-(void) setStartColor_alpha:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).startColor;
    color.alpha = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).startColor = color;
}

-(void) setStartColorVariance_red:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).startColorVariance;
    color.red = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).startColorVariance = color;
}
-(void) setStartColorVariance_green:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).startColorVariance;
    color.green = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).startColorVariance = color;
}
-(void) setStartColorVariance_blue:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).startColorVariance;
    color.blue = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).startColorVariance = color;
}
-(void) setStartColorVariance_alpha:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).startColorVariance;
    color.alpha = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).startColorVariance = color;
}

-(void) setFinishColor_red:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).finishColor;
    color.red = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).finishColor = color;
}
-(void) setFinishColor_green:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).finishColor;
    color.green = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).finishColor = color;
}
-(void) setFinishColor_blue:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).finishColor;
    color.blue = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).finishColor = color;
}
-(void) setFinishColor_alpha:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).finishColor;
    color.alpha = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).finishColor = color;
}

-(void) setFinishColorVariance_red:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).finishColorVariance;
    color.red = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).finishColorVariance = color;
}
-(void) setFinishColorVariance_green:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).finishColorVariance;
    color.green = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).finishColorVariance = color;
}
-(void) setFinishColorVariance_blue:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).finishColorVariance;
    color.blue = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).finishColorVariance = color;
}
-(void) setFinishColorVariance_alpha:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    Color4f color = ((QuickTiGame2dParticles*)sprite).finishColorVariance;
    color.alpha = [value floatValue];
    
    ((QuickTiGame2dParticles*)sprite).finishColorVariance = color;
}

-(void) setStartParticleSize:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).startParticleSize = [value floatValue];
}

-(void) setStartParticleSizeVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).startParticleSizeVariance = [value floatValue];
}

-(void) setFinishParticleSize:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).finishParticleSize = [value floatValue];
}

-(void) setFinishParticleSizeVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).finishParticleSizeVariance = [value floatValue];
}

-(void) setEmissionRate:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).emissionRate = [value floatValue];
}

-(void) setEmitCounter:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).emitCounter = [value floatValue];
}

-(void) setDuration:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).duration = [value floatValue];
}

-(void) setRotationStart:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).rotationStart = [value floatValue];
}

-(void) setRotationStartVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).rotationStartVariance = [value floatValue];
}

-(void) setRotationEnd:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).rotationEnd = [value floatValue];
}

-(void) setRotationEndVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).rotationEndVariance = [value floatValue];
}

-(void) setMaxRadius:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).maxRadius = [value floatValue];
}

-(void) setMaxRadiusVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).maxRadiusVariance = [value floatValue];
}

-(void) setRadiusSpeed:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).radiusSpeed = [value floatValue];
}

-(void) setMinRadius:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).minRadius = [value floatValue];
}

-(void) setRotatePerSecond:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).rotatePerSecond = [value floatValue];
}

-(void) setRotatePerSecondVariance:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dParticles*)sprite).rotatePerSecondVariance = [value floatValue];
}

@end
