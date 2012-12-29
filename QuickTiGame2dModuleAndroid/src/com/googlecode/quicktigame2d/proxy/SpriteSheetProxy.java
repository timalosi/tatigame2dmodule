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

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;

import com.googlecode.quicktigame2d.Quicktigame2dModule;

@Kroll.proxy(creatableInModule=Quicktigame2dModule.class)
public class SpriteSheetProxy extends SpriteProxy {

	public SpriteSheetProxy() {
		super();
		
		sprite.enableSheet(true);
	}

    @Override
    public void handleCreationDict(KrollDict options) {
    	super.handleCreationDict(options);
    	if (options.containsKey("border")) {
    		setBorder(options.getInt("border"));
    	}
    	if (options.containsKey("margin")) {
    		setMargin(options.getInt("margin"));
    	}
    	if (options.containsKey("frame")) {
    		setFrame(options.getInt("frame"));
    	}
    }

	@Kroll.method
	public void animate(Object arg1, int arg2, int arg3, int arg4) {
		if (arg1.getClass().isArray()) {
			Object[] framesObj = (Object[])arg1;
			
			int[] frames = new int[framesObj.length];
			for (int i = 0; i < frames.length; i++) {
				frames[i] = (int)Double.parseDouble(framesObj[i].toString());
			}
			
			sprite.animate(frames, arg2, arg3);
		} else {
			sprite.animate((int)Double.parseDouble(arg1.toString()), arg2, arg3, arg4);
		}
	}
	
	@Kroll.method
	public void stop() {
		sprite.stop();
	}
	
	@Kroll.method
	public void pause() {
		sprite.pause();
	}
	
	@Kroll.method
	public boolean pauseAt(int index) {
		return sprite.pauseAt(index);
	}
	
	@Kroll.method
	public boolean isAnimationFinished() {
		return sprite.isAnimationFinished();
	}
	
	@Kroll.method
	public void selectFrame(String name) {
		sprite.selectFrame(name);
	}
	
	@Kroll.getProperty @Kroll.method
	public int getFrameCount() {
		return sprite.getFrameCount();
	}

	@Kroll.getProperty @Kroll.method
	public int getBorder() {
		return sprite.getBorder();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setBorder(int border) {
		sprite.setBorder(border);
	}

	@Kroll.getProperty @Kroll.method
	public int getMargin() {
		return sprite.getMargin();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setMargin(int margin) {
		sprite.setMargin(margin);
	}

	@Kroll.getProperty @Kroll.method
	public int getFrame() {
		return sprite.getFrameIndex();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFrame(int frame) {
		sprite.setFrameIndex(frame);
	}

}
