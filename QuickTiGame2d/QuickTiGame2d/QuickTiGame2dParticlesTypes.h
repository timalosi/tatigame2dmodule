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
#ifndef QuickTiGame2d_QuickTiGame2dParticlesTypes_h
#define QuickTiGame2d_QuickTiGame2dParticlesTypes_h

typedef struct {
	GLfloat red;
	GLfloat green;
	GLfloat blue;
	GLfloat alpha;
} Color4f;

typedef struct {
	GLfloat x;
	GLfloat y;
} Vector2f;

// Particle type
enum kParticleTypes {
	kParticleTypeGravity,
	kParticleTypeRadial
};

// Structure used to hold particle specific information
typedef struct {
	Vector2f position;
	Vector2f direction;
    Vector2f startPos;
	Color4f color;
	Color4f deltaColor;
    GLfloat rotation;
    GLfloat rotationDelta;
    GLfloat radialAcceleration;
    GLfloat tangentialAcceleration;
	GLfloat radius;
	GLfloat radiusDelta;
	GLfloat angle;
	GLfloat degreesPerSecond;
	GLfloat particleSize;
	GLfloat particleSizeDelta;
	GLfloat timeToLive;
} Particle;

// Class used to hold tiled map information
@interface QuickTiGame2dMapTile : NSObject {
    NSString* image;
    NSInteger firstgid;
    NSInteger gid;
    float red;
    float green;
    float blue;
    float alpha;
    BOOL  flip;
    
    float margin;
    float border;
    float width;
    float height;
    float atlasX;
    float atlasY;
    float atlasWidth;
    float atlasHeight;
    float offsetX;
    float offsetY;
    
    BOOL  positionFixed;
    float initialX;
    float initialY;
    
    NSInteger index;

    BOOL  isOverwrap;
    float overwrapWidth;
    float overwrapHeight;
    float overwrapAtlasX;
    float overwrapAtlasY;
    BOOL  suppressUpdate;
    
    BOOL isChild;
    NSInteger parent;
    
    NSInteger rowCount;
    NSInteger columnCount;
}
@property (readwrite, copy) NSString* image;
@property (readwrite) NSInteger firstgid;
@property (readwrite) NSInteger gid;
@property (readwrite) float red;
@property (readwrite) float green;
@property (readwrite) float blue;
@property (readwrite) float alpha;
@property (readwrite) BOOL  flip;
@property (readwrite) float width;
@property (readwrite) float height;
@property (readwrite) float atlasX;
@property (readwrite) float atlasY;
@property (readwrite) float margin;
@property (readwrite) float border;
@property (readwrite) float atlasWidth;
@property (readwrite) float atlasHeight;
@property (readwrite) float offsetX;
@property (readwrite) float offsetY;
@property (readwrite) BOOL  positionFixed;
@property (readwrite) float initialX;
@property (readwrite) float initialY;
@property (readwrite) NSInteger index;
@property (readwrite) NSInteger parent;
@property (readwrite) BOOL  isChild;
@property (readwrite) BOOL  isOverwrap;
@property (readwrite) BOOL  suppressUpdate;
@property (readwrite) float overwrapWidth;
@property (readwrite) float overwrapHeight;
@property (readwrite) float overwrapAtlasX;
@property (readwrite) float overwrapAtlasY;
@property (readwrite) NSInteger rowCount;
@property (readwrite) NSInteger columnCount;

-(void)cc:(QuickTiGame2dMapTile*)other;
-(void)indexcc:(QuickTiGame2dMapTile*)other;
@end

#define MAXIMUM_UPDATE_RATE 60.0f	// The maximum number of updates that occur per frame

// Macro which returns a random value between -1 and 1
#define RANDOM_MINUS_1_TO_1() ((random() / (GLfloat)0x3fffffff )-1.0f)

// Macro which returns a random number between 0 and 1
#define RANDOM_0_TO_1() ((random() / (GLfloat)0x7fffffff ))

// Macro which converts degrees into radians
#define DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) / 180.0 * M_PI)

// Macro that allows you to clamp a value within the defined bounds
#define CLAMP(X, A, B) ((X < A) ? A : ((X > B) ? B : X))

#pragma mark -
#pragma mark Inline Functions

// Return a Color4f structure populated with 1.0's
static const Color4f Color4fOnes = {1.0f, 1.0f, 1.0f, 1.0f};

// Return a zero populated Vector2f
static const Vector2f Vector2fZero = {0.0f, 0.0f};

// Return a populated Vector2d structure from the floats passed in
static inline Vector2f Vector2fMake(GLfloat x, GLfloat y) {
	return (Vector2f) {x, y};
}

// Return a Color4f structure populated with the color values passed in
static inline Color4f Color4fMake(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {
	return (Color4f) {red, green, blue, alpha};
}

// Return a Vector2f containing v multiplied by s
static inline Vector2f Vector2fMultiply(Vector2f v, GLfloat s) {
	return (Vector2f) {v.x * s, v.y * s};
}

// Return a Vector2f containing v1 + v2
static inline Vector2f Vector2fAdd(Vector2f v1, Vector2f v2) {
	return (Vector2f) {v1.x + v2.x, v1.y + v2.y};
}

// Return a Vector2f containing v1 - v2
static inline Vector2f Vector2fSub(Vector2f v1, Vector2f v2) {
	return (Vector2f) {v1.x - v2.x, v1.y - v2.y};
}

// Return the dot product of v1 and v2
static inline GLfloat Vector2fDot(Vector2f v1, Vector2f v2) {
	return (GLfloat) v1.x * v2.x + v1.y * v2.y;
}

// Return the length of the vector v
static inline GLfloat Vector2fLength(Vector2f v) {
	return (GLfloat) sqrtf(Vector2fDot(v, v));
}

// Return a Vector2f containing a normalized vector v
static inline Vector2f Vector2fNormalize(Vector2f v) {
	return Vector2fMultiply(v, 1.0f/Vector2fLength(v));
}

#endif
