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

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;

import com.googlecode.quicktigame2d.QuickTiGame2dScene;
import com.googlecode.quicktigame2d.Quicktigame2dModule;

@Kroll.proxy(creatableInModule=Quicktigame2dModule.class)
public class SceneProxy extends KrollProxy {

	private QuickTiGame2dScene scene;
	private ArrayList<SpriteProxy> sprites = new ArrayList<SpriteProxy>();
	private TransformProxy transform;
	
	public SceneProxy() {
		super();
		
		scene = new QuickTiGame2dScene();
	}
	
	public void onActivate() {
		KrollDict eventCache = new KrollDict();
		eventCache.put("eventName", "activated");
		fireEvent(eventCache.getString("eventName"), eventCache);
	}
	
	public void onDeactivate() {
		KrollDict eventCache = new KrollDict();
		eventCache.put("eventName", "deactivated");
		fireEvent(eventCache.getString("eventName"), eventCache);
	}
	
	public void onDispose() {
		
		if (scene != null) {
			scene.onDispose();
		}
		
		for (SpriteProxy sprite : sprites) {
			sprite.onDispose();
		}
		
		sprites.clear();
		
		scene = null;
		transform = null;
	}
	
	public void onNotification(KrollDict info) {
		fireEvent(info.getString("eventName"), info);
		
		synchronized (sprites) {
			for (SpriteProxy sprite : sprites) {
				sprite.onNotification(info);
			}
		}
	}
	
	public void onTransformNotification(KrollDict info) {
		if (transform != null) {
			Object source = info.get("source");
			if (transform.getTransformer() == source) {

				KrollDict eventParam = new KrollDict();
				eventParam.putAll(info);
				eventParam.remove("source");
				
				String name = "unknown";
				if (info.getString("eventName").equals("onstarttransform")) {
					name = "start";
				} else if (info.getString("eventName").equals("oncompletetransform")) {
					name = "complete";
				}

				transform.fireEvent(name, eventParam);

				if (name.equals("complete")) {
					transform = null;
				}
			}
		}
		
		synchronized (sprites) {
			for (SpriteProxy sprite : sprites) {
				sprite.onTransformNotification(info);
			}
		}
	}

	@Kroll.method
	public void color(float red, float green, float blue) {
		scene.color(red, green, blue);
	}
		
	@Kroll.method
	public void add(SpriteProxy sprite) {
		synchronized (sprites) {
			sprites.add(sprite);
		}
		scene.addSprite(sprite.getSprite());
	}
	
	@Kroll.method
	public void remove(SpriteProxy sprite) {
		synchronized (sprites) {
			sprites.remove(sprite);
		}
		scene.removeSprite(sprite.getSprite());
	}
	
	@Kroll.method
	public void transform(TransformProxy transform) {
		this.transform = transform;
		scene.transform(transform.getTransformer());
	}
	
	public QuickTiGame2dScene getScene() {
		return scene;
	}

	@Kroll.setProperty @Kroll.method
	public void setAlpha(float alpha) {
		scene.setAlpha(alpha);
	}
	
	@Kroll.getProperty @Kroll.method
	public float getAlpha() {
		return scene.getAlpha();
	}

}
