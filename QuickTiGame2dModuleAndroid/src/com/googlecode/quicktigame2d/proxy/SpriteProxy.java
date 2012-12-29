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
package com.googlecode.quicktigame2d.proxy;

import java.util.ArrayList;
import java.util.HashMap;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiBlob;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.titanium.util.TiPlatformHelper;

import com.googlecode.quicktigame2d.QuickTiGame2dConstant;
import com.googlecode.quicktigame2d.QuickTiGame2dSprite;
import com.googlecode.quicktigame2d.Quicktigame2dModule;

import android.util.Log;

@Kroll.proxy(creatableInModule=Quicktigame2dModule.class)
public class SpriteProxy extends KrollProxy {
	protected QuickTiGame2dSprite sprite;
	protected ArrayList<TransformProxy> transforms = new ArrayList<TransformProxy>();
	protected HashMap<String, Object> centerInfoCache = new HashMap<String, Object>();
	protected HashMap<String, Object> rotationCenterInfoCache = new HashMap<String, Object>();
	protected HashMap<String, Object> scaleCenterInfoCache = new HashMap<String, Object>();
	
	public SpriteProxy() {
		sprite = new QuickTiGame2dSprite();
	}

    @Override
    public void handleCreationDict(KrollDict options) {
    	super.handleCreationDict(options);
    	if (options.containsKey("image")) {
    		setImage(options.getString("image"));
    	}
    	if (options.containsKey("tag")) {
    		setTag(options.getString("tag"));
    	}
    	if (options.containsKey("x")) {
    		setX(options.getDouble("x").floatValue());
    	}
    	if (options.containsKey("y")) {
    		setY(options.getDouble("y").floatValue());
    	}
    	if (options.containsKey("z")) {
    		setZ(options.getDouble("z").floatValue());
    	}
    	if (options.containsKey("width")) {
    		setWidth(options.getInt("width"));
    	}
    	if (options.containsKey("height")) {
    		setHeight(options.getInt("height"));
    	}
    	if (options.containsKey("angle")) {
    		setAngle(options.getDouble("angle").floatValue());
    	}
    	if (options.containsKey("alpha")) {
    		setAlpha(options.getDouble("alpha").floatValue());
    	}
    	if (options.containsKey("scaleX")) {
    		setScaleX(options.getDouble("scaleX").floatValue());
    	}
    	if (options.containsKey("scaleY")) {
    		setScaleY(options.getDouble("scaleY").floatValue());
    	}
    	if (options.containsKey("data")) {
    		this.setData((TiBlob)options.get("data"));
    	}
    }
	
	public void onNotification(KrollDict info) {
		fireEvent(info.getString("eventName"), info);
	}
	
	public void onDispose() {
		
		if (sprite != null) {
			sprite.onDispose();
		}
		
		sprite = null;
		transforms.clear();
		centerInfoCache.clear();
		rotationCenterInfoCache.clear();
		scaleCenterInfoCache.clear();
	}

	public void onTransformNotification(KrollDict info) {
		Object source = info.get("source");
		if (source != null) {
			
			TransformProxy proxyToRemove = null;
			
			KrollDict eventParam = new KrollDict();
			
			synchronized(transforms) {
				for (TransformProxy transform : transforms) {
					if (source != transform.getTransformer()) continue;

					eventParam.clear();
					eventParam.putAll(info);
					eventParam.put("source", transform);

					String name = "unknown";
					if (info.getString("eventName").equals("onstarttransform")) {
						name = "start";
					} else if (info.getString("eventName").equals("oncompletetransform")) {
						name = "complete";
					}

					transform.fireEvent(name, eventParam);

					if (name.equals("complete")) {
						proxyToRemove = transform;
					}

					break;
				}

				if (proxyToRemove != null) {
					transforms.remove(proxyToRemove);
				}
			}
		}
	}

	public QuickTiGame2dSprite getSprite() {
		return sprite;
	}
	
	/*
	 * Load texture from Blob object with given name
	 * The name parameter should be unique among textures
	 */
	@Kroll.method
	public void loadTextureByBlobWithName(String name, TiBlob blob) {
		sprite.loadTexture(name, blob.getBytes());
	}
	
	/*
	 * Load texture from Blob object with unique name
	 */
	@Kroll.method
	public void loadTextureByBlob(TiBlob blob) {
		sprite.loadTexture(QuickTiGame2dConstant.TIBLOB_UNIQUENAME_PREFIX + TiPlatformHelper.createUUID(), blob.getBytes());
	}
	
	@Kroll.method
	public boolean collidesWith(SpriteProxy otherProxy) {
	    QuickTiGame2dSprite other = otherProxy.getSprite();
	    
	    return (sprite.getX() < other.getX() + other.getWidth() && other.getX() < sprite.getX() + sprite.getWidth() &&
	        sprite.getY() < other.getY() + other.getHeight() && other.getY() < sprite.getY() + sprite.getHeight());
	}

	@Kroll.method
	public boolean contains(int x, int y) {
	    return (x >= sprite.getX() && x <= sprite.getX() + sprite.getWidth() &&
	           y >= sprite.getY() && y <= sprite.getY() + sprite.getHeight());
	    
	}

	@Kroll.method
	public void hide() {
		sprite.hide();
	}
	
	@Kroll.method
	public void show() {
		sprite.show();
	}
	
	@Kroll.method
	public void dispose() {
		transforms.clear();
		
		if (sprite != null) {
			sprite.onDispose();
			sprite = null;
		}
	}

	@Kroll.method
	public void blendFunc(int src, int dst) {
		sprite.blendFunc(src, dst);
	}
	
	@Kroll.method
	public void move(float x, float y) {
		sprite.move(x, y);
	}
	
	@Kroll.method
	public void color(float red, float green, float blue) {
		sprite.color(red, green, blue);
	}
	
	@Kroll.method
	public void rotate(float angle) {
		sprite.rotate(angle);
	}
	
	@Kroll.method
	public void rotateZ(float angle) {
		sprite.rotateZ(angle);
	}
	
	@Kroll.method
	public void rotateY(float angle) {
		sprite.rotateY(angle);
	}
	
	@Kroll.method
	public void rotateX(float angle) {
		sprite.rotateX(angle);
	}
	
	@Kroll.method
	public void rotateFrom(float angle, float centerX, float centerY) {
		sprite.rotate(angle, centerX, centerY);
	}
	
	@Kroll.method
	public void rotateFromAxis(float angle, float centerX, float centerY, float axis) {
		sprite.rotate(angle, centerX, centerY, axis);
	}
	
	@Kroll.method
	public void scale(float factor) {
		sprite.scale(factor, factor);
	}
	
	@Kroll.method
	public void scaleBy(float factorX, float factorY) {
		sprite.scale(factorX, factorY);
	}

	@Kroll.method
	public void scaleFromCenter(float factorX, float factorY, float centerX, float centerY) {
		sprite.scale(factorX, factorY, centerX, centerY);
	}
	
	@Kroll.method
	public void transform(TransformProxy transform) {
		synchronized(transforms) {
			transforms.add(transform);
		}
		sprite.transform(transform.getTransformer());
	}

	@Kroll.method
	public void clearTransforms() {
		sprite.clearTransforms();
	}

	@Kroll.method
	public void clearTransform(TransformProxy transform) {
		sprite.clearTransform(transform.getTransformer());
	}
	
	@Kroll.method
	public void addChild(SpriteProxy child) {
		Log.w(Quicktigame2dModule.LOG_TAG, "sprite.addChild is deprecated. Use sprite.addTransformChild instead.");
		sprite.addChild(child.getSprite());
	}

	@Kroll.method
	public void removeChild(SpriteProxy child) {
		Log.w(Quicktigame2dModule.LOG_TAG, "sprite.removeChild is deprecated. Use sprite.removeTransformChild instead.");
		sprite.removeChild(child.getSprite());
	}

	@Kroll.method
	public void addTransformChild(SpriteProxy child) {
		sprite.addChild(child.getSprite());
	}

	@Kroll.method
	public void removeTransformChild(SpriteProxy child) {
		sprite.removeChild(child.getSprite());
	}

	@Kroll.method
	public void addTransformChildWithRelativePosition(SpriteProxy child) {
		sprite.addChildWithRelativePosition(child.getSprite());
	}
	
	@Kroll.getProperty @Kroll.method
	public String getImage() {
		return sprite.getImage();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setImage(String image) {
		sprite.setImage(image);
	}
	
	@Kroll.getProperty @Kroll.method
	public String getTag() {
		return sprite.getTag();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setTag(String tag) {
		sprite.setTag(tag);
	}
	
	@Kroll.getProperty @Kroll.method
	public float getX() {
		return sprite.getX();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setX(float x) {
		sprite.setX(x);
	}
	
	@Kroll.getProperty @Kroll.method
	public float getY() {
		return sprite.getY();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setY(float y) {
		sprite.setY(y);
	}
	
	@Kroll.getProperty @Kroll.method
	public float getZ() {
		return sprite.getZ();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setZ(float z) {
		sprite.setZ(z);
	}

	@Kroll.getProperty @Kroll.method
	public int getWidth() {
		return sprite.getWidth();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setWidth(int width) {
		sprite.setWidth(width);
	}

	@Kroll.getProperty @Kroll.method
	public int getHeight() {
		return sprite.getHeight();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setHeight(int height) {
		sprite.setHeight(height);
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean getDebug() {
		return sprite.getDebug();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setDebug(boolean enabled) {
		sprite.setDebug(enabled);
	}

	@Kroll.getProperty @Kroll.method
	public float getAngle() {
		return sprite.getAngle();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setAngle(float angle) {
		sprite.setAngle(angle);
	}
	
	@Kroll.getProperty @Kroll.method
	public float getAlpha() {
		return sprite.getAlpha();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setAlpha(float alpha) {
		sprite.setAlpha(alpha);
	}
	
	@Kroll.getProperty @Kroll.method
	public float getScaleX() {
		return sprite.getScaleX();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setScaleX(float value) {
		sprite.setScaleX(value);
	}
	
	@Kroll.getProperty @Kroll.method
	public float getScaleY() {
		return sprite.getScaleY();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setScaleY(float value) {
		sprite.setScaleY(value);
	}
	
	@Kroll.setProperty @Kroll.method
	public void setCenter(@SuppressWarnings("rawtypes") HashMap info) {
		if (info.containsKey("x")) {
			float x = (float)TiConvert.toDouble(info.get("x"));
			sprite.setX(x - (sprite.getScaledWidth() * 0.5f));
		}
		if (info.containsKey("y")) {
			float y = (float)TiConvert.toDouble(info.get("y"));
			sprite.setY(y - (sprite.getScaledHeight() * 0.5f));
		}
	}
	
	@SuppressWarnings("rawtypes")
	@Kroll.getProperty @Kroll.method
	public HashMap getCenter() {
		centerInfoCache.put("x" , sprite.getX() + (sprite.getScaledWidth()  * 0.5));
		centerInfoCache.put("y" , sprite.getY() + (sprite.getScaledHeight() * 0.5));
		
		return centerInfoCache;
	}
	
	@Kroll.setProperty @Kroll.method
	public void setRotationCenter(@SuppressWarnings("rawtypes") HashMap info) {
		if (info.containsKey("x")) {
			sprite.setRotationCenterX((float)TiConvert.toDouble(info.get("x")));
		}
		if (info.containsKey("y")) {
			sprite.setRotationCenterY((float)TiConvert.toDouble(info.get("y")));
		}
	}
	
	@SuppressWarnings("rawtypes")
	@Kroll.getProperty @Kroll.method
	public HashMap getRotationCenter() {
		rotationCenterInfoCache.put("x" , sprite.getRotationCenterX());
		rotationCenterInfoCache.put("y" , sprite.getRotationCenterY());
		
		return rotationCenterInfoCache;
	}

	@Kroll.setProperty @Kroll.method
	public void setScaleCenter(@SuppressWarnings("rawtypes") HashMap info) {
		if (info.containsKey("x")) {
			sprite.setScaleCenterX((float)TiConvert.toDouble(info.get("x")));
		}
		if (info.containsKey("y")) {
			sprite.setScaleCenterY((float)TiConvert.toDouble(info.get("y")));
		}
	}
	
	@SuppressWarnings("rawtypes")
	@Kroll.getProperty @Kroll.method
	public HashMap getScaleCenter() {
		scaleCenterInfoCache.put("x" , sprite.getScaleCenterX());
		scaleCenterInfoCache.put("y" , sprite.getScaleCenterY());
		
		return scaleCenterInfoCache;
	}

	@Kroll.getProperty @Kroll.method
	public boolean getFollowParentTransformPosition() {
		return sprite.isFollowParentTransformPosition();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFollowParentTransformPosition(boolean follow) {
		sprite.setFollowParentTransformPosition(follow);
	}

	@Kroll.getProperty @Kroll.method
	public boolean getFollowParentTransformRotation() {
		return sprite.isFollowParentTransformRotation();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFollowParentTransformRotation(boolean follow) {
		sprite.setFollowParentTransformRotation(follow);
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean getFollowParentTransformRotationCenter() {
		return sprite.isFollowParentTransformRotationCenter();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFollowParentTransformRotationCenter(boolean follow) {
		sprite.setFollowParentTransformRotationCenter(follow);
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean getFollowParentTransformScale() {
		return sprite.isFollowParentTransformScale();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFollowParentTransformScale(boolean follow) {
		sprite.setFollowParentTransformScale(follow);
	}
	@Kroll.getProperty @Kroll.method
	public boolean getFollowParentTransformColor() {
		return sprite.isFollowParentTransformColor();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFollowParentTransformColor(boolean follow) {
		sprite.setFollowParentTransformColor(follow);
	}
	@Kroll.getProperty @Kroll.method
	public boolean getFollowParentTransformFrameIndex() {
		return sprite.isFollowParentTransformFrameIndex();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFollowParentTransformFrameIndex(boolean follow) {
		sprite.setFollowParentTransformFrameIndex(follow);
	}
	@Kroll.getProperty @Kroll.method
	public boolean getFollowParentTransformSize() {
		return sprite.isFollowParentTransformSize();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFollowParentTransformSize(boolean follow) {
		sprite.setFollowParentTransformSize(follow);
	}
	
	@Kroll.getProperty @Kroll.method
	public TiBlob getData() {
		byte[] data = sprite.getTextureData();
		if (data == null) {
			return null;
		} else {
			return TiBlob.blobFromData(data, "application/octet-stream");
		}
	}
	
	@Kroll.setProperty @Kroll.method
	public void setData(TiBlob blob) {
		sprite.loadTexture(QuickTiGame2dConstant.TIBLOB_UNIQUENAME_PREFIX + TiPlatformHelper.createUUID(), blob.getBytes());
	}

}
