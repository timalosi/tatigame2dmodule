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

import java.util.HashMap;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.util.TiConvert;

import android.util.Log;

import com.googlecode.quicktigame2d.QuickTiGame2dTransform;
import com.googlecode.quicktigame2d.Quicktigame2dModule;

@Kroll.proxy(creatableInModule=Quicktigame2dModule.class)
public class TransformProxy extends KrollProxy {
	protected QuickTiGame2dTransform transform;
	protected HashMap<String, Object> bezierConfigCache = null;
	
	public TransformProxy() {
		transform = new QuickTiGame2dTransform();
	}

    @Override
    public void handleCreationDict(KrollDict options) {
    	super.handleCreationDict(options);
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
    	if (options.containsKey("frameIndex")) {
    		setFrameIndex(options.getInt("frameIndex"));
    	}
    	if (options.containsKey("angle")) {
    		setAngle(options.getDouble("angle").floatValue());
    	}
    	if (options.containsKey("rotate_axis")) {
    		setRotate_axis(options.getDouble("rotate_axis").floatValue());
    	}
    	if (options.containsKey("rotate_centerX")) {
    		setRotate_centerX(options.getDouble("rotate_centerX").floatValue());
    	}
    	if (options.containsKey("rotate_centerY")) {
    		setRotate_centerY(options.getDouble("rotate_centerY").floatValue());
    	}
    	if (options.containsKey("scale_centerX")) {
    		setScale_centerX(options.getDouble("scale_centerX").floatValue());
    	}
    	if (options.containsKey("scale_centerY")) {
    		setScale_centerY(options.getDouble("scale_centerY").floatValue());
    	}
    	
    	if (options.containsKey("scaleX")) {
    		setScaleX(options.getDouble("scaleX").floatValue());
    	}
    	if (options.containsKey("scaleY")) {
    		setScaleY(options.getDouble("scaleY").floatValue());
    	}
    	
    	if (options.containsKey("red")) {
    		setRed(options.getDouble("red").floatValue());
    	}
    	if (options.containsKey("green")) {
    		setGreen(options.getDouble("green").floatValue());
    	}
    	if (options.containsKey("blue")) {
    		setBlue(options.getDouble("blue").floatValue());
    	}
    	if (options.containsKey("alpha")) {
    		setAlpha(options.getDouble("alpha").floatValue());
    	}
    	
    	if (options.containsKey("delay")) {
    		setDelay(options.getInt("delay"));
    	}
    	if (options.containsKey("easing")) {
    		setEasing(options.getInt("easing"));
    	}
    	if (options.containsKey("duration")) {
    		setDuration(options.getInt("duration"));
    	}
    	if (options.containsKey("repeat")) {
    		setRepeat(options.getInt("repeat"));
    	}
    	
    	if (options.containsKey("autoreverse")) {
    		setAutoreverse(options.getBoolean("autoreverse"));
    	}
    	
    	if (options.containsKey("bezier")) {
    		setBezier(options.getBoolean("bezier"));
    	}
    	
    	if (options.containsKey("bezierConfig")) {
    		setBezierConfig(options.getKrollDict("bezierConfig"));
    	}
    }

	@Kroll.method
	public void hide() {
		transform.hide();
	}
	
	@Kroll.method
	public void show() {
		transform.show();
	}

	@Kroll.method
	public void move(float x, float y) {
		transform.move(Float.valueOf(x), Float.valueOf(y));
	}
	
	@Kroll.method
	public void color(float red, float green, float blue) {
		transform.color(red, green, blue);
	}
	
	@Kroll.method
	public void rotate(float angle) {
		transform.rotate(angle);
	}
	
	@Kroll.method
	public void rotateZ(float angle) {
		transform.rotateZ(angle);
	}
	
	@Kroll.method
	public void rotateY(float angle) {
		transform.rotateY(angle);
	}
	
	@Kroll.method
	public void rotateX(float angle) {
		transform.rotateX(angle);
	}
	
	@Kroll.method
	public void rotateFrom(float angle, float centerX, float centerY) {
		transform.rotate(angle, centerX, centerY);
	}
	
	@Kroll.method
	public void scale(float factorX, float factorY) {
		transform.scale(factorX, factorY);
	}
    
	@Kroll.getProperty @Kroll.method
	public float getX() {
		if (transform.getX() == null) return 0.0f;
		return transform.getX().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setX(float x) {
		transform.setX(Float.valueOf(x));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getY() {
		if (transform.getY() == null) return 0.0f;
		return transform.getY().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setY(float y) {
		transform.setY(Float.valueOf(y));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getZ() {
		if (transform.getZ() == null) return 0.0f;
		return transform.getZ().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setZ(float z) {
		transform.setZ(Float.valueOf(z));
	}

	@Kroll.getProperty @Kroll.method
	public int getWidth() {
		if (transform.getWidth() == null) return 0;
		return transform.getWidth().intValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setWidth(int width) {
		transform.setWidth(Integer.valueOf(width));
	}
	
	@Kroll.getProperty @Kroll.method
	public int getHeight() {
		if (transform.getHeight() == null) return 0;
		return transform.getHeight().intValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setHeight(int height) {
		transform.setHeight(Integer.valueOf(height));
	}

	@Kroll.getProperty @Kroll.method
	public int getFrameIndex() {
		if (transform.getFrameIndex() == null) return 0;
		return transform.getFrameIndex().intValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFrameIndex(int index) {
		transform.setFrameIndex(Integer.valueOf(index));
	}

	@Kroll.getProperty @Kroll.method
	public float getAngle() {
		if (transform.getAngle() == null) return 0.0f;
		return transform.getAngle().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setAngle(float angle) {
		transform.setAngle(Float.valueOf(angle));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getRotate_axis() {
		if (transform.getRotate_axis() == null) return 0.0f;
		return transform.getRotate_axis().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setRotate_axis(float value) {
		transform.setRotate_axis(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getRotate_centerX() {
		if (transform.getRotate_centerX() == null) return 0.0f;
		return transform.getRotate_centerX().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setRotate_centerX(float value) {
		transform.setRotate_centerX(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getRotate_centerY() {
		if (transform.getRotate_centerY() == null) return 0.0f;
		return transform.getRotate_centerY().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setRotate_centerY(float value) {
		transform.setRotate_centerY(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getScaleX() {
		if (transform.getScaleX() == null) return 1f;
		return transform.getScaleX().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setScaleX(float value) {
		transform.setScaleX(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getScaleY() {
		if (transform.getScaleY() == null) return 1f;
		return transform.getScaleY().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setScaleY(float value) {
		transform.setScaleY(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getRed() {
		if (transform.getRed() == null) return 1f;
		return transform.getRed().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setRed(float value) {
		transform.setRed(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getGreen() {
		if (transform.getGreen() == null) return 1f;
		return transform.getGreen().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setGreen(float value) {
		transform.setGreen(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getBlue() {
		if (transform.getBlue() == null) return 1f;
		return transform.getBlue().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setBlue(float value) {
		transform.setBlue(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getAlpha() {
		if (transform.getAlpha() == null) return 1f;
		return transform.getAlpha().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setAlpha(float value) {
		transform.setAlpha(Float.valueOf(value));
	}

	@Kroll.getProperty @Kroll.method
	public float getScale_centerX() {
		if (transform.getScale_centerX() == null) return 1f;
		return transform.getScale_centerX().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setScale_centerX(float value) {
		transform.setScale_centerX(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getScale_centerY() {
		if (transform.getScale_centerY() == null) return 1f;
		return transform.getScale_centerY().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setScale_centerY(float value) {
		transform.setScale_centerY(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public int getDelay() {
		return transform.getDelay();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setDelay(int value) {
		transform.setDelay(value);
	}

	@Kroll.getProperty @Kroll.method
	public int getDuration() {
		return transform.getDuration();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setDuration(int value) {
		transform.setDuration(value);
	}

	@Kroll.getProperty @Kroll.method
	public int getRepeat() {
		return transform.getRepeat();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setRepeat(int value) {
		transform.setRepeat(value);
	}

	@Kroll.getProperty @Kroll.method
	public int getEasing() {
		return transform.getEasing();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setEasing(int value) {
		transform.setEasing(value);
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean getAutoreverse() {
		return transform.isAutoreverse();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setAutoreverse(boolean enabled) {
		transform.setAutoreverse(enabled);
	}

	@Kroll.getProperty @Kroll.method
	public boolean getBezier() {
		return transform.isUseBezier();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setBezier(boolean enabled) {
		transform.setUseBezier(enabled);
	}

	@Kroll.setProperty @Kroll.method
	public void setBezierConfig(@SuppressWarnings("rawtypes") HashMap info) {
		float cx1 = 0;
		float cy1 = 0;
		float cx2 = 0;
		float cy2 = 0;
		if (info.containsKey("cx1")) {
			cx1 = (float)TiConvert.toDouble(info.get("cx1"));
		} else {
			Log.w(Quicktigame2dModule.LOG_TAG, "Transform.bezierConfig cx1 is missing, assume value equals 0.");
		}
		if (info.containsKey("cy1")) {
			cy1 = (float)TiConvert.toDouble(info.get("cy1"));
		} else {
			Log.w(Quicktigame2dModule.LOG_TAG, "Transform.bezierConfig cy1 is missing, assume value equals 0.");
		}
		if (info.containsKey("cx2")) {
			cx2 = (float)TiConvert.toDouble(info.get("cx2"));
		} else {
			Log.w(Quicktigame2dModule.LOG_TAG, "Transform.bezierConfig cx2 is missing, assume value equals 0.");
		}
		if (info.containsKey("cy2")) {
			cy2 = (float)TiConvert.toDouble(info.get("cy2"));
		} else {
			Log.w(Quicktigame2dModule.LOG_TAG, "Transform.bezierConfig cy2 is missing, assume value equals 0.");
		}
		
		transform.updateBezierCurvePoint(cx1, cy1, cx2, cy2);
	}
	
	@SuppressWarnings("rawtypes")
	@Kroll.getProperty @Kroll.method
	public HashMap getBezierConfig() {
		if (bezierConfigCache == null) {
			bezierConfigCache = new HashMap<String, Object>();
		}
		bezierConfigCache.put("cx1" , transform.getBezierCurvePoint1_X());
		bezierConfigCache.put("cy1" , transform.getBezierCurvePoint1_Y());
		bezierConfigCache.put("cx2" , transform.getBezierCurvePoint2_X());
		bezierConfigCache.put("cy2" , transform.getBezierCurvePoint2_Y());
		
		return bezierConfigCache;
	}
	
	@Kroll.getProperty @Kroll.method
	public float getLookAt_centerX() {
		if (transform.getRotate_centerX() == null) return 0.0f;
		return transform.getRotate_centerX().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setLookAt_centerX(float value) {
		transform.setRotate_centerX(Float.valueOf(value));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getLookAt_centerY() {
		if (transform.getRotate_centerY() == null) return 0.0f;
		return transform.getRotate_centerY().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setLookAt_centerY(float value) {
		transform.setRotate_centerY(Float.valueOf(value));
	}

	@Kroll.getProperty @Kroll.method
	public float getLookAt_eyeX() {
		if (transform.getX() == null) return 0.0f;
		return transform.getX().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setLookAt_eyeX(float x) {
		transform.setX(Float.valueOf(x));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getLookAt_eyeY() {
		if (transform.getY() == null) return 0.0f;
		return transform.getY().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setLookAt_eyeY(float y) {
		transform.setY(Float.valueOf(y));
	}
	
	@Kroll.getProperty @Kroll.method
	public float getLookAt_eyeZ() {
		if (transform.getZ() == null) return 0.0f;
		return transform.getZ().floatValue();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setLookAt_eyeZ(float z) {
		transform.setZ(Float.valueOf(z));
	}
	
	public QuickTiGame2dTransform getTransformer() {
		return transform;
	}
}
