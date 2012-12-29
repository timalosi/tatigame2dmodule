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
/**
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComGooglecodeQuicktigame2dModule.h"
#import "QuickTiGame2dConstant.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation ComGooglecodeQuicktigame2dModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"43e5477d-c827-44b6-b7e3-9c1db662a652";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.googlecode.quicktigame2d";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

-(void)suspend:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onSuspend" object:sender];
	[super suspend:sender];
}

-(void)resume:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"onResume" object:sender];
	[super resume:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
    
    [self fireEvent:@"onlowmemory" withObject:nil propagate:NO];
}

#pragma mark Listener Notifications

#pragma Public APIs

#pragma mark Public Constants
MAKE_SYSTEM_PROP(X, AXIS_X);
MAKE_SYSTEM_PROP(Y, AXIS_Y);
MAKE_SYSTEM_PROP(Z, AXIS_Z);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_EASE_IN_OUT,ANIMATION_EASING_CUBIC_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_EASE_IN,    ANIMATION_EASING_CUBIC_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_EASE_OUT,   ANIMATION_EASING_CIRC_OUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_LINEAR,     ANIMATION_EASING_LINEAR);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_CUBIC_IN_OUT, ANIMATION_EASING_CUBIC_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_CUBIC_IN,     ANIMATION_EASING_CUBIC_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_CUBIC_OUT,    ANIMATION_EASING_CUBIC_OUT);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_BACK_IN_OUT, ANIMATION_EASING_BACK_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_BACK_IN,     ANIMATION_EASING_BACK_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_BACK_OUT,    ANIMATION_EASING_BACK_OUT);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_ELASTIC_IN_OUT, ANIMATION_EASING_ELASTIC_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_ELASTIC_IN,     ANIMATION_EASING_ELASTIC_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_ELASTIC_OUT,    ANIMATION_EASING_ELASTIC_OUT);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_BOUNCE_IN_OUT, ANIMATION_EASING_BOUNCE_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_BOUNCE_IN,     ANIMATION_EASING_BOUNCE_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_BOUNCE_OUT,    ANIMATION_EASING_BOUNCE_OUT);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_EXPO_IN_OUT, ANIMATION_EASING_EXPO_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_EXPO_IN,     ANIMATION_EASING_EXPO_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_EXPO_OUT,    ANIMATION_EASING_EXPO_OUT);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_QUAD_IN_OUT, ANIMATION_EASING_QUAD_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_QUAD_IN,     ANIMATION_EASING_QUAD_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_QUAD_OUT,    ANIMATION_EASING_QUAD_OUT);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_SINE_IN_OUT, ANIMATION_EASING_SINE_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_SINE_IN,     ANIMATION_EASING_SINE_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_SINE_OUT,    ANIMATION_EASING_SINE_OUT);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_CIRC_IN_OUT, ANIMATION_EASING_CIRC_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_CIRC_IN,     ANIMATION_EASING_CIRC_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_CIRC_OUT,    ANIMATION_EASING_CIRC_OUT);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_QUINT_IN_OUT, ANIMATION_EASING_QUINT_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_QUINT_IN,     ANIMATION_EASING_QUINT_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_QUINT_OUT,    ANIMATION_EASING_QUINT_OUT);

MAKE_SYSTEM_PROP(ANIMATION_CURVE_QUART_IN_OUT, ANIMATION_EASING_QUART_INOUT);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_QUART_IN,     ANIMATION_EASING_QUART_IN);
MAKE_SYSTEM_PROP(ANIMATION_CURVE_QUART_OUT,    ANIMATION_EASING_QUART_OUT);

MAKE_SYSTEM_PROP(MAP_ORTHOGONAL,       MAP_ORIENTATION_ORTHOGONAL);
MAKE_SYSTEM_PROP(MAP_ISOMETRIC,        MAP_ORIENTATION_ISOMETRIC);
MAKE_SYSTEM_PROP(MAP_HEXAGONAL,        MAP_ORIENTATION_HEXAGONAL);

MAKE_SYSTEM_PROP(OPENGL_NICEST,  GL_NICEST);
MAKE_SYSTEM_PROP(OPENGL_FASTEST, GL_FASTEST);
MAKE_SYSTEM_PROP(OPENGL_NEAREST, GL_NEAREST);
MAKE_SYSTEM_PROP(OPENGL_LINEAR,  GL_LINEAR);

MAKE_SYSTEM_PROP(ENGINE_TIMER_DEFAULT,      TIMER_DEFAULT);
MAKE_SYSTEM_PROP(ENGINE_TIMER_NSTIMER,      TIMER_NSTIMER);
MAKE_SYSTEM_PROP(ENGINE_TIMER_DISPLAYLINK,  TIMER_DISPLAYLINK);

//
// Constants for physics
//
-(id)REV_JOINT {
    return NUMINT(1);
}

-(id)STATIC_BODY {
    
    return @"static";
}

-(id)DYNAMIC_BODY {
 	return @"dynamic";
}

-(id)KINEMATIC_BODY {
 	return @"kinematic";
}

@end
