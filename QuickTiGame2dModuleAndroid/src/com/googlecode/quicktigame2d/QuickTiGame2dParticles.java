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
package com.googlecode.quicktigame2d;

import java.io.BufferedInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.nio.FloatBuffer;
import java.nio.ShortBuffer;

import javax.microedition.khronos.opengles.GL10;
import javax.microedition.khronos.opengles.GL11;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;

import android.util.Log;

import com.googlecode.quicktigame2d.opengl.GLHelper;
import com.googlecode.quicktigame2d.util.Particle;
import com.googlecode.quicktigame2d.util.Vector2;
import com.googlecode.quicktigame2d.util.Color4f;

public class QuickTiGame2dParticles extends QuickTiGame2dSprite {
	
	public static final int kParticleTypeGravity = 0;
	public static final int kParticleTypeRadial  = 1;
	public static final float MAXIMUM_UPDATE_RATE  = 90.0f;
	
    private boolean active = false;
    
    private FloatBuffer quadsBuffer;
    
    private float[] quads;
    private short[] indices;
    private Particle[] particles;
    private String gzipBase64Data;
    
	private int   particleCount = 0;
	private float elapsedTime   = 0;
    
	private int[] verticesID = new int[1];
	private int particleIndex = 0;

    private int emitterType;
	private int maxParticles;
	
	private Vector2 sourcePosition         = new Vector2();
	private Vector2 sourcePositionVariance = new Vector2();			
	private Vector2 gravity                = new Vector2();	
	
	private float angle, angleVariance;								
	private float speed, speedVariance;	
	private float radialAcceleration, tangentialAcceleration;
	private float radialAccelVariance, tangentialAccelVariance;
	private float particleLifespan, particleLifespanVariance;
	
	private Color4f startColor          = new Color4f();
	private Color4f startColorVariance  = new Color4f();
	private Color4f finishColor         = new Color4f();
	private Color4f finishColorVariance = new Color4f();
	
	private float startParticleSize, startParticleSizeVariance;
	private float finishParticleSize, finishParticleSizeVariance;
	private float emissionRate;
	private float emitCounter;	
	private float duration;
	private float rotationStart, rotationStartVariance;
	private float rotationEnd, rotationEndVariance;
    
	private float maxRadius;
	private float maxRadiusVariance;
	private float radiusSpeed;
	private float minRadius;
	private float rotatePerSecond;
	private float rotatePerSecondVariance;
    
    private ShortBuffer indicesBuffer;
	
	public QuickTiGame2dParticles() {
		maxParticles = 1;
	}
	
	public void onLoad(GL10 gl, QuickTiGame2dGameView view) {
		if (loaded) return;
		
		if (this.view == null) {
			this.view = new WeakReference<QuickTiGame2dGameView>(view);
		}

	    // load particle setting from Particle Designer XML
	    loadParticleXML();
	    
	    if (gzipBase64Data != null && gzipBase64Data.length() > 0) {
	    	view.loadTexture(gl, image, gzipBase64Data, tag);
	    	gzipBase64Data = "";
	    }
	    
		QuickTiGame2dTexture aTexture = view.getTextureFromCache(image);
		
	    // if texture is not yet cached, try to load texture here
		if (aTexture == null && image != null) {
			view.loadTexture(gl, image, tag);
			aTexture = view.getTextureFromCache(image);
		}
		
	    if (aTexture != null) {
	        hasTexture = true;
	        
	        if (width  == 0) width  = aTexture.getWidth();
	        if (height == 0) height = aTexture.getHeight();
	    }

	    createTextureBuffer(gl);
	    createQuadBuffer(gl);
	    
	    if (hasTexture && !aTexture.isSnapshot()) view.onLoadSprite(this);
	    if (debug) GLHelper.checkError(gl);
	    
		loaded = true;
	}
	
	public void onDrawFrame(GL10 gl10, boolean fpsTimeElapsed) {
		GL11 gl = (GL11)gl10;

		updateWithDelta(1.0f / MAXIMUM_UPDATE_RATE);
	
	    synchronized (transforms) {
			if (fpsTimeElapsed) {
				onTransform();
			}
	    }
	    sourcePosition.x = x;
	    sourcePosition.y = y;
	    
	    gl.glMatrixMode(GL11.GL_MODELVIEW);
	    gl.glLoadIdentity(); 
	    
	    gl.glEnableClientState(GL11.GL_COLOR_ARRAY);
	    
	    // unbind all buffers
	    gl.glBindBuffer(GL11.GL_ELEMENT_ARRAY_BUFFER, 0);
	    gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, 0);
	    gl.glBindTexture(GL11.GL_TEXTURE_2D, 0);
	    
	    gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, verticesID[0]);
	    
	    // Using glBufferSubData means that a copy is done from the quads array to the buffer rather than recreating the buffer which
	    // would be an allocation and copy. The copy also only takes over the number of live particles. This provides a nice performance
	    // boost.
	    quadsBuffer.put(quads);
	    quadsBuffer.position(0);
	    
	    gl.glBufferSubData(GL11.GL_ARRAY_BUFFER, 0, 128 * particleIndex, quadsBuffer);
	    
		// Configure the vertex pointer which will use the currently bound VBO for its data
	    gl.glVertexPointer(2, GL11.GL_FLOAT, 32, 0);
	    gl.glColorPointer(4, GL11.GL_FLOAT,  32,   (4 * 4));
	    gl.glTexCoordPointer(2, GL11.GL_FLOAT, 32, (4 * 2));

		if (hasTexture) {
			gl.glEnable(GL11.GL_TEXTURE_2D);
			gl.glBindTexture(GL11.GL_TEXTURE_2D, getTexture().getTextureId());
	    }
		
		gl.glBlendFunc(srcBlendFactor, dstBlendFactor);
		
		gl.glDrawElements(GL11.GL_TRIANGLES, particleIndex * 6, GL11.GL_UNSIGNED_SHORT, indicesBuffer);
	    
		gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, 0);
		gl.glBlendFunc(GL11.GL_ONE, GL11.GL_ONE_MINUS_SRC_ALPHA);
	    
		gl.glDisableClientState(GL11.GL_COLOR_ARRAY);
	}
	
	private void updateQuad(int index, int vi, float vx, float vy, Color4f color) {
	    int start = (index * 32) + (vi * 8);
	    
	    quads[start + 0] = vx;
	    quads[start + 1] = vy;
	    
	    quads[start + 4] = color.red;
	    quads[start + 5] = color.green;
	    quads[start + 6] = color.blue;
	    quads[start + 7] = color.alpha;
	}
	
	private float degreesToRadians(float angle) {
		return angle / 180.0f * (float)Math.PI;
	}

	/*
	 * update with delta (aDelta=delta seconds)
	 */
	private void updateWithDelta(float aDelta) {
	    
		// If the emitter is active and the emission rate is greater than zero then emit
		// particles
		if(active && emissionRate > 0) {
			float rate = 1.0f / emissionRate;
			emitCounter += aDelta;
			while(particleCount < maxParticles && emitCounter > rate) {
				addParticle();
				emitCounter -= rate;
			}
	        
			elapsedTime += aDelta;
			if(duration != -1 && duration < elapsedTime)
				stopParticleEmitter();
		}
		
		// Reset the particle index before updating the particles in this emitter
		particleIndex = 0;
	    
	    // Loop through all the particles updating their location and color
		while(particleIndex < particleCount) {
	        
			// Get the particle for the current particle index
			Particle currentParticle = particles[particleIndex];
	        
	        // FIX 1
	        // Reduce the life span of the particle
	        currentParticle.timeToLive -= aDelta;
			
			// If the current particle is alive then update it
			if(currentParticle.timeToLive > 0) {
				
				// If maxRadius is greater than 0 then the particles are going to spin otherwise
				// they are effected by speed and gravity
				if (emitterType == kParticleTypeRadial) {
	                
	                // FIX 2
	                // Update the angle of the particle from the sourcePosition and the radius.  This is only
					// done of the particles are rotating
					currentParticle.angle += currentParticle.degreesPerSecond * aDelta;
					currentParticle.radius -= currentParticle.radiusDelta;
	                
					Vector2 tmp = new Vector2();
					tmp.x = (float) (sourcePosition.x - Math.cos(currentParticle.angle) * currentParticle.radius);
					tmp.y = (float) (sourcePosition.y - Math.sin(currentParticle.angle) * currentParticle.radius);
					currentParticle.position = tmp;
	                
					if (currentParticle.radius < minRadius)
						currentParticle.timeToLive = 0;
				} else {
					Vector2 tmp, radial;
					Vector2 tangential = new Vector2();
	                
	                radial = Vector2.makeZeroVector();
	                Vector2 diff = Vector2.sub(currentParticle.startPos, Vector2.makeZeroVector());
	                
	                currentParticle.position = Vector2.sub(currentParticle.position, diff);
	                
	                if (currentParticle.position.x > 0 || currentParticle.position.y > 0)
	                    radial = Vector2.normalize(currentParticle.position);
	                
	                tangential.x = radial.x;
	                tangential.y = radial.y;
	                radial = Vector2.multiply(radial, currentParticle.radialAcceleration);
	                
	                float newy = tangential.x;
	                tangential.x = -tangential.y;
	                tangential.y = newy;
	                tangential = Vector2.multiply(tangential, currentParticle.tangentialAcceleration);
	                
					tmp = Vector2.add(Vector2.add(radial, tangential), gravity);
	                tmp = Vector2.multiply(tmp, aDelta);
					currentParticle.direction = Vector2.add(currentParticle.direction, tmp);
					tmp = Vector2.multiply(currentParticle.direction, aDelta);
					currentParticle.position = Vector2.add(currentParticle.position, tmp);
	                currentParticle.position = Vector2.add(currentParticle.position, diff);
				}
				
				// Update the particles color
				currentParticle.color.red += currentParticle.deltaColor.red;
				currentParticle.color.green += currentParticle.deltaColor.green;
				currentParticle.color.blue += currentParticle.deltaColor.blue;
				currentParticle.color.alpha += currentParticle.deltaColor.alpha;
				
				// Update the particle size
				currentParticle.particleSize += currentParticle.particleSizeDelta;
	            
	            // Update the rotation of the particle
	            currentParticle.rotation += (currentParticle.rotationDelta * aDelta);
	            
	            // As we are rendering the particles as quads, we need to define 6 vertices for each particle
	            float halfSize = currentParticle.particleSize * 0.5f;
	            
	            // If a rotation has been defined for this particle then apply the rotation to the vertices that define
	            // the particle
	            if (currentParticle.rotation > 0) {
	                float x1 = -halfSize;
	                float y1 = -halfSize;
	                float x2 = halfSize;
	                float y2 = halfSize;
	                float lx = currentParticle.position.x;
	                float ly = currentParticle.position.y;
	                float r = (float)degreesToRadians(currentParticle.rotation);
	                float cr = (float) Math.cos(r);
	                float sr = (float) Math.sin(r);
	                float ax = x1 * cr - y1 * sr + lx;
	                float ay = x1 * sr + y1 * cr + ly;
	                float bx = x2 * cr - y1 * sr + lx;
	                float by = x2 * sr + y1 * cr + ly;
	                float cx = x2 * cr - y2 * sr + lx;
	                float cy = x2 * sr + y2 * cr + ly;
	                float dx = x1 * cr - y2 * sr + lx;
	                float dy = x1 * sr + y2 * cr + ly;
	                
	                updateQuad(particleIndex, 0, ax, ay, currentParticle.color);
	                updateQuad(particleIndex, 1, dx, dy, currentParticle.color);
	                updateQuad(particleIndex, 2, cx, cy, currentParticle.color);
	                updateQuad(particleIndex, 3, bx, by, currentParticle.color);
	            } else {
	                updateQuad(particleIndex, 0, 
	                               currentParticle.position.x - halfSize,
	                               currentParticle.position.y - halfSize,
	                               currentParticle.color);
	                updateQuad(particleIndex, 1, 
	                               currentParticle.position.x - halfSize,
	                               currentParticle.position.y + halfSize,
	                               currentParticle.color);
	                updateQuad(particleIndex, 2,
	                               currentParticle.position.x + halfSize,
	                               currentParticle.position.y + halfSize,
	                               currentParticle.color);
	                updateQuad(particleIndex, 3, 
	                               currentParticle.position.x + halfSize,
	                               currentParticle.position.y - halfSize,
	                               currentParticle.color);
	            }
				particleIndex++;
			} else {
	            
				// As the particle is not alive anymore replace it with the last active particle 
				// in the array and reduce the count of particles by one.  This causes all active particles
				// to be packed together at the start of the array so that a particle which has run out of
				// life will only drop into this clause once
				if(particleIndex != particleCount - 1)
					particles[particleIndex] = particles[particleCount - 1].copy();
				particleCount--;
			}
		}
	}

	private void stopParticleEmitter() {
		active = false;
		elapsedTime = 0;
		emitCounter = 0;
	}

	private boolean addParticle() {
		
		// If we have already reached the maximum number of particles then do nothing
		if(particleCount == maxParticles)
			return false;
		
		// Take the next particle out of the particle pool we have created and initialize it
		if (particles[particleCount] == null) {
			particles[particleCount] = new Particle();
		}
		Particle particle = particles[particleCount];
		initParticle(particle);
		
		// Increment the particle count
		particleCount++;
		
		// Return YES to show that a particle has been created
		return true;
	}
	
	private double random_minus_1_to_1() {
		double value = Math.random();
		double seed  = Math.random();
		
		if (seed > 0.5) value = -value;
		
		return value;
	}

	private void initParticle(Particle particle) {
		
		// Init the position of the particle.  This is based on the source position of the particle emitter
		// plus a configured variance.  The random_minus_1_to_1 macro allows the number to be both positive
		// and negative
		particle.position.x = (float) (sourcePosition.x + sourcePositionVariance.x * random_minus_1_to_1());
		particle.position.y = (float) (sourcePosition.y + sourcePositionVariance.y * random_minus_1_to_1());
	    particle.startPos.x = sourcePosition.x;
	    particle.startPos.y = sourcePosition.y;
		
		// Init the direction of the particle.  The newAngle is calculated using the angle passed in and the
		// angle variance.
		float newAngle = (float)degreesToRadians((float) (angle + angleVariance * random_minus_1_to_1()));
		
		// Create a new Vector2 using the newAngle
		Vector2 vector = new Vector2((float)Math.cos(newAngle), (float)Math.sin(newAngle));
		
		// Calculate the vectorSpeed using the speed and speedVariance which has been passed in
		float vectorSpeed = (float) (speed + speedVariance * random_minus_1_to_1());
		
		// The particles direction vector is calculated by taking the vector calculated above and
		// multiplying that by the speed
		particle.direction = Vector2.multiply(vector, vectorSpeed);
		
		// Set the default diameter of the particle from the source position
		particle.radius = (float) (maxRadius + maxRadiusVariance * random_minus_1_to_1());
		particle.radiusDelta = (maxRadius / particleLifespan) * (1.0f / MAXIMUM_UPDATE_RATE);
		particle.angle = degreesToRadians((float) (angle + angleVariance * random_minus_1_to_1()));
		particle.degreesPerSecond = degreesToRadians((float) (rotatePerSecond + rotatePerSecondVariance * random_minus_1_to_1()));
	    
	    particle.radialAcceleration = radialAcceleration;
	    particle.tangentialAcceleration = tangentialAcceleration;
		
		// Calculate the particles life span using the life span and variance passed in
		particle.timeToLive = (float) Math.max(0, particleLifespan + particleLifespanVariance * random_minus_1_to_1());
		
		// Calculate the particle size using the start and finish particle sizes
		float particleStartSize = (float) (startParticleSize + startParticleSizeVariance * random_minus_1_to_1());
		float particleFinishSize = (float) (finishParticleSize + finishParticleSizeVariance * random_minus_1_to_1());
		particle.particleSizeDelta = ((particleFinishSize - particleStartSize) / particle.timeToLive) * (1.0f / MAXIMUM_UPDATE_RATE);
		particle.particleSize = Math.max(0, particleStartSize);
		
		// Calculate the color the particle should have when it starts its life.  All the elements
		// of the start color passed in along with the variance are used to calculate the star color
		Color4f start = new Color4f(0, 0, 0, 0);
		start.red = (float) (startColor.red + startColorVariance.red * random_minus_1_to_1());
		start.green = (float) (startColor.green + startColorVariance.green * random_minus_1_to_1());
		start.blue = (float) (startColor.blue + startColorVariance.blue * random_minus_1_to_1());
		start.alpha = (float) (startColor.alpha + startColorVariance.alpha * random_minus_1_to_1());
		
		// Calculate the color the particle should be when its life is over.  This is done the same
		// way as the start color above
		Color4f end = new Color4f(0, 0, 0, 0);
		end.red = (float) (finishColor.red + finishColorVariance.red * random_minus_1_to_1());
		end.green = (float) (finishColor.green + finishColorVariance.green * random_minus_1_to_1());
		end.blue = (float) (finishColor.blue + finishColorVariance.blue * random_minus_1_to_1());
		end.alpha = (float) (finishColor.alpha + finishColorVariance.alpha * random_minus_1_to_1());
		
		// Calculate the delta which is to be applied to the particles color during each cycle of its
		// life.  The delta calculation uses the life span of the particle to make sure that the 
		// particles color will transition from the start to end color during its life time.  As the game
		// loop is using a fixed delta value we can calculate the delta color once saving cycles in the 
		// update method
		particle.color = start;
		particle.deltaColor.red = ((end.red - start.red) / particle.timeToLive) * (1.0f / MAXIMUM_UPDATE_RATE);
		particle.deltaColor.green = ((end.green - start.green) / particle.timeToLive)  * (1.0f / MAXIMUM_UPDATE_RATE);
		particle.deltaColor.blue = ((end.blue - start.blue) / particle.timeToLive)  * (1.0f / MAXIMUM_UPDATE_RATE);
		particle.deltaColor.alpha = ((end.alpha - start.alpha) / particle.timeToLive)  * (1.0f / MAXIMUM_UPDATE_RATE);
	    
	    // Calculate the rotation
	    float startA = (float) (rotationStart + rotationStartVariance * random_minus_1_to_1());
	    float endA = (float) (rotationEnd + rotationEndVariance * random_minus_1_to_1());
	    particle.rotation = startA;
	    particle.rotationDelta = (endA - startA) / particle.timeToLive;
	    
	}

	public void onDispose() {
		super.onDispose();
	}
	
	private boolean loadParticleXML() {
		InputStream is = null;
		try {
			SAXParserFactory spf = SAXParserFactory.newInstance();
			SAXParser sp = spf.newSAXParser();

			QuickTiGame2dParticleParser handler = new QuickTiGame2dParticleParser(this);
			
			XMLReader xr = sp.getXMLReader();
			xr.setContentHandler(handler);

			is = QuickTiGame2dUtil.getFileInputStream(image);
			xr.parse(new InputSource(new BufferedInputStream(is)));
			
		    emissionRate = maxParticles / particleLifespan;
		    
		    sourcePosition.x = x;
		    sourcePosition.y = y;
		    
		} catch (Exception e) {
            if (debug) Log.w(Quicktigame2dModule.LOG_TAG, String.format("failed to load particle: %s", image), e);
            return false;
		} finally {
			if (is != null) {
				try {
					is.close();
				} catch (IOException e) {
					// nothing to do
				}
			}
		}

		return true;
	}
	
	private void createQuadBuffer(GL10 gl10) {
	    
		GL11 gl = (GL11)gl10;
		
	    //
	    // quad = ([vertex x, vertex y, texture x, texture y, red, green, blue, alpha] * 4) = 8 * 4 * (float=4bytes) = 128 bytes
	    //
	    quads     = new float[32 * maxParticles];
	    indices   = new short[maxParticles * 6];
		particles = new Particle[maxParticles];
	    
	    for( int i = 0; i < maxParticles; i++) {
			indices[i * 6 + 0] = (short) (i * 4 + 0);
			indices[i * 6 + 1] = (short) (i * 4 + 1);
			indices[i * 6 + 2] = (short) (i * 4 + 2);
			
			indices[i * 6 + 3] = (short) (i * 4 + 2);
			indices[i * 6 + 4] = (short) (i * 4 + 3);
			indices[i * 6 + 5] = (short) (i * 4 + 0);
		}

		// initialize texture.x, texture.y
	    for(int i = 0; i < maxParticles; i++) {
	        int vi = i * 32;

	        quads[vi + 0] = 0; // vertex  x
	        quads[vi + 1] = 0; // vertex  y
	        
	        quads[vi + 2] = 0 + getTexelHalfX(); // texture x
	        quads[vi + 3] = getTexture().getMaxT() + getTexelHalfY(); // texture y
	        
	        quads[vi + 4] = 0; // red
	        quads[vi + 5] = 0; // green
	        quads[vi + 6] = 0; // blue
	        quads[vi + 7] = 0; // alpha
	        
	        // -----------------------------
	        quads[vi + 8] = 0; // vertex  x
	        quads[vi + 9] = 1; // vertex  y
	        
	        quads[vi + 10] = 0 + getTexelHalfX();
	        quads[vi + 11] = 0 - getTexelHalfY();
	        
	        quads[vi + 12] = 0; // red
	        quads[vi + 13] = 0; // green
	        quads[vi + 14] = 0; // blue
	        quads[vi + 15] = 0; // alpha
			
	        // -----------------------------
	        quads[vi + 16] = 1; // vertex  x
	        quads[vi + 17] = 1; // vertex  y
	        
	        quads[vi + 18] = getTexture().getMaxS() - getTexelHalfX();
	        quads[vi + 19] = 0 - getTexelHalfY();
	        
	        quads[vi + 20] = 0; // red
	        quads[vi + 21] = 0; // green
	        quads[vi + 22] = 0; // blue
	        quads[vi + 23] = 0; // alpha
	        
	        // -----------------------------
	        quads[vi + 24] = 1;  // vertex  x
	        quads[vi + 25] = 0;  // vertex  y
	        
	        quads[vi + 26] = getTexture().getMaxS() - getTexelHalfX();
	        quads[vi + 27] = getTexture().getMaxT() + getTexelHalfY();
	        
	        quads[vi + 28] = 0; // red
	        quads[vi + 29] = 0; // green
	        quads[vi + 30] = 0; // blue
	        quads[vi + 31] = 0; // alpha
		}
	    	
	    quadsBuffer = GLHelper.createFloatBuffer(quads);

	    // Generate the vertices VBO
		gl.glGenBuffers(1, verticesID, 0);
		gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, verticesID[0]);
		gl.glBufferData(GL11.GL_ARRAY_BUFFER, 128 * maxParticles, quadsBuffer, GL11.GL_DYNAMIC_DRAW);
		gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, 0);
		
		// By default the particle emitter is active when created
		active = true;
		
		// Set the particle count to zero
		particleCount = 0;
		
		// Reset the elapsed time
		elapsedTime = 0;	
		
	    indicesBuffer = GLHelper.createShortBuffer(indices);
	}

	
	public void setImage(String image) {
		this.image = image;
	}

	public int getEmitterType() {
		return emitterType;
	}

	public void setEmitterType(int emitterType) {
		this.emitterType = emitterType;
	}

	public int getMaxParticles() {
		return maxParticles;
	}

	public void setMaxParticles(int maxParticles) {
		this.maxParticles = maxParticles;
	}

	public float getAngle() {
		return angle;
	}

	public void setAngle(float angle) {
		this.angle = angle;
	}

	public float getAngleVariance() {
		return angleVariance;
	}

	public void setAngleVariance(float angleVariance) {
		this.angleVariance = angleVariance;
	}

	public float getSpeed() {
		return speed;
	}

	public void setSpeed(float speed) {
		this.speed = speed;
	}

	public float getSpeedVariance() {
		return speedVariance;
	}

	public void setSpeedVariance(float speedVariance) {
		this.speedVariance = speedVariance;
	}

	public float getRadialAcceleration() {
		return radialAcceleration;
	}

	public void setRadialAcceleration(float radialAcceleration) {
		this.radialAcceleration = radialAcceleration;
	}

	public float getTangentialAcceleration() {
		return tangentialAcceleration;
	}

	public void setTangentialAcceleration(float tangentialAcceleration) {
		this.tangentialAcceleration = tangentialAcceleration;
	}

	public float getRadialAccelVariance() {
		return radialAccelVariance;
	}

	public void setRadialAccelVariance(float radialAccelVariance) {
		this.radialAccelVariance = radialAccelVariance;
	}

	public float getTangentialAccelVariance() {
		return tangentialAccelVariance;
	}

	public void setTangentialAccelVariance(float tangentialAccelVariance) {
		this.tangentialAccelVariance = tangentialAccelVariance;
	}

	public float getParticleLifespan() {
		return particleLifespan;
	}

	public void setParticleLifespan(float particleLifespan) {
		this.particleLifespan = particleLifespan;
	}

	public float getParticleLifespanVariance() {
		return particleLifespanVariance;
	}

	public void setParticleLifespanVariance(float particleLifespanVariance) {
		this.particleLifespanVariance = particleLifespanVariance;
	}

	public float getStartParticleSize() {
		return startParticleSize;
	}

	public void setStartParticleSize(float startParticleSize) {
		this.startParticleSize = startParticleSize;
	}

	public float getStartParticleSizeVariance() {
		return startParticleSizeVariance;
	}

	public void setStartParticleSizeVariance(float startParticleSizeVariance) {
		this.startParticleSizeVariance = startParticleSizeVariance;
	}

	public float getFinishParticleSize() {
		return finishParticleSize;
	}

	public void setFinishParticleSize(float finishParticleSize) {
		this.finishParticleSize = finishParticleSize;
	}

	public float getFinishParticleSizeVariance() {
		return finishParticleSizeVariance;
	}

	public void setFinishParticleSizeVariance(float finishParticleSizeVariance) {
		this.finishParticleSizeVariance = finishParticleSizeVariance;
	}

	public float getEmissionRate() {
		return emissionRate;
	}

	public void setEmissionRate(float emissionRate) {
		this.emissionRate = emissionRate;
	}

	public float getEmitCounter() {
		return emitCounter;
	}

	public void setEmitCounter(float emitCounter) {
		this.emitCounter = emitCounter;
	}

	public float getDuration() {
		return duration;
	}

	public void setDuration(float duration) {
		this.duration = duration;
	}

	public float getRotationStart() {
		return rotationStart;
	}

	public void setRotationStart(float rotationStart) {
		this.rotationStart = rotationStart;
	}

	public float getRotationStartVariance() {
		return rotationStartVariance;
	}

	public void setRotationStartVariance(float rotationStartVariance) {
		this.rotationStartVariance = rotationStartVariance;
	}

	public float getRotationEnd() {
		return rotationEnd;
	}

	public void setRotationEnd(float rotationEnd) {
		this.rotationEnd = rotationEnd;
	}

	public float getRotationEndVariance() {
		return rotationEndVariance;
	}

	public void setRotationEndVariance(float rotationEndVariance) {
		this.rotationEndVariance = rotationEndVariance;
	}

	public float getMaxRadius() {
		return maxRadius;
	}

	public void setMaxRadius(float maxRadius) {
		this.maxRadius = maxRadius;
	}

	public float getMaxRadiusVariance() {
		return maxRadiusVariance;
	}

	public void setMaxRadiusVariance(float maxRadiusVariance) {
		this.maxRadiusVariance = maxRadiusVariance;
	}

	public float getRadiusSpeed() {
		return radiusSpeed;
	}

	public void setRadiusSpeed(float radiusSpeed) {
		this.radiusSpeed = radiusSpeed;
	}

	public float getMinRadius() {
		return minRadius;
	}

	public void setMinRadius(float minRadius) {
		this.minRadius = minRadius;
	}

	public float getRotatePerSecond() {
		return rotatePerSecond;
	}

	public void setRotatePerSecond(float rotatePerSecond) {
		this.rotatePerSecond = rotatePerSecond;
	}

	public float getRotatePerSecondVariance() {
		return rotatePerSecondVariance;
	}

	public void setRotatePerSecondVariance(float rotatePerSecondVariance) {
		this.rotatePerSecondVariance = rotatePerSecondVariance;
	}

	public Vector2 getSourcePosition() {
		return sourcePosition;
	}

	public void setSourcePosition(Vector2 sourcePosition) {
		this.sourcePosition = sourcePosition;
	}

	public Vector2 getSourcePositionVariance() {
		return sourcePositionVariance;
	}

	public void setSourcePositionVariance(Vector2 sourcePositionVariance) {
		this.sourcePositionVariance = sourcePositionVariance;
	}

	public Vector2 getGravity() {
		return gravity;
	}

	public void setGravity(Vector2 gravity) {
		this.gravity = gravity;
	}

	public Color4f getStartColor() {
		return startColor;
	}

	public void setStartColor(Color4f startColor) {
		this.startColor = startColor;
	}

	public Color4f getStartColorVariance() {
		return startColorVariance;
	}

	public void setStartColorVariance(Color4f startColorVariance) {
		this.startColorVariance = startColorVariance;
	}

	public Color4f getFinishColor() {
		return finishColor;
	}

	public void setFinishColor(Color4f finishColor) {
		this.finishColor = finishColor;
	}

	public Color4f getFinishColorVariance() {
		return finishColorVariance;
	}

	public void setFinishColorVariance(Color4f finishColorVariance) {
		this.finishColorVariance = finishColorVariance;
	}
	
	public void setGzipBase64Data(String gzipBase64Data) {
		this.gzipBase64Data = gzipBase64Data;
	}
}
class QuickTiGame2dParticleParser extends DefaultHandler {
	private StringBuilder characters = new StringBuilder();
	private final QuickTiGame2dParticles sprite;
	
	public QuickTiGame2dParticleParser(QuickTiGame2dParticles sprite) {
		this.sprite = sprite;
	}

    @Override
    public void startElement(String uri, String localName, 
                    String qName, Attributes atts) throws SAXException {
        if (localName.equals("emitterType")) {
            sprite.setEmitterType(intValue(atts));
        } else if (localName.equals("sourcePosition")) {
            sprite.setSourcePosition(vector2Value(atts));
        } else if (localName.equals("sourcePositionVariance")) {
            sprite.setSourcePositionVariance(vector2Value(atts));
        } else if (localName.equals("speed")) {
            sprite.setSpeed(floatValue(atts));
        } else if (localName.equals("speedVariance")) {
            sprite.setSpeedVariance(floatValue(atts));
        } else if (localName.equals("particleLifeSpan")) {
            sprite.setParticleLifespan(floatValue(atts));
        } else if (localName.equals("particleLifespanVariance")) {
            sprite.setParticleLifespanVariance(floatValue(atts));
        } else if (localName.equals("angle")) {
            sprite.setAngle(floatValue(atts));
        } else if (localName.equals("angleVariance")) {
            sprite.setAngleVariance(floatValue(atts));
        } else if (localName.equals("gravity")) {
            sprite.setGravity(vector2Value(atts));
        } else if (localName.equals("radialAcceleration")) {
            sprite.setRadialAcceleration(floatValue(atts));
        } else if (localName.equals("tangentialAcceleration")) {
            sprite.setTangentialAcceleration(floatValue(atts));
        } else if (localName.equals("startColor")) {
            sprite.setStartColor(color4fValue(atts));
        } else if (localName.equals("startColorVariance")) {
            sprite.setStartColorVariance(color4fValue(atts));
        } else if (localName.equals("finishColor")) {
            sprite.setFinishColor(color4fValue(atts));
        } else if (localName.equals("finishColorVariance")) {
            sprite.setFinishColorVariance(color4fValue(atts));
        } else if (localName.equals("maxParticles")) {
            sprite.setMaxParticles(intValue(atts));
        } else if (localName.equals("startParticleSize")) {
            sprite.setStartParticleSize(floatValue(atts));
        } else if (localName.equals("startParticleSizeVariance")) {
            sprite.setStartParticleSizeVariance(floatValue(atts));
        } else if (localName.equals("finishParticleSize")) {
            sprite.setFinishParticleSize(floatValue(atts));
        } else if (localName.equals("finishParticleSizeVariance")) {
            sprite.setFinishParticleSizeVariance(floatValue(atts));
        } else if (localName.equals("duration")) {
            sprite.setDuration(floatValue(atts));
        } else if (localName.equals("blendFuncSource")) {
            sprite.setSrcBlendFactor(intValue(atts));
        } else if (localName.equals("blendFuncDestination")) {
            sprite.setDstBlendFactor(intValue(atts));
        } else if (localName.equals("maxRadius")) {
            sprite.setMaxRadius(floatValue(atts));
        } else if (localName.equals("maxRadiusVariance")) {
            sprite.setMaxRadiusVariance(floatValue(atts));
        } else if (localName.equals("radiusSpeed")) {
            sprite.setRadiusSpeed(floatValue(atts));
        } else if (localName.equals("rotatePerSecond")) {
            sprite.setRotatePerSecond(floatValue(atts));
        } else if (localName.equals("rotatePerSecondVariance")) {
            sprite.setRotatePerSecondVariance(floatValue(atts));
        } else if (localName.equals("rotationStart")) {
            sprite.setRotationStart(floatValue(atts));
        } else if (localName.equals("rotationStartVariance")) {
            sprite.setRotationStartVariance(floatValue(atts));
        } else if (localName.equals("rotationEnd")) {
            sprite.setRotationEnd(floatValue(atts));
        } else if (localName.equals("rotationEndVariance")) {
            sprite.setRotationEndVariance(floatValue(atts));
        } else if (localName.equals("texture")) {
            if (!hasValue(atts, "data") && hasValue(atts, "name")) {
            	String image = sprite.getImage();
            	String pathname = image.substring(0, image.lastIndexOf("/"));
                sprite.setImage(pathname + "/" + getString(atts, "name"));
            }
            if (hasValue(atts, "data")) {
            	sprite.setGzipBase64Data(getString(atts, "data"));
            }
        }
    }
    
    @Override
    public void endElement(String uri, String localName, String qName) {
        this.characters.setLength(0);
    }

    @Override
    public void characters(char[] characters, int start, int length) throws SAXException {
        this.characters.append(characters, start, length);
    }

    private boolean hasValue(Attributes atts, String name) {
    	return atts.getValue("", name) != null;
    }
    
    private int intValue(Attributes atts) {
    	return getInt(atts, "value");
    }
    
    private float floatValue(Attributes atts) {
    	return getFloat(atts, "value");
    }
    
    private Vector2 vector2Value(Attributes atts) {
    	return new Vector2(getFloat(atts, "x"), getFloat(atts, "y"));
    }
    
    private Color4f color4fValue(Attributes atts) {
    	return new Color4f(getFloat(atts, "red"), getFloat(atts, "green"), getFloat(atts, "blue"), getFloat(atts, "alpha"));
    }
    
    private int getInt(Attributes atts, String name) {
    	final String value = atts.getValue("", name);
    	if(value != null) {
    		return Integer.parseInt(value);
    	}
    	throw new IllegalArgumentException("No value found for attribute: " + name);
    }
    
    private float getFloat(Attributes atts, String name) {
    	final String value = atts.getValue("", name);
    	if(value != null) {
    		return Float.parseFloat(value);
    	}
    	throw new IllegalArgumentException("No value found for attribute: " + name);
    }
    
    private String getString(Attributes atts, String name) {
    	return atts.getValue("", name);
    }
}