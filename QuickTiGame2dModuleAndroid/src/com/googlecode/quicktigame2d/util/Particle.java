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
package com.googlecode.quicktigame2d.util;

public class Particle {
	public Vector2 position  = new Vector2();
	public Vector2 direction = new Vector2();
    public Vector2 startPos  = new Vector2();
	public Color4f color = new Color4f();
	public Color4f deltaColor = new Color4f();
	public float rotation;
	public float rotationDelta;
	public float radialAcceleration;
	public float tangentialAcceleration;
	public float radius;
	public float radiusDelta;
	public float angle;
	public float degreesPerSecond;
	public float particleSize;
	public float particleSizeDelta;
	public float timeToLive;
	
	public Particle copy() {
		Particle obj  = new Particle();
		obj.position  = position.copy();
		obj.direction = direction.copy();
		obj.startPos  = startPos.copy();
		obj.color = color.copy();
		obj.deltaColor = deltaColor.copy();
		obj.rotation = rotation;
		obj.rotationDelta = rotationDelta;
		obj.radialAcceleration = radialAcceleration;
		obj.tangentialAcceleration = tangentialAcceleration;
		obj.radius = radius;
		obj.radiusDelta = radiusDelta;
		obj.angle = angle;
		obj.degreesPerSecond = degreesPerSecond;
		obj.particleSize = particleSize;
		obj.particleSizeDelta = particleSizeDelta;
		obj.timeToLive =  timeToLive;
		return obj;
	}
}
