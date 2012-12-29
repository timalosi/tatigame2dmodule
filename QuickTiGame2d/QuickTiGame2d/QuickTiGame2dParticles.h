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
#import "QuickTiGame2dSprite.h"
#import "QuickTiGame2dParticlesTypes.h"

@interface QuickTiGame2dParticles : QuickTiGame2dSprite {
    GLfloat  *quads;
    GLushort *indices;
	Particle *particles;		// Array of particles that hold the particle emitters particle details
    
    BOOL    active;
	GLint   particleCount;
	GLfloat elapsedTime;
    
	GLuint verticesID;			// Holds the buffer name of the VBO that stores the color and vertices info for the particles
	GLint  particleIndex;		// Stores the number of particles that are going to be rendered

    int emitterType;
    
	GLuint  maxParticles;
	Vector2f sourcePosition, sourcePositionVariance;			
	GLfloat angle, angleVariance;								
	GLfloat speed, speedVariance;	
    GLfloat radialAcceleration, tangentialAcceleration;
    GLfloat radialAccelVariance, tangentialAccelVariance;
	Vector2f gravity;	
	GLfloat particleLifespan, particleLifespanVariance;			
	Color4f startColor, startColorVariance;						
	Color4f finishColor, finishColorVariance;
	GLfloat startParticleSize, startParticleSizeVariance;
	GLfloat finishParticleSize, finishParticleSizeVariance;
	GLfloat emissionRate;
	GLfloat emitCounter;	
	GLfloat duration;
    GLfloat rotationStart, rotationStartVariance;
    GLfloat rotationEnd, rotationEndVariance;
    
	GLfloat maxRadius;						// Max radius at which particles are drawn when rotating
	GLfloat maxRadiusVariance;				// Variance of the maxRadius
	GLfloat radiusSpeed;					// The speed at which a particle moves from maxRadius to minRadius
	GLfloat minRadius;						// Radius from source below which a particle dies
	GLfloat rotatePerSecond;				// Numeber of degress to rotate a particle around the source pos per second
	GLfloat rotatePerSecondVariance;		// Variance in degrees for rotatePerSecond
    
    float uptime;

}

@property (readwrite) int emitterType;
@property (readwrite) GLuint  maxParticles;
@property (readwrite) Vector2f sourcePosition, sourcePositionVariance;			
@property (readwrite) GLfloat angle, angleVariance;								
@property (readwrite) GLfloat speed, speedVariance;	
@property (readwrite) GLfloat radialAcceleration, tangentialAcceleration;
@property (readwrite) GLfloat radialAccelVariance, tangentialAccelVariance;
@property (readwrite) Vector2f gravity;	
@property (readwrite) GLfloat particleLifespan, particleLifespanVariance;			
@property (readwrite) Color4f startColor, startColorVariance;						
@property (readwrite) Color4f finishColor, finishColorVariance;
@property (readwrite) GLfloat startParticleSize, startParticleSizeVariance;
@property (readwrite) GLfloat finishParticleSize, finishParticleSizeVariance;
@property (readwrite) GLfloat emissionRate;
@property (readwrite) GLfloat emitCounter;	
@property (readwrite) GLfloat duration;
@property (readwrite) GLfloat rotationStart, rotationStartVariance;
@property (readwrite) GLfloat rotationEnd, rotationEndVariance;
@property (readwrite) GLfloat maxRadius;
@property (readwrite) GLfloat maxRadiusVariance;
@property (readwrite) GLfloat radiusSpeed;
@property (readwrite) GLfloat minRadius;
@property (readwrite) GLfloat rotatePerSecond;
@property (readwrite) GLfloat rotatePerSecondVariance;

-(void)onLoad;
-(void)drawFrame:(QuickTiGame2dEngine*)engine;
-(void)onDispose;

@end

@interface QuickTiGame2dParticlesParser : NSObject <NSXMLParserDelegate> {
    QuickTiGame2dParticles* sprite;
}
@property (assign, readwrite) QuickTiGame2dParticles* sprite;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict;
- (NSInteger)intValueFromDict:(NSDictionary*)attributeDict;
- (float)floatValueFromDict:(NSDictionary*)attributeDict;
- (Vector2f)vector2fValueFromDict:(NSDictionary*)attributeDict;
- (Color4f)color4fValueFromDict:(NSDictionary*)attributeDict;

@end