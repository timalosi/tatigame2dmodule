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

import java.lang.ref.WeakReference;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;

import javax.microedition.khronos.opengles.GL10;
import javax.microedition.khronos.opengles.GL11;

import android.util.Log;

public class QuickTiGame2dScene {
	
	private boolean debug  = false;
	private float[] color  = new float[4];
	private boolean loaded = false;
	private static boolean sortOrderDirty = true;
	private boolean snapshot = false;
	
	private ArrayList<QuickTiGame2dSprite> waitingForAddSprites    = new ArrayList<QuickTiGame2dSprite>();
	private ArrayList<QuickTiGame2dSprite> waitingForRemoveSprites = new ArrayList<QuickTiGame2dSprite>();
	private ArrayList<QuickTiGame2dSprite> sprites = new ArrayList<QuickTiGame2dSprite>();

	private int srcBlendFactor = GL11.GL_ONE;
	private int dstBlendFactor = GL11.GL_ONE_MINUS_SRC_ALPHA;
	
	private QuickTiGame2dTransform transform;
	protected WeakReference<QuickTiGame2dGameView> view = null;
	
	private boolean isHUD = false;

	public QuickTiGame2dScene() {
		color[0] = 0;
		color[1] = 0;
		color[2] = 0;
		color[3] = 1;
	}
	
	public void onLoad(GL10  gl, QuickTiGame2dGameView gameview) {
		if (loaded) return;
		if (this.view == null) {
			this.view = new WeakReference<QuickTiGame2dGameView>(gameview);
		}
		loaded = true;
	}
	
	public void onDrawFrame(GL10 gl) {
		if (transform != null) {
			synchronized (transform) {
				onTransform();
			}
		}
	    
		if (!isHUD) {
			gl.glClear(GL10.GL_COLOR_BUFFER_BIT | GL10.GL_DEPTH_BUFFER_BIT);
			gl.glClearColor(color[0], color[1], color[2], color[3]);
		}

		addWaitingSprites();
		removeWaitingSprites();
		
		if (sortOrderDirty) {
			Collections.sort(sprites, new SpriteComparator());
			sortOrderDirty = false;
		}

		synchronized (sprites) {
		for (QuickTiGame2dSprite sprite : sprites) {
			sprite.setDebug(getDebug());
			if (!sprite.isLoaded()) sprite.onLoad(gl, view.get());
	        if ((srcBlendFactor != sprite.getSrcBlendFactor()) ||
	                (dstBlendFactor != sprite.getDstBlendFactor())) {
	                srcBlendFactor = sprite.getSrcBlendFactor();
	                dstBlendFactor = sprite.getDstBlendFactor();
	                gl.glBlendFunc(srcBlendFactor, dstBlendFactor);
	            }
			sprite.onDrawFrame(gl);
		}
		}
	}
	
	public void onDeactivate() {
		removeWaitingSprites();
	}

	public void onDispose() {
		if (!loaded) return;
		
		if (getDebug()) Log.d(Quicktigame2dModule.LOG_TAG, "QuickTiGame2dScene.onDispose");
		
		waitingForAddSprites.clear();
		waitingForRemoveSprites.clear();
		sprites.clear();
		
		transform = null;
		view = null;
		
		loaded = false;
	}
	
	private void addWaitingSprites() {
		synchronized (sprites) {
			if (snapshot) return;
			for (QuickTiGame2dSprite sprite : waitingForAddSprites) {
				if (getDebug()) Log.d(Quicktigame2dModule.LOG_TAG, String.format("addSprite: %s", sprite.getImage()));
				sprites.add(sprite);
			}
			waitingForAddSprites.clear();
		}
		sortOrderDirty = true;
	}
	
	private void removeWaitingSprites() {
		synchronized (sprites) {
			if (snapshot) return;
			for (QuickTiGame2dSprite sprite : waitingForRemoveSprites) {
				if (getDebug()) Log.d(Quicktigame2dModule.LOG_TAG, String.format("removeSprite: %s", sprite.getImage()));
				sprites.remove(sprite);
			}
			waitingForRemoveSprites.clear();
		}
		sortOrderDirty = true;
	}
	
	public void color(float red, float green, float blue, float alpha) {
		color[0] = red;
		color[1] = green;
		color[2] = blue;
		color[3] = alpha;
	}
	
	public void color(float red, float green, float blue) {
		color(red, green, blue, color[3]);
	}
		
	public void setAlpha(float alpha) {
		color[3] = alpha;
	}
	
	public float getAlpha() {
		return color[3];
	}
	
	public void setDebug(boolean enabled) {
		this.debug = enabled;
	}
	
	public boolean getDebug() {
		return this.debug;
	}
	
	public boolean isLoaded() {
		return loaded;
	}
	
	public void addSprite(QuickTiGame2dSprite sprite) {
		synchronized (sprites) {
			waitingForAddSprites.add(sprite);
		}
	}
	
	public void removeSprite(QuickTiGame2dSprite sprite) {
		synchronized (sprites) {
			waitingForRemoveSprites.add(sprite);
		}
	}
	
	public static void setSortOrderDirty() {
		sortOrderDirty = true;
	}

	public boolean isSnapshot() {
		return snapshot;
	}

	public void setSnapshot(boolean snapshot) {
		this.snapshot = snapshot;
	}
	
	private void onTransform() {
		if (transform == null) return;
		if (transform.isCompleted()) return;

		// waiting for delay
		if (!transform.hasStarted()) return;

		// fire onStartTransform event
		if (!transform.isStartEventFired()) {
			transform.setStartEventFired(true);
			view.get().onStartTransform(transform);
		}

		if (transform.hasExpired()) {
			// if transform has been completed, finish the transformation
			if (transform.getRepeatCount() >= transform.getRepeat()) {
				if (transform.isAutoreverse() && !transform.isReversing()) {
					// no nothing
				} else {
					applyTransform();
					completeTransform();
					return;
				}
			}

			if (transform.isAutoreverse()) {
				transform.reverse();
			} else {
				transform.restart();
			}
		}

		applyTransform();
	}

	public void transform(QuickTiGame2dTransform _transform) {
		try {
			transform = _transform;

			// save initial state
			transform.setStart_red(color[0]);
			transform.setStart_green(color[1]);
			transform.setStart_blue(color[2]);
			transform.setStart_alpha(color[3]);

			transform.start();

		} catch (Exception e) {
			Log.e(Quicktigame2dModule.LOG_TAG, "Error at scene.transform", e);
		}
	}


	private void applyTransform() {
	    transform.apply();
	    
	    if (transform.getRed()    != null) color[0] = transform.getCurrent_red();
	    if (transform.getGreen()  != null) color[1] = transform.getCurrent_green();
	    if (transform.getBlue()   != null) color[2] = transform.getCurrent_blue();
	    if (transform.getAlpha()  != null) color[3] = transform.getCurrent_alpha();
	}

	private void completeTransform() {

	    transform.setCompleted(true);
	    
	    view.get().onCompleteTransform(transform);
	}
	
	public boolean hasSprite() {
	    return sprites.size() > 0 || waitingForAddSprites.size() > 0;
	}

	public boolean isHUD() {
		return isHUD;
	}

	public void setHUD(boolean isHUD) {
		this.isHUD = isHUD;
	}
}

class SpriteComparator implements Comparator<QuickTiGame2dSprite> {
	public int compare(QuickTiGame2dSprite s1, QuickTiGame2dSprite s2) {
        if (s1.getZ() > s2.getZ()) return 1;
        else if (s1.getZ() < s2.getZ()) return -1;
        return 0;
	}
}
