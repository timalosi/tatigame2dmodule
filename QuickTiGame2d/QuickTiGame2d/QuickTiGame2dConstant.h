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
#ifndef NativeView_QuickTiGame2dConstant_h
#define NativeView_QuickTiGame2dConstant_h

typedef void (^CommandBlock)(void);

#define SHARED_MODULE_NAME "com.googlecode.quicktigame2d"

#define DEFAULT_ANIMATION_NAME "default_animation"

#define RETINA_SCALE_FACTOR 2
#define MOTION_EVENT_PARAMS_SIZE 8

#define MOTION_EVENT_ACTION_DOWN            0
#define MOTION_EVENT_ACTION_UP              1
#define MOTION_EVENT_ACTION_MOVE            2
#define MOTION_EVENT_ACTION_CANCEL          3

#define GAME_STOPPED 0
#define GAME_STARTED 1
#define GAME_PAUSED  2

#define AXIS_X 0
#define AXIS_Y 1
#define AXIS_Z 2

#define SNAPSHOT_TEXTURE_NAME "/quicktigame2d/@snapshot"
#define TIBLOB_UNIQUENAME_PREFIX "tiblob://"

#define DEFAULT_ONFPS_INTERVAL 5000

#define ANIMATION_EASING_CUBIC_INOUT   0
#define ANIMATION_EASING_CUBIC_IN      1
#define ANIMATION_EASING_CUBIC_OUT     2
#define ANIMATION_EASING_LINEAR        3
#define ANIMATION_EASING_BACK_INOUT    4
#define ANIMATION_EASING_BACK_IN       5
#define ANIMATION_EASING_BACK_OUT      6
#define ANIMATION_EASING_ELASTIC_INOUT 7
#define ANIMATION_EASING_ELASTIC_IN    8
#define ANIMATION_EASING_ELASTIC_OUT   9
#define ANIMATION_EASING_BOUNCE_INOUT  10
#define ANIMATION_EASING_BOUNCE_IN     11
#define ANIMATION_EASING_BOUNCE_OUT    12
#define ANIMATION_EASING_EXPO_INOUT    13
#define ANIMATION_EASING_EXPO_IN       14
#define ANIMATION_EASING_EXPO_OUT      15
#define ANIMATION_EASING_QUAD_INOUT    16
#define ANIMATION_EASING_QUAD_IN       17
#define ANIMATION_EASING_QUAD_OUT      18
#define ANIMATION_EASING_SINE_INOUT    19
#define ANIMATION_EASING_SINE_IN       20
#define ANIMATION_EASING_SINE_OUT      21
#define ANIMATION_EASING_CIRC_INOUT    22
#define ANIMATION_EASING_CIRC_IN       23
#define ANIMATION_EASING_CIRC_OUT      24
#define ANIMATION_EASING_QUINT_INOUT   25
#define ANIMATION_EASING_QUINT_IN      26
#define ANIMATION_EASING_QUINT_OUT     27
#define ANIMATION_EASING_QUART_INOUT   28
#define ANIMATION_EASING_QUART_IN      29
#define ANIMATION_EASING_QUART_OUT     30

#define MAP_ORIENTATION_ORTHOGONAL 0
#define MAP_ORIENTATION_ISOMETRIC  1
#define MAP_ORIENTATION_HEXAGONAL  2

#define TIMER_DEFAULT 0
#define TIMER_NSTIMER 0
#define TIMER_DISPLAYLINK 1

#endif
