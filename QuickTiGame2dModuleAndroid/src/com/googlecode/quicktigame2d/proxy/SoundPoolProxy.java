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

import java.io.IOException;
import java.util.HashMap;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;

import android.media.AudioManager;
import android.media.SoundPool;

import com.googlecode.quicktigame2d.QuickTiGame2dUtil;
import com.googlecode.quicktigame2d.Quicktigame2dModule;

/**
 * Simple sound pool that uses android.media.SoundPool.
 * 
 *
 * var soundPool = quicktigame2d.createSoundPool({maxStream:5, debug:true});
 * 
 * soundPool.addEventListener('onSoundPoolLoadComplete', function(e) {
 *   Ti.API.info(JSON.stringify(e));
 * });
 * 
 * var sound = soundPool.createSound({filename:'sound.mp3'});
 * 
 * sound.volume = 0.5;
 * sound.loopCount = 1;
 * 
 * var stream = soundPool.play(sound);
 * soundPool.pause(stream);
 * soundPool.stop(stream);
 * soundPool.unload(stream);
 * 
 * soundPool.release();
 *
 */
@Kroll.proxy(creatableInModule=Quicktigame2dModule.class)
public class SoundPoolProxy extends KrollProxy implements SoundPool.OnLoadCompleteListener {

	private static SoundPool soundPool = null;
	
	private static final String STATUS     = "status";
	private static final String FILENAME   = "filename";
	private static final String SOUND_ID   = "soundId";
	private static final String STREAM_ID  = "streamId";
	private static final String VOLUME     = "volume";
	private static final String LOOP_COUNT = "loopCount";
	
	private int maxStreams = 3;
	private boolean debug  = false;
	
	public SoundPoolProxy() {
		
	}
	
    @Override
    public void handleCreationDict(KrollDict options) {
    	super.handleCreationDict(options);
    	if (options.containsKey("maxStreams")) {
    		this.setMaxStreams(options.getInt("maxStreams"));
    	} else if (options.containsKey("debug")) {
    		this.setDebug(options.getBoolean("debug"));
    	}
    }

	private int load(String filename) {
		if (soundPool == null) {
			soundPool = new SoundPool(maxStreams, AudioManager.STREAM_MUSIC, 0);
			soundPool.setOnLoadCompleteListener(this);
		}
		
		try {
			String fileUrl = QuickTiGame2dUtil.resolveUrl(filename);
			
			if (QuickTiGame2dUtil.isAsset(fileUrl)) {
				return soundPool.load(QuickTiGame2dUtil.getAssetFileDescriptor(fileUrl), 1); 
			} else {
				return soundPool.load(QuickTiGame2dUtil.getFilePath(fileUrl), 1);
			}
		} catch (IOException e) {
			if (debug) Log.w(Quicktigame2dModule.LOG_TAG, "Failed to load " + filename, e);
		}
		
		return Integer.MIN_VALUE;
	}
	
	@Kroll.method
	public KrollDict createSound(@SuppressWarnings("rawtypes") HashMap param) {
		String filename  = null;
		if (param.containsKey(FILENAME)) {
			filename  = getString(param, FILENAME);
		}
		
		KrollDict info = new KrollDict();
		
		info.put(FILENAME, filename);
		info.put(SOUND_ID, load(filename));
		
		return info;
	}
	
	@Kroll.method
	public boolean unload(@SuppressWarnings("rawtypes") HashMap param) {
		return soundPool.unload(getInt(param, SOUND_ID));
	}
	
	@Kroll.method
	public KrollDict play(@SuppressWarnings("rawtypes") HashMap param) {
		float  volume    = 1.0f;
		int    loopCount = 0;
		int    soundId   = Integer.MIN_VALUE;
		String filename  = null;
		
		if (param.containsKey(FILENAME)) {
			filename = getString(param, FILENAME);
		}
		
		if (param.containsKey(SOUND_ID)) {
			soundId = getInt(param, SOUND_ID);
		} else {
			if (debug) Log.w(Quicktigame2dModule.LOG_TAG, "Sound Id does not found: " + filename);
			return null;
		}
		
		if (param.containsKey(VOLUME)) {
			volume    = getFloat(param, VOLUME);
		}
		if (param.containsKey(LOOP_COUNT)) {
			loopCount = getInt(param, LOOP_COUNT);
		}
		
		KrollDict info = new KrollDict();
		
		info.put(FILENAME,   filename);
		info.put(SOUND_ID,   soundId);
		info.put(VOLUME,     volume);
		info.put(LOOP_COUNT, loopCount);
		info.put(STREAM_ID, soundPool.play(soundId, volume, volume, 0, loopCount, 1.0f));
		
		return info;
	}
	
	@Kroll.method
	public void pause(@SuppressWarnings("rawtypes") HashMap param) {
		soundPool.pause(getInt(param, STREAM_ID));
	}
	
	@Kroll.method
	public void resume(@SuppressWarnings("rawtypes") HashMap param) {
		soundPool.resume(getInt(param, STREAM_ID));
	}
	
	@Kroll.method
	public void stop(@SuppressWarnings("rawtypes") HashMap param) {
		soundPool.stop(getInt(param, STREAM_ID));
	}
	
	@Kroll.method
	public void release() {
		if (soundPool != null) {
			soundPool.release();
			soundPool = null;
		}
	}

	@Kroll.getProperty @Kroll.method
	public int getMaxStreams() {
		return maxStreams;
	}

	@Kroll.setProperty @Kroll.method
	public void setMaxStreams(int maxStreams) {
		this.maxStreams = maxStreams;
	}

	@Kroll.getProperty @Kroll.method
	public boolean isDebug() {
		return debug;
	}

	@Kroll.setProperty @Kroll.method
	public void setDebug(boolean debug) {
		this.debug = debug;
	}

	@Override
	public void onLoadComplete(SoundPool pool, int sampleId, int status) {
		KrollDict info = new KrollDict();
		info.put(SOUND_ID, sampleId);
		info.put(STATUS,   status);
		
		fireEvent("onSoundPoolLoadComplete", info);
	}
	
	private String getString(@SuppressWarnings("rawtypes") HashMap hash, String key) {
		return String.valueOf(hash.get(key));
	}
	
	private int getInt(@SuppressWarnings("rawtypes") HashMap hash, String key) {
		return (int)getFloat(hash, key);
	}
	
	private float getFloat(@SuppressWarnings("rawtypes") HashMap hash, String key) {
		return Float.valueOf(getString(hash, key)).floatValue();
	}
}
