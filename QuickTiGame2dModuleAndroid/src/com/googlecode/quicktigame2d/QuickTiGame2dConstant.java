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

public interface QuickTiGame2dConstant {
	int AXIS_X = 0;
	int AXIS_Y = 1;
	int AXIS_Z = 2;
	
	String DEFAULT_ANIMATION_NAME = "default_animation";
	String SNAPSHOT_TEXTURE_NAME  = "/quicktigame2d/@snapshot";

	String TIBLOB_UNIQUENAME_PREFIX = "tiblob://";
	
	int ANIMATION_EASING_CUBIC_INOUT   = 0;
	int ANIMATION_EASING_CUBIC_IN      = 1;
	int ANIMATION_EASING_CUBIC_OUT     = 2;
	int ANIMATION_EASING_LINEAR        = 3;
	int ANIMATION_EASING_BACK_INOUT    = 4;
	int ANIMATION_EASING_BACK_IN       = 5;
	int ANIMATION_EASING_BACK_OUT      = 6;
	int ANIMATION_EASING_ELASTIC_INOUT = 7;
	int ANIMATION_EASING_ELASTIC_IN    = 8;
	int ANIMATION_EASING_ELASTIC_OUT   = 9;
	int ANIMATION_EASING_BOUNCE_INOUT  = 10;
	int ANIMATION_EASING_BOUNCE_IN     = 11;
	int ANIMATION_EASING_BOUNCE_OUT    = 12;
	int ANIMATION_EASING_EXPO_INOUT    = 13;
	int ANIMATION_EASING_EXPO_IN       = 14;
	int ANIMATION_EASING_EXPO_OUT      = 15;
	int ANIMATION_EASING_QUAD_INOUT    = 16;
	int ANIMATION_EASING_QUAD_IN       = 17;
	int ANIMATION_EASING_QUAD_OUT      = 18;
	int ANIMATION_EASING_SINE_INOUT    = 19;
	int ANIMATION_EASING_SINE_IN       = 20;
	int ANIMATION_EASING_SINE_OUT      = 21;
	int ANIMATION_EASING_CIRC_INOUT    = 22;
	int ANIMATION_EASING_CIRC_IN       = 23;
	int ANIMATION_EASING_CIRC_OUT      = 24;
	int ANIMATION_EASING_QUINT_INOUT   = 25;
	int ANIMATION_EASING_QUINT_IN      = 26;
	int ANIMATION_EASING_QUINT_OUT     = 27;
	int ANIMATION_EASING_QUART_INOUT   = 28;
	int ANIMATION_EASING_QUART_IN      = 29;
	int ANIMATION_EASING_QUART_OUT     = 30;

	int DEFAULT_ONFPS_INTERVAL         = 5000;
	
	int MAP_ORIENTATION_ORTHOGONAL     = 0;
	int MAP_ORIENTATION_ISOMETRIC      = 1;
	int MAP_ORIENTATION_HEXAGONAL      = 2;

	int TIMER_DEFAULT     = 0;
	int TIMER_NSTIMER     = 0;
	int TIMER_DISPLAYLINK = 1;

}
