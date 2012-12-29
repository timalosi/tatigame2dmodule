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
#import "QuickTiGame2dParticles.h"
#import "QuickTiGame2dEngine.h"
#import "ParticleDataReader.h"

@interface QuickTiGame2dParticles (PrivateMethods)
- (void)createQuadBuffer;
- (void)loadParticleXML;

- (BOOL)addParticle;
- (void)initParticle:(Particle*)particle;
- (void)updateWithDelta:(GLfloat)aDelta;
- (void)stopParticleEmitter;

- (void)updateQuad:(NSInteger)index vi:(NSInteger)vi x:(float)vx y:(float)vy color:(Color4f)color;

@end

@implementation QuickTiGame2dParticles
@synthesize emitterType;
@synthesize maxParticles;
@synthesize sourcePosition, sourcePositionVariance;			
@synthesize angle, angleVariance;								
@synthesize speed, speedVariance;	
@synthesize radialAcceleration, tangentialAcceleration;
@synthesize radialAccelVariance, tangentialAccelVariance;
@synthesize gravity;	
@synthesize particleLifespan, particleLifespanVariance;			
@synthesize startColor, startColorVariance;						
@synthesize finishColor, finishColorVariance;
@synthesize startParticleSize, startParticleSizeVariance;
@synthesize finishParticleSize, finishParticleSizeVariance;
@synthesize emissionRate;
@synthesize emitCounter;	
@synthesize duration;
@synthesize rotationStart, rotationStartVariance;
@synthesize rotationEnd, rotationEndVariance;
@synthesize maxRadius;
@synthesize maxRadiusVariance;
@synthesize radiusSpeed;
@synthesize minRadius;
@synthesize rotatePerSecond;
@synthesize rotatePerSecondVariance;

-(id)init {
    self = [super init];
    if (self != nil) {
        hasSheet     = TRUE;
        maxParticles = 1;
    }
    return self;
}

-(void)dealloc {
	if (quads)   free(quads);
	if (indices) free(indices);
	if (particles) free(particles);
    
	glDeleteBuffers(1, &verticesID);
    
    [super dealloc];
}

/*
 * load particle setting from Particle Designer XML
 */
-(void)loadParticleXML {
    if (![image hasSuffix:@".pex"]) return;

    NSString* path = nil;
    NSString* filename = replaceFileSchemeFromString(image);
    
    if ([filename hasPrefix:@"/"]) {
        path = filename;
        NSFileManager* filemanager = [NSFileManager defaultManager];
        if (![filemanager fileExistsAtPath:path]) {
            NSLog(@"[WARN] Requested resource is not found: %@", image);
            return;
        }
    } else {
        path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
        // if resource is not found, search for the module assets directory
        if (path == nil) {
            path = [[NSBundle mainBundle] pathForResource:
                    [NSString stringWithFormat:@"modules/%@/%@", @SHARED_MODULE_NAME, filename] ofType:nil];
        }
        if (path == nil) {
            NSLog(@"[WARN] Requested resource is not found: %@", image);
            return;
        }
    }
    
    NSURL *url = [NSURL fileURLWithPath:path];
    
    QuickTiGame2dParticlesParser* pack = [[QuickTiGame2dParticlesParser alloc] init];
    pack.sprite = self;
    
    // init particle from pex file
    NSXMLParser *parser = [[NSXMLParser alloc] initWithContentsOfURL:url];
    [parser setDelegate:pack];
    [parser parse];
    [parser release];
    
    [pack release];
    
    emissionRate = maxParticles / particleLifespan;
    
    sourcePosition.x = x;
    sourcePosition.y = y;
}

-(void)onLoad {
    if (loaded) return;

    // load particle setting from Particle Designer XML
    [self loadParticleXML];
    
    QuickTiGame2dTexture* aTexture = [[QuickTiGame2dEngine sharedTextureCache] objectForKey:image];
    
    // if texture is not yet cached, try to load texture here
    if (aTexture == nil && image != nil) {
        [QuickTiGame2dEngine loadTexture:image tag:self.tag];
        aTexture =[[QuickTiGame2dEngine sharedTextureCache] objectForKey:image];
    }
    
    if (aTexture != nil) {
        hasTexture = TRUE;
        
        if (width  == 0) width  = aTexture.width;
        if (height == 0) height = aTexture.height;
    }
    
    [self createTextureBuffer];
    [self createQuadBuffer];
    
    uptime = [QuickTiGame2dEngine uptime];
    
    loaded = TRUE;
    
    if (hasTexture) {
        [self fireOnLoadSprite];
    }
}

-(void)drawFrame:(QuickTiGame2dEngine*)engine {
    
    [self updateWithDelta:([QuickTiGame2dEngine uptime] - uptime)];
    uptime = [QuickTiGame2dEngine uptime];
    
    @synchronized (transforms) {
        [self onTransform];
    }
    
    sourcePosition.x = x;
    sourcePosition.y = y;
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity(); 
    
    glEnableClientState(GL_COLOR_ARRAY);
    
    // unbind all buffers
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindTexture(GL_TEXTURE_2D, 0);
    
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);
    
    // Using glBufferSubData means that a copy is done from the quads array to the buffer rather than recreating the buffer which
    // would be an allocation and copy. The copy also only takes over the number of live particles. This provides a nice performance
    // boost.
    glBufferSubData(GL_ARRAY_BUFFER, 0, 128 * particleIndex, quads);
    
	// Configure the vertex pointer which will use the currently bound VBO for its data
    glVertexPointer(2, GL_FLOAT, 32, 0);
    glColorPointer(4, GL_FLOAT,  32,   (GLvoid*)(4 * 4));
    glTexCoordPointer(2, GL_FLOAT, 32, (GLvoid*)(4 * 2));

	if (hasTexture) {
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, self.texture.textureId);
    }
	
    glBlendFunc(srcBlendFactor, dstBlendFactor);
	
    glDrawElements(GL_TRIANGLES, particleIndex * 6, GL_UNSIGNED_SHORT, indices);
    
	glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    glDisableClientState(GL_COLOR_ARRAY);
}

-(void)onDispose {
    [super onDispose];
}

- (void)createQuadBuffer {
    clearGLErrors(@"before createQuadBuffer");
    
    //
    // quad = ([vertex x, vertex y, texture x, texture y, red, green, blue, alpha] * 4) = 8 * 4 * (float=4bytes) = 128 bytes
    //
    quads   = calloc(sizeof(float) * 32, maxParticles);
    indices = calloc(sizeof(GLushort), maxParticles * 6);
	particles = malloc(sizeof(Particle) * maxParticles);
    
    for( int i = 0; i < maxParticles; i++) {
		indices[i * 6 + 0] = i * 4 + 0;
		indices[i * 6 + 1] = i * 4 + 1;
		indices[i * 6 + 2] = i * 4 + 2;
		
		indices[i * 6 + 3] = i * 4 + 2;
		indices[i * 6 + 4] = i * 4 + 3;
		indices[i * 6 + 5] = i * 4 + 0;
	}

	// initialize texture.x, texture.y
    for(int i = 0; i < maxParticles; i++) {
        int vi = i * 32;

        quads[vi + 0] = 0; // vertex  x
        quads[vi + 1] = 0; // vertex  y
        
        quads[vi + 2] = 0 + [self getTexelHalfX]; // texture x
        quads[vi + 3] = self.texture.maxT + [self getTexelHalfY]; // texture y
        
        quads[vi + 4] = 0; // red
        quads[vi + 5] = 0; // green
        quads[vi + 6] = 0; // blue
        quads[vi + 7] = 0; // alpha
        
        // -----------------------------
        quads[vi + 8] = 0; // vertex  x
        quads[vi + 9] = 1; // vertex  y
        
        quads[vi + 10] = 0 + [self getTexelHalfX];
        quads[vi + 11] = 0 - [self getTexelHalfY];
        
        quads[vi + 12] = 0; // red
        quads[vi + 13] = 0; // green
        quads[vi + 14] = 0; // blue
        quads[vi + 15] = 0; // alpha
		
        // -----------------------------
        quads[vi + 16] = 1; // vertex  x
        quads[vi + 17] = 1; // vertex  y
        
        quads[vi + 18] = self.texture.maxS - [self getTexelHalfX];
        quads[vi + 19] = 0 - [self getTexelHalfY];
        
        quads[vi + 20] = 0; // red
        quads[vi + 21] = 0; // green
        quads[vi + 22] = 0; // blue
        quads[vi + 23] = 0; // alpha
        
        // -----------------------------
        quads[vi + 24] = 1;  // vertex  x
        quads[vi + 25] = 0;  // vertex  y
        
        quads[vi + 26] = self.texture.maxS - [self getTexelHalfX];
        quads[vi + 27] = self.texture.maxT + [self getTexelHalfY];
        
        quads[vi + 28] = 0; // red
        quads[vi + 29] = 0; // green
        quads[vi + 30] = 0; // blue
        quads[vi + 31] = 0; // alpha
	}
    	
	// Generate the vertices VBO
	glGenBuffers(1, &verticesID);
    glBindBuffer(GL_ARRAY_BUFFER, verticesID);
    glBufferData(GL_ARRAY_BUFFER, 128 * maxParticles, quads, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
	
	// By default the particle emitter is active when created
	active = YES;
	
	// Set the particle count to zero
	particleCount = 0;
	
	// Reset the elapsed time
	elapsedTime = 0;	
    
    clearGLErrors(@"createQuadBuffer");
}

- (void)updateQuad:(NSInteger)index vi:(NSInteger)vi x:(float)vx y:(float)vy color:(Color4f)color {
    int start = (index * 32) + (vi * 8);
    
    quads[start + 0] = vx;
    quads[start + 1] = vy;
    
    quads[start + 4] = color.red;
    quads[start + 5] = color.green;
    quads[start + 6] = color.blue;
    quads[start + 7] = color.alpha;
}

/*
 * update with delta (aDelta=delta seconds)
 */
- (void)updateWithDelta:(GLfloat)aDelta {
    
	// If the emitter is active and the emission rate is greater than zero then emit
	// particles
	if(active && emissionRate > 0) {
		float rate = 1.0f/emissionRate;
		emitCounter += aDelta;
		while(particleCount < maxParticles && emitCounter > rate) {
			[self addParticle];
			emitCounter -= rate;
		}
        
		elapsedTime += aDelta;
		if(duration != -1 && duration < elapsedTime)
			[self stopParticleEmitter];
	}
	
	// Reset the particle index before updating the particles in this emitter
	particleIndex = 0;
    
    // Loop through all the particles updating their location and color
	while(particleIndex < particleCount) {
        
		// Get the particle for the current particle index
		Particle *currentParticle = &particles[particleIndex];
        
        // FIX 1
        // Reduce the life span of the particle
        currentParticle->timeToLive -= aDelta;
		
		// If the current particle is alive then update it
		if(currentParticle->timeToLive > 0) {
			
			// If maxRadius is greater than 0 then the particles are going to spin otherwise
			// they are effected by speed and gravity
			if (emitterType == kParticleTypeRadial) {
                
                // FIX 2
                // Update the angle of the particle from the sourcePosition and the radius.  This is only
				// done of the particles are rotating
				currentParticle->angle += currentParticle->degreesPerSecond * aDelta;
				currentParticle->radius -= currentParticle->radiusDelta;
                
				Vector2f tmp;
				tmp.x = sourcePosition.x - cosf(currentParticle->angle) * currentParticle->radius;
				tmp.y = sourcePosition.y - sinf(currentParticle->angle) * currentParticle->radius;
				currentParticle->position = tmp;
                
				if (currentParticle->radius < minRadius)
					currentParticle->timeToLive = 0;
			} else {
				Vector2f tmp, radial, tangential;
                
                radial = Vector2fZero;
                Vector2f diff = Vector2fSub(currentParticle->startPos, Vector2fZero);
                
                currentParticle->position = Vector2fSub(currentParticle->position, diff);
                
                if (currentParticle->position.x || currentParticle->position.y)
                    radial = Vector2fNormalize(currentParticle->position);
                
                tangential.x = radial.x;
                tangential.y = radial.y;
                radial = Vector2fMultiply(radial, currentParticle->radialAcceleration);
                
                GLfloat newy = tangential.x;
                tangential.x = -tangential.y;
                tangential.y = newy;
                tangential = Vector2fMultiply(tangential, currentParticle->tangentialAcceleration);
                
				tmp = Vector2fAdd( Vector2fAdd(radial, tangential), gravity);
                tmp = Vector2fMultiply(tmp, aDelta);
				currentParticle->direction = Vector2fAdd(currentParticle->direction, tmp);
				tmp = Vector2fMultiply(currentParticle->direction, aDelta);
				currentParticle->position = Vector2fAdd(currentParticle->position, tmp);
                currentParticle->position = Vector2fAdd(currentParticle->position, diff);
			}
			
			// Update the particles color
			currentParticle->color.red += currentParticle->deltaColor.red;
			currentParticle->color.green += currentParticle->deltaColor.green;
			currentParticle->color.blue += currentParticle->deltaColor.blue;
			currentParticle->color.alpha += currentParticle->deltaColor.alpha;
			
			// Update the particle size
			currentParticle->particleSize += currentParticle->particleSizeDelta;
            
            // Update the rotation of the particle
            currentParticle->rotation += (currentParticle->rotationDelta * aDelta);
            
            // As we are rendering the particles as quads, we need to define 6 vertices for each particle
            GLfloat halfSize = currentParticle->particleSize * 0.5f;
            
            // If a rotation has been defined for this particle then apply the rotation to the vertices that define
            // the particle
            if (currentParticle->rotation) {
                float x1 = -halfSize;
                float y1 = -halfSize;
                float x2 = halfSize;
                float y2 = halfSize;
                float lx = currentParticle->position.x;
                float ly = currentParticle->position.y;
                float r = (float)DEGREES_TO_RADIANS(currentParticle->rotation);
                float cr = cosf(r);
                float sr = sinf(r);
                float ax = x1 * cr - y1 * sr + lx;
                float ay = x1 * sr + y1 * cr + ly;
                float bx = x2 * cr - y1 * sr + lx;
                float by = x2 * sr + y1 * cr + ly;
                float cx = x2 * cr - y2 * sr + lx;
                float cy = x2 * sr + y2 * cr + ly;
                float dx = x1 * cr - y2 * sr + lx;
                float dy = x1 * sr + y2 * cr + ly;
                
                [self updateQuad:particleIndex vi:0 x:ax y:ay color:currentParticle->color];
                [self updateQuad:particleIndex vi:1 x:dx y:dy color:currentParticle->color];
                [self updateQuad:particleIndex vi:2 x:cx y:cy color:currentParticle->color];
                [self updateQuad:particleIndex vi:3 x:bx y:by color:currentParticle->color];
            } else {
                [self updateQuad:particleIndex vi:0 
                               x:currentParticle->position.x - halfSize
                               y:currentParticle->position.y - halfSize
                               color:currentParticle->color];
                [self updateQuad:particleIndex vi:1 
                               x:currentParticle->position.x - halfSize
                               y:currentParticle->position.y + halfSize
                           color:currentParticle->color];
                [self updateQuad:particleIndex vi:2 
                               x:currentParticle->position.x + halfSize
                               y:currentParticle->position.y + halfSize
                           color:currentParticle->color];
                [self updateQuad:particleIndex vi:3 
                               x:currentParticle->position.x + halfSize
                               y:currentParticle->position.y - halfSize
                           color:currentParticle->color];
            }
			particleIndex++;
		} else {
            
			// As the particle is not alive anymore replace it with the last active particle 
			// in the array and reduce the count of particles by one.  This causes all active particles
			// to be packed together at the start of the array so that a particle which has run out of
			// life will only drop into this clause once
			if(particleIndex != particleCount - 1)
				particles[particleIndex] = particles[particleCount - 1];
			particleCount--;
		}
	}
}

- (void)stopParticleEmitter {
	active = NO;
	elapsedTime = 0;
	emitCounter = 0;
}

- (BOOL)addParticle {
	
	// If we have already reached the maximum number of particles then do nothing
	if(particleCount == maxParticles)
		return NO;
	
	// Take the next particle out of the particle pool we have created and initialize it
	Particle *particle = &particles[particleCount];
	[self initParticle:particle];
	
	// Increment the particle count
	particleCount++;
	
	// Return YES to show that a particle has been created
	return YES;
}

- (void)initParticle:(Particle*)particle {
	
	// Init the position of the particle.  This is based on the source position of the particle emitter
	// plus a configured variance.  The RANDOM_MINUS_1_TO_1 macro allows the number to be both positive
	// and negative
	particle->position.x = sourcePosition.x + sourcePositionVariance.x * RANDOM_MINUS_1_TO_1();
	particle->position.y = sourcePosition.y + sourcePositionVariance.y * RANDOM_MINUS_1_TO_1();
    particle->startPos.x = sourcePosition.x;
    particle->startPos.y = sourcePosition.y;
	
	// Init the direction of the particle.  The newAngle is calculated using the angle passed in and the
	// angle variance.
	float newAngle = (GLfloat)DEGREES_TO_RADIANS(angle + angleVariance * RANDOM_MINUS_1_TO_1());
	
	// Create a new Vector2f using the newAngle
	Vector2f vector = Vector2fMake(cosf(newAngle), sinf(newAngle));
	
	// Calculate the vectorSpeed using the speed and speedVariance which has been passed in
	float vectorSpeed = speed + speedVariance * RANDOM_MINUS_1_TO_1();
	
	// The particles direction vector is calculated by taking the vector calculated above and
	// multiplying that by the speed
	particle->direction = Vector2fMultiply(vector, vectorSpeed);
	
	// Set the default diameter of the particle from the source position
	particle->radius = maxRadius + maxRadiusVariance * RANDOM_MINUS_1_TO_1();
	particle->radiusDelta = (maxRadius / particleLifespan) * (1.0 / MAXIMUM_UPDATE_RATE);
	particle->angle = DEGREES_TO_RADIANS(angle + angleVariance * RANDOM_MINUS_1_TO_1());
	particle->degreesPerSecond = DEGREES_TO_RADIANS(rotatePerSecond + rotatePerSecondVariance * RANDOM_MINUS_1_TO_1());
    
    particle->radialAcceleration = radialAcceleration;
    particle->tangentialAcceleration = tangentialAcceleration;
	
	// Calculate the particles life span using the life span and variance passed in
	particle->timeToLive = MAX(0, particleLifespan + particleLifespanVariance * RANDOM_MINUS_1_TO_1());
	
	// Calculate the particle size using the start and finish particle sizes
	GLfloat particleStartSize = startParticleSize + startParticleSizeVariance * RANDOM_MINUS_1_TO_1();
	GLfloat particleFinishSize = finishParticleSize + finishParticleSizeVariance * RANDOM_MINUS_1_TO_1();
	particle->particleSizeDelta = ((particleFinishSize - particleStartSize) / particle->timeToLive) * (1.0 / MAXIMUM_UPDATE_RATE);
	particle->particleSize = MAX(0, particleStartSize);
	
	// Calculate the color the particle should have when it starts its life.  All the elements
	// of the start color passed in along with the variance are used to calculate the star color
	Color4f start = {0, 0, 0, 0};
	start.red = startColor.red + startColorVariance.red * RANDOM_MINUS_1_TO_1();
	start.green = startColor.green + startColorVariance.green * RANDOM_MINUS_1_TO_1();
	start.blue = startColor.blue + startColorVariance.blue * RANDOM_MINUS_1_TO_1();
	start.alpha = startColor.alpha + startColorVariance.alpha * RANDOM_MINUS_1_TO_1();
	
	// Calculate the color the particle should be when its life is over.  This is done the same
	// way as the start color above
	Color4f end = {0, 0, 0, 0};
	end.red = finishColor.red + finishColorVariance.red * RANDOM_MINUS_1_TO_1();
	end.green = finishColor.green + finishColorVariance.green * RANDOM_MINUS_1_TO_1();
	end.blue = finishColor.blue + finishColorVariance.blue * RANDOM_MINUS_1_TO_1();
	end.alpha = finishColor.alpha + finishColorVariance.alpha * RANDOM_MINUS_1_TO_1();
	
	// Calculate the delta which is to be applied to the particles color during each cycle of its
	// life.  The delta calculation uses the life span of the particle to make sure that the 
	// particles color will transition from the start to end color during its life time.  As the game
	// loop is using a fixed delta value we can calculate the delta color once saving cycles in the 
	// update method
	particle->color = start;
	particle->deltaColor.red = ((end.red - start.red) / particle->timeToLive) * (1.0 / MAXIMUM_UPDATE_RATE);
	particle->deltaColor.green = ((end.green - start.green) / particle->timeToLive)  * (1.0 / MAXIMUM_UPDATE_RATE);
	particle->deltaColor.blue = ((end.blue - start.blue) / particle->timeToLive)  * (1.0 / MAXIMUM_UPDATE_RATE);
	particle->deltaColor.alpha = ((end.alpha - start.alpha) / particle->timeToLive)  * (1.0 / MAXIMUM_UPDATE_RATE);
    
    // Calculate the rotation
    GLfloat startA = rotationStart + rotationStartVariance * RANDOM_MINUS_1_TO_1();
    GLfloat endA = rotationEnd + rotationEndVariance * RANDOM_MINUS_1_TO_1();
    particle->rotation = startA;
    particle->rotationDelta = (endA - startA) / particle->timeToLive;
    
}

@end

@implementation QuickTiGame2dParticlesParser
@synthesize sprite;

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
    attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"emitterType"]) {
        sprite.emitterType = [self intValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"sourcePosition"]) {
        sprite.sourcePosition = [self vector2fValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"sourcePositionVariance"]) {
        sprite.sourcePositionVariance = [self vector2fValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"speed"]) {
        sprite.speed = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"speedVariance"]) {
        sprite.speedVariance = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"particleLifeSpan"]) {
        sprite.particleLifespan = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"particleLifespanVariance"]) {
        sprite.particleLifespanVariance = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"angle"]) {
        sprite.angle = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"angleVariance"]) {
        sprite.angleVariance = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"gravity"]) {
        sprite.gravity = [self vector2fValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"radialAcceleration"]) {
        sprite.radialAcceleration = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"tangentialAcceleration"]) {
        sprite.tangentialAcceleration = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"startColor"]) {
        sprite.startColor = [self color4fValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"startColorVariance"]) {
        sprite.startColorVariance = [self color4fValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"finishColor"]) {
        sprite.finishColor = [self color4fValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"finishColorVariance"]) {
        sprite.finishColorVariance = [self color4fValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"maxParticles"]) {
        sprite.maxParticles = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"startParticleSize"]) {
        sprite.startParticleSize = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"startParticleSizeVariance"]) {
        sprite.startParticleSizeVariance = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"finishParticleSize"]) {
        sprite.finishParticleSize = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"finishParticleSizeVariance"]) {
        sprite.finishParticleSizeVariance = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"duration"]) {
        sprite.duration = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"blendFuncSource"]) {
        sprite.srcBlendFactor = [self intValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"blendFuncDestination"]) {
        sprite.dstBlendFactor = [self intValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"maxRadius"]) {
        sprite.maxRadius = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"maxRadiusVariance"]) {
        sprite.maxRadiusVariance = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"radiusSpeed"]) {
        sprite.radiusSpeed = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"rotatePerSecond"]) {
        sprite.rotatePerSecond = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"rotatePerSecondVariance"]) {
        sprite.rotatePerSecondVariance = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"rotationStart"]) {
        sprite.rotationStart = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"rotationStartVariance"]) {
        sprite.rotationStartVariance = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"rotationEnd"]) {
        sprite.rotationEnd = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"rotationEndVariance"]) {
        sprite.rotationEndVariance = [self floatValueFromDict:attributeDict];
    } else if ([elementName isEqualToString:@"texture"]) {
        if ([attributeDict objectForKey:@"data"] == nil && [attributeDict objectForKey:@"name"] != nil) {
            NSString* pathname = deleteFilenameFromPath(sprite.image);
            sprite.image = [pathname stringByAppendingString:[attributeDict objectForKey:@"name"]];
        }
        if ([attributeDict objectForKey:@"data"] != nil) {
            QuickTiGame2dTexture* data = [[QuickTiGame2dTexture alloc] init];
            NSData* texdata = [ParticleDataReader parseDataWithBase64EncodedString:[attributeDict objectForKey:@"data"]];
            [data setName:sprite.image];
            if ([data onLoad:texdata]) {
                [QuickTiGame2dEngine loadTexture:sprite.image texture:data tag:sprite.tag];
                [data freeData];
            }
            [data release];
        }
    }
}

- (NSInteger)intValueFromDict:(NSDictionary*)attributeDict {
    return [[attributeDict objectForKey:@"value"] intValue];
}

- (float)floatValueFromDict:(NSDictionary*)attributeDict {
    return [[attributeDict objectForKey:@"value"] floatValue];
}

- (Vector2f)vector2fValueFromDict:(NSDictionary*)attributeDict {
    float vx = [[attributeDict objectForKey:@"x"] floatValue];
    float vy = [[attributeDict objectForKey:@"y"] floatValue];
    return Vector2fMake(vx, vy);
}

- (Color4f)color4fValueFromDict:(NSDictionary*)attributeDict {
    float red   = [[attributeDict objectForKey:@"red"] floatValue];
    float green = [[attributeDict objectForKey:@"green"] floatValue];
    float blue  = [[attributeDict objectForKey:@"blue"] floatValue];
    float alpha = [[attributeDict objectForKey:@"alpha"] floatValue];
    return Color4fMake(red, green, blue, alpha);
}

@end
