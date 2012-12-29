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
package com.googlecode.quicktigame2d.opengl;

import java.nio.Buffer;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.IntBuffer;
import java.nio.ShortBuffer;

import javax.microedition.khronos.opengles.GL10;

import com.googlecode.quicktigame2d.Quicktigame2dModule;

import android.graphics.Bitmap;
import android.opengl.GLU;
import android.opengl.GLUtils;
import android.util.Log;

public class GLHelper {

    private static final boolean USE_LITTLE_ENDIAN = (ByteOrder.nativeOrder() == ByteOrder.LITTLE_ENDIAN);

	public static FloatBuffer createFloatBuffer(float[] data) {
	    ByteBuffer vbb = ByteBuffer.allocateDirect(data.length * 4);
	    vbb.order(ByteOrder.nativeOrder());
	    
	    FloatBuffer buffer = vbb.asFloatBuffer();
	    buffer.put(data);
	    buffer.position(0);
	    return buffer;
	}

	public static ShortBuffer createShortBuffer(short[] data) {
	    ByteBuffer vbb = ByteBuffer.allocateDirect(data.length * 2);
	    vbb.order(ByteOrder.nativeOrder());
	    
	    ShortBuffer buffer = vbb.asShortBuffer();
	    buffer.put(data);
	    buffer.position(0);
	    return buffer;
	}

	public static void texSubImage2D(GL10 gl, int target, int level, 
			int xoffset, int yoffset, Bitmap bitmap, int format, int type) {
		GLHelper.texSubImage2D(gl, target, level, xoffset, yoffset, bitmap, format, type, true);
	}

	public static void texSubImage2D(GL10 gl, int target, int level, 
			int xoffset, int yoffset, Bitmap bitmap, int format, int type, boolean usePreMultiplyAlpha) {
		if (usePreMultiplyAlpha) {
			GLUtils.texSubImage2D(target, level, xoffset, yoffset, bitmap, format, type);
		} else {
			int[] pixels = GLHelper.getPixels(bitmap);
			Buffer pixelBuffer = GLHelper.convertARGBtoRGBABuffer(pixels);
			gl.glTexSubImage2D(target, level, xoffset, yoffset, bitmap.getWidth(), bitmap.getHeight(), format, type, pixelBuffer);
		}
	}

	public static Buffer convertARGBtoRGBABuffer(int[] pixcels) {
		for(int i = pixcels.length - 1; i >= 0; i--) {
			int pixel = pixcels[i];

			int red = ((pixel >> 16) & 0xFF);
			int green = ((pixel >> 8) & 0xFF);
			int blue = ((pixel) & 0xFF);
			int alpha = (pixel >> 24);

			if(USE_LITTLE_ENDIAN) {
				pixcels[i] = alpha << 24 | blue << 16 | green << 8 | red;
			} else {
				pixcels[i] = red << 24 | green << 16 | blue << 8 | alpha;
			}
		}
		return IntBuffer.wrap(pixcels);
	}

	public static int[] getPixels(Bitmap bitmap) {
		int w = bitmap.getWidth();
		int h = bitmap.getHeight();

		int[] pixels = new int[w * h];
		bitmap.getPixels(pixels, 0, w, 0, 0, w, h);

		return pixels;
	}
	
	public static int[] getPixels(Bitmap bitmap, int xoffset, int yoffset, int width, int height) {
		int[] pixels = new int[width * height];
		bitmap.getPixels(pixels, 0, width, xoffset, yoffset, width, height);
		return pixels;
	}

    public static void checkError(GL10 gl) {
        int error = gl.glGetError();
        if (error != GL10.GL_NO_ERROR) {
                String method = Thread.currentThread().getStackTrace()[3].getMethodName();
                Log.d(Quicktigame2dModule.LOG_TAG, "Error: " + error + " (" + GLU.gluErrorString(error) + "): " + method);
        }
    }

    public static boolean checkIfContextSupportsFrameBufferObject(GL10 gl) {
        return checkIfContextSupportsExtension(gl, "GL_OES_framebuffer_object");
    }

    public static boolean checkIfContextSupportsExtension(GL10 gl, String extension) {
        String extensions = " " + gl.glGetString(GL10.GL_EXTENSIONS) + " ";
        return extensions.indexOf(" " + extension + " ") >= 0;
    }

}
