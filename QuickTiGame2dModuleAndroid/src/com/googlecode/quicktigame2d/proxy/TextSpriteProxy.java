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
import org.appcelerator.kroll.annotations.Kroll;

import android.text.Layout;

import com.googlecode.quicktigame2d.QuickTiGame2dTextSprite;
import com.googlecode.quicktigame2d.Quicktigame2dModule;

@Kroll.proxy(creatableInModule=Quicktigame2dModule.class)
public class TextSpriteProxy extends SpriteProxy {
	public TextSpriteProxy() {
		sprite = new QuickTiGame2dTextSprite();
	}
	
	private QuickTiGame2dTextSprite getTextSprite() {
		return (QuickTiGame2dTextSprite)sprite;
	}
	
	@Kroll.method
	public void reload() {
		getTextSprite().reload();
	}
	
	@Override
    public void handleCreationDict(KrollDict options) {
    	super.handleCreationDict(options);
    	if (options.containsKey("text")) {
    		setText(options.getString("text"));
    	}
    	if (options.containsKey("fontFamily")) {
    		setFontFamily(options.getString("fontFamily"));
    	}
    	if (options.containsKey("fontSize")) {
    		setFontSize(options.getDouble("fontSize").floatValue());
    	}
    	if (options.containsKey("fontWeight")) {
    		setFontWeight(options.getString("fontWeight"));
    	}
    	if (options.containsKey("fontStyle")) {
    		setFontStyle(options.getString("fontStyle"));
    	}
    }
	
	@SuppressWarnings("rawtypes")
	@Kroll.method
	public HashMap sizeWithText(String value) {
		HashMap<String, Object> sizeInfo = new HashMap<String, Object>();
		
		int[] textSize = getTextSprite().sizeWithText(value);
		
		sizeInfo.put("width",  Integer.valueOf(textSize[0]));
		sizeInfo.put("height", Integer.valueOf(textSize[1]));
		
		return sizeInfo;
	}
	
	@Kroll.getProperty @Kroll.method
	public String getText() {
		return getTextSprite().getText();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setText(String text) {
		getTextSprite().setText(text);
		getTextSprite().reload();
	}

	@Kroll.getProperty @Kroll.method
	public String getFontWeight() {
		return getTextSprite().isBold() ? "bold" : "normal";
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFontWeight(String weight) {
		if (weight.toLowerCase().equals("bold")) {
			getTextSprite().setBold(true);
		} else {
			getTextSprite().setBold(false);
		}
		getTextSprite().reload();
	}
	
	@Kroll.getProperty @Kroll.method
	public String getFontStyle() {
		return getTextSprite().isItalic() ? "italic" : "normal";
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFontStyle(String style) {
		if (style.toLowerCase().equals("italic")) {
			getTextSprite().setItalic(true);
		} else {
			getTextSprite().setItalic(false);
		}
		getTextSprite().reload();
	}
	
	@Kroll.getProperty @Kroll.method
	public String getFontFamily() {
		return getTextSprite().getFontFamily();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFontFamily(String fontFace) {
		getTextSprite().setFontFamily(fontFace);
		getTextSprite().reload();
	}
	
	@Kroll.getProperty @Kroll.method
	public float getFontSize() {
		return getTextSprite().getFontSize();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFontSize(float fontSize) {
		getTextSprite().setFontSize(fontSize);
		getTextSprite().reload();
	}

	@Kroll.getProperty @Kroll.method
	public String getTextAlign() {
		Layout.Alignment align = getTextSprite().getTextAlign();
		if (align == Layout.Alignment.ALIGN_OPPOSITE) {
			return "right";
		} else if (align == Layout.Alignment.ALIGN_CENTER) {
			return "center";
		} else {
			return "left";
		}
	}
	
	@Kroll.setProperty @Kroll.method
	public void setTextAlign(String value) {
		Layout.Alignment align = getTextSprite().getTextAlign();
		
		if (value.equals("right")) {
			align = Layout.Alignment.ALIGN_OPPOSITE;
		} else if (value.equals("center")) {
			align = Layout.Alignment.ALIGN_CENTER;
		} else {
			align = Layout.Alignment.ALIGN_NORMAL;
		}
		
		getTextSprite().setTextAlign(align);
		getTextSprite().reload();
	}

}
