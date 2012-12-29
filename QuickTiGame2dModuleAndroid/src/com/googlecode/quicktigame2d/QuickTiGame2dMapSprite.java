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

import java.nio.FloatBuffer;
import java.nio.ShortBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.microedition.khronos.opengles.GL10;
import javax.microedition.khronos.opengles.GL11;

import org.appcelerator.kroll.common.Log;

import com.googlecode.quicktigame2d.opengl.GLHelper;
import com.googlecode.quicktigame2d.util.RunnableGL;

public class QuickTiGame2dMapSprite extends QuickTiGame2dSprite {
    private float[] quads;
    private short[] indices;
    
    private List<QuickTiGame2dMapTile> tiles = new ArrayList<QuickTiGame2dMapTile>();
    private Map<Integer, QuickTiGame2dMapTile> updatedTiles = new HashMap<Integer, QuickTiGame2dMapTile>();
    
    private float tileWidth;
    private float tileHeight;
    private float tileOffsetX;
	private float tileOffsetY;
    
    private int tileCount;
    private int tileCountX;
    private int tileCountY;
    
	private int[] verticesID = new int[1];
    boolean tileChanged = false;

    private FloatBuffer quadsBuffer;
    private ShortBuffer indicesBuffer;
    
    private int firstgid;
    
    private int orientation;
    private float tileTiltFactorX = 1.0f;
    private float tileTiltFactorY = 1.0f;
    
    private Map<String, Map<String, String>> tilesets = new HashMap<String, Map<String, String>>();
    private List<Map<String, String>> tilesetgids = new ArrayList<Map<String, String>>();
    private Map<Integer, Map<String, String>> gidproperties = new HashMap<Integer, Map<String, String>>();
    
    private boolean isTopLayer = false;
    private boolean isSubLayer = false;
    
    private boolean useFixedTileCount = false;
    
    public QuickTiGame2dMapSprite() {
		firstgid = 1;
		verticesID[0] = 0;
	}
    
    public Map<String, String> getGIDProperties(int gid) {
    	return gidproperties.get(Integer.valueOf(gid));
    }
    
    public boolean updateTileCount() {
        if (tileWidth == 0 || tileHeight == 0) return false;
        
        if (useFixedTileCount) {
            tileCount  = tileCountX * tileCountY;
            
            if (orientation == QuickTiGame2dConstant.MAP_ORIENTATION_ISOMETRIC) {
            	this.width  = (int)(tileWidth  * tileCountX * tileTiltFactorX * 2);
            	this.height = (int)(this.width * 0.5f);
            } else {
            	this.width  = (int)(tileWidth  * tileCountX * tileTiltFactorX);
            	this.height = (int)(tileHeight * tileCountY * tileTiltFactorY);
            }
            
        } else {
        	if (orientation != QuickTiGame2dConstant.MAP_ORIENTATION_HEXAGONAL) {
        		tileCountX = (int)Math.ceil(width  / (tileWidth  * tileTiltFactorX));
        		tileCountY = (int)Math.ceil(height / (tileHeight * tileTiltFactorY));
        		tileCount  = tileCountX * tileCountY;
        	} else {
        		tileCountX = (int)Math.ceil(width  / (tileWidth  * tileTiltFactorX));
        		tileCountY = (int)Math.ceil(height / (tileHeight * tileTiltFactorY));
	        
        		tileCount = (tileCountX * tileCountY) - (tileCountY / 2);
        	}
        }
	    return true;
    }
    
    @Override
	public void onLoad(GL10 gl, QuickTiGame2dGameView view) {
		if (loaded) return;
		
		super.onLoad(gl, view);
		
	    if (tileWidth  == 0) tileWidth  = width;
	    if (tileHeight == 0) tileHeight = height;
	    
	    if (updateTileCount()) {
	    	createQuadBuffer(gl);
	    }
	}
    
    private void reloadQuadBuffer() {
    	beforeCommandQueue.offer(new RunnableGL() {
    		@Override
    		public void run(GL10 gl) {
    		    if (updateTileCount()) {
    		    	createQuadBuffer(gl);
    		    }
    		}
    	});
    }
    
    private boolean useLayeredMap() {
    	return isTopLayer || isSubLayer;
    }

    @Override
	public void onDrawFrame(GL10 gl10) {
		GL11 gl = (GL11)gl10;

		while(!beforeCommandQueue.isEmpty()) {
			beforeCommandQueue.poll().run(gl);
		}
		
	    //
	    // synchronize child layers position & scale
	    //
		synchronized (children) {
			for (QuickTiGame2dSprite child : children) {
				child.setX(getX());
				child.setY(getY());
				child.setScaleX(getScaleX());
				child.setScaleY(getScaleY());
				child.setScaleCenterX(getScaleCenterX());
				child.setScaleCenterY(getScaleCenterY());
			}
		}
		
	    synchronized (transforms) {
			onTransform();
	    }
	    
	    synchronized (animations) {
			if (animating && animations.size() > 0) {
				for (String name : animations.keySet()) {
					double uptime = QuickTiGame2dGameView.uptime();
					QuickTiGame2dAnimationFrame animation = animations.get(name);
					if (animation.getLastOnAnimationDelta(uptime) < animation.getInterval()) {
						continue;
					}
					int index = animation.getNameAsInt();
					if (index >= 0) {
						QuickTiGame2dMapTile updatedTile = getTile(index);
						updatedTile.gid = animation.getNextIndex(tileCount, updatedTile.gid);
						
					    setTile(index, updatedTile);
					}
					animation.setLastOnAnimationInterval(uptime);
				}
			}
	    }
	    
	    synchronized (updatedTiles) {
	        tileChanged = updatedTiles.size() > 0;
	        if (tileChanged) {
	            for (Map.Entry<Integer, QuickTiGame2dMapTile> e : updatedTiles.entrySet()) {
	                updateQuad(e.getKey().intValue(), e.getValue());
	            }
	            updatedTiles.clear();
	        }
	    }
	    
	    if (useLayeredMap()) {
	    	view.get().updateOrthoViewport(gl);
	    	
	    	gl.glDepthFunc(GL10.GL_LEQUAL);
	    	gl.glEnable(GL10.GL_DEPTH_TEST);
	    	
	        // Cut off alpha of sub layer to blend with top layer
	        // sublayer should not use half-translucent alpha
	        if (isSubLayer) {
	            gl.glEnable(GL10.GL_ALPHA_TEST);
	            gl.glAlphaFunc(GL10.GL_GREATER, 0.5f);
	        }
	    }
		
	    gl.glMatrixMode(GL11.GL_MODELVIEW);
	    gl.glLoadIdentity(); 
	    
	    gl.glEnableClientState(GL11.GL_COLOR_ARRAY);
	    
	    // unbind all buffers
	    gl.glBindBuffer(GL11.GL_ELEMENT_ARRAY_BUFFER, 0);
	    gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, 0);
	    gl.glBindTexture(GL11.GL_TEXTURE_2D, 0);

	    // update position
	    gl.glTranslatef(x * orthFactorX, y * orthFactorY, 0);
		
	    // rotate angle, center x, center y, center z, axis
	    gl.glTranslatef(param_rotate[1], param_rotate[2], param_rotate[3]);
	    if (param_rotate[4] == QuickTiGame2dConstant.AXIS_X) {
	    	gl.glRotatef(param_rotate[0], 1, 0, 0);
	    } else if (param_rotate[4] == QuickTiGame2dConstant.AXIS_Y) {
	    	gl.glRotatef(param_rotate[0], 0, 1, 0);
	    } else {
	    	gl.glRotatef(param_rotate[0], 0, 0, 1);
	    }
	    gl.glTranslatef(-param_rotate[1], -param_rotate[2], -param_rotate[3]);
		
	    // scale param x, y, z, center x, center y, center z
	    gl.glTranslatef(param_scale[3], param_scale[4], param_scale[5]);
	    gl.glScalef(param_scale[0], param_scale[1], param_scale[2]);
	    gl.glTranslatef(-param_scale[3], -param_scale[4], -param_scale[5]);
	    
	    gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, verticesID[0]);
	    
	    if (tileChanged) {
		    quadsBuffer.put(quads);
		    quadsBuffer.position(0);
			gl.glBufferData(GL11.GL_ARRAY_BUFFER, 144 * tileCount, quadsBuffer, GL11.GL_STATIC_DRAW);
	    	tileChanged = false;
	    }
	    
		// Configure the vertex pointer which will use the currently bound VBO for its data
	    gl.glVertexPointer(3, GL11.GL_FLOAT, 36, 0);
	    gl.glColorPointer(4, GL11.GL_FLOAT,  36,   (4 * 5));
	    gl.glTexCoordPointer(2, GL11.GL_FLOAT, 36, (4 * 3));

		if (hasTexture) {
			gl.glEnable(GL11.GL_TEXTURE_2D);
			gl.glBindTexture(GL11.GL_TEXTURE_2D, getTexture().getTextureId());
	    }
		
		gl.glBlendFunc(srcBlendFactor, dstBlendFactor);
		
		gl.glDrawElements(GL11.GL_TRIANGLES, tileCount * 6, GL11.GL_UNSIGNED_SHORT, indicesBuffer);
	    
		gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, 0);
		gl.glBlendFunc(GL11.GL_ONE, GL11.GL_ONE_MINUS_SRC_ALPHA);
		
		if (useLayeredMap()) {
			gl.glDisable(GL10.GL_ALPHA_TEST);
			gl.glDisable(GL10.GL_DEPTH_TEST);
			gl.glDepthFunc(GL10.GL_LESS);
			
			view.get().forceUpdateViewport(gl);
		}
	    
		gl.glDisableClientState(GL11.GL_COLOR_ARRAY);
		
		while(beforeCommandQueue.isEmpty() && !afterCommandQueue.isEmpty()) {
			afterCommandQueue.poll().run(gl);
		}
	}

    @Override
	public void onDispose() {
    	quads = new float[0];
    	indices = new short[0];

    	tiles.clear();
    	updatedTiles.clear();

    	quadsBuffer = null;
    	indicesBuffer = null;

    	tilesets.clear();
    	tilesetgids.clear();
    	gidproperties.clear();
    	
		super.onDispose();
	}

    @Override
	protected void bindVertex(GL10 gl10) {
	    // overwrite parent function..to do nothing
	}
	
	// disable frame animation
    @Override
	public boolean setFrameIndex(int index, boolean force) {
		return true;
	}

	private void createQuadBuffer(GL10 gl10) {
	    
		GL11 gl = (GL11)gl10;
		
	    quads     = new float[36 * tileCount];
	    indices   = new short[tileCount * 6];
	    
	    tiles.clear();
	    updatedTiles.clear();
	    
	    for( int i = 0; i < tileCount; i++) {
			indices[i * 6 + 0] = (short) (i * 4 + 0);
			indices[i * 6 + 1] = (short) (i * 4 + 1);
			indices[i * 6 + 2] = (short) (i * 4 + 2);
			
			indices[i * 6 + 3] = (short) (i * 4 + 2);
			indices[i * 6 + 4] = (short) (i * 4 + 3);
			indices[i * 6 + 5] = (short) (i * 4 + 0);
			
			QuickTiGame2dMapTile tile = new QuickTiGame2dMapTile();
			tile.alpha = 0;
			tile.index = i;
			tiles.add(tile);
			
			updateQuad(i, tile);
		}

	    //
		// initialize texture vertex
	    //
	    int index = 0;
	    for(int ty = 0; ty < tileCountY; ty++) {
	        for (int tx = 0; tx < tileCountX; tx++) {
	            int vi = index * 36;
	            
	            if (orientation == QuickTiGame2dConstant.MAP_ORIENTATION_ISOMETRIC) {
	            	float iso_startX = (tx * tileTiltFactorX  * tileWidth)  - (ty * tileTiltFactorX  * tileWidth);
	            	float iso_startY = (ty * tileTiltFactorY * tileHeight) + (tx * tileTiltFactorY * tileHeight);

	            	quads[vi + 0] = iso_startX;  // vertex  x
	            	quads[vi + 1] = iso_startY;  // vertex  y
	            	quads[vi + 2] = 0;           // vertex  z

	            	// -----------------------------
	            	quads[vi + 9] = iso_startX;               // vertex  x
	            	quads[vi + 10] = iso_startY + tileHeight; // vertex  y
	            	quads[vi + 11] = 0;                       // vertex  z

	            	// -----------------------------
	            	quads[vi + 18] = iso_startX + tileWidth;  // vertex  x
	            	quads[vi + 19] = iso_startY + tileHeight; // vertex  y
	            	quads[vi + 20] = 0;                       // vertex  z

	            	// -----------------------------
	            	quads[vi + 27] = iso_startX + tileWidth; // vertex  x
	            	quads[vi + 28] = iso_startY;             // vertex  y
	            	quads[vi + 29] = 0;                      // vertex  z
	            	
	            } else if (orientation == QuickTiGame2dConstant.MAP_ORIENTATION_HEXAGONAL) {
	                if (ty % 2 == 1 && tx >= tileCountX - 1) {
	                    continue;
	                } else if (index >= tileCount) {
	                    break;
	                }
	                float hex_startX = ((ty % 2) * tileWidth * tileTiltFactorX) + (tx * tileWidth);
	                float hex_startY = (ty * tileTiltFactorY * tileHeight);
	                
	                quads[vi + 0] = hex_startX;  // vertex  x
	                quads[vi + 1] = hex_startY;  // vertex  y
	            	quads[vi + 2] = 0;           // vertex  z
	                
	                // -----------------------------
	                quads[vi + 9] = hex_startX;               // vertex  x
	                quads[vi + 10] = hex_startY + tileHeight; // vertex  y
	            	quads[vi + 11] = 0;                       // vertex  z
	                
	                // -----------------------------
	                quads[vi + 18] = hex_startX + tileWidth;  // vertex  x
	                quads[vi + 19] = hex_startY + tileHeight; // vertex  y
	            	quads[vi + 20] = 0;                       // vertex  z
	                
	                // -----------------------------
	                quads[vi + 27] = hex_startX + tileWidth; // vertex  x
	                quads[vi + 28] = hex_startY;             // vertex  y
	            	quads[vi + 29] = 0;                      // vertex  z
	            	
	            } else {
	            	quads[vi + 0] = tx * tileWidth;  // vertex  x
	            	quads[vi + 1] = ty * tileHeight; // vertex  y
	            	quads[vi + 2] = 0;               // vertex  z

	            	// -----------------------------
	            	quads[vi + 9]  = (tx * tileWidth);               // vertex  x
	            	quads[vi + 10] = (ty * tileHeight) + tileHeight; // vertex  y
	            	quads[vi + 11] = 0;                              // vertex  z

	            	// -----------------------------
	            	quads[vi + 18] = (tx * tileWidth)  + tileWidth;  // vertex  x
	            	quads[vi + 19] = (ty * tileHeight) + tileHeight; // vertex  y
	            	quads[vi + 20] = 0;                              // vertex  z

	            	// -----------------------------
	            	quads[vi + 27] = (tx * tileWidth) + tileWidth;  // vertex  x
	            	quads[vi + 28] = (ty * tileHeight);             // vertex  y
	            	quads[vi + 29] = 0;                             // vertex  z
	            }
	            index++;
	        }
		}
	    
	    quadsBuffer = GLHelper.createFloatBuffer(quads);
	    indicesBuffer = GLHelper.createShortBuffer(indices);

	    // Generate the vertices VBO
	    if (verticesID[0] == 0) {
	    	gl.glGenBuffers(1, verticesID, 0);
	    }
		gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, verticesID[0]);
		gl.glBufferData(GL11.GL_ARRAY_BUFFER, 144 * tileCount, quadsBuffer, GL11.GL_STATIC_DRAW);
		gl.glBindBuffer(GL11.GL_ARRAY_BUFFER, 0);
	}
	
	private int getTileNumber(QuickTiGame2dMapTile tile) {
		return tile.gid - tile.firstgid - (this.firstgid - 1);
	}

	private float tex_coord_startX(QuickTiGame2dMapTile tile) {
		int tileNo = getTileNumber(tile);
		
		if (tilesets.size() > 0) {
	        float awidth = tile.atlasWidth > 0 ? tile.atlasWidth : width;
	        float twidth = tile.isOverwrap ? tile.overwrapWidth : tile.width > 0 ? tile.width : tileWidth;
	        
	        int xcount = (int)Math.round((awidth - (tile.margin * 2) + tile.border) / (float)(twidth  + tile.border));
	        int xindex = tileNo % xcount;
	        
	        float atlasX = tile.atlasX;
	        if (tile.flip && tile.isOverwrap) {
	            atlasX = (tile.overwrapAtlasX * 2) - tile.atlasX - tile.width + tile.overwrapWidth;
	        }
	        
	        return atlasX + ((tile.border + twidth) * xindex) + tile.margin;
		} else {
			int xcount = (int)Math.round((getTexture().getWidth() - (margin * 2) + border) / (float)(tileWidth  + border));
			int xindex = tileNo % xcount;
			return ((border + tileWidth) * xindex) + margin;
		}
	}

	private float tex_coord_startY(QuickTiGame2dMapTile tile) {
	    int tileNo = getTileNumber(tile);
	    
		if (tilesets.size() > 1) {
	        float awidth  = tile.atlasWidth  > 0 ? tile.atlasWidth  : width;
	        float aheight = tile.atlasHeight > 0 ? tile.atlasHeight : height;
	        float twidth  = tile.isOverwrap ? tile.overwrapWidth  : tile.width  > 0 ? tile.width : tileWidth;
	        float theight = tile.isOverwrap ? tile.overwrapHeight : tile.height > 0 ? tile.height : tileHeight;
	        
	        int xcount = (int)Math.round((awidth  - (tile.margin * 2) + tile.border) / (float)(twidth  + tile.border));
	        int ycount = (int)Math.round((aheight - (tile.margin * 2) + tile.border) / (float)(theight + tile.border));
	        int yindex = flipY() ? ycount - (tileNo / xcount) - 1 : (tileNo / xcount);
	                
	        return tile.atlasY + ((tile.border + theight) * yindex) + tile.margin;
		} else {
			int xcount = (int)Math.round((getTexture().getWidth() - (margin * 2) + border) / (float)(tileWidth  + border));
			int ycount = (int)Math.round((getTexture().getHeight() - (margin * 2) + border) / (float)(tileHeight + border));
			int yindex = flipY() ? ycount - (tileNo / xcount) - 1 : (tileNo / xcount);
			return ((border + tileHeight) * yindex) + margin;
		}
	}

	private float tileCoordStartX(QuickTiGame2dMapTile tile) {
	    return tex_coord_startX(tile) / (float)getTexture().getGlWidth() + getTexelHalfX();
	}

	private float tileCoordEndX(QuickTiGame2dMapTile tile) {
	    float twidth = tile.width > 0 ? tile.width : tileWidth;
	    float value  = (float)(tex_coord_startX(tile) + twidth) / (float)getTexture().getGlWidth() - getTexelHalfX();
	    
	    return value > 1.0f ? 1.0f : value;
	}

	private float tileCoordStartY(QuickTiGame2dMapTile tile) {
	    float theight = tile.height > 0 ? tile.height : tileHeight;
	    float value   = (float)(tex_coord_startY(tile) + theight) / (float)getTexture().getGlHeight() - getTexelHalfY();
	    return value > 1.0f ? 1.0f : value;
	}

	private float tileCoordEndY(QuickTiGame2dMapTile tile) {
	    return tex_coord_startY(tile) / (float)getTexture().getGlHeight() + getTexelHalfY();
	}

	private void updateQuad(int index, QuickTiGame2dMapTile cctile) {
	    if (index >= tiles.size()) return;
	    
	    int vi = index * 36;
	    QuickTiGame2dMapTile tile = tiles.get(index);
	    tile.cc(cctile);
	    
	    if (getTileNumber(tile) < 0) tile.alpha = 0;
	    
	    float parentAlpha =  getAlpha();
	    
	    quads[vi + 3] = tile.flip? tileCoordEndX(tile) : tileCoordStartX(tile); // texture x
	    quads[vi + 4] = tileCoordEndY(tile);  // texture y
	    
	    quads[vi + 5] = tile.red * tile.alpha * parentAlpha;   // red
	    quads[vi + 6] = tile.green * tile.alpha * parentAlpha; // green
	    quads[vi + 7] = tile.blue * tile.alpha * parentAlpha;  // blue
	    quads[vi + 8] = tile.alpha * parentAlpha; // alpha
	    
	    // -----------------------------
	    quads[vi + 12] = tile.flip? tileCoordEndX(tile) : tileCoordStartX(tile);
	    quads[vi + 13] = tileCoordStartY(tile);
	    
	    quads[vi + 14] = tile.red * tile.alpha * parentAlpha;   // red
	    quads[vi + 15] = tile.green * tile.alpha * parentAlpha; // green
	    quads[vi + 16] = tile.blue * tile.alpha * parentAlpha;  // blue
	    quads[vi + 17] = tile.alpha * parentAlpha; // alpha
	    
	    // -----------------------------
	    quads[vi + 21] = tile.flip ? tileCoordStartX(tile) : tileCoordEndX(tile);
	    quads[vi + 22] = tileCoordStartY(tile);
	    
	    quads[vi + 23] = tile.red * tile.alpha * parentAlpha;   // red
	    quads[vi + 24] = tile.green * tile.alpha * parentAlpha; // green
	    quads[vi + 25] = tile.blue * tile.alpha * parentAlpha;  // blue
	    quads[vi + 26] = tile.alpha * parentAlpha; // alpha
	    
	    // -----------------------------
	    
	    quads[vi + 30] = tile.flip ? tileCoordStartX(tile) : tileCoordEndX(tile);
	    quads[vi + 31] = tileCoordEndY(tile);
	    
	    quads[vi + 32] = tile.red * tile.alpha * parentAlpha;   // red
	    quads[vi + 33] = tile.green * tile.alpha * parentAlpha; // green
	    quads[vi + 34] = tile.blue * tile.alpha * parentAlpha;  // blue
	    quads[vi + 35] = tile.alpha * parentAlpha; // alpha
	    
	    if (tile.width > 0 && tile.height > 0) {
	        
	        if (!tile.positionFixed) {
	            tile.initialX = quads[vi + 0];
	            tile.initialY = quads[vi + 1];
	            tile.positionFixed = true;
	        }
	        
	        float tilez = !useLayeredMap() ? 0 : tile.alpha > 0 ? index : -1;
	        
	        quads[vi + 0] = tile.initialX + tile.offsetX;  // vertex  x
	        quads[vi + 1] = tile.initialY + tile.offsetY;  // vertex  y
        	quads[vi + 2] = tilez;                         // vertex  z
	            
	        quads[vi + 9]  = tile.initialX + tile.offsetX; // vertex  x
	        quads[vi + 10] = quads[vi + 1] + tile.height;  // vertex  y
        	quads[vi + 11] = tilez;                        // vertex  z
	        
	        // -----------------------------
	        quads[vi + 18] = quads[vi + 0] + tile.width;  // vertex  x
	        quads[vi + 19] = quads[vi + 1] + tile.height; // vertex  y
        	quads[vi + 20] = tilez;                       // vertex  z
	        
	        // -----------------------------
	        quads[vi + 27] = quads[vi + 0] + tile.width;   // vertex  x
	        quads[vi + 28] = tile.initialY + tile.offsetY; // vertex  y
        	quads[vi + 29] = tilez;                        // vertex  z
	    }
	    
	}
	
	private int getChildTileRowCount(QuickTiGame2dMapTile tile) {
	    return (int)(tile.width / tileWidth);
	}
	
	public int getTileRowCount(QuickTiGame2dMapTile tile) {
	    if (tile.rowCount <= 0) {
	        return getChildTileRowCount(tile);
	    } else {
	        return tile.rowCount;
	    }
	}

	public int getTileColumnCount(QuickTiGame2dMapTile tile) {
	    if (tile.columnCount <= 0) {
	        return getChildTileRowCount(tile);
	    } else {
	        return tile.columnCount;
	    }
	}

	public boolean isHalfTile(QuickTiGame2dMapTile tile) {
	    int row    = getTileRowCount(tile);
	    int column = getTileColumnCount(tile);
	    
	    return (row > 1 || column > 1) && (row != column);
	}
	
    // check if this tile consists of multiple tiles
    // this assumes tile has same tile count for X&Y axis (2x2, 3x3, 4x4)
	public boolean hasChild(QuickTiGame2dMapTile tile) {
		return getChildTileRowCount(tile) > 1;
	}
	
	public void updateGIDProperties(Map<String, Map<String, String>> info, int firstgid) {
		for (String key : info.keySet()) {
			int gid = firstgid + Integer.parseInt(key);
			gidproperties.put(Integer.valueOf(gid), info.get(key));
		}
	}

	private QuickTiGame2dMapTile updateTileProperty(QuickTiGame2dMapTile tile) {
	    // Update tile properties if we found multiple tilesets
	    if (tilesets.size() > 1) {
	    	if (tile.gid <= 0) {
	    		tile.image = tilesetgids.get(0).get("image");
	    	} else if (tile.image == null) {
	            for (Map<String, String> gids : tilesetgids) {
	                int tsgid = (int)Float.parseFloat(gids.get("firstgid"));
	                if (tsgid > tile.gid) {
	                    break;
	                }
	                tile.image = gids.get("image");
	            }
	        }
	        
	        if (tile.image != null) {
	            Map<String, String> prop = tilesets.get(tile.image);
	            
	            tile.width  = Float.parseFloat(prop.get("tilewidth"));
	            tile.height = Float.parseFloat(prop.get("tileheight"));
	            tile.firstgid = (int)Float.parseFloat(prop.get("firstgid"));
	            tile.margin = Float.parseFloat(prop.get("margin"));
	            tile.border = Float.parseFloat(prop.get("border"));
	            
	            tile.offsetX  = Float.parseFloat(prop.get("offsetX"));
	            tile.offsetY  = Float.parseFloat(prop.get("offsetY"));
	            
	            tile.atlasX = Float.parseFloat(prop.get("atlasX"));
	            tile.atlasY = Float.parseFloat(prop.get("atlasY"));
	            tile.atlasWidth  = Float.parseFloat(prop.get("atlasWidth"));;
	            tile.atlasHeight = Float.parseFloat(prop.get("atlasHeight"));;
	            
	            tile.rowCount    = (int)Float.parseFloat(prop.get("rowCount"));
	            tile.columnCount = (int)Float.parseFloat(prop.get("columnCount"));
	        }
	    }
	    
	    return tile;
	}

	public boolean canUpdate(int index, QuickTiGame2dMapTile tile) {
	    if (getChildTileRowCount(tile) < 2) return true;
	    
	    int rowCount    = tile.flip ? tile.columnCount : tile.rowCount;
	    int columnCount = tile.flip ? tile.rowCount : tile.columnCount;
	    
	    for (int row = 0; row < rowCount; row++) {
	        for (int column = 0; column < columnCount; column++) {
	            if (row == 0 && column == 0) continue;
	            
	            QuickTiGame2dMapTile target = getTile(index + column + (row * tileCountX));
	            if (target == null) continue;
	            
	            if (target.isChild) {
	            	if (target.parent == index) {
	            		continue;
	            	} else {
	            		return false;
	            	}
	            } else if (target.gid > 0) {
	                return false;
	            } else if (hasChild(target)) {
	                return false;
	            }
	        }
	    }
	    
	    return true;
	}

	public boolean setTile(int index, QuickTiGame2dMapTile tile) {
		QuickTiGame2dMapTile target = getTile(index);
	    if (target != null && target.isChild) {
	        Log.d(Quicktigame2dModule.LOG_TAG, String.format(
	        		"Tile %d can not be replaced because it is part of multiple tiles.", index));
	        return false;
	    }
	    
	    tile = updateTileProperty(tile);
		
	    if (!canUpdate(index, tile)) {
	        Log.d(Quicktigame2dModule.LOG_TAG, String.format(
	        		"Tile %d can not be replaced because another tile is found.", index));
	        return false;
	    }
	    
	    // check if this tile consists of multiple tiles
	    // this assumes tile has same tile count for X&Y axis (2x2, 3x3, 4x4)
	    int childRowCount = getChildTileRowCount(tile);
	    if (childRowCount >= 2) {

	        // Fill out neighboring tile with empty tile
	        for (int row = 0; row < childRowCount; row++) {
	            for (int column = 1; column < childRowCount; column++) {
	                
	                int index2 = index + column + (row * tileCountX);
	                QuickTiGame2dMapTile target2 = getTile(index2);
	                QuickTiGame2dMapTile neighbor = new QuickTiGame2dMapTile();;
	                
	                if (target2 != null) {
	                    neighbor.cc(target2);
	                }
	                
                    neighbor = updateTileProperty(neighbor);
	                
	                neighbor.index = index2;
	                neighbor.isChild = true;
	                neighbor.suppressUpdate = true;
	                neighbor.alpha = 0;
	                neighbor.parent = index;
	                neighbor.gid = tile.gid;
	                
	                if (!isTileSpaceUsed(tile, row, column)) {
		                // Clear neighboring tile that is not used
	                    if (target2 != null && target2.parent == index) {
	                        neighbor.clearViewProperty(this);
	                    } else {
	                        continue;
	                    }
	                }
	                
		    	    synchronized(updatedTiles) {
		    	    	updatedTiles.put(Integer.valueOf(neighbor.index), neighbor);
		    	    }
	            }
	        }
	    	
	        float baseTileHeight = (float) tileWidth * 0.5f;
	        float baseTileMargin = tile.height - (childRowCount * baseTileHeight);
	        for (int i = 1; i < childRowCount; i++) {
	            
	            QuickTiGame2dMapTile tile2 = new QuickTiGame2dMapTile();
	            
	            tile2.cc(tile);
	            
	            tile2.index    = index + (i * tileCountX);
	            
	            QuickTiGame2dMapTile target2 = getTile(tile2.index);
	            if (target2 != null) {
	                tile2.initialX = target2.initialX;
	                tile2.initialY = target2.initialY;
	            } else {
	                tile2.positionFixed = false;
	            }
	            
	            tile2.width    = tileWidth;
	            tile2.height   = baseTileHeight + baseTileMargin;
	            tile2.atlasX   = tile.atlasX + ((childRowCount - i - 1) * tileWidth * 0.5f);
	            tile2.atlasY   = tile.atlasY + (baseTileHeight * 0.5f) * i;
	            
	            tile2.overwrapWidth  = tile.width;
	            tile2.overwrapHeight = tile.height;
	            tile2.overwrapAtlasX = tile.atlasX;
	            tile2.overwrapAtlasY = tile.atlasY;
	            tile2.isOverwrap      = true;
	            tile2.isChild         = true;
	            tile2.offsetX = -tileWidth * 0.5f;
	            tile2.offsetY = tile.offsetY;
	            tile2.parent  = index;
	            
	            tile2.suppressUpdate = true;
	            
	            if (!isTileSpaceUsed(tile, i, 0)) {
                    if (target2 != null && target2.parent == index) {
                    	tile2.clearViewProperty(this);
                    	tile2.alpha = 0;
                    	tile2.suppressUpdate = false;
                    } else {
                    	continue;
                    }
	            }
	            
	    	    synchronized(updatedTiles) {
	    	    	updatedTiles.put(Integer.valueOf(tile2.index), tile2);
	    	    }
	    	    
	    	    tile2 = null;
	        }
	    }
	    
	    synchronized(updatedTiles) {
	    	updatedTiles.put(Integer.valueOf(index), tile);
	    }
	    
	    return true;
	}

	public void setTiles(final List<Integer> data) {
		
		reloadQuadBuffer();
		
		beforeCommandQueue.offer(new RunnableGL() {
			@Override
			public void run(GL10 gl) {
			    for (int i = 0; i < data.size(); i++) {
			    	
			    	QuickTiGame2dMapTile overwrap = updatedTiles.get(Integer.valueOf(i));
			    	if (overwrap != null && overwrap.suppressUpdate) {
			    		overwrap.suppressUpdate = false;
			    		continue;
			    	}
			    	
			        QuickTiGame2dMapTile tile = new QuickTiGame2dMapTile();
			        tile.gid = data.get(i).intValue();
			        tile.alpha = 1;
			        tile.index = i;
			        
			        setTile(i, tile);
			    }
			}
		});
	}

	public boolean removeTile(int index) {
	    if (index < 0 || index >= tiles.size()) return false;
	    
	    QuickTiGame2dMapTile target = getTile(index);
	    if (target == null) return false;
	    
	    if (target.isChild) {
	        Log.d(Quicktigame2dModule.LOG_TAG, String.format(
	        		"Tile %d can not be removed because it is part of multiple tiles.", index));
	        return false;
	    }
	    
	    // check if this tile consists of multiple tiles
	    // this assumes tile has same tile count for X&Y axis (2x2, 3x3, 4x4)
	    int childRowCount = getChildTileRowCount(target);
	    // Fill out neighboring tile with empty tile
	    for (int row = 0; row < childRowCount; row++) {
	    	for (int column = 0; column < childRowCount; column++) {

	    		QuickTiGame2dMapTile target2 = getTile(index + column + (row * tileCountX));
	    		if (target2 == null) continue;
	    		
	    		QuickTiGame2dMapTile tile2 = new QuickTiGame2dMapTile();
	    		tile2.indexcc(target2);

	            if (target2.index != index && (!target2.isChild || target2.parent != index)) {
	                continue;
	            }
	            
	    		tile2.clearViewProperty(this);
	    		tile2.alpha  = 0;

	    		synchronized(updatedTiles) {
	    			updatedTiles.put(Integer.valueOf(tile2.index), tile2);
	    		}
	    	}
	    }
	    
	    return true;
	}

	public boolean flipTile(int index) {
	    if (index >= tiles.size()) return false;
	    
	    QuickTiGame2dMapTile tile = tiles.get(index);
	    tile.flip = !tile.flip;
	    
	    synchronized(updatedTiles) {
	    	updatedTiles.put(Integer.valueOf(index), tile);
	    }
	    
	    return true;
	}
	
    public boolean collidesIsometric(float otherX, float otherY, QuickTiGame2dMapTile tile) {
        otherX = otherX - this.tileOffsetX - tile.initialX;
        otherY = otherY - (tileHeight * tileTiltFactorY) - tile.initialY;
        
        float dHeight = tileHeight - (tileHeight * tileTiltFactorY);
        float ratio = Math.min(tileWidth, dHeight) / Math.max(tileWidth, dHeight);
        float rHeight = dHeight * ratio;
        
        float a1 = (ratio * otherX) - rHeight;
        float a2 = (ratio * otherX) + rHeight;
        float a3 = -(ratio * otherX) + rHeight;
        float a4 = -(ratio * otherX) + (3 * rHeight);
        
        return (otherY > a1 && otherY < a2 && otherY > a3 && otherY < a4);
    }
    
	public QuickTiGame2dMapTile getTileAtPosition(float sx, float sy) {
	    float posX = (sx - x) / getScaleX();
	    float posY = (sy - y) / getScaleY();
	    
	    float tiltStepX = (tileWidth  * tileTiltFactorX);
	    float tiltStepY = (tileHeight * tileTiltFactorY);
	    
	    if (orientation == QuickTiGame2dConstant.MAP_ORIENTATION_ISOMETRIC) {
	        
	        //
	        // poor implementation but this is enough this time
	        //
	        float localX = ((int)(posX / tiltStepX)) * tiltStepX;
	        float localY = ((int)(posY / tiltStepY)) * tiltStepY - tiltStepY;
	        
	        float a = localX / tileTiltFactorX / tileWidth;
	        float b = localY / tileTiltFactorY / tileHeight;
	        
	        int indexX = (int)Math.floor((a + b) / 2);
	        int indexY = (int)Math.floor(indexX - a);
	        
	        QuickTiGame2dMapTile tile = getTile(indexX + (tileCountX * indexY));
	        
	        if (tile != null && collidesIsometric(posX, posY, tile)) {
	            return tile;
	        }
	        
	        //
	        // Check other tiles around because tiles can be overwrapped
	        //
	        tile = getTile((indexX + 1) + (tileCountX * indexY));
	        if (tile != null && collidesIsometric(posX, posY, tile)) {
	            return tile;
	        }
	        
	        tile = getTile(indexX + (tileCountX * (indexY + 1)));
	        if (tile != null && collidesIsometric(posX, posY, tile)) {
	            return tile;
	        }
	        
	        tile = getTile(indexX + (tileCountX * (indexY - 1)));
	        if (tile != null && collidesIsometric(posX, posY, tile)) {
	            return tile;
	        }
	        
	        tile = getTile((indexX - 1) + (tileCountX * indexY));
	        if (tile != null && collidesIsometric(posX, posY, tile)) {
	            return tile;
	        }
	        
	        return null;
	    } else {
	        float indexX = posX / tiltStepX;
	        float indexY = posY / tiltStepY;
	        
	        return getTile((int)(indexX + (tileCountX * indexY)));
	    }
	}
	
	public QuickTiGame2dMapTile getTile(int index) {
	    if (index < 0 || index >= tiles.size()) return null;
	    
	    return tiles.get(index);
	}

	public List<Integer> getTiles() {
		List<Integer> data = new ArrayList<Integer>();
		
		if (tiles.size() == 0) {
	        for (int i = 0; i < updatedTiles.size(); i++) {
	            data.add(Integer.valueOf(-1));
	        }
	        for (Integer num : updatedTiles.keySet()) {
	            data.set(num.intValue(), updatedTiles.get(num).gid); 
	        }
			
		} else {
			for (int i = 0; i < tiles.size(); i++) {
				data.add(Integer.valueOf(tiles.get(i).gid));
			}
		}
		return data;
	}
	
	public void setImage(String image) {
		this.image = image;
	}

	public float getTileWidth() {
		return tileWidth;
	}
	
	public void setTileWidth(float tileWidth) {
		this.tileWidth = tileWidth;
	}
	
	public float getTileHeight() {
		return tileHeight;
	}
	
	public void setTileHeight(float tileHeight) {
		this.tileHeight = tileHeight;
	}
	
	public int getTileCount() {
		return tileCount;
	}
	
	public int getTileCountX() {
		return tileCountX;
	}
	
	public int getTileCountY() {
		return tileCountY;
	}
	
	public void setFirstgid(int firstgid) {
		this.firstgid = firstgid;
	}
	
	public int getFirstgid() {
		return firstgid;
	}

	public int getOrientation() {
		return orientation;
	}
	
	@Override
	public void setAlpha(float alpha) {
		super.setAlpha(alpha);
		
		// Update all tiles to reload buffers
		synchronized(updatedTiles) {
			for (int i = 0; i < tiles.size(); i++) {
				updatedTiles.put(Integer.valueOf(i), tiles.get(i));
			}
		}
	}

	public void setOrientation(int orientation) {
		this.orientation = orientation;
		
	    if (orientation == QuickTiGame2dConstant.MAP_ORIENTATION_ISOMETRIC) {
	        tileTiltFactorX = 0.5f;
	        tileTiltFactorY = 0.25f;
	    } else if (orientation == QuickTiGame2dConstant.MAP_ORIENTATION_HEXAGONAL) {
	        tileTiltFactorX = 0.5f;
	        tileTiltFactorY = 0.75f;
	    } else {
	        tileTiltFactorX = 1.0f;
	        tileTiltFactorY = 1.0f;
	    }
	}

	public float getTileTiltFactorX() {
		return tileTiltFactorX;
	}

	public void setTileTiltFactorX(float tileTiltFactorX) {
		this.tileTiltFactorX = tileTiltFactorX;
	}

	public float getTileTiltFactorY() {
		return tileTiltFactorY;
	}

	public void setTileTiltFactorY(float tileTiltFactorY) {
		this.tileTiltFactorY = tileTiltFactorY;
	}

	public void addTileset(Map<String, String> prop) {

	    String[] checker = {
	            "image", "tilewidth", "tileheight", "offsetX", "offsetY",
	            "firstgid", "margin", "border", "atlasX",
	            "atlasY", "atlasWidth", "atlasHeight"
	    };

	    for (String key : checker) {
	        if (prop.get(key) == null) {
	            Log.e(Quicktigame2dModule.LOG_TAG, String.format("'%s' property not found for tileset", key));
	            return;
	        }
	    }
	    
	    if (tilesets.size() == 0) {
	        this.tileWidth  = Float.parseFloat(prop.get("tilewidth"));
	        this.tileHeight = Float.parseFloat(prop.get("tileheight"));
	        this.tileOffsetX = Float.parseFloat(prop.get("offsetX"));
	        this.tileOffsetY = Float.parseFloat(prop.get("offsetY"));
	    }
	    
	    Map<String, String> gids = new HashMap<String, String>();
	    gids.put("firstgid", prop.get("firstgid"));
	    gids.put("image",    prop.get("image"));
	    tilesetgids.add(gids);
	    
	    tilesets.put(prop.get("image"), prop);
	}

	public Map<String, Map<String, String>> getTilesets() {
	    return tilesets;
	}
	
	public void animateTile(int tileIndex, int start, int count, int interval, int loop) {
	    QuickTiGame2dAnimationFrame animation = new QuickTiGame2dAnimationFrame();
	    
	    animation.setName(String.valueOf(tileIndex));
	    animation.updateNameAsInt();
	    
	    animation.setStart(start);
	    animation.setCount(count);
	    animation.setInterval(interval);
	    animation.setLoop(loop);

	    addAnimation(animation);
	    
	    animating = true;
	}

	public void animateTile(int tileIndex, int[] frames, int interval) {
	    animateTile(tileIndex, frames, interval, 0);
	}

	public void animateTile(int tileIndex, int[] frames, int interval, int loop) {
	    QuickTiGame2dAnimationFrame animation = new QuickTiGame2dAnimationFrame();
	    
	    animation.setName(String.valueOf(tileIndex));
	    animation.updateNameAsInt();
	    
	    animation.setCount(frames.length);
	    animation.setInterval(interval);
	    animation.setLoop(loop);
	    
	    if (frames.length > 0) {
	    	animation.setStart(frames[0]);
	    }

	    animation.initializeIndividualFrames();
	    for (int i = 0; i < frames.length; i++) {
	        animation.setFrame(i, frames[i]);
	    }
	    
	    addAnimation(animation);
	    
	    animating = true;
	}

	public float getDefaultX(QuickTiGame2dMapTile tile) {
		return getX() + tile.initialX * getScaleX();
	}
	
	public float getDefaultY(QuickTiGame2dMapTile tile) {
		return getY() + tile.initialY * getScaleY();
	}

	public float getScreenX(QuickTiGame2dMapTile tile) {
		return getX() + (tile.initialX + tile.offsetX) * getScaleX();
	}
	
	public float getScreenY(QuickTiGame2dMapTile tile) {
		return getY() + (tile.initialY + tile.offsetY) * getScaleY();
	}
	
	public float getScaledTileWidth() {
		return getTileWidth() * getScaleX();
	}
	
	public float getScaledTileHeight() {
		return getTileHeight() * getScaleY();
	}
	
	public float getScaledTileWidth(QuickTiGame2dMapTile tile) {
		return tile.width * getScaleX();
	}
	
	public float getScaledTileHeight(QuickTiGame2dMapTile tile) {
		return tile.height * getScaleY();
	}
	
	public float getTileOffsetX() {
		return this.tileOffsetX;
	}
	
	public float getTileOffsetY() {
		return this.tileOffsetY;
	}
	
	public boolean isTileSpaceUsed(QuickTiGame2dMapTile tile, int row, int column) {
	    if (tile == null) return false;
	    
	    int targetColumn = tile.flip ? row : column;
	    int targetRow    = tile.flip ? column : row;
	    
	    if (tile.columnCount > 0 && tile.columnCount <= targetColumn) {
	        return false;
	    }
	    if (tile.rowCount > 0 && tile.rowCount <= targetRow) {
	        return false;
	    }
	    
	    return true;
	}
	
	public void updateMapSize(int x, int y) {
		this.tileCountX = x;
		this.tileCountY = y;
		
		useFixedTileCount = true;
		
		this.updateTileCount();
	}

	public boolean isTopLayer() {
		return isTopLayer;
	}

	public void setTopLayer(boolean isTopLayer) {
		this.isTopLayer = isTopLayer;
	}

	public boolean isSubLayer() {
		return isSubLayer;
	}

	public void setSubLayer(boolean isSubLayer) {
		this.isSubLayer = isSubLayer;
	}
}
