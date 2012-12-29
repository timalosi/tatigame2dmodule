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

public class QuickTiGame2dAnimationFrame {
	private String   name;
	private int      nameAsInt = -1;
	private int      start = 0;
	private int      count = 1;
	private int      loop  = 0;
	private int      interval = 0;
	
	private int      currentLoopCount = 0;
	private int      currentCount = 0;
	
	private double lastOnAnimationInterval = 0.0;
    
	private int[]  frames = null;

    public boolean isFinished() {
    	return (loop >= 0 && currentLoopCount > loop);
    }

    public void initializeIndividualFrames() {
        frames = new int[count];
        for (int i = 0; i < count; i++) {
            frames[i] = 0;
        }
    }

    public void setFrame(int index, int value) {
        frames[index] = value;
    }

    public int current() {
        if (frames != null) {
            return frames[currentCount];
        } else {
            return currentCount + start;
        }
    }

    public int getNextIndex(int frameCount, int currentIndex) {
    	
    	if (isFinished()) {
    		return currentIndex;
    	}
    	
    	currentCount++;
    	
    	if (currentCount >= count) {
    		currentCount = 0;
    		if (loop >= 0) {
    			currentLoopCount++;
    		}
    	}
    	
    	if (isFinished()) {
    		return currentIndex;
    	} else if (currentCount + start >= frameCount) {
    		currentCount = 0;
    	}
    	
        if (frames != null) {
            return frames[currentCount];
        } else {
            return currentCount + start;
    	}
    }

    public double getLastOnAnimationDelta(double uptime) {
    	return (uptime - lastOnAnimationInterval) * 1000;
    }

	public void setLastOnAnimationInterval(double uptime) {
		lastOnAnimationInterval = uptime;
	}

	public void setName(String name) {
		this.name = name;
	}
	
	public String getName() {
		return name;
	}

	// convenient method to convert name to integer
	public void updateNameAsInt() {
		try {
			nameAsInt = Integer.parseInt(name);
		} catch (Exception e) {
			nameAsInt = -1;
		}
	}
	
	public int getNameAsInt() {
		return nameAsInt;
	}
	
	public void setStart(int start) {
		this.start = start;
	}
	
	public int getStart() {
		return start;
	}
	
	public void setCount(int count) {
		this.count = count;
	}
	
	public void setLoop(int loop) {
		this.loop = loop;
	}
	
	public void setInterval(int interval) {
		this.interval = interval;
	}
	
	public int getInterval() {
		return interval;
	}
}
