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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Queue;
import java.util.concurrent.ConcurrentLinkedQueue;

import javax.microedition.khronos.opengles.GL10;
import javax.microedition.khronos.opengles.GL11;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.Attributes;
import org.xml.sax.InputSource;
import org.xml.sax.SAXException;
import org.xml.sax.XMLReader;
import org.xml.sax.helpers.DefaultHandler;

import com.googlecode.quicktigame2d.opengl.GLHelper;
import com.googlecode.quicktigame2d.util.RunnableGL;

import android.graphics.BitmapFactory;
import android.util.Log;

public class QuickTiGame2dSprite {
	
	protected boolean loaded = false;
	protected boolean debug  = false;
	protected boolean hasTexture = false;
	protected boolean hasSheet   = false;
	protected boolean isPackedAtlas = false;
	
	protected boolean animating  = false;
	protected String  animationName;
	protected QuickTiGame2dAnimationFrame currentAnimation;
	protected HashMap<String, QuickTiGame2dAnimationFrame> animations = new HashMap<String, QuickTiGame2dAnimationFrame>();
	protected HashMap<String, QuickTiGame2dImagePackInfo> imagepacks = new HashMap<String, QuickTiGame2dImagePackInfo>();
	protected List<String> imagepacks_names = new ArrayList<String>();
	protected String selectedFrameName;
	
    protected float[] vertex_tex_coords = new float[8];
    protected int[] frames_vbos  = new int[1];
    
	protected float[] param_color  = new float[4];
	protected float[] param_rotate = new float[5];
	protected float[] param_scale  = new float[6];
	
	protected WeakReference<QuickTiGame2dGameView> view = null;

	protected String image;
	protected String tag = "";
	
	protected float x = 0;
	protected float y = 0;
	protected float z = 0;
	
	protected int width  = 0;
	protected int height = 0;
	
	protected int border = 0;
	protected int margin = 0;
	
    protected float orthFactorX = 1.0f;
    protected float orthFactorY = 1.0f;

	protected int frameCount = 1;
	protected int frameIndex = 0;
	protected int nextFrameIndex = 0;
	protected boolean frameIndexChanged = false;
	
	protected int srcBlendFactor = GL11.GL_ONE;
	protected int dstBlendFactor = GL11.GL_ONE_MINUS_SRC_ALPHA;
	
	protected List<QuickTiGame2dTransform> transforms = new ArrayList<QuickTiGame2dTransform>();
	protected List<QuickTiGame2dTransform> transformsToBeRemoved = new ArrayList<QuickTiGame2dTransform>();
	
	protected List<QuickTiGame2dSprite> children = new ArrayList<QuickTiGame2dSprite>();
	
    protected boolean relativeToTransformParent;
    protected float   relativeToTransformParentX;
    protected float   relativeToTransformParentY;
    
    protected boolean followParentTransformPosition   = true;
	protected boolean followParentTransformRotation   = true;
	protected boolean followParentTransformRotationCenter   = true;
    protected boolean followParentTransformScale      = true;
    protected boolean followParentTransformSize       = true;
    protected boolean followParentTransformColor      = true;
    protected boolean followParentTransformFrameIndex = false;
    
	protected Queue<RunnableGL> beforeCommandQueue = new ConcurrentLinkedQueue<RunnableGL>();
	protected Queue<RunnableGL> afterCommandQueue  = new ConcurrentLinkedQueue<RunnableGL>();
	
	protected byte[] textureData = null;

	public QuickTiGame2dSprite() {
        // color param RGBA
        param_color[0] = 1.0f;
        param_color[1] = 1.0f;
        param_color[2] = 1.0f;
        param_color[3] = 1.0f;
        
        // rotate angle, center x, center y, center z, axis
        param_rotate[0] = 0;
        param_rotate[1] = 0;
        param_rotate[2] = 0;
        param_rotate[3] = 0;
        param_rotate[4] = QuickTiGame2dConstant.AXIS_Z;
        
        // scale param x, y, z, center x, center y, center z
        param_scale[0] = 1;
        param_scale[1] = 1;
        param_scale[2] = 1;
        param_scale[3] = 0;
        param_scale[4] = 0;
        param_scale[5] = 0;
        
        relativeToTransformParent  = false;
        relativeToTransformParentX = 0;
        relativeToTransformParentY = 0;
	}

	public QuickTiGame2dTexture getTexture() {
		return view.get().getTextureFromCache(image);
	}
	
	public boolean loadTexture(String name, byte[] data) {
		this.textureData  = data;
		this.image = name;
		
		return true;
	}

	public void onLoad(GL10 gl, QuickTiGame2dGameView gameview) {
		if (loaded) return;
		
		if (this.view == null) {
			this.view = new WeakReference<QuickTiGame2dGameView>(gameview);
		}
		
		if (textureData != null) {
			this.view.get().loadTexture(gl, image, textureData, tag);
			textureData = null;
		}

		QuickTiGame2dTexture aTexture = view.get().getTextureFromCache(image);
		
	    // if texture is not yet cached, try to load texture here
		if (aTexture == null && image != null) {
			view.get().loadTexture(gl, image, tag);
			aTexture = view.get().getTextureFromCache(image);
		}
		
	    if (aTexture != null) {
	        hasTexture = true;
	        
	        if (width  == 0) width  = aTexture.getWidth();
	        if (height == 0) height = aTexture.getHeight();
	        
	        if (hasSheet && !isPackedAtlas) {
	            setFrameCount((int) ((int)Math.floor(aTexture.getWidth() / (float)(width  + border)) 
	                                * Math.floor(aTexture.getHeight() /(float)(height + border))));
	        }
	    } else {
	        hasTexture = false;
	        hasSheet   = false;
	        isPackedAtlas = false;
	    }

	    createTextureBuffer(gl);
	    bindVertex(gl);
	    
		if (animating && currentAnimation != null) {
	        setFrameIndex(currentAnimation.current());
	    }
		
	    if (isPackedAtlas && selectedFrameName != null) {
	        selectFrame(selectedFrameName);
	    }
	    
	    if (debug && hasTexture && !aTexture.isSnapshot()) Log.d(Quicktigame2dModule.LOG_TAG, String.format("load Sprite: %s", image));
	    if (hasTexture && !aTexture.isSnapshot()) view.get().onLoadSprite(this);
		
	    if (debug) GLHelper.checkError(gl);
	    
		loaded = true;
	}
	
	public void onDrawFrame(GL10 gl10) {
		GL11 gl = (GL11)gl10;

		// sprite had texture but it is unloaded
    	if (hasTexture && getTexture() == null) {
    		return;
    	}
    	
		while(!beforeCommandQueue.isEmpty()) {
			beforeCommandQueue.poll().run(gl);
		}
		
		if (frameIndexChanged) {
			frameIndex = nextFrameIndex;
			frameIndexChanged = false;
		}

		if (animating && currentAnimation != null) {
			QuickTiGame2dAnimationFrame animation = currentAnimation;
			if (animation.getLastOnAnimationDelta(QuickTiGame2dGameView.uptime()) >= animation.getInterval()) {
				setFrameIndex(animation.getNextIndex(frameCount, frameIndex));
				animation.setLastOnAnimationInterval(QuickTiGame2dGameView.uptime());
			}
		}
		
		if (frames_vbos[frameIndex] <= 0) {
			bindVertex(gl10);
		}
		
	    synchronized (transforms) {
			onTransform();
	    }
	    
	    gl.glMatrixMode (GL11.GL_MODELVIEW);
	    gl.glLoadIdentity (); 
		
	    // update colors
	    if (srcBlendFactor == GL11.GL_ONE && dstBlendFactor == GL11.GL_ONE_MINUS_SRC_ALPHA) {
	        gl.glColor4f(param_color[0] * param_color[3],
	                  param_color[1] * param_color[3],
	                  param_color[2] * param_color[3], param_color[3]);
	    } else {
	        gl.glColor4f(param_color[0], param_color[1], param_color[2], param_color[3]);
	    }
		
	    // update position
	    gl.glTranslatef(x * orthFactorX, y * orthFactorY, 0);
		
	    // rotate angle, center x, center y, center z, axis
	    gl.glTranslatef(param_rotate[1], param_rotate[2], param_rotate[3]);
	    if (param_rotate[4] == QuickTiGame2dConstant.AXIS_X) {
	    	gl.glRotatef(param_rotate[0], 1, 0, 0);
	    } else if (param_rotate[4] == QuickTiGame2dConstant.AXIS_Y) {
	    	gl.glRotatef(param_rotate[0], 0, 1, 0);
	    } else {
	    	gl.glRotatef(param_rotate[0], 0, 0, 1);
	    }
	    gl.glTranslatef(-param_rotate[1], -param_rotate[2], -param_rotate[3]);
		
	    // scale param x, y, z, center x, center y, center z
	    gl.glTranslatef(param_scale[3], param_scale[4], param_scale[5]);
	    gl.glScalef(param_scale[0], param_scale[1], param_scale[2]);
	    gl.glTranslatef(-param_scale[3], -param_scale[4], -param_scale[5]);
		
	    // update width and height
	    gl.glScalef(width, height, 1);
		
	    // bind vertex positions
	    gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, QuickTiGame2dGameView.sharedPositionPointer());
	    gl.glVertexPointer(3, GL11.GL_FLOAT, 0, 0);
		
		// bind a texture
	    if (hasTexture && getTexture() != null) {
	    	gl.glEnable(GL11.GL_TEXTURE_2D);
	    	gl.glBindTexture(GL11.GL_TEXTURE_2D, getTexture().getTextureId());
	        
	        // bind texture coords
	    	gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, frames_vbos[frameIndex]);
	    	gl.glTexCoordPointer(2, GL11.GL_FLOAT, 0, 0);
		} else {
			gl.glDisable(GL11.GL_TEXTURE_2D);
		}
	    
	    // bind indices
	    gl.glBindBuffer(GL11.GL_ELEMENT_ARRAY_BUFFER, QuickTiGame2dGameView.sharedIndexPointer());
		
	    // draw sprite
	    gl.glDrawElements(GL11.GL_TRIANGLE_FAN, 4, GL11.GL_UNSIGNED_SHORT, 0);
	    
		while(beforeCommandQueue.isEmpty() && !afterCommandQueue.isEmpty()) {
			afterCommandQueue.poll().run(gl);
		}
		
	    gl.glBindBuffer(GL11.GL_ELEMENT_ARRAY_BUFFER, 0);
	    gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, 0);
	    gl.glBindTexture(GL11.GL_TEXTURE_2D, 0);
	}
	
	public void onDispose() {
		if (!loaded) return;
	    if (debug && hasTexture && !getTexture().isSnapshot()) Log.d(Quicktigame2dModule.LOG_TAG, String.format("unload Sprite: %s", image));
	    if (hasTexture && !getTexture().isSnapshot() && view != null) view.get().onUnloadSprite(this);
	    QuickTiGame2dGameView.deleteGLBuffer(frames_vbos);
	    
	    currentAnimation = null;
	    animations.clear();
	    imagepacks.clear();
	    imagepacks_names.clear();

	    view = null;
	    transforms.clear();
	    transformsToBeRemoved.clear();
	    children.clear();
	    beforeCommandQueue.clear();
	    afterCommandQueue.clear();
	    
	    loaded = false;
	}

	public boolean pauseAt(int index) {
		if (!setFrameIndex(index)) {
			return false;
		}
		animating = false;
		
		return true;
	}
	
	public void pause() {
		animating = false;
	}
	
	public void stop() {
		animating = false;
		setFrameIndex(0);
	}

	protected void addAnimation(QuickTiGame2dAnimationFrame animation) {
		deleteAnimation(animation.getName());
		animations.put(animation.getName(), animation);
	}

	private boolean setAnimation(String name) {
		if (getAnimation(name) == null) {
			animationName = null;
			return false;
		} else {
			animationName = name;
		}
		return true;
	}

	public QuickTiGame2dAnimationFrame getAnimation(String name) {
		return animations.get(name);
	}

	public boolean deleteAnimation(String name) {
		QuickTiGame2dAnimationFrame animation = getAnimation(name);
	    
		if (animation == null) return false;
		
		animations.remove(name);
		
		return true;
	}

	public void deleteAnimations() {
		animations.clear();
	}

	private boolean enableAnimation(boolean enable) {
		animating = enable;
		
		currentAnimation = null;
		
		if (enable) {
			if (animationName == null) return false;
			QuickTiGame2dAnimationFrame animation = getAnimation(animationName);
			if (animation == null) {
				return false;
			} else {
				currentAnimation = animation;
				animation.setLastOnAnimationInterval(QuickTiGame2dGameView.uptime());
				setFrameIndex(animation.getStart());
			}
		}
		return true;
	}

	public boolean isAnimationFinished() {
		if (animating && currentAnimation != null) {
			return currentAnimation.isFinished();
		}
		return true;
	}

	public void animate(int start, int count, int interval) {
	    animate(start, count, interval, 0);
	}

	public void animate(int start, int count, int interval, int loop) {
	    QuickTiGame2dAnimationFrame animation = new QuickTiGame2dAnimationFrame();
	    
	    animation.setName(QuickTiGame2dConstant.DEFAULT_ANIMATION_NAME);
	    animation.setStart(start);
	    animation.setCount(count);
	    animation.setInterval(interval);
	    animation.setLoop(loop);

	    addAnimation(animation);
	    setAnimation(animation.getName());
	    enableAnimation(true);
	}

	public void animate(int[] frames, int interval) {
	    animate(frames, interval, 0);
	}

	public void animate(int[] frames, int interval, int loop) {
	    QuickTiGame2dAnimationFrame animation = new QuickTiGame2dAnimationFrame();
	    
	    animation.setName(QuickTiGame2dConstant.DEFAULT_ANIMATION_NAME);
	    animation.setCount(frames.length);
	    animation.setInterval(interval);
	    animation.setLoop(loop);
	    
	    if (frames.length > 0) {
	    	animation.setStart(frames[0]);
	    }

	    animation.initializeIndividualFrames();
	    for (int i = 0; i < frames.length; i++) {
	        animation.setFrame(i, frames[i]);
	    }
	    
	    addAnimation(animation);
	    setAnimation(animation.getName());
	    enableAnimation(true);
	}
	
	public boolean setFrameIndex(int index, boolean force) {
		if (loaded && frameCount <= index) {
			return false;
		}
	    if (force) {
	        frameIndex = index;
	    } else {
	        nextFrameIndex = index;
	        frameIndexChanged = true;
	    }
	    
	    if (isPackedAtlas) {
	        QuickTiGame2dImagePackInfo info = getImagePack(imagepacks_names.get(index));
	        this.width  = info.getWidth();
	        this.height = info.getHeight();
	    }
	    
		return true;
	}

	public boolean setFrameIndex(int index) {
	    return setFrameIndex(index, false);
	}

	protected void bindVertex(GL10 gl10) {
		GL11 gl = (GL11)gl10;
		
	    vertex_tex_coords[0] = getTexCoordStartX();
	    vertex_tex_coords[1] = flipY() ? getTexCoordStartY() : getTexCoordEndY();
		
	    vertex_tex_coords[2] = getTexCoordStartX();
	    vertex_tex_coords[3] = flipY() ? getTexCoordEndY() : getTexCoordStartY();
		
	    vertex_tex_coords[4] = getTexCoordEndX();
	    vertex_tex_coords[5] = flipY() ? getTexCoordEndY() : getTexCoordStartY();
		
	    vertex_tex_coords[6] = getTexCoordEndX();
	    vertex_tex_coords[7] = flipY() ? getTexCoordStartY() : getTexCoordEndY();
		
		if (frames_vbos[frameIndex] == 0) {
			gl.glGenBuffers(1, frames_vbos, frameIndex);
		}
		
	    FloatBuffer vertexBuffer = GLHelper.createFloatBuffer(vertex_tex_coords);

	    gl.glEnable(GL11.GL_TEXTURE_2D);
	    gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, frames_vbos[frameIndex]);
	    gl.glBufferData(GL11.GL_ARRAY_BUFFER, 4 * vertex_tex_coords.length, vertexBuffer, GL11.GL_STATIC_DRAW);
	    
	    gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, 0);
	    
	    if (debug) GLHelper.checkError(gl);
	}
	
	protected void createTextureBuffer(GL10 gl10) {
		GL11 gl = (GL11)gl10;
		
	    frames_vbos = new int[frameCount];
		
		for (int i = 0; i < frameCount; i++) {
			frames_vbos[i] = 0;
		}
		
		gl.glGenBuffers(1, frames_vbos, frameIndex);
	}
	
	protected boolean flipY() {
		return hasTexture && getTexture().isSnapshot();
	}
	
	private int tex_coord_frame_startX() {
	    if (isPackedAtlas && !flipY()) {
	        return getImagePack(imagepacks_names.get(frameIndex)).getX();
	    } else if (isPackedAtlas) {
	        return getTexture().getHeight() - height - getImagePack(imagepacks_names.get(frameIndex)).getY();
	    }
		int xcount = (int)Math.round((getTexture().getWidth() - (margin * 2) + border) / (float)(width  + border));
		int xindex = frameIndex % xcount;
		return ((border + width) * xindex) + margin;
	}

	private int tex_coord_frame_startY() {
	    if (isPackedAtlas) {
	        return getImagePack(imagepacks_names.get(frameIndex)).getY();
	    }
		int xcount = (int)Math.round((getTexture().getWidth() - (margin * 2) + border) / (float)(width  + border));
		int ycount = (int)Math.round((getTexture().getHeight() - (margin * 2) + border) / (float)(height + border));
		int yindex = flipY() ? ycount - (frameIndex / xcount) - 1 : (frameIndex / xcount);
		return ((border + height) * yindex) + margin;
	}

	protected float getTexelHalfX() {
	    if (hasTexture) {
	        return (float)((1.0 / getTexture().getGlWidth()) * 0.5);
	    } else {
	        return 0;
	    }   
	}   

	protected float getTexelHalfY (){
	    if (hasTexture) {
	        return (float)((1.0 / getTexture().getGlHeight()) * 0.5);
	    } else {
	        return 0;
	    }   
	}   

	private float getTexCoordStartX(){
		if (hasSheet) {
	        return tex_coord_frame_startX() / (float)getTexture().getGlWidth() + getTexelHalfX();
	    } else {
	        return getTexelHalfX();
	    }
	}

	private float getTexCoordEndX() {
		if (!hasTexture) {
			return 1 - getTexelHalfX();
	    } else if (hasSheet) {
	        return (float)(tex_coord_frame_startX() + width) / (float)getTexture().getGlWidth() - getTexelHalfX();
	    } else {
	        return (float)getTexture().getWidth() / (float)getTexture().getGlWidth() - getTexelHalfX();
	    }
	}

	private float getTexCoordStartY() {
		if (!hasTexture) {
			return 1 - getTexelHalfY();
		} else if (hasSheet) {
	        return (float)(tex_coord_frame_startY() + height) / (float)getTexture().getGlHeight() - getTexelHalfY();
	    } else {
	        return (float)getTexture().getHeight() / (float)getTexture().getGlHeight() - getTexelHalfY();
	    }
	}

	private float getTexCoordEndY() {
	    if (hasSheet) {
	        return tex_coord_frame_startY() / (float)getTexture().getGlHeight() + getTexelHalfY();
	    } else {
	        return getTexelHalfY();
	    }
	}

	public void setX(float x) {
		this.x = x;
	}
	
	public float getX() {
		return x;
	}

	public void setY(float y) {
		this.y = y;
	}
	
	public float getY() {
		return y;
	}
	
	public void setZ(float z) {
		this.z = z;
		
		QuickTiGame2dScene.setSortOrderDirty();
	}
	
	public float getZ() {
		return z;
	}
	
	public void setImage(String image) {
		this.image = image;
		
		// update image size
		if (image.endsWith(".xml")) {
	        isPackedAtlas = true;
	        hasSheet      = true;
			
	        if (!loadPackedAtlasXml(frameIndex)) {
	            if (debug) Log.w(Quicktigame2dModule.LOG_TAG, String.format("packed atlas loading failed: %s", image));
	        }
	        
		} else {
			BitmapFactory.Options options = QuickTiGame2dUtil.getBitmapOptions(image, debug);
			
			if (width == 0)  width  = options.outWidth;
			if (height == 0) height = options.outHeight;
		}
	}
	
	private boolean loadPackedAtlasXml(int frameIndex) {
		InputStream is = null;
		try {
			SAXParserFactory spf = SAXParserFactory.newInstance();
			SAXParser sp = spf.newSAXParser();

			QuickTiGame2dImagePackParser handler = new QuickTiGame2dImagePackParser(frameIndex, this);
			
			XMLReader xr = sp.getXMLReader();
			xr.setContentHandler(handler);

			is = QuickTiGame2dUtil.getFileInputStream(image);
			xr.parse(new InputSource(new BufferedInputStream(is)));
            
			setFrameCount(imagepacks_names.size());
		} catch (Exception e) {
            if (debug) Log.w(Quicktigame2dModule.LOG_TAG, String.format("failed to load packed atlas: %s", image), e);
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

	public void color(float red, float green, float blue) {
		param_color[0] = red;
		param_color[1] = green;
		param_color[2] = blue;
	}
	
	public void hide() {
		setAlpha(0);
	}
	
	public void show() {
		setAlpha(1);
	}
	
	public void move(float x, float y) {
		this.x = x;
		this.y = y;
	}
	
	public void setAlpha(float alpha) {
		param_color[3] = alpha;
	}
	
	public float getAlpha() {
		return param_color[3];
	}
	
	public void setAngle(float angle) {
		param_rotate[0] = angle;
	}
	
	public float getAngle() {
		return param_rotate[0];
	}
	
	public void rotate(float angle) {
	    rotate(angle, (width * 0.5f), (height * 0.5f));
	}

	public void rotateZ(float angle) {
	    rotate(angle);
	    param_rotate[4] = QuickTiGame2dConstant.AXIS_Z;
	}

	public void rotateY(float angle) {
	    rotate(angle);
	    param_rotate[4] = QuickTiGame2dConstant.AXIS_Y;
	}

	public void rotateX(float angle) {
	    rotate(angle);
	    param_rotate[4] = QuickTiGame2dConstant.AXIS_X;
	}

	public void rotate(float angle, float centerX, float centerY) {
		rotate(angle, centerX, centerY, QuickTiGame2dConstant.AXIS_Z);
	}
	
	public void rotate(float angle, float centerX, float centerY, float axis) {
	    param_rotate[0] = angle;
	    param_rotate[1] = centerX;
	    param_rotate[2] = centerY;
	    param_rotate[3] = 0;
	    param_rotate[4] = axis;
	}
	
	public float getRotationCenterX() {
		return param_rotate[1];
	}
	
	public void setRotationCenterX(float value) {
		param_rotate[1] = value;
	}

	public float getRotationCenterY() {
		return param_rotate[2];
	}
	
	public void setRotationCenterY(float value) {
		param_rotate[2] = value;
	}
	
	public void scale(float scaleXY) {
	    scale(scaleXY, scaleXY);
	}

	public void scale(float scaleX, float scaleY) {
	    param_scale[0] = scaleX;
	    param_scale[1] = scaleY;
	    param_scale[2] = 1;
	    param_scale[3] = width  * 0.5f;
	    param_scale[4] = height * 0.5f;
	    param_scale[5] = 0;
	}
	
	public void scale(float scaleX, float scaleY, float centerX, float centerY) {
	    param_scale[0] = scaleX;
	    param_scale[1] = scaleY;
	    param_scale[2] = 1;
	    param_scale[3] = centerX;
	    param_scale[4] = centerY;
	    param_scale[5] = 0;
	}
	
	public float getScaleX() {
		return param_scale[0];
	}

	public void setScaleX(float value) {
		param_scale[0] = value;
	}
	
	public float getScaleY() {
		return param_scale[1];
	}
	
	public void setScaleY(float value) {
		param_scale[1] = value;
	}
	
	public float getScaleCenterX() {
		return param_scale[3];
	}
	
	public void setScaleCenterX(float value) {
		param_scale[3] = value;
	}

	public float getScaleCenterY() {
		return param_scale[4];
	}
	
	public void setScaleCenterY(float value) {
		param_scale[4] = value;
	}
	
	public String getImage() {
		return image;
	}
	
	public String getTag() {
		return tag;
	}

	public void setTag(String tag) {
		this.tag = tag;
	}

	public int getWidth() {
		return width;
	}
	
	public void setWidth(int width) {
		this.width = width;
	}
	
	public int getHeight() {
		return height;
	}
	
	public void setHeight(int height) {
		this.height = height;
	}
	
	public float getScaledWidth() {
		return getWidth() * getScaleX();
	}
	
	public float getScaledHeight() {
		return getHeight() * getScaleY();
	}
	
	public int getBorder() {
		return border;
	}
	
	public void setBorder(int border) {
		this.border = border;
	}
	
	public int getMargin() {
		return margin;
	}
	
	public void setMargin(int margin) {
		this.margin = margin;
	}
	
	public void setDebug(boolean enabled) {
		this.debug = enabled;
	}
	
	public boolean getDebug() {
		return debug;
	}

	public boolean hasTexture() {
		return hasTexture;
	}

	public int getFrameCount() {
		return frameCount;
	}

	public void setFrameCount(int frameCount) {
		this.frameCount = frameCount;
	}
	
	public int getFrameIndex() {
		return frameIndex;
	}
	
	public boolean isLoaded() {
		return loaded;
	}
	
	public boolean hasSheet() {
		return hasSheet;
	}
	
	public void enableSheet(boolean enable) {
		this.hasSheet = enable;
	}

	public void blendFunc(int src, int dst) {
		this.srcBlendFactor = src;
		this.dstBlendFactor = dst;
	}

	public int getSrcBlendFactor() {
		return srcBlendFactor;
	}
	
	public void setSrcBlendFactor(int value) {
		this.srcBlendFactor = value;
	}

	public int getDstBlendFactor() {
		return dstBlendFactor;
	}
	
	public void setDstBlendFactor(int value) {
		this.dstBlendFactor = value;
	}
	
	public boolean selectFrame(String name) {
	    if (!isPackedAtlas) return false;
	    
	    this.selectedFrameName = name;
	    
	    QuickTiGame2dImagePackInfo info = getImagePack(name);
	    if (info == null) return false;
	    
	    return setFrameIndex(info.getIndex());
	}

	public void addImagePack(QuickTiGame2dImagePackInfo info) {
		deleteImagePack(info.getName());
		imagepacks.put(info.getName(), info);
	    imagepacks_names.add(info.getName());
	}

	private QuickTiGame2dImagePackInfo getImagePack(String name) {
		return imagepacks.get(name);
	}

	private boolean deleteImagePack(String name) {
		QuickTiGame2dImagePackInfo info = getImagePack(name);
	    
		if (info == null) return false;
		
		return imagepacks.remove(name) != null;
	}
	
	protected void onTransform() {
	    if (transforms.size() == 0) return;

	    for (QuickTiGame2dTransform transform : transforms) {
	        if (transform.isCompleted()) {
	            transformsToBeRemoved.add(transform);
	            continue;
	        }
	        
	        // waiting for delay
	        if (!transform.hasStarted()) continue;
	        
	        // fire onStartTransform event
	        if (!transform.isStartEventFired()) {
	        	transform.setStartEventFired(true);
	        	view.get().onStartTransform(transform);
	        }
	        
	        if (transform.hasExpired()) {
	            // if transform has been completed, finish the transformation
	            if (transform.getRepeat() >= 0 && transform.getRepeatCount() >= transform.getRepeat()) {
	                if (transform.isAutoreverse() && !transform.isReversing()) {
	                    // no nothing
	                } else {
	                    applyTransform(transform);
	                    completeTransform(transform);
	                    continue;
	                }
	            }
	            
	            if (transform.isAutoreverse()) {
	    	        applyTransform(transform);
	                transform.reverse();
	            } else if (transform.getRepeat() < 0) {
	                // transform.repeat < 0 means infinite loop
	    	        applyTransform(transform);
	                transform.start();
	            } else {
	    	        applyTransform(transform);
	                transform.restart();
	            }
                continue;
	        }
	        
	        applyTransform(transform);
	    }

	    for (QuickTiGame2dTransform transform : transformsToBeRemoved) {
	        transforms.remove(transform);
	    }
	    transformsToBeRemoved.clear();
	}

	public void transform(QuickTiGame2dTransform transform) {
		synchronized(children) {
	    	for (QuickTiGame2dSprite child : children) {
	    		if (child.isRelativeToTransformParent()) {
	    			child.setRelativeToTransformParentX(child.x - this.x);
	    			child.setRelativeToTransformParentY(child.y - this.y);
	    		}
	    	}
		}
		
	    synchronized (transforms) {
	    	try {
	    		transforms.remove(transform);
	    		transforms.add(transform);

	    		// save initial state
	    		transform.setStart_x(x);
	    		transform.setStart_y(y);
	    		transform.setStart_z(z);
	    		transform.setStart_width(width);
	    		transform.setStart_height(height);
	    		transform.setStart_frameIndex(frameIndex);
	    		transform.setStart_angle(param_rotate[0]);
	    		transform.setStart_rotate_axis(param_rotate[4]);
	    		transform.setStart_rotate_centerX(param_rotate[1]);
	    		transform.setStart_rotate_centerY(param_rotate[2]);

	    		transform.setStart_scaleX(param_scale[0]);
	    		transform.setStart_scaleY(param_scale[1]);
	    		transform.setStart_red(param_color[0]);
	    		transform.setStart_green(param_color[1]);
	    		transform.setStart_blue(param_color[2]);
	    		transform.setStart_alpha(param_color[3]);

	    		transform.start();
	    	} catch (Exception e) {
	    		Log.e(Quicktigame2dModule.LOG_TAG, "Error at sprite.transform", e);
	    	}
	    }
	}

	protected void applyTransform(QuickTiGame2dTransform transform) {
		applyTransform(transform, false);
	}
	
	protected void applyTransform(QuickTiGame2dTransform transform, boolean isChild) {
		if (transform.isCompleted()) return;
		
		transform.setLocked(isChild);
	    transform.apply();
	    
	    if (isChild && relativeToTransformParent) {
	    	if (transform.getX() != null && (!isChild || followParentTransformPosition)) x = transform.getCurrent_x() + relativeToTransformParentX;
	    	if (transform.getY() != null && (!isChild || followParentTransformPosition)) y = transform.getCurrent_y() + relativeToTransformParentY;
	    } else {
	    	if (transform.getX() != null && (!isChild || followParentTransformPosition)) x = transform.getCurrent_x();
	    	if (transform.getY() != null && (!isChild || followParentTransformPosition)) y = transform.getCurrent_y();
	    }
	    
	    if (transform.getZ() != null && (!isChild || followParentTransformPosition)) z = transform.getCurrent_z();
	    if (transform.getWidth()  != null && (!isChild || followParentTransformSize)) width  = transform.getCurrent_width();
	    if (transform.getHeight() != null && (!isChild || followParentTransformSize)) height = transform.getCurrent_height();
	    if (transform.getFrameIndex() != null && (!isChild || followParentTransformFrameIndex)) frameIndex = transform.getCurrent_frameIndex();
	    
	    if (transform.getAngle() != null && (!isChild || followParentTransformRotation)) {
	    	if (transform.getRotate_centerX() == null && transform.getRotate_centerY() == null) {
	    		rotate(transform.getCurrent_angle());
	    	} else {
	    		setAngle(transform.getCurrent_angle());
	    	}
	    }
        if (transform.getRotate_axis() != null && (!isChild || followParentTransformRotation)) {
            param_rotate[4] = transform.getRotate_axis().intValue();
        }
        if (transform.getRotate_centerX() != null && (!isChild || followParentTransformRotationCenter)) {
            param_rotate[1] = transform.getRotate_centerX().floatValue();
        }
        if (transform.getRotate_centerY() != null && (!isChild || followParentTransformRotationCenter)) {
            param_rotate[2] = transform.getRotate_centerY().floatValue();
        }
	    
	    if (transform.getScaleX() != null && (!isChild || followParentTransformScale)) {
	        scale(transform.getCurrent_scaleX());
	    }
	    if (transform.getScaleY() != null && (!isChild || followParentTransformScale)) {
	        scale(param_scale[0], transform.getCurrent_scaleY());
	    }
	    if (transform.getScale_centerX() != null && transform.getScale_centerY() != null && (!isChild || followParentTransformScale)) {
	        param_scale[3] = transform.getScale_centerX().floatValue();
	        param_scale[4] = transform.getScale_centerY().floatValue();
	    }
	    
	    if (transform.getRed()    != null && (!isChild || followParentTransformColor)) param_color[0] = transform.getCurrent_red();
	    if (transform.getGreen()  != null && (!isChild || followParentTransformColor)) param_color[1] = transform.getCurrent_green();
	    if (transform.getBlue()   != null && (!isChild || followParentTransformColor)) param_color[2] = transform.getCurrent_blue();
	    if (transform.getAlpha()  != null && (!isChild || followParentTransformColor)) param_color[3] = transform.getCurrent_alpha();
	    
	    synchronized(children) {
	    	for (QuickTiGame2dSprite child : children) {
	    		child.applyTransform(transform, true);
	    	}
	    }
	}

	protected void completeTransform(QuickTiGame2dTransform transform) {
	    
	    transform.setCompleted(true);
	    
	    view.get().onCompleteTransform(transform);
	}

	public void clearTransforms() {
	    synchronized(transforms) {
	        for (QuickTiGame2dTransform transform : transforms) {
	            transform.setCompleted(true);
	        }
	    }
	}

	public void clearTransform(QuickTiGame2dTransform transform) {
	    synchronized(transforms) {
	        transform.setCompleted(true);
	    }
	}
	
	public void addChild(QuickTiGame2dSprite child) {
		synchronized(children) {
			child.setRelativeToTransformParent(false);
			child.setRelativeToTransformParentX(0);
			child.setRelativeToTransformParentY(0);
			children.add(child);
		}
	}
	
	public void addChildWithRelativePosition(QuickTiGame2dSprite child) {
		synchronized(children) {
			child.setRelativeToTransformParent(true);
			children.add(child);
		}
	}
	
	public void removeChild(QuickTiGame2dSprite child) {
		synchronized(children) {
			children.remove(child);
		}
	}

	public boolean isRelativeToTransformParent() {
		return relativeToTransformParent;
	}

	public void setRelativeToTransformParent(boolean relativeToTransformParent) {
		this.relativeToTransformParent = relativeToTransformParent;
	}

	public float getRelativeToTransformParentX() {
		return relativeToTransformParentX;
	}

	public void setRelativeToTransformParentX(float relativeToTransformParentX) {
		this.relativeToTransformParentX = relativeToTransformParentX;
	}

	public float getRelativeToTransformParentY() {
		return relativeToTransformParentY;
	}

	public void setRelativeToTransformParentY(float relativeToTransformParentY) {
		this.relativeToTransformParentY = relativeToTransformParentY;
	}

	public boolean isFollowParentTransformPosition() {
		return followParentTransformPosition;
	}

	public void setFollowParentTransformPosition(
			boolean followParentTransformPosition) {
		this.followParentTransformPosition = followParentTransformPosition;
	}

	public boolean isFollowParentTransformRotation() {
		return followParentTransformRotation;
	}

	public void setFollowParentTransformRotation(
			boolean followParentTransformRotation) {
		this.followParentTransformRotation = followParentTransformRotation;
		this.followParentTransformRotationCenter = followParentTransformRotation;
	}

	public boolean isFollowParentTransformRotationCenter() {
		return followParentTransformRotationCenter;
	}

	public void setFollowParentTransformRotationCenter(
			boolean followParentTransformRotationCenter) {
		this.followParentTransformRotationCenter = followParentTransformRotationCenter;
	}
	
	public boolean isFollowParentTransformScale() {
		return followParentTransformScale;
	}

	public void setFollowParentTransformScale(boolean followParentTransformScale) {
		this.followParentTransformScale = followParentTransformScale;
	}

	public boolean isFollowParentTransformSize() {
		return followParentTransformSize;
	}

	public void setFollowParentTransformSize(boolean followParentTransformSize) {
		this.followParentTransformSize = followParentTransformSize;
	}

	public boolean isFollowParentTransformColor() {
		return followParentTransformColor;
	}

	public void setFollowParentTransformColor(boolean followParentTransformColor) {
		this.followParentTransformColor = followParentTransformColor;
	}

	public boolean isFollowParentTransformFrameIndex() {
		return followParentTransformFrameIndex;
	}

	public void setFollowParentTransformFrameIndex(
			boolean followParentTransformFrameIndex) {
		this.followParentTransformFrameIndex = followParentTransformFrameIndex;
	}
	
	public byte[] getTextureData() {
		return this.textureData;
	}
}
class QuickTiGame2dImagePackInfo {
    private String name;
    private int x;
    private int y;
    private int width;
    private int height;
    private int index;
    
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public int getX() {
		return x;
	}
	public void setX(int x) {
		this.x = x;
	}
	public int getY() {
		return y;
	}
	public void setY(int y) {
		this.y = y;
	}
	public int getWidth() {
		return width;
	}
	public void setWidth(int width) {
		this.width = width;
	}
	public int getHeight() {
		return height;
	}
	public void setHeight(int height) {
		this.height = height;
	}
	public int getIndex() {
		return index;
	}
	public void setIndex(int index) {
		this.index = index;
	}
}

class QuickTiGame2dImagePackParser extends DefaultHandler {
	private StringBuilder characters = new StringBuilder();
	private final int frameIndex;
	private final QuickTiGame2dSprite sprite;
	private int itemCount = 0;
	
	public QuickTiGame2dImagePackParser(int frameIndex, QuickTiGame2dSprite sprite) {
		this.frameIndex = frameIndex;
		this.sprite = sprite;
	}

    @Override
    public void startElement(String uri, String localName, 
                    String qName, Attributes atts) throws SAXException {
    	if (localName.equals("Imageset") || localName.equals("TextureAtlas")) {
    		if (hasValue(atts, "Imagefile")) sprite.setImage(getString(atts, "Imagefile"));
    		if (hasValue(atts, "imagePath")) sprite.setImage(getString(atts, "imagePath"));
    	} else if (localName.equals("Image") || localName.equals("SubTexture")) {
    		QuickTiGame2dImagePackInfo info = new QuickTiGame2dImagePackInfo();
    		if (hasValue(atts, "name")) info.setName(getString(atts, "name"));
    		if (hasValue(atts, "Name")) info.setName(getString(atts, "Name"));
    		if (hasValue(atts, "x")) info.setX(getInt(atts, "x"));
    		if (hasValue(atts, "XPos")) info.setX(getInt(atts, "XPos"));
    		if (hasValue(atts, "y")) info.setY(getInt(atts, "y"));
    		if (hasValue(atts, "YPos")) info.setY(getInt(atts, "YPos"));
    		if (hasValue(atts, "width")) info.setWidth(getInt(atts, "width"));
    		if (hasValue(atts, "Width")) info.setWidth(getInt(atts, "Width"));
    		if (hasValue(atts, "height")) info.setHeight(getInt(atts, "height"));
    		if (hasValue(atts, "Height")) info.setHeight(getInt(atts, "Height"));
    		
            if (info.getName() != null && info.getName().length() > 0) {
                info.setIndex(itemCount);
                if (info.getIndex() == frameIndex) {
                    sprite.setWidth(info.getWidth());
                    sprite.setHeight(info.getHeight());
                    sprite.setMargin(0);
                    sprite.setBorder(0);
                }
                sprite.addImagePack(info);
                itemCount++;
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
    
    private int getInt(Attributes atts, String name) {
    	final String value = atts.getValue("", name);
    	if(value != null) {
    		return Integer.parseInt(value);
    	}
    	throw new IllegalArgumentException("No value found for attribute: " + name);
    }
    
    private String getString(Attributes atts, String name) {
    	return atts.getValue("", name);
    }
}