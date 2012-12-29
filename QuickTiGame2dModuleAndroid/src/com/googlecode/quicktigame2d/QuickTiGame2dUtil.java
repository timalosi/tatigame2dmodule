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

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;

import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.util.TiUrl;

import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.graphics.BitmapFactory;
import android.util.Log;

public class QuickTiGame2dUtil {
	
	public static final String SCHEME_ASSET     = "file:///android_asset/";
	public static final String SCHEME_FILE      = "file://";
	public static final String SCHEME_APP       = "app://";
	public static final String SCHEME_APPDATA   = "appdata://";
	public static final String SCHEME_APPDATA_PRIVATE  = "appdata-private://";
	
	/**
	 * @param x integer
	 * @return TRUE if x is a power of two, FALSE otherwise
	 */
	public static boolean isPowerOfTwo(int x) {
		return (x != 0) && ((x & (x - 1)) == 0);
	}

	/**
	 * Finds the next power of two, from a given minimum
	 * 
	 * @param minimum integer
	 * @return the next (or same, if minimum is power-of-two) power-of-two
	 */
	public static int nextPowerOfTwo(int minimum) {
		if(isPowerOfTwo(minimum)) {
			return minimum;
		}
		int i = 0;
		while(true) {
			i++;
			if(Math.pow(2, i) >= minimum) {
				return (int)Math.pow(2, i);
			}
		}
	}

	public static Context getContext() {
		return TiApplication.getAppRootOrCurrentActivity();		
	}
	
	public static boolean isAsset(String url) {
		return url.startsWith(SCHEME_ASSET);
	}
	
	public static AssetFileDescriptor getAssetFileDescriptor(String url) throws IOException {
		return getContext().getAssets().openFd(url.substring(SCHEME_ASSET.length()));
	}
	
	public static String getFilePath(String url) {
		if (url.startsWith(SCHEME_ASSET)) {
			return url.substring(SCHEME_ASSET.length());
		} else {
			return url.substring(SCHEME_FILE.length());
		}
		
	}
	
	public static String resolveUrl(String name) {
		if (name.startsWith(SCHEME_FILE)) return name;
		if (name.startsWith(SCHEME_APP))  {
			return TiUrl.resolve(SCHEME_APP, name.substring(SCHEME_APP.length()), "app");
		} else if (name.startsWith(SCHEME_APPDATA)) {
			return TiUrl.resolve(SCHEME_APPDATA, name.substring(SCHEME_APPDATA.length()), "appdata");
		} else if (name.startsWith(SCHEME_APPDATA_PRIVATE)) {
			return TiUrl.resolve(SCHEME_APPDATA_PRIVATE, name.substring(SCHEME_APPDATA_PRIVATE.length()), "appdata-private");
		}
		return TiC.URL_ANDROID_ASSET_RESOURCES + name;
	}
	
	public static InputStream getFileInputStream(String name) {
		try {
			String url = resolveUrl(name);
			
			if (url.startsWith(SCHEME_ASSET)) {
				return getContext().getAssets().open(url.substring(SCHEME_ASSET.length()));
			} else {
				return new FileInputStream(url.substring(SCHEME_FILE.length()));
			}
		} catch (IOException e) {
			return getContext().getClass().getResourceAsStream("/assets/" + name);
		}
	}
	
	public static BitmapFactory.Options getBitmapOptions(String name, boolean debug) {
		InputStream is = null;
		BitmapFactory.Options bitmapOptions = new BitmapFactory.Options();
		bitmapOptions.inJustDecodeBounds = true;

		try {
			is = getFileInputStream(name);
			BitmapFactory.decodeStream(is, null, bitmapOptions);
		} catch (Exception e) {
			if (debug) Log.w(Quicktigame2dModule.LOG_TAG, "Failed to get bitmap size" + name, e);
		} finally {
			if (is != null) {
				try {
					is.close();
				} catch (IOException e) {
					// nothing to do
				}
			}
		}
		return bitmapOptions;
	}

}
