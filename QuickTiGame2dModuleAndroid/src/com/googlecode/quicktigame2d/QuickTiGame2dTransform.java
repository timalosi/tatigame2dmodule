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

import android.util.FloatMath;

public class QuickTiGame2dTransform {
    private Number x;
    private Number y;
    private Number z;
    private Number width;
    private Number height;
    private Number frameIndex;
    
    private Number angle;
    private Number rotate_axis;
    private Number rotate_centerX;
    private Number rotate_centerY;
    
    private Number scaleX;
    private Number scaleY;
    private Number scale_centerX;
    private Number scale_centerY;
    
    private Number red;
    private Number green;
    private Number blue;
    private Number alpha;

    private float start_x;
    private float start_y;
    private float start_z;
    private int start_width;
    private int start_height;
    private int start_frameIndex;
    
    private float start_angle;
    private float start_rotate_axis;
    private float start_rotate_centerX;
    private float start_rotate_centerY;
    
    private float start_scaleX;
    private float start_scaleY;
    
    private float start_red;
    private float start_green;
    private float start_blue;
    private float start_alpha;

    private float current_x;
    private float current_y;
    private float current_z;
    private int current_width;
    private int current_height;
    private int current_frameIndex;
    
    private float current_angle;
    private float current_rotate_axis;
    private float current_rotate_centerX;
    private float current_rotate_centerY;
    
    private float current_scaleX;
    private float current_scaleY;
    
    private float current_red;
    private float current_green;
    private float current_blue;
    private float current_alpha;

    private double startTime;
    
    private int delay;
    private int duration;
    private int repeat;
    
    private int easing;
    private int repeatCount;
    
    private boolean autoreverse;
    private boolean reversing;
    
    private boolean completed;
    private boolean isStartEventFired = false;
    private boolean locked = false;
    
    // Bezier
    private boolean useBezier = false;
    private Number bezierCurvePoint1_X;;
    private Number bezierCurvePoint1_Y;;
    private Number bezierCurvePoint2_X;;
    private Number bezierCurvePoint2_Y;;
    
    public QuickTiGame2dTransform() {
    	easing = QuickTiGame2dConstant.ANIMATION_EASING_LINEAR;
    	repeatCount = 0;
    	reversing   = false;
    	completed   = false;
    	autoreverse = false;
    }

    private int elapsedFromStart() {
        return (int)((QuickTiGame2dGameView.uptime() - startTime) * 1000);
    }

    private int elapsed() {
        return elapsedFromStart() - delay;
    }

    public boolean hasExpired() {
        return elapsed() >= duration;
    }

    public boolean hasStarted() {
        return elapsed() > 0;
    }

    public void start() {
        startTime   = QuickTiGame2dGameView.uptime();
        reversing   = false;
        repeatCount = 0;
        completed   = false;
    }

    public void restart() {
        repeatCount++;
        startTime = QuickTiGame2dGameView.uptime();
    }

    public void reverse() {
        if (reversing) {
            repeatCount++;
        }
        startTime = QuickTiGame2dGameView.uptime();
        reversing = !reversing;
    }

    public void apply() {
        if (!hasStarted()) return;
        if (locked) return;
        
        if (useBezier) {
        	if (x != null) current_x = currentBezier_X(start_x, x.floatValue());
        	if (y != null) current_y = currentBezier_Y(start_y, y.floatValue());
        } else {
        	if (x != null) current_x = current(start_x, x.floatValue());
        	if (y != null) current_y = current(start_y, y.floatValue());
        }
        
        if (z != null) current_z = (int) current(start_z, z.floatValue());
        if (width != null) current_width  = (int) current(start_width, width.intValue());
        if (height != null) current_height = (int) current(start_height, height.intValue());
        if (frameIndex != null) current_frameIndex = (int) current(start_frameIndex, frameIndex.intValue());
        
        if (angle != null) current_angle = current(start_angle, angle.floatValue());
        if (rotate_axis != null) current_rotate_axis = current(start_rotate_axis, rotate_axis.floatValue());
        if (rotate_centerX != null) current_rotate_centerX = current(start_rotate_centerX, rotate_centerX.floatValue());
        if (rotate_centerY != null) current_rotate_centerY = current(start_rotate_centerY, rotate_centerY.floatValue());
        
        if (scaleX != null) current_scaleX = current(start_scaleX, scaleX.floatValue());
        if (scaleY != null) current_scaleY = current(start_scaleY, scaleY.floatValue());

        if (red != null) current_red   = current(start_red, red.floatValue());
        if (green != null) current_green = current(start_green, green.floatValue());
        if (blue != null) current_blue  = current(start_blue, blue.floatValue());
        if (alpha != null) current_alpha = current(start_alpha, alpha.floatValue());
    }
    
    public void color(float _red, float _green, float _blue) {
        red   = Float.valueOf(_red);
        green = Float.valueOf(_green);
        blue  = Float.valueOf(_blue);
    }

    public void color(float _red, float _green, float _blue, float _alpha) {
        red   = Float.valueOf(_red);
        green = Float.valueOf(_green);
        blue  = Float.valueOf(_blue);
        alpha = Float.valueOf(_alpha);
    }
    
    public void hide() {
    	alpha = Float.valueOf(0);
    }

    public void show() {
    	alpha = Float.valueOf(1);
    }
    
    public void move(Number x, Number y) {
    	this.x = x;
    	this.y = y;
    }
    
    public void rotate(float _angle) {
        angle = Float.valueOf(_angle);
    }

    public void rotateZ(float _angle) {
        angle = Float.valueOf(_angle);
        rotate_axis = Float.valueOf(QuickTiGame2dConstant.AXIS_Z);
    }

    public void rotateY(float _angle) {
        angle = Float.valueOf(_angle);
        rotate_axis = Float.valueOf(QuickTiGame2dConstant.AXIS_Y);
    }

    public void rotateX(float _angle) {
        angle = Float.valueOf(_angle);
        rotate_axis = Float.valueOf(QuickTiGame2dConstant.AXIS_X);
    }

    public void rotate(float _angle, float _centerX, float _centerY) {
        angle = Float.valueOf(_angle);
        rotate_centerX = Float.valueOf(_centerX);
        rotate_centerY = Float.valueOf(_centerY);
    }

    public void scale(float scale) {
        scaleX = Float.valueOf(scale);
        scaleY = Float.valueOf(scale);
    }

    public void scale(float _scaleX, float _scaleY) {
        scaleX = Float.valueOf(_scaleX);
        scaleY = Float.valueOf(_scaleY);
    }

    public void move(int _x, int _y) {
        x = Integer.valueOf(_x);
        y = Integer.valueOf(_y);
    }
    
    public void updateBezierCurvePoint(float cx1, float cy1, float cx2, float cy2) {
    	this.bezierCurvePoint1_X = Float.valueOf(cx1);
    	this.bezierCurvePoint1_Y = Float.valueOf(cy1);
    	this.bezierCurvePoint2_X = Float.valueOf(cx2);
    	this.bezierCurvePoint2_Y = Float.valueOf(cy2);
    }
    
    private float current(float _from, float _to) {
        float percent = ease(elapsed(), duration);
        if (hasExpired()) {
            percent = reversing ? 0 : 1;
        }
        return _from + (percent * (_to - _from));
    }
    
    private float currentBezier_X(float _from, float _to) {
        float percent = ease(elapsed(), duration);
        if (hasExpired()) {
            percent = reversing ? 0 : 1;
        }
        
        float q1, q2, q3, q4;
        
        q1 = percent * percent * percent * -1 + percent * percent *  3 + percent * -3 + 1;
        q2 = percent * percent * percent *  3 + percent * percent * -6 + percent *  3;
        q3 = percent * percent * percent * -3 + percent * percent *  3;
        q4 = percent * percent * percent;
        
        return q1 * _from + q2 * this.bezierCurvePoint1_X.floatValue() + q3 * this.bezierCurvePoint2_X.floatValue() + q4 * _to;
    }

    private float currentBezier_Y(float _from, float _to) {
        float percent = ease(elapsed(), duration);
        if (hasExpired()) {
            percent = reversing ? 0 : 1;
        }

        float q1, q2, q3, q4;
        
        q1 = percent * percent * percent * -1 + percent * percent * 3 + percent * -3 + 1;
        q2 = percent * percent * percent *  3 + percent * percent *-6 + percent *  3;
        q3 = percent * percent * percent * -3 + percent * percent * 3;
        q4 = percent * percent * percent;
        
        return q1 * _from + q2 * this.bezierCurvePoint1_Y.floatValue() + q3 * this.bezierCurvePoint2_Y.floatValue() + q4 * _to;
    }


    private float ease(float _elapsed, float _duration) {
        if (reversing) {
            _elapsed = _duration - _elapsed;
        }
        if (easing == QuickTiGame2dConstant.ANIMATION_EASING_LINEAR) {
            return easingLinear(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_CUBIC_IN) {
            return easingCubicIn(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_CUBIC_OUT) {
            return easingCubicOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_CUBIC_INOUT) {
            return easingCubicInOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_BACK_IN) {
            return easingBackIn(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_BACK_OUT) {
            return easingBackOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_BACK_INOUT) {
            return easingBackInOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_ELASTIC_INOUT) {
            return easingElasticInOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_ELASTIC_IN) {
            return easingElasticIn(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_ELASTIC_OUT) {
            return easingElasticOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_BOUNCE_INOUT) {
            return easingBounceInOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_BOUNCE_IN) {
            return easingBounceIn(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_BOUNCE_OUT) {
            return easingBounceOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_EXPO_INOUT) {
            return easingExpoInOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_EXPO_IN) {
            return easingExpoIn(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_EXPO_OUT) {
            return easingExpoOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_QUAD_INOUT) {
            return easingQuadInOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_QUAD_IN) {
            return easingQuadIn(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_QUAD_OUT) {
            return easingQuadOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_SINE_INOUT) {
            return easingSineInOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_SINE_IN) {
            return easingSineIn(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_SINE_OUT) {
            return easingSineOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_CIRC_INOUT) {
            return easingCircInOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_CIRC_IN) {
            return easingCircIn(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_CIRC_OUT) {
            return easingCircOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_QUINT_INOUT) {
            return easingQuintInOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_QUINT_IN) {
            return easingQuintIn(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_QUINT_OUT) {
            return easingQuintOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_QUART_INOUT) {
            return easingQuartInOut(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_QUART_IN) {
            return easingQuartIn(_elapsed, _duration);
        } else if (easing == QuickTiGame2dConstant.ANIMATION_EASING_QUART_OUT) {
            return easingQuartOut(_elapsed, _duration);
        } else {
            return easingLinear(_elapsed, _duration);
        }
    }
    
    private float easingLinear(float _elapsed, float _duration) {
        return _elapsed / _duration;
    }

    private float easingCubicIn(float _elapsed, float _duration) {
        return (float) ((_elapsed = _elapsed / _duration) * Math.pow(_elapsed, 2));
    }

    private float easingCubicOut(float _elapsed, float _duration) {
        return (float) ((_elapsed = _elapsed / _duration - 1) * Math.pow(_elapsed, 2) + 1);
    }

    private float easingCubicInOut(float _elapsed, float _duration) {
        if ((_elapsed /= _duration / 2.0) < 1) return (float) (1.0 / 2.0 * Math.pow(_elapsed, 3));
        return (float) (1.0 / 2.0 * ((_elapsed -= 2) * Math.pow(_elapsed, 2) + 2));
    }

    private float easingBackIn(float _elapsed, float _duration) {
        return (float) ((_elapsed /= _duration) * _elapsed * ((1.70158 + 1) * _elapsed - 1.70158));
    }

    private float easingBackOut(float _elapsed, float _duration) {
        return (float) ((_elapsed = _elapsed / _duration - 1) * _elapsed * ((1.70158 + 1) * _elapsed + 1.70158) + 1);
    }

    private float easingBackInOut(float _elapsed, float _duration) {
        float s = 1.70158f;
        if ((_elapsed /= _duration / 2.0) < 1) return (float) (1.0 / 2.0 * (_elapsed * _elapsed * (((s *= (1.525)) + 1) * _elapsed - s)));
        return (float) (1.0 / 2.0 * ((_elapsed -= 2) * _elapsed * (((s *= (1.525)) + 1) * _elapsed + s) + 2));
    }

    private float easingElasticIn(float _elapsed, float _duration) {
        if ((_elapsed /= _duration) == 1) return 1;
        float p = _duration * 0.3f;
        float s = p / 4.0f;
        return (float) -(Math.pow(2, 10 * (_elapsed -= 1)) * FloatMath.sin((_elapsed * _duration - s) * (2.0f * (float)Math.PI) / p));
    }

    private float easingElasticOut(float _elapsed, float _duration) {
        if ((_elapsed /= _duration) == 1) return 1;
        float p = _duration * 0.3f;
        float s = p / 4.0f;
        return (float) (Math.pow(2, -10 * _elapsed) * FloatMath.sin((_elapsed * _duration - s) * (2.0f * (float)Math.PI) / p) + 1);
    }

    private float easingElasticInOut(float _elapsed, float _duration) {
        if ((_elapsed /= _duration / 2.0) == 2) return 1;
        float p = _duration * (0.3f * 1.5f);
        float s = p / 4.0f;
        if (_elapsed < 1) return (float) (-0.5f * (Math.pow(2, 10 * (_elapsed -= 1)) * FloatMath.sin((_elapsed * _duration - s) * (2.0f * (float)Math.PI) / p)));
        return (float) (Math.pow(2, -10 * (_elapsed -= 1)) * FloatMath.sin((_elapsed * _duration - s) * (2.0f * (float)Math.PI) / p) * 0.5f + 1);
    }

    private float easingBounceOut(float _elapsed, float _duration) {
        if ((_elapsed /= _duration) < (1.0 / 2.75)) return (7.5625f * _elapsed * _elapsed);
        else if (_elapsed < (2.0 / 2.75)) return (7.5625f * (_elapsed -= (1.5f / 2.75f)) * _elapsed + 0.75f);
        else if (_elapsed < (2.5 / 2.75)) return (7.5625f * (_elapsed -= (2.25f / 2.75f)) * _elapsed + 0.9375f);
        else return (7.5625f * (_elapsed -= (2.625f / 2.75f)) * _elapsed + 0.984375f);
    }

    private float easingBounceIn(float _elapsed, float _duration) {
        return 1 - easingBounceOut(_duration - _elapsed, _duration);
    }

    private float easingBounceInOut(float _elapsed, float _duration) {
        if (_elapsed < _duration / 2.0) return easingBounceIn(_elapsed * 2.0f, _duration) * 0.5f;
        else return (float) (easingBounceOut(_elapsed * 2.0f - _duration, _duration) * 0.5 + 0.5);
    }

    private float easingExpoIn(float _elapsed, float _duration) {
        return (float) ((_elapsed == 0) ? 0 : Math.pow(2, 10 * (_elapsed / _duration - 1)));
    }

    private float easingExpoOut(float _elapsed, float _duration) {
        return (float) ((_elapsed == _duration) ? 1 : (-Math.pow(2, -10 * _elapsed / _duration) + 1));
    }

    private float easingExpoInOut(float _elapsed, float _duration) {
        if (_elapsed == 0) return 0;
        if (_elapsed == _duration) return 1;
        if ((_elapsed /= _duration / 2.0) < 1) return (float) (1.0f / 2.0f * Math.pow(2, 10 * (_elapsed - 1)));
        return (float) (1.0f / 2.0f * (-Math.pow(2, -10 * --_elapsed) + 2));
    }

    private float easingQuadIn(float _elapsed, float _duration) {
        return (_elapsed /= _duration) * _elapsed;
    }

    private float easingQuadOut(float _elapsed, float _duration) {
        return -1 * (_elapsed /= _duration) * (_elapsed - 2);
    }

    private float easingQuadInOut(float _elapsed, float _duration) {
        if ((_elapsed /= _duration / 2.0) < 1) return 1.0f / 2.0f * _elapsed * _elapsed;
        return -1.0f / 2.0f * ((--_elapsed) * (_elapsed - 2) - 1);
    }

    private float easingSineIn(float _elapsed, float _duration) {
        return -1 * FloatMath.cos(_elapsed / _duration * ((float)Math.PI / 2.0f)) + 1;
    }

    private float easingSineOut(float _elapsed, float _duration) {
        return 1 * FloatMath.sin(_elapsed / _duration * ((float)Math.PI / 2.0f));
    }

    private float easingSineInOut(float _elapsed, float _duration) {
        if ((_elapsed /= _duration / 2.0) < 1) return 1.0f / 2.0f * (FloatMath.sin((float)Math.PI * _elapsed / 2.0f));
        return -1.0f / 2.0f * (FloatMath.cos((float)Math.PI * --_elapsed / 2.0f) - 2);
    }

    private float easingCircIn(float _elapsed, float _duration) {
        return -1 * (FloatMath.sqrt(1 - (_elapsed /= _duration) * _elapsed) - 1);
    }

    private float easingCircOut(float _elapsed, float _duration) {
        return FloatMath.sqrt(1 - (_elapsed = _elapsed / _duration - 1) * _elapsed);
    }

    private float easingCircInOut(float _elapsed, float _duration) {
        if ((_elapsed /= _duration / 2.0) < 1) return -1.0f / 2.0f * (FloatMath.sqrt(1 - _elapsed * _elapsed) - 1);
        return 1.0f / 2.0f * (FloatMath.sqrt(1 - (_elapsed -= 2) * _elapsed) + 1);
        
    }

    private float easingQuintIn(float _elapsed, float _duration) {
        return (_elapsed /= _duration) * _elapsed * _elapsed * _elapsed * _elapsed;
    }

    private float easingQuintOut(float _elapsed, float _duration) {
        return ((_elapsed = _elapsed / _duration - 1) * _elapsed * _elapsed * _elapsed * _elapsed + 1);
    }

    private float easingQuintInOut(float _elapsed, float _duration) {
        if ((_elapsed /= _duration / 2.0) < 1) return 1.0f / 2.0f * _elapsed * _elapsed * _elapsed * _elapsed * _elapsed;
        return 1.0f / 2.0f * ((_elapsed -= 2) * _elapsed * _elapsed * _elapsed * _elapsed + 2);
    }

    private float easingQuartIn(float _elapsed, float _duration) {
        return (_elapsed /= _duration) * _elapsed * _elapsed * _elapsed;
    }

    private float easingQuartOut(float _elapsed, float _duration) {
        return -1 * ((_elapsed = _elapsed / _duration - 1) * _elapsed * _elapsed * _elapsed - 1);
    }

    private float easingQuartInOut(float _elapsed, float _duration) {
        if ((_elapsed /= _duration / 2.0) < 1) return 1.0f / 2.0f * _elapsed * _elapsed * _elapsed * _elapsed;
        return -1.0f / 2.0f * ((_elapsed -= 2) * _elapsed * _elapsed * _elapsed - 2);
    }

    
	public Number getX() {
		return x;
	}

	public void setX(Number x) {
		this.x = x;
	}

	public Number getY() {
		return y;
	}

	public void setY(Number y) {
		this.y = y;
	}

	public Number getZ() {
		return z;
	}

	public void setZ(Number z) {
		this.z = z;
	}

	public Number getWidth() {
		return width;
	}

	public void setWidth(Number width) {
		this.width = width;
	}

	public Number getHeight() {
		return height;
	}

	public void setHeight(Number height) {
		this.height = height;
	}

	public Number getFrameIndex() {
		return frameIndex;
	}

	public void setFrameIndex(Number frameIndex) {
		this.frameIndex = frameIndex;
	}

	public Number getAngle() {
		return angle;
	}

	public void setAngle(Number angle) {
		this.angle = angle;
	}

	public Number getRotate_axis() {
		return rotate_axis;
	}

	public void setRotate_axis(Number rotate_axis) {
		this.rotate_axis = rotate_axis;
	}

	public Number getRotate_centerX() {
		return rotate_centerX;
	}

	public void setRotate_centerX(Number rotate_centerX) {
		this.rotate_centerX = rotate_centerX;
	}

	public Number getRotate_centerY() {
		return rotate_centerY;
	}

	public void setRotate_centerY(Number rotate_centerY) {
		this.rotate_centerY = rotate_centerY;
	}

	public Number getScaleX() {
		return scaleX;
	}

	public void setScaleX(Number scaleX) {
		this.scaleX = scaleX;
	}

	public Number getScaleY() {
		return scaleY;
	}

	public void setScaleY(Number scaleY) {
		this.scaleY = scaleY;
	}

	public Number getRed() {
		return red;
	}

	public void setRed(Number red) {
		this.red = red;
	}

	public Number getGreen() {
		return green;
	}

	public void setGreen(Number green) {
		this.green = green;
	}

	public Number getBlue() {
		return blue;
	}

	public void setBlue(Number blue) {
		this.blue = blue;
	}

	public Number getAlpha() {
		return alpha;
	}

	public void setAlpha(Number alpha) {
		this.alpha = alpha;
	}

	public float getStart_x() {
		return start_x;
	}

	public void setStart_x(float start_x) {
		this.start_x = start_x;
	}

	public float getStart_y() {
		return start_y;
	}

	public void setStart_y(float start_y) {
		this.start_y = start_y;
	}

	public float getStart_z() {
		return start_z;
	}

	public void setStart_z(float start_z) {
		this.start_z = start_z;
	}

	public float getStart_width() {
		return start_width;
	}

	public void setStart_width(int start_width) {
		this.start_width = start_width;
	}

	public int getStart_height() {
		return start_height;
	}

	public void setStart_height(int start_height) {
		this.start_height = start_height;
	}

	public int getStart_frameIndex() {
		return start_frameIndex;
	}

	public void setStart_frameIndex(int start_frameIndex) {
		this.start_frameIndex = start_frameIndex;
	}

	public float getStart_angle() {
		return start_angle;
	}

	public void setStart_angle(float start_angle) {
		this.start_angle = start_angle;
	}

	public float getStart_rotate_axis() {
		return start_rotate_axis;
	}

	public void setStart_rotate_axis(float start_rotate_axis) {
		this.start_rotate_axis = start_rotate_axis;
	}

	public float getStart_rotate_centerX() {
		return start_rotate_centerX;
	}

	public void setStart_rotate_centerX(float start_rotate_centerX) {
		this.start_rotate_centerX = start_rotate_centerX;
	}

	public float getStart_rotate_centerY() {
		return start_rotate_centerY;
	}

	public void setStart_rotate_centerY(float start_rotate_centerY) {
		this.start_rotate_centerY = start_rotate_centerY;
	}

	public float getStart_scaleX() {
		return start_scaleX;
	}

	public void setStart_scaleX(float start_scaleX) {
		this.start_scaleX = start_scaleX;
	}

	public float getStart_scaleY() {
		return start_scaleY;
	}

	public void setStart_scaleY(float start_scaleY) {
		this.start_scaleY = start_scaleY;
	}

	public float getStart_red() {
		return start_red;
	}

	public void setStart_red(float start_red) {
		this.start_red = start_red;
	}

	public float getStart_green() {
		return start_green;
	}

	public void setStart_green(float start_green) {
		this.start_green = start_green;
	}

	public float getStart_blue() {
		return start_blue;
	}

	public void setStart_blue(float start_blue) {
		this.start_blue = start_blue;
	}

	public float getStart_alpha() {
		return start_alpha;
	}

	public void setStart_alpha(float start_alpha) {
		this.start_alpha = start_alpha;
	}

	public float getCurrent_x() {
		return current_x;
	}

	public void setCurrent_x(float current_x) {
		this.current_x = current_x;
	}

	public float getCurrent_y() {
		return current_y;
	}

	public void setCurrent_y(float current_y) {
		this.current_y = current_y;
	}

	public float getCurrent_z() {
		return current_z;
	}

	public void setCurrent_z(float current_z) {
		this.current_z = current_z;
	}

	public int getCurrent_width() {
		return current_width;
	}

	public void setCurrent_width(int current_width) {
		this.current_width = current_width;
	}

	public int getCurrent_height() {
		return current_height;
	}

	public void setCurrent_height(int current_height) {
		this.current_height = current_height;
	}

	public int getCurrent_frameIndex() {
		return current_frameIndex;
	}

	public void setCurrent_frameIndex(int current_frameIndex) {
		this.current_frameIndex = current_frameIndex;
	}

	public float getCurrent_angle() {
		return current_angle;
	}

	public void setCurrent_angle(float current_angle) {
		this.current_angle = current_angle;
	}

	public float getCurrent_rotate_axis() {
		return current_rotate_axis;
	}

	public void setCurrent_rotate_axis(float current_rotate_axis) {
		this.current_rotate_axis = current_rotate_axis;
	}

	public float getCurrent_rotate_centerX() {
		return current_rotate_centerX;
	}

	public void setCurrent_rotate_centerX(float current_rotate_centerX) {
		this.current_rotate_centerX = current_rotate_centerX;
	}

	public float getCurrent_rotate_centerY() {
		return current_rotate_centerY;
	}

	public void setCurrent_rotate_centerY(float current_rotate_centerY) {
		this.current_rotate_centerY = current_rotate_centerY;
	}

	public float getCurrent_scaleX() {
		return current_scaleX;
	}

	public void setCurrent_scaleX(float current_scaleX) {
		this.current_scaleX = current_scaleX;
	}

	public float getCurrent_scaleY() {
		return current_scaleY;
	}

	public void setCurrent_scaleY(float current_scaleY) {
		this.current_scaleY = current_scaleY;
	}

	public float getCurrent_red() {
		return current_red;
	}

	public void setCurrent_red(float current_red) {
		this.current_red = current_red;
	}

	public float getCurrent_green() {
		return current_green;
	}

	public void setCurrent_green(float current_green) {
		this.current_green = current_green;
	}

	public float getCurrent_blue() {
		return current_blue;
	}

	public void setCurrent_blue(float current_blue) {
		this.current_blue = current_blue;
	}

	public float getCurrent_alpha() {
		return current_alpha;
	}

	public void setCurrent_alpha(float current_alpha) {
		this.current_alpha = current_alpha;
	}

	public double getStartTime() {
		return startTime;
	}

	public void setStartTime(double startTime) {
		this.startTime = startTime;
	}

	public int getDelay() {
		return delay;
	}

	public void setDelay(int delay) {
		this.delay = delay;
	}

	public int getDuration() {
		return duration;
	}

	public void setDuration(int duration) {
		this.duration = duration;
	}

	public int getRepeat() {
		return repeat;
	}

	public void setRepeat(int repeat) {
		this.repeat = repeat;
	}

	public int getEasing() {
		return easing;
	}

	public void setEasing(int easing) {
		this.easing = easing;
	}

	public int getRepeatCount() {
		return repeatCount;
	}

	public void setRepeatCount(int repeatCount) {
		this.repeatCount = repeatCount;
	}

	public boolean isAutoreverse() {
		return autoreverse;
	}

	public void setAutoreverse(boolean autoreverse) {
		this.autoreverse = autoreverse;
	}

	public boolean isReversing() {
		return reversing;
	}

	public void setReversing(boolean reversing) {
		this.reversing = reversing;
	}

	public boolean isCompleted() {
		return completed;
	}

	public void setCompleted(boolean completed) {
		this.completed = completed;
	}

	public boolean isStartEventFired() {
		return isStartEventFired;
	}

	public void setStartEventFired(boolean isStartEventFired) {
		this.isStartEventFired = isStartEventFired;
	}

	public Number getScale_centerX() {
		return scale_centerX;
	}

	public void setScale_centerX(Number scale_centerX) {
		this.scale_centerX = scale_centerX;
	}

	public Number getScale_centerY() {
		return scale_centerY;
	}

	public void setScale_centerY(Number scale_centerY) {
		this.scale_centerY = scale_centerY;
	}

	public boolean isLocked() {
		return locked;
	}

	public void setLocked(boolean locked) {
		this.locked = locked;
	}

	public boolean isUseBezier() {
		return useBezier;
	}

	public void setUseBezier(boolean useBezier) {
		this.useBezier = useBezier;
	}

	public Number getBezierCurvePoint1_X() {
		return bezierCurvePoint1_X;
	}

	public void setBezierCurvePoint1_X(Number bezierCurvePoint1_X) {
		this.bezierCurvePoint1_X = bezierCurvePoint1_X;
	}

	public Number getBezierCurvePoint1_Y() {
		return bezierCurvePoint1_Y;
	}

	public void setBezierCurvePoint1_Y(Number bezierCurvePoint1_Y) {
		this.bezierCurvePoint1_Y = bezierCurvePoint1_Y;
	}

	public Number getBezierCurvePoint2_X() {
		return bezierCurvePoint2_X;
	}

	public void setBezierCurvePoint2_X(Number bezierCurvePoint2_X) {
		this.bezierCurvePoint2_X = bezierCurvePoint2_X;
	}

	public Number getBezierCurvePoint2_Y() {
		return bezierCurvePoint2_Y;
	}

	public void setBezierCurvePoint2_Y(Number bezierCurvePoint2_Y) {
		this.bezierCurvePoint2_Y = bezierCurvePoint2_Y;
	}

}
