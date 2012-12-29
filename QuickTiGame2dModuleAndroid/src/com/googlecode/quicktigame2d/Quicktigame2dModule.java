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

import javax.microedition.khronos.opengles.GL10;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.TiApplication;

@Kroll.module(name="ComGooglecodeQuicktigame2d", id="com.googlecode.quicktigame2d")
public class Quicktigame2dModule extends KrollModule {
	
	@Kroll.constant public static final int X = QuickTiGame2dConstant.AXIS_X;
	@Kroll.constant public static final int Y = QuickTiGame2dConstant.AXIS_Y;
	@Kroll.constant public static final int Z = QuickTiGame2dConstant.AXIS_Z;
	
	@Kroll.constant public static final int OPENGL_NICEST  = GL10.GL_NICEST;
	@Kroll.constant public static final int OPENGL_FASTEST = GL10.GL_FASTEST;
	@Kroll.constant public static final int OPENGL_NEAREST = GL10.GL_NEAREST;
	@Kroll.constant public static final int OPENGL_LINEAR  = GL10.GL_LINEAR;
	
	@Kroll.constant public static final int MAP_ORTHOGONAL = QuickTiGame2dConstant.MAP_ORIENTATION_ORTHOGONAL;
	@Kroll.constant public static final int MAP_ISOMETRIC  = QuickTiGame2dConstant.MAP_ORIENTATION_ISOMETRIC;
	@Kroll.constant public static final int MAP_HEXAGONAL  = QuickTiGame2dConstant.MAP_ORIENTATION_HEXAGONAL;
    
	@Kroll.constant public static final int ENGINE_TIMER_DEFAULT      = QuickTiGame2dConstant.TIMER_DEFAULT;
	@Kroll.constant public static final int ENGINE_TIMER_NSTIMER      = QuickTiGame2dConstant.TIMER_NSTIMER;
	@Kroll.constant public static final int ENGINE_TIMER_DISPLAYLINK  = QuickTiGame2dConstant.TIMER_DISPLAYLINK;
	
    @Kroll.constant public static final int ANIMATION_CURVE_EASE_IN_OUT   = QuickTiGame2dConstant.ANIMATION_EASING_CUBIC_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_EASE_IN      = QuickTiGame2dConstant.ANIMATION_EASING_CUBIC_IN;;
    
    @Kroll.constant public static final int ANIMATION_CURVE_EASE_OUT     = QuickTiGame2dConstant.ANIMATION_EASING_CUBIC_OUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_CUBIC_INOUT   = QuickTiGame2dConstant.ANIMATION_EASING_CUBIC_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_CUBIC_IN      = QuickTiGame2dConstant.ANIMATION_EASING_CUBIC_IN;;
    
    @Kroll.constant public static final int ANIMATION_CURVE_CUBIC_OUT     = QuickTiGame2dConstant.ANIMATION_EASING_CUBIC_OUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_LINEAR        = QuickTiGame2dConstant.ANIMATION_EASING_LINEAR;
    
    @Kroll.constant public static final int ANIMATION_CURVE_BACK_INOUT    = QuickTiGame2dConstant.ANIMATION_EASING_BACK_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_BACK_IN       = QuickTiGame2dConstant.ANIMATION_EASING_BACK_IN;
    
    @Kroll.constant public static final int ANIMATION_CURVE_BACK_OUT      = QuickTiGame2dConstant.ANIMATION_EASING_BACK_OUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_ELASTIC_INOUT = QuickTiGame2dConstant.ANIMATION_EASING_ELASTIC_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_ELASTIC_IN    = QuickTiGame2dConstant.ANIMATION_EASING_ELASTIC_IN;
    
    @Kroll.constant public static final int ANIMATION_CURVE_ELASTIC_OUT   = QuickTiGame2dConstant.ANIMATION_EASING_ELASTIC_OUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_BOUNCE_INOUT  = QuickTiGame2dConstant.ANIMATION_EASING_BOUNCE_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_BOUNCE_IN     = QuickTiGame2dConstant.ANIMATION_EASING_BOUNCE_IN;
    
    @Kroll.constant public static final int ANIMATION_CURVE_BOUNCE_OUT    = QuickTiGame2dConstant.ANIMATION_EASING_BOUNCE_OUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_EXPO_INOUT    = QuickTiGame2dConstant.ANIMATION_EASING_EXPO_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_EXPO_IN       = QuickTiGame2dConstant.ANIMATION_EASING_EXPO_IN;
    
    @Kroll.constant public static final int ANIMATION_CURVE_EXPO_OUT      = QuickTiGame2dConstant.ANIMATION_EASING_EXPO_OUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_QUAD_INOUT    = QuickTiGame2dConstant.ANIMATION_EASING_QUAD_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_QUAD_IN       = QuickTiGame2dConstant.ANIMATION_EASING_QUAD_IN;
    
    @Kroll.constant public static final int ANIMATION_CURVE_QUAD_OUT      = QuickTiGame2dConstant.ANIMATION_EASING_QUAD_OUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_SINE_INOUT    = QuickTiGame2dConstant.ANIMATION_EASING_SINE_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_SINE_IN       = QuickTiGame2dConstant.ANIMATION_EASING_SINE_IN;
    
    @Kroll.constant public static final int ANIMATION_CURVE_SINE_OUT      = QuickTiGame2dConstant.ANIMATION_EASING_SINE_OUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_CIRC_INOUT    = QuickTiGame2dConstant.ANIMATION_EASING_CIRC_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_CIRC_IN       = QuickTiGame2dConstant.ANIMATION_EASING_CIRC_IN;
   
    @Kroll.constant public static final int ANIMATION_CURVE_CIRC_OUT      = QuickTiGame2dConstant.ANIMATION_EASING_CIRC_OUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_QUINT_INOUT   = QuickTiGame2dConstant.ANIMATION_EASING_QUINT_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_QUINT_IN      = QuickTiGame2dConstant.ANIMATION_EASING_QUINT_IN;
    
    @Kroll.constant public static final int ANIMATION_CURVE_QUINT_OUT     = QuickTiGame2dConstant.ANIMATION_EASING_QUINT_OUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_QUART_INOUT   = QuickTiGame2dConstant.ANIMATION_EASING_QUART_INOUT;
    
    @Kroll.constant public static final int ANIMATION_CURVE_QUART_IN      = QuickTiGame2dConstant.ANIMATION_EASING_QUART_IN;
    
    @Kroll.constant public static final int ANIMATION_CURVE_QUART_OUT     = QuickTiGame2dConstant.ANIMATION_EASING_QUART_OUT;
    
	public static final String LOG_TAG = "Quicktigame2dModule";

	public Quicktigame2dModule() {
		super();
	}

	@Kroll.onAppCreate
	public static void onAppCreate(TiApplication app) {
		// put module init code that needs to run when the application is created
	}
	
}

