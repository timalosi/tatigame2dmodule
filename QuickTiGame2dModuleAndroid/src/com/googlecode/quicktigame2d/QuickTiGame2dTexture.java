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

import java.io.IOException;
import java.io.InputStream;

import javax.microedition.khronos.opengles.GL10;
import javax.microedition.khronos.opengles.GL11;
import javax.microedition.khronos.opengles.GL11ExtensionPack;

import org.appcelerator.kroll.common.Log;
import com.googlecode.quicktigame2d.opengl.GLHelper;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Bitmap.Config;
import android.graphics.BitmapFactory;
import android.opengl.GLUtils;

public class QuickTiGame2dTexture {

	private Context context;
	private String name;
	private boolean loaded;
	private boolean debug;
	private int width;
	private int height;
	private int glWidth;
	private int glHeight;
	private byte[] data;
	private boolean hasAlpha;
	private boolean freed;
	private int dataLength;

	private boolean isSnapshot;
	private int framebufferId;
	private int framebufferOldId;
	
	private boolean useCustomFilter = false;
	private int textureFilter = GL10.GL_NEAREST;

	private final int[] GENERATED_TEXTUREID  = new int[1];

	public QuickTiGame2dTexture(Context context) {
		this.context = context;
	}

	public void onLoad(GL10 gl) {
		onLoad(gl, null);
	}
	
	public void onLoad(GL10 gl, byte[] data) {
		if (loaded) return;

		if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "load Texture " + getDescription());

		// generate texture id even if no image is bound to this texture.
		gl.glGenTextures(1, GENERATED_TEXTUREID, 0);
		
		if (name == null) {
			loaded = true;
			return;
		}
		
		gl.glBindTexture(GL10.GL_TEXTURE_2D, getTextureId());
		
		gl.glTexParameterf(GL10.GL_TEXTURE_2D, GL10.GL_TEXTURE_MIN_FILTER, getTextureFilter());
		gl.glTexParameterf(GL10.GL_TEXTURE_2D, GL10.GL_TEXTURE_MAG_FILTER, getTextureFilter());
		gl.glTexParameterf(GL10.GL_TEXTURE_2D, GL10.GL_TEXTURE_WRAP_S, GL10.GL_CLAMP_TO_EDGE);
		gl.glTexParameterf(GL10.GL_TEXTURE_2D, GL10.GL_TEXTURE_WRAP_T, GL10.GL_CLAMP_TO_EDGE);
		gl.glTexEnvf(GL10.GL_TEXTURE_ENV, GL10.GL_TEXTURE_ENV_MODE, GL10.GL_MODULATE);

		Bitmap bitmap = null;
		
		if (data == null) {
			bitmap = loadBitmap(name);
		} else {
			bitmap = loadBitmap(name, data);
		}
		
		if (bitmap == null) {
			loaded = true;
			return;
		}
		
		try {
			if (QuickTiGame2dUtil.isPowerOfTwo(width) && QuickTiGame2dUtil.isPowerOfTwo(height)) {
				GLUtils.texImage2D(GL10.GL_TEXTURE_2D, 0, bitmap, 0);
			} else {
				final Bitmap holder = Bitmap.createBitmap(glWidth, glHeight, Bitmap.Config.ARGB_8888);
				GLUtils.texImage2D(GL10.GL_TEXTURE_2D, 0, holder, 0);
				holder.recycle();
				
				GLHelper.texSubImage2D(gl, GL10.GL_TEXTURE_2D, 0, 
						0, 0, bitmap, GL10.GL_RGBA, GL10.GL_UNSIGNED_BYTE);             
			}

		} finally {
			bitmap.recycle();
			bitmap = null;
		}
		
		loaded = true;
	}

	public boolean onLoadSnapshot(GL10 gl10, int width, int height) {
		GL11ExtensionPack gl11Ext  = (GL11ExtensionPack)gl10;
		
	    name   = QuickTiGame2dConstant.SNAPSHOT_TEXTURE_NAME;
	    
	    this.width  = width;
	    this.height = height;
	    
	    this.glWidth  = QuickTiGame2dUtil.nextPowerOfTwo(width);
	    this.glHeight = QuickTiGame2dUtil.nextPowerOfTwo(height);

		gl10.glEnable(GL11.GL_TEXTURE_2D);
		gl10.glGenTextures(1, GENERATED_TEXTUREID, 0);
	    
	    gl11Ext.glBindTexture(GL11.GL_TEXTURE_2D, getTextureId());
	    gl10.glTexImage2D(GL11.GL_TEXTURE_2D, 0, GL11.GL_RGB, 
	    		QuickTiGame2dUtil.nextPowerOfTwo(width), QuickTiGame2dUtil.nextPowerOfTwo(height),
	    		0, GL11.GL_RGB, GL11.GL_UNSIGNED_BYTE, null);
	    gl11Ext.glTexParameterf(GL11.GL_TEXTURE_2D, GL11.GL_TEXTURE_MIN_FILTER, getTextureFilter());
	    gl11Ext.glTexParameterf(GL11.GL_TEXTURE_2D, GL11.GL_TEXTURE_MAG_FILTER, getTextureFilter());
	    gl11Ext.glTexParameterf(GL11.GL_TEXTURE_2D, GL11.GL_TEXTURE_WRAP_S, GL11.GL_CLAMP_TO_EDGE);
	    gl11Ext.glTexParameterf(GL11.GL_TEXTURE_2D, GL11.GL_TEXTURE_WRAP_T, GL11.GL_CLAMP_TO_EDGE);
	    
	    int[] frameParam = new int[1];
		gl11Ext.glGetIntegerv(GL11ExtensionPack.GL_FRAMEBUFFER_BINDING_OES, frameParam, 0);
        int error = gl10.glGetError();
        if (error != GL10.GL_NO_ERROR) {
            frameParam[0] = 0;
        }
		framebufferOldId = frameParam[0];
		
		gl11Ext.glGenFramebuffersOES(1, frameParam, 0);
		gl11Ext.glBindFramebufferOES(GL11ExtensionPack.GL_FRAMEBUFFER_OES, frameParam[0]);
	    framebufferId = frameParam[0];
	    
        gl11Ext.glFramebufferTexture2DOES(GL11ExtensionPack.GL_FRAMEBUFFER_OES,
                GL11ExtensionPack.GL_COLOR_ATTACHMENT0_OES, GL10.GL_TEXTURE_2D,
                getTextureId(), 0);
	    
        int status = gl11Ext.glCheckFramebufferStatusOES(GL11ExtensionPack.GL_FRAMEBUFFER_OES);
        if (status != GL11ExtensionPack.GL_FRAMEBUFFER_COMPLETE_OES) {
	        onDispose(gl10);
	        Log.d(Quicktigame2dModule.LOG_TAG, "Could not create snapshot buffer: " + Integer.toHexString(status));
	        return false;
        }
	    
	    gl11Ext.glBindFramebufferOES(GL11ExtensionPack.GL_FRAMEBUFFER_OES, framebufferOldId);

	    isSnapshot = true;
	    loaded = true;
	    
	    return true;
	}
	
	
	public void onDispose(GL10 gl) {
		if (!loaded) return;
		if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "unload Texture " + getDescription());

		deleteTextureBuffer(gl);
		loaded = false;
	}

	public void reload(GL10 gl) {
		if (!loaded) return;
		if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "reload Texture" + getDescription());
		
		deleteTextureBuffer(gl);
		loaded = false;
	}
	
	public String getDescription() {
		if (name == null) return String.format("Rectangle %dx%d", width, height);
		else if (width == 0 && height == 0) return name;
		else return String.format("%s %dx%d", name, width, height);
	}
	
	private void deleteTextureBuffer(GL10 gl) {
		if (getTextureId() <= 0) return;
        gl.glDeleteTextures(1, GENERATED_TEXTUREID, 0);
        GENERATED_TEXTUREID[0] = 0;
	}

	private Bitmap loadBitmap(String name, byte[] data) {
		Bitmap bitmap  = null;
		BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
		bitmapOptions.inPreferredConfig = Config.ARGB_8888;

		try {
			bitmap = BitmapFactory.decodeByteArray(data, 0, data.length, bitmapOptions);

			setWidth(bitmapOptions.outWidth);
			setHeight(bitmapOptions.outHeight);

			setGlWidth(QuickTiGame2dUtil.nextPowerOfTwo(getWidth()));
			setGlHeight(QuickTiGame2dUtil.nextPowerOfTwo(getHeight()));

		} catch (Exception e) {
			if (debug) Log.w(Quicktigame2dModule.LOG_TAG, "Failed to load bitmap " + name, e);
		}
		
		return bitmap;
	}
	
	private Bitmap loadBitmap(String name) {
		InputStream is = null;
		Bitmap bitmap  = null;
		BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
		bitmapOptions.inPreferredConfig = Config.ARGB_8888;

		try {
			
			is = QuickTiGame2dUtil.getFileInputStream(name);
			bitmap = BitmapFactory.decodeStream(is, null, bitmapOptions);

			setWidth(bitmapOptions.outWidth);
			setHeight(bitmapOptions.outHeight);

			setGlWidth(QuickTiGame2dUtil.nextPowerOfTwo(getWidth()));
			setGlHeight(QuickTiGame2dUtil.nextPowerOfTwo(getHeight()));

		} catch (Exception e) {
			if (debug) Log.d(Quicktigame2dModule.LOG_TAG, "Failed to load bitmap " + name, e);
		} finally {
			if (is != null) {
				try {
					is.close();
				} catch (IOException e) {
					// nothing to do
				}
			}
		}
		return bitmap;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public boolean isLoaded() {
		return loaded;
	}

	public void setLoaded(boolean loaded) {
		this.loaded = loaded;
	}

	public int getTextureId() {
		return GENERATED_TEXTUREID[0];
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

	public int getGlWidth() {
		return glWidth;
	}

	public void setGlWidth(int glWidth) {
		this.glWidth = glWidth;
	}

	public int getGlHeight() {
		return glHeight;
	}

	public void setGlHeight(int glHeight) {
		this.glHeight = glHeight;
	}

	public byte[] getData() {
		return data;
	}

	public void setData(byte[] data) {
		this.data = data;
	}

	public boolean hasAlpha() {
		return hasAlpha;
	}

	public void setHasAlpha(boolean hasAlpha) {
		this.hasAlpha = hasAlpha;
	}

	public boolean isFreed() {
		return freed;
	}

	public void setFreed(boolean freed) {
		this.freed = freed;
	}

	public int getDataLength() {
		return dataLength;
	}

	public void setDataLength(int dataLength) {
		this.dataLength = dataLength;
	}

	public boolean isSnapshot() {
		return isSnapshot;
	}

	public void setSnapshot(boolean isSnapshot) {
		this.isSnapshot = isSnapshot;
	}

	public int getFramebufferId() {
		return framebufferId;
	}

	public void setFramebufferId(int framebufferId) {
		this.framebufferId = framebufferId;
	}

	public int getFramebufferOldId() {
		return framebufferOldId;
	}

	public void setFramebufferOldId(int framebufferOldId) {
		this.framebufferOldId = framebufferOldId;
	}

	public boolean isDebug() {
		return debug;
	}

	public void setDebug(boolean debug) {
		this.debug = debug;
	}

	public Context getContext() {
		return context;
	}

	public float getMaxS() {
	    return width / (float)glWidth;
	}

	public float getMaxT() {
	    return height / (float)glHeight;
	}

	public int getTextureFilter() {
		if (useCustomFilter) {
			return textureFilter;
		} else {
			return QuickTiGame2dGameView.textureFilter;
		}
	}

	public void setTextureFilter(int textureFilter) {
		this.useCustomFilter = true;
		this.textureFilter = textureFilter;
	}

}
