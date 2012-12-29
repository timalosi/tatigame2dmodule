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

import java.nio.FloatBuffer;
import java.nio.ShortBuffer;
import java.util.ArrayList;
import java.util.EmptyStackException;
import java.util.HashMap;
import java.util.List;
import java.util.Queue;
import java.util.Stack;
import java.util.concurrent.ConcurrentLinkedQueue;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;
import javax.microedition.khronos.opengles.GL11;
import javax.microedition.khronos.opengles.GL11ExtensionPack;

import android.app.Activity;
import android.content.Context;
import android.graphics.PixelFormat;
import android.opengl.GLSurfaceView;
import android.opengl.GLSurfaceView.Renderer;
import android.opengl.GLU;
import android.os.Handler;

import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.util.TiOrientationHelper;
import org.appcelerator.titanium.TiContext.OnLifecycleEvent;
import com.googlecode.quicktigame2d.opengl.GLHelper;
import com.googlecode.quicktigame2d.util.Base64;
import com.googlecode.quicktigame2d.util.RunnableGL;

public class QuickTiGame2dGameView extends GLSurfaceView implements Renderer, OnLifecycleEvent, Runnable {

	public static int correctionHint = GL10.GL_NICEST;
	public static int textureFilter  = GL10.GL_NEAREST;
	
	private static final int GAME_STOPPED = 0;
	private static final int GAME_STARTED = 1;
	private static final int GAME_PAUSED  = 2;
	
	private static long startTime = System.currentTimeMillis();
	
	private int framebufferWidth;
	private int framebufferHeight;
	private int width;
	private int height;
	private float fps = 60;
	
	private double lastOnDrawTime = 0;
	private boolean enableOnDrawFrameEvent = true;

    private boolean enableOnFpsEvent = false;
    private int     fpsFrameCount = 0;
    private int     onFpsInterval = QuickTiGame2dConstant.DEFAULT_ONFPS_INTERVAL;
    private double  lastOnFpsTime = 0;

	private int status = GAME_STOPPED;

	private boolean focused = false;
	private boolean dirty  = true;
	private boolean loaded = false;
	private boolean usePerspective = true;
	private boolean shouldRotateOrientation = false;
	private boolean useCustomCamera = false;
	private boolean sizeChanged = false;
	private boolean orientationFixed = false;
	private boolean shouldReloadSnapshot = true;
	private boolean squareVBOLoaded = false;

	private static Queue<RunnableGL> beforeCommandQueue = new ConcurrentLinkedQueue<RunnableGL>();
	private static Queue<RunnableGL> afterCommandQueue  = new ConcurrentLinkedQueue<RunnableGL>();;

	private boolean offscreenSupported = false;
	private boolean takeSnapshot    = false;
	private boolean releaseSnapshot = false;
	private QuickTiGame2dSprite  snapshotSprite;
	private QuickTiGame2dTexture snapshotTexture;
	
	private int orientation = TiOrientationHelper.ORIENTATION_PORTRAIT;
    
	private QuickTiGame2dCameraInfo defaultPortraitCamera;
	private QuickTiGame2dCameraInfo defaultLandscapeCamera;
	private QuickTiGame2dCameraInfo customCamera;
	private QuickTiGame2dCameraInfo transformCameraCache;
	
	private float[] color = new float[4];
	private short[] squareIndices = new short[4];
	private float[] squarePositions = new float[12];
	private static int[] squareVBOPointerCache = new int[2];
	
	private boolean debug  = false;
	
	private HashMap<String, QuickTiGame2dTexture> textureCache = new HashMap<String, QuickTiGame2dTexture>();
	private HashMap<String, String> textureTagCache = new HashMap<String, String>();
	
	private Stack<QuickTiGame2dScene> sceneStack = new Stack<QuickTiGame2dScene>();
	private List<GameViewEventListener> listeners = new ArrayList<GameViewEventListener>();
	
	private List<QuickTiGame2dTransform> cameraTransforms = new ArrayList<QuickTiGame2dTransform>();
	private List<QuickTiGame2dTransform> cameraTransformsToBeRemoved = new ArrayList<QuickTiGame2dTransform>();
	
	private QuickTiGame2dScene hudScene;
	private QuickTiGame2dScene previousScene = null;
	
	private boolean isRendererSet    = false;
	private boolean opaqueBackground = true;
	
	private Handler redrawHandler = new Handler();
	
	public QuickTiGame2dGameView(Context context) {
		super(context);
		
		color[0] = 0;
		color[1] = 0;
		color[2] = 0;
		color[3] = 1;
		
		defaultPortraitCamera  = new QuickTiGame2dCameraInfo();
		defaultLandscapeCamera = new QuickTiGame2dCameraInfo();
		customCamera           = new QuickTiGame2dCameraInfo();
		transformCameraCache   = new QuickTiGame2dCameraInfo();
		
		hudScene = new QuickTiGame2dScene();
		hudScene.setHUD(true);
	}
	
	private void loadSnapshotTexture(GL10 gl10) {
		if (GLHelper.checkIfContextSupportsFrameBufferObject(gl10)) {
			
			if (snapshotTexture != null) {
				snapshotTexture.onDispose(gl10);
				snapshotTexture = null;
			}
			
            if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "QuickTiGame2dGameView:loadSnapshotTexture");
			
			snapshotTexture = new QuickTiGame2dTexture(getContext());
			if (snapshotTexture.onLoadSnapshot(gl10, framebufferWidth, framebufferHeight)) {
				textureCache.put(snapshotTexture.getName(), snapshotTexture);
				offscreenSupported = true;
			}
		}
	}
	
	private void onLoad(GL10 gl10) {
		if (loaded) return;
		
		GL11 gl = (GL11)gl10;
		
		restoreGLState(gl, true);
		loadSquareVBOPointer(gl);
		restoreGLState(gl, false);

		synchronized (listeners) {
			for (GameViewEventListener listener : listeners) {
				listener.onLoad();
			}
		}
		
		loaded = true;
	}
	
	public void onLostFocus() {
		focused = false;
		
		synchronized (listeners) {
			for (GameViewEventListener listener : listeners) {
				listener.onLostFocus();
			}
		}
	}
	
	/*
     * Requrest drawing OpenGL surface
	 */
	@Override
	public void run() {
		if (focused) {
			requestRender();
			redrawHandler.postDelayed(this, getFpsMsec());
		}
	}
	
	public void onGainedFocus() {
		
		if (!isRendererSet) {
			setRenderer(this);
			setRenderMode(RENDERMODE_WHEN_DIRTY);
			
			isRendererSet = true;
		}
		
		focused = true;
		
		synchronized (listeners) {
			for (GameViewEventListener listener : listeners) {
				listener.onGainedFocus();
			}
		}
		
        // Enqueue drawing OpenGL surface
        redrawHandler.post(this);
	}
	
	public void onDispose() {
		synchronized (listeners) {
			for (GameViewEventListener listener : listeners) {
				listener.onDispose();
			}
		}
		
		synchronized(sceneStack) {
			for (QuickTiGame2dScene scene : sceneStack) {
				scene.onDispose();
			}
		}
		
		beforeCommandQueue.clear();
		afterCommandQueue.clear();
		
		snapshotSprite = null;
		snapshotTexture = null;
		
		defaultPortraitCamera = null;
		defaultLandscapeCamera = null;
		customCamera = null;
		transformCameraCache = null;
		
		textureCache.clear();
		textureTagCache.clear();
		sceneStack.clear();
		listeners.clear();
		
		cameraTransforms.clear();
		cameraTransformsToBeRemoved.clear();
		
		hudScene = null;
		previousScene = null;
	}
	
	public void onLoadSprite(QuickTiGame2dSprite sprite) {
		synchronized (listeners) {
			for (SpriteEventListener listener : listeners) {
				listener.onLoadSprite(sprite);
			}
		}
	}

	public void onUnloadSprite(QuickTiGame2dSprite sprite) {
		synchronized (listeners) {
			for (SpriteEventListener listener : listeners) {
				listener.onUnloadSprite(sprite);
			}
		}
	}

	public void onStartTransform(QuickTiGame2dTransform transform) {
		synchronized (listeners) {
			for (SpriteEventListener listener : listeners) {
				listener.onStartTransform(transform);
			}
		}
	}

	public void onCompleteTransform(QuickTiGame2dTransform transform) {
		synchronized (listeners) {
			for (SpriteEventListener listener : listeners) {
				listener.onCompleteTransform(transform);
			}
		}
	}

	public void startCurrentScene() {
		releaseSnapshot();
	}
	
	public void commitLoadTexture(final String texture, final String tag) {
    	beforeCommandQueue.offer(new RunnableGL() {
    		@Override
    		public void run(GL10 gl) {
				loadTexture(gl, texture, tag);
    		}
    	});
	}

	public void commitUnloadTexture(final String texture, final String tag) {
    	afterCommandQueue.offer(new RunnableGL() {
    		@Override
    		public void run(GL10 gl) {
				unloadTexture(gl, texture, tag);
    		}
    	});
	}
	
	public QuickTiGame2dTexture getTextureFromCache(String name) {
		if (name == null) return null;
		return textureCache.get(name);
	}
	
	public void loadTexture(GL10 gl, String name, String tag) {
		if (debug && name == null) {
        	Log.w(Quicktigame2dModule.LOG_TAG, 
            		"QuickTiGame2dGameView:loadTexture name should not be null!");
			return;
		}
		if (textureCache.containsKey(name)) return;
		
		QuickTiGame2dTexture texture = new QuickTiGame2dTexture(getContext());
		texture.setDebug(getDebug());
		texture.setName(name);
		texture.onLoad(gl);
		textureCache.put(name, texture);
		
		if (tag != null && tag.length() > 0) {
			textureTagCache.put(tag,  name);
		}
	}
	
	public void loadTexture(GL10 gl, String name, String gzipBase64Data, String tag) {
		byte[] data = new byte[0];
		
		try {
			data = Base64.decode(gzipBase64Data);
		} catch (Exception e) {
            if (debug) {
            	Log.w(Quicktigame2dModule.LOG_TAG, 
            		String.format("QuickTiGame2dGameView:loadTexture failed: %s", name), e);
            }
			return;
		}

		loadTexture(gl, name, data, tag);
	}

	public void loadTexture(GL10 gl, String name, byte[] data, String tag) {
		if (debug && name == null) {
        	Log.w(Quicktigame2dModule.LOG_TAG, 
            		"QuickTiGame2dGameView:loadTexture name should not be null!");
			return;
		}
		if (textureCache.containsKey(name)) return;

		QuickTiGame2dTexture texture = new QuickTiGame2dTexture(getContext());
		texture.setDebug(getDebug());
		texture.setName(name);
		texture.onLoad(gl, data);
		
		textureCache.put(name, texture);
		
		if (tag != null && tag.length() > 0) {
			textureTagCache.put(tag,  name);
		}
	}

	public void unloadTexture(GL10 gl, String name, String tag) {
		if (name == null && tag != null && tag.length() > 0) {
			name = textureTagCache.get(tag);
			if (name != null) {
				textureTagCache.remove(tag);
			}
		}
		
		if (debug && name == null && tag == null) {
        	Log.w(Quicktigame2dModule.LOG_TAG, 
            		"QuickTiGame2dGameView:unloadTexture both name and tag equals null!");
			return;
		}
		
		if (!textureCache.containsKey(name)) return;
		QuickTiGame2dTexture texture = textureCache.get(name);
		texture.onDispose(gl);
		textureCache.remove(name);
	}
	
	public static void deleteGLBuffer(final int[] ids) {
    	afterCommandQueue.offer(new RunnableGL() {
    		@Override
    		public void run(GL10 gl10) {
    			GL11 gl = (GL11)gl10;
    			gl.glDeleteBuffers(ids.length, ids, 0);
    		}
    	});
	}
	
	private void loadSquareVBOPointer(GL10 gl10) {
		if (squareVBOLoaded) return;
		
		GL11 gl = (GL11)gl10;
		
	    squareIndices[0] = 0;
	    squareIndices[1] = 1;
	    squareIndices[2] = 2;
	    squareIndices[3] = 3;
		
	    squarePositions[0] = 0;
	    squarePositions[1] = 0;
	    squarePositions[2] = 0;
		
	    squarePositions[3] = 0;
	    squarePositions[4] = 1;
	    squarePositions[5] = 0;
		
	    squarePositions[6] = 1;
	    squarePositions[7] = 1;
	    squarePositions[8] = 0;
		
	    squarePositions[9]  = 1;
	    squarePositions[10] = 0;
	    squarePositions[11] = 0;
		
	    ShortBuffer squareIndicesBuffer   = GLHelper.createShortBuffer(squareIndices);
	    FloatBuffer squarePositionsBuffer = GLHelper.createFloatBuffer(squarePositions);
	    
	    gl.glGenBuffers(2, squareVBOPointerCache, 0);
		
	    gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, squareVBOPointerCache[0]);
	    gl.glBufferData(GL11.GL_ARRAY_BUFFER, 4 * 12, squarePositionsBuffer, GL11.GL_STATIC_DRAW);
	    gl.glBindBuffer(GL11.GL_ELEMENT_ARRAY_BUFFER, squareVBOPointerCache[1]);
	    gl.glBufferData(GL11.GL_ELEMENT_ARRAY_BUFFER, 2 * 4, squareIndicesBuffer, GL11.GL_STATIC_DRAW);
		
	    gl.glBindBuffer(GL11.GL_ELEMENT_ARRAY_BUFFER, 0);
	    gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, 0);
	    
	    if (debug) GLHelper.checkError(gl);
	    
	    squareVBOLoaded = true;
	}
	
	private void restoreGLState(GL10 gl10, boolean enabled) {
		GL11 gl = (GL11)gl10;
	    if (enabled) {
	        gl.glDisable(GL11.GL_LIGHTING);
	        gl.glDisable(GL11.GL_MULTISAMPLE);
	        gl.glDisable(GL11.GL_DITHER);
	        gl.glDisable(GL11.GL_CULL_FACE);
	        gl.glDisable(GL11.GL_DEPTH_TEST);
	        gl.glDisable(GL11.GL_ALPHA_TEST);
	        
	        gl.glEnable(GL11.GL_TEXTURE_2D);
	        gl.glEnable(GL11.GL_BLEND);
	        gl.glBlendFunc(GL11.GL_ONE, GL11.GL_ONE_MINUS_SRC_ALPHA);
	        
	        gl.glHint(GL11.GL_POINT_SMOOTH_HINT, QuickTiGame2dGameView.correctionHint);
	        gl.glHint(GL11.GL_LINE_SMOOTH_HINT,  QuickTiGame2dGameView.correctionHint);
	        gl.glHint(GL11.GL_PERSPECTIVE_CORRECTION_HINT, QuickTiGame2dGameView.correctionHint);
	        
	        gl.glEnableClientState(GL11.GL_VERTEX_ARRAY);
	        gl.glEnableClientState(GL11.GL_TEXTURE_COORD_ARRAY);
	        gl.glDisableClientState(GL11.GL_COLOR_ARRAY);
	    } else {
	    	gl.glBindBuffer(GL11.GL_ELEMENT_ARRAY_BUFFER, 0);
	    	gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, 0);
	    	gl.glBindTexture(GL11.GL_TEXTURE_2D, 0);
	        
	    	gl.glDisable(GL11.GL_ALPHA_TEST);
	    	gl.glDisable(GL11.GL_DEPTH_TEST);
	    	gl.glDisable(GL11.GL_TEXTURE_2D);
	    	gl.glDisable(GL11.GL_BLEND);
	        
	    	gl.glDisableClientState(GL11.GL_VERTEX_ARRAY);
	    	gl.glDisableClientState(GL11.GL_TEXTURE_COORD_ARRAY);
	    	gl.glDisableClientState(GL11.GL_COLOR_ARRAY);
	    }
	}
	
	private void updateCameraInfo() {
	    float zfar = Math.max(width, height) * 4;
	    
	    defaultPortraitCamera.eyeX = (float) (width  * 0.5);
	    defaultPortraitCamera.eyeY = (float) (height * 0.5);
	    defaultPortraitCamera.eyeZ = (float) (height * 0.5);
	    defaultPortraitCamera.centerX = (float) (width * 0.5);
	    defaultPortraitCamera.centerY = (float) (height * 0.5);
	    defaultPortraitCamera.centerZ = 0;
	    defaultPortraitCamera.upX = 0;
	    defaultPortraitCamera.upY = 1;
	    defaultPortraitCamera.upZ = 0;
	    defaultPortraitCamera.zNear = 1;
	    defaultPortraitCamera.zFar  = zfar;
	    defaultPortraitCamera.loaded = true;

	    defaultLandscapeCamera.eyeX = (float) (width  * 0.5);
	    defaultLandscapeCamera.eyeY = (float) (height * 0.5);
	    defaultLandscapeCamera.eyeZ = (float) (width  * 0.5);
	    defaultLandscapeCamera.centerX = (float) (width * 0.5);
	    defaultLandscapeCamera.centerY = (float) (height * 0.5);
	    defaultLandscapeCamera.centerZ = 0;
	    defaultLandscapeCamera.upX = 1;
	    defaultLandscapeCamera.upY = 0;
	    defaultLandscapeCamera.upZ = 0;
	    defaultLandscapeCamera.zNear = 1;
	    defaultLandscapeCamera.zFar  = zfar;
	    defaultLandscapeCamera.loaded = false;
	}
	
	private void updateHUDViewport(GL10 gl) {
        gl.glViewport(0, 0, framebufferWidth, framebufferHeight); 
        gl.glMatrixMode(GL10.GL_PROJECTION);
        gl.glLoadIdentity();
        
        float zFar = this.defaultPortraitCamera.zFar;
        
        gl.glOrthof(0, width, height, 0, -zFar, zFar);
	}
	
	public void updateOrthoViewport(GL10 gl) {
        gl.glViewport(0, 0, framebufferWidth, framebufferHeight); 
        gl.glMatrixMode(GL10.GL_PROJECTION);
        gl.glLoadIdentity();
        
        float zFar = this.defaultPortraitCamera.zFar;
        
        gl.glOrthof(0, width, height, 0, -zFar, zFar);
	}
	
	public void forceUpdateViewport(GL10 gl) {
		this.dirty = true;
		this.updateViewport(gl);
	}
	
	private void updateViewport(GL10 gl) {
	    if (dirty) {
	        gl.glViewport(0, 0, framebufferWidth, framebufferHeight); 
	        gl.glMatrixMode(GL10.GL_PROJECTION);
	        gl.glLoadIdentity();
	        
	        if (shouldRotateOrientation) {
	            int _width = width;
	            width  = height;
	            height = _width;
	            shouldRotateOrientation = false;
	        }
	        
	        updateCameraInfo();
	        
	        if (usePerspective) {
	            float ratio = framebufferWidth / (float)framebufferHeight;
	        
	            QuickTiGame2dCameraInfo camera = defaultPortraitCamera;
	            
	            gl.glFrustumf(-ratio, ratio, 1, -1, camera.zNear, camera.zFar);
	            
	            if (useCustomCamera) {
	                camera.eyeX = customCamera.eyeX;
	                camera.eyeY = customCamera.eyeY;
	                camera.eyeZ = customCamera.eyeZ;
	                
	                camera.centerX = customCamera.centerX;
	                camera.centerY = customCamera.centerY;
	                camera.centerZ = customCamera.centerZ;
	            }
	    	    
	            GLU.gluLookAt(gl, camera.eyeX, camera.eyeY, camera.eyeZ, 
	                      camera.centerX, camera.centerY, camera.centerZ,
	                      camera.upX,     camera.upY,     camera.upZ);
	        } else {
	            gl.glOrthof(0, width, height, 0, -100, 100);
	        }
	        
	        dirty = false;
	    }
	}

	private int getFpsMsec() {
		return (int)(1000.0f / fps);
	}
	
	public boolean isFpsTimeElapsed(int delta) {
		// look ahead for 1 frame
		return delta + 16 >= getFpsMsec();
	}

	private void prepareScreenShot(GL10 gl) {
        
        if (!takeSnapshot && releaseSnapshot) {
            if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "QuickTiGame2dGameView:releaseSnapshot");
            if (snapshotSprite != null) {
            	snapshotSprite.onDispose();
            	snapshotSprite = null;
            }
            releaseSnapshot = false;
        }
        
        if (takeSnapshot) {
            if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "QuickTiGame2dGameView:takeSnapshot start");
            
            GL11ExtensionPack gl11Ext = (GL11ExtensionPack)gl;
            
            int[] framebufferOldId = new int[1];
            gl11Ext.glGetIntegerv(GL11ExtensionPack.GL_FRAMEBUFFER_BINDING_OES, framebufferOldId, 0);
            int error = gl.glGetError();
            if (error != GL10.GL_NO_ERROR) {
                framebufferOldId[0] = 0;
            }
            snapshotTexture.setFramebufferOldId(framebufferOldId[0]);
            
            gl11Ext.glBindFramebufferOES(GL11ExtensionPack.GL_FRAMEBUFFER_OES, snapshotTexture.getFramebufferId());
            
            dirty = true;
        }
	}

	private void finishScreenShot(GL10 gl) {
        if (takeSnapshot) {
            if(snapshotTexture.getFramebufferOldId() >= 0) {
	            GL11ExtensionPack gl11Ext = (GL11ExtensionPack)gl;
	            
                gl11Ext.glBindFramebufferOES(GL11ExtensionPack.GL_FRAMEBUFFER_OES, snapshotTexture.getFramebufferOldId());
                snapshotTexture.setFramebufferOldId(0);

                snapshotSprite  = new QuickTiGame2dSprite();
                snapshotSprite.setImage(QuickTiGame2dConstant.SNAPSHOT_TEXTURE_NAME);
                snapshotSprite.setWidth(width);
                snapshotSprite.setHeight(height);
                snapshotSprite.setX(0);
                snapshotSprite.setY(0);
                snapshotSprite.setZ(99.5f);
            }
            
            takeSnapshot = false;
            if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "QuickTiGame2dGameView:takeSnapshot end");
        }
	}
	
	@Override
	public void onDrawFrame(GL10 gl) {
		if (!focused || !orientationFixed) return;
		if (!loaded) onLoad(gl);
		
		if (shouldReloadSnapshot) {
			loadSnapshotTexture(gl);
			shouldReloadSnapshot = false;
		}
		
		restoreGLState(gl, true);

		while(!beforeCommandQueue.isEmpty()) {
			beforeCommandQueue.poll().run(gl);
		}
		
		QuickTiGame2dScene scene = this.topScene();
		
		if (!takeSnapshot && previousScene != null) {
			if (previousScene != scene) {
				previousScene.onDeactivate();
			}
			previousScene = null;
		}
		
		if (scene != null && status != GAME_STOPPED) {
			
			// check event delta time
			int delta = (int)((uptime() - lastOnDrawTime) * 1000);
			if (enableOnDrawFrameEvent) {
				synchronized (listeners) {
					for (GameViewEventListener listener : listeners) {
						listener.onDrawFrame(delta);
					}
				}
			}
			
			lastOnDrawTime = uptime();
			
	        if (enableOnFpsEvent) {
	        	fpsFrameCount++;
	        	int   fpsdelta = (int)((uptime() - lastOnFpsTime) * 1000);
	        	float fpsvalue = fpsFrameCount / (fpsdelta / 1000.0f);
	        	if (fpsdelta > onFpsInterval) {
	        		synchronized (listeners) {
	        			for (GameViewEventListener listener : listeners) {
	        				listener.onFps(fpsdelta, fpsvalue);
	        			}
	        		}
	        		lastOnFpsTime = uptime();
	        		fpsFrameCount = 0;
	        	}
	        }
			
	        prepareScreenShot(gl);
	        
			synchronized (cameraTransforms) {
				onTransformCamera();
			}
			
			updateViewport(gl);
			
			scene.setDebug(debug);
			scene.setSnapshot(takeSnapshot);
			
			if (!scene.isLoaded()) {
				scene.onLoad(gl, this);
			}
			scene.onDrawFrame(gl);
			
	        if (hudScene.hasSprite()) {
	            updateHUDViewport(gl);
	            
	            hudScene.setDebug(debug);
	            hudScene.setSnapshot(takeSnapshot);
	            
				if (!hudScene.isLoaded()) {
					hudScene.onLoad(gl, this);
				}
	            hudScene.onDrawFrame(gl);
	            
	            dirty = true;
	        }

	        finishScreenShot(gl);
	        
	        scene.setSnapshot(takeSnapshot);
		} else {
			gl.glClear(GL10.GL_COLOR_BUFFER_BIT | GL10.GL_DEPTH_BUFFER_BIT);
			gl.glClearColor(color[0], color[1], color[2], color[3]);
		}
		
	    if (snapshotSprite != null) {
	        snapshotSprite.onLoad(gl, this);
	        snapshotSprite.onDrawFrame(gl);
	    }
	    
		while(beforeCommandQueue.isEmpty() && !afterCommandQueue.isEmpty()) {
			afterCommandQueue.poll().run(gl);
		}
	    
		restoreGLState(gl, false);
	}

	protected void onActivateScene(QuickTiGame2dScene activateScene) {
		if (activateScene == null) return;
		synchronized (listeners) {
			for (GameViewEventListener listener : listeners) {
				listener.onActivateScene(activateScene);
			}
		}
	}
	
	protected void onDeactivateScene(QuickTiGame2dScene deactivateScene) {
		if (deactivateScene == null) return;
		synchronized (listeners) {
			for (GameViewEventListener listener : listeners) {
				listener.onDeactivateScene(deactivateScene);
			}
		}
	}
	
	@Override
	public void onSurfaceChanged(GL10 gl, int width, int height) {
		updateSurfaceSize(width, height);
		
		synchronized (listeners) {
			for (GameViewEventListener listener : listeners) {
				listener.onSurfaceChanged(width, height);
			}
		}
		
		if (debug) Log.d(Quicktigame2dModule.LOG_TAG, 
				String.format("QuickTiGame2dGameView.onSurfaceChanged orientation=%d buffer=%dx%d screen=%dx%d",
						orientation, framebufferWidth, framebufferHeight, this.width, this.height));

	}

	@Override
	public void onSurfaceCreated(GL10 gl, EGLConfig congi) {
		updateSurfaceSize(getMeasuredWidth(), getMeasuredHeight());
		
		if (debug) Log.d(Quicktigame2dModule.LOG_TAG, 
				String.format("QuickTiGame2dGameView.onSurfaceCreated orientation=%d buffer=%dx%d screen=%dx%d",
						orientation, framebufferWidth, framebufferHeight, this.width, this.height));
	}
	
	private void updateSurfaceSize(int width, int height) {
		if (width <= 0 || height <= 0) return;
		
		this.framebufferWidth  = width;
		this.framebufferHeight = height;
		
		if (!sizeChanged) this.width  = width;
		if (!sizeChanged) this.height = height;
		
		this.orientationFixed = true;
		this.dirty  = true;
		this.shouldReloadSnapshot = true;
	}
	
	public void start() {
		status = GAME_STARTED;
	}
	
	public void stop() {
		status = GAME_STOPPED;
	}
	
	public void pause() {
		status = GAME_PAUSED;
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
		return debug;
	}
	
	public void setGameViewWidth(int width) {
		setGameViewSize(width, this.height);
	}
	
	public void setGameViewHeight(int height) {
		setGameViewSize(this.width, height);
	}
	
	public void setGameViewSize(int width, int height) {
		this.width  = width;
		this.height = height;
		this.sizeChanged = true;
	}
	
	public int getGameViewWidth() {
		return width;
	}
	
	public int getGameViewHeight() {
		return height;
	}
	
	public int getFramebufferWidth() {
		return framebufferWidth;
	}
	
	public int getFramebufferHeight() {
		return framebufferHeight;
	}

	public void setFramebufferWidth(int value) {
		framebufferWidth = value;
	}
	
	public void setFramebufferHeight(int value) {
		framebufferHeight = value;
	}

	public float getFps() {
		return fps;
	}
	
	public void setFps(float fps) {
		this.fps = fps;
	}
	
	public void setOrientation(int orientation) {
		// ignore reversed orientation because it looks like Titanium does not support the orientation
		
		if (orientation == TiOrientationHelper.ORIENTATION_LANDSCAPE_REVERSE) {
			orientation = TiOrientationHelper.ORIENTATION_LANDSCAPE;
		} else if (orientation == TiOrientationHelper.ORIENTATION_PORTRAIT_REVERSE) {
			orientation = TiOrientationHelper.ORIENTATION_PORTRAIT;
		}
		
		this.orientation = orientation;
	}
	
	public int getOrientation() {
		return orientation;
	}
	
	public QuickTiGame2dCameraInfo getCamera() {
	    if (useCustomCamera && customCamera.loaded) {
	        return customCamera;
	    }
	    
	    updateCameraInfo();

	    return defaultPortraitCamera;
	}
	
	public void setCamera(QuickTiGame2dCameraInfo camera) {
	    useCustomCamera = true;
	    customCamera.copy(camera);
	    customCamera.loaded = true;
	    dirty = true;
	}
	
	public void resetCamera() {
	    useCustomCamera = false;
	    dirty = true;
	}
	
	public QuickTiGame2dScene topScene() {
		try {
			return sceneStack.peek();
		} catch (EmptyStackException e) {
			return null;
		}
	}
	
	private QuickTiGame2dScene popSceneOrNull() {
		try {
			return sceneStack.pop();
		} catch (EmptyStackException e) {
			return null;
		}
	}
	
	public QuickTiGame2dScene popScene() {
    	snapshot();

    	afterCommandQueue.offer(new RunnableGL() {
    		@Override
    		public void run(GL10 gl) {
    			if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "QuickTiGame2dGameView:popScene");
    			previousScene = popSceneOrNull();
    			onDeactivateScene(previousScene);
    			onActivateScene(topScene());
    		}
    	});
	    
	    return topScene();
	}

	public QuickTiGame2dScene pushScene(final QuickTiGame2dScene scene) {
	    snapshot();
	    
	    afterCommandQueue.offer(new RunnableGL() {
	    	@Override
	    	public void run(GL10 gl) {
	    		if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "QuickTiGame2dGameView:pushScene");
	    		previousScene = topScene();
	    		onDeactivateScene(previousScene);
	    		sceneStack.push(scene);
	    		onActivateScene(topScene());
	    	}
	    });
	    
	    return scene;
	}
	
	public QuickTiGame2dScene replaceScene(final QuickTiGame2dScene scene) {
	    snapshot();
	    
	    afterCommandQueue.offer(new RunnableGL() {
	    	@Override
	    	public void run(GL10 gl) {
	    		if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "QuickTiGame2dGameView:replaceScene");
	    		previousScene = popSceneOrNull();
	    		onDeactivateScene(previousScene);
	    		sceneStack.push(scene);
	    		onActivateScene(topScene());
	    	}
	    });
	    
	    return topScene();
	}
	
	public void addListener(GameViewEventListener listener) {
		synchronized (listeners) {
			if (!listeners.contains(listener)) listeners.add(listener);
		}
	}
	
	public void removeListener(GameViewEventListener listener) {
		synchronized (listeners) {
			listeners.remove(listener);
		}
	}
	
	public static double uptime() {
		return (System.currentTimeMillis() - startTime) / 1000.0;
	}
	
	public static int sharedPositionPointer() {
		return squareVBOPointerCache[0];
	}
	
	public static int sharedIndexPointer() {
		return squareVBOPointerCache[1];
	}
	
	public void snapshot() {
	    if (offscreenSupported && topScene() != null) {
	    	beforeCommandQueue.offer(new RunnableGL() {
	    		@Override
	    		public void run(GL10 gl) {
	    			takeSnapshot = true;
	    		}
	    	});
	    }
	}

	public void releaseSnapshot() {
	    if (offscreenSupported && topScene() != null) {
	    	beforeCommandQueue.offer(new RunnableGL() {
	    		@Override
	    		public void run(GL10 gl) {
	    			releaseSnapshot = true;
	    		}
	    	});
	    }
	}

	public boolean isUsePerspective() {
		return usePerspective;
	}

	public void setUsePerspective(boolean usePerspective) {
		this.usePerspective = usePerspective;
	}

	public boolean isOnDrawFrameEventEnabled() {
		return enableOnDrawFrameEvent;
	}

	public void enableOnDrawFrameEvent(boolean enableOnDrawFrameEvent) {
		this.enableOnDrawFrameEvent = enableOnDrawFrameEvent;
	}

	public boolean isOnFpsEventEnabled() {
		return enableOnFpsEvent;
	}

	public void enableOnFpsEvent(boolean enableOnFpsEvent) {
		this.enableOnFpsEvent = enableOnFpsEvent;
	}
	
	private void onTransformCamera() {
	    if (cameraTransforms.size() == 0) return;

	    for (QuickTiGame2dTransform transform : cameraTransforms) {
	        if (transform.isCompleted()) {
	            cameraTransformsToBeRemoved.add(transform);
	            continue;
	        }
	        
	        // waiting for delay
	        if (!transform.hasStarted()) continue;
	        
	        // fire onStartTransform event
	        if (!transform.isStartEventFired()) {
	        	transform.setStartEventFired(true);
	        	onStartTransform(transform);
	        }
	        
	        if (transform.hasExpired()) {
	            // if transform has been completed, finish the transformation
	            if (transform.getRepeat() >= 0 && transform.getRepeatCount() >= transform.getRepeat()) {
	                if (transform.isAutoreverse() && !transform.isReversing()) {
	                    // no nothing
	                } else {
	                    applyTransformCamera(transform);
	                    completeTransformCamera(transform);
	                    continue;
	                }
	            }
	            
	            if (transform.isAutoreverse()) {
	    	        applyTransformCamera(transform);
	                transform.reverse();
	            } else if (transform.getRepeat() < 0) {
	                // transform.repeat < 0 means infinite loop
	    	        applyTransformCamera(transform);
	                transform.start();
	            } else {
	    	        applyTransformCamera(transform);
	                transform.restart();
	            }
                continue;
	        }
	        
	        applyTransformCamera(transform);
	    }

	    for (QuickTiGame2dTransform transform : cameraTransformsToBeRemoved) {
	        cameraTransforms.remove(transform);
	    }
	    cameraTransformsToBeRemoved.clear();
	}

	public void transformCamera(QuickTiGame2dTransform transform) {
	    synchronized (cameraTransforms) {
	    	try {
	    		cameraTransforms.remove(transform);
	    		cameraTransforms.add(transform);

	    		// save initial state
	    		transform.setStart_x(getCamera().eyeX);
	    		transform.setStart_y(getCamera().eyeY);
	    		transform.setStart_z(getCamera().eyeZ);
	    		transform.setStart_rotate_centerX(getCamera().centerX);
	    		transform.setStart_rotate_centerY(getCamera().centerY);

	    		transform.start();
	    	} catch (Exception e) {
	    		Log.e(Quicktigame2dModule.LOG_TAG, "Error at sprite.transform", e);
	    	}
	    }
	}

	public void applyTransformCamera(QuickTiGame2dTransform transform) {
		if (transform.isCompleted()) return;
		
	    transform.apply();
	    
		transformCameraCache.copy(getCamera());
	    
	    if (transform.getX() != null) transformCameraCache.eyeX = transform.getCurrent_x();
	    if (transform.getY() != null) transformCameraCache.eyeY = transform.getCurrent_y();
	    if (transform.getZ() != null) transformCameraCache.eyeZ = transform.getCurrent_z();
	    
	    if (transform.getRotate_centerX() != null) {
	    	transformCameraCache.centerX = transform.getCurrent_rotate_centerX();
	    } else if (transform.getX() != null) {
	    	transformCameraCache.centerX = transform.getCurrent_x();
	    }

	    if (transform.getRotate_centerY() != null) {
	    	transformCameraCache.centerY = transform.getCurrent_rotate_centerY();
	    } else if (transform.getY() != null) {
	    	transformCameraCache.centerY = transform.getCurrent_y();
	    }
	    
	    setCamera(transformCameraCache);
	}

	private void completeTransformCamera(QuickTiGame2dTransform transform) {
	    
	    transform.setCompleted(true);
	    
	    onCompleteTransform(transform);
	}

	public void clearTransformCameras() {
	    synchronized(cameraTransforms) {
	        for (QuickTiGame2dTransform transform : cameraTransforms) {
	            transform.setCompleted(true);
	        }
	    }
	}

	public void clearTransformCamera(QuickTiGame2dTransform transform) {
	    synchronized(cameraTransforms) {
	        transform.setCompleted(true);
	    }
	}
	
	public void addHUD(QuickTiGame2dSprite sprite) {
		hudScene.addSprite(sprite);
	}

	public void removeHUD(QuickTiGame2dSprite sprite) {
		hudScene.removeSprite(sprite);
	}

	public int getOnFpsInterval() {
		return onFpsInterval;
	}

	public void setOnFpsInterval(int onFpsInterval) {
		this.onFpsInterval = onFpsInterval;
	}

	@Override
	public void onPause() {
        if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "QuickTiGame2dGameView:onPause");
		super.onPause();
	}

	@Override
	public void onResume() {
        if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "QuickTiGame2dGameView:onResume");
        
		super.onResume();
	}
	
	@Override
	public void onPause(Activity context) {
		this.onPause();
	}

	@Override
	public void onResume(Activity context) {
		this.onResume();
	}

	@Override
	public void onStart(Activity context) {
		// Do nothing
	}

	@Override
	public void onStop(Activity context) {
		// Do nothing
	}
	
	@Override
	public void onDestroy(Activity arg0) {

	}

	public boolean isOpaqueBackground() {
		return opaqueBackground;
	}

	public void setOpaqueBackground(boolean opaqueBackground) {
		this.opaqueBackground = opaqueBackground;
		
		if (opaqueBackground) {
			getHolder().setFormat(PixelFormat.RGB_565);
		} else {
			setZOrderOnTop(true);
			setEGLConfigChooser(8, 8, 8, 8, 16, 0);
			getHolder().setFormat(PixelFormat.TRANSLUCENT);
		}
	}

}
