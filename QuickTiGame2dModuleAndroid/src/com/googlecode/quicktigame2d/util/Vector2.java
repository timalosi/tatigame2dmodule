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

public final class Vector2 {
	
	public float x = 0.0f;
	public float y = 0.0f;
	
	public Vector2() {
		
	}

	public	Vector2(float x, float y) {
		this.x = x;
		this.y = y;
	}
	
	public	Vector2(Vector2 origin) {
		set(origin);
	}

	public void set(Vector2 origin) {
		x = origin.x;
		y = origin.y;
	}

	public void set(float x, float y) {
		this.x = x;
		this.y = y;
	}
	
	@Override
	public boolean equals(Object obj) {
		Vector2	v =	( Vector2 )obj;
		return	x == v.x &&	y == v.y;
	}

	@Override
	public String toString() {
		return "V( " + x + ", " + y +  " )";
	}
	
	public Vector2 copy() {
		return new Vector2(x, y);
	}
	
	public static Vector2 makeZeroVector() {
		return new Vector2(0, 0);
	}

	public static Vector2 sub(Vector2 v1, Vector2 v2) {
		return new Vector2(v1.x - v2.x, v1.y - v2.y);
	}
	
	public static Vector2 add(Vector2 v1, Vector2 v2) {
		return new Vector2(v1.x + v2.x, v1.y + v2.y);
	}
	
	public static Vector2 multiply(Vector2 v1, float s) {
		return new Vector2(v1.x * s, v1.y * s);
	}
	
	public static float dot(Vector2 v1, Vector2 v2) {
		return (float) v1.x * v2.x + v1.y * v2.y;
	}
	
	public static float length(Vector2 v1) {
		return (float) Math.sqrt(Vector2.dot(v1, v1));
	}

	public static Vector2 normalize(Vector2 v1) {
		return Vector2.multiply(v1, 1.0f / Vector2.length(v1));
	}
}
