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

public class QuickTiGame2dMapTile {
    public String image;
    public int   index;
    public int   firstgid;
    public int   gid;
    public float red;
    public float green;
    public float blue;
    public float alpha;
    public boolean flip;
    
    public float margin;
    public float border;
    public float width;
    public float height;
    public float atlasX;
    public float atlasY;
    public float atlasWidth;
    public float atlasHeight;
    public float offsetX;
    public float offsetY;
    
    public boolean  positionFixed;
    public float initialX;
    public float initialY;
    
    public boolean  isOverwrap;
    public float overwrapWidth;
    public float overwrapHeight;
    public float overwrapAtlasX;
    public float overwrapAtlasY;
    
    public boolean  suppressUpdate;
    
    public boolean isChild;
    public int parent;
    
    public int rowCount;
    public int columnCount;
    
    public QuickTiGame2dMapTile() {
        gid   = 0;
        index = 0;
        red   = 1;
        green = 1;
        blue  = 1;
        alpha = 1;
        flip  = false;
        width  = 0;
        height = 0;
        atlasX = 0;
        atlasY = 0;
        firstgid = 1;
        atlasWidth  = 0;
        atlasHeight = 0;
        offsetX = 0;
        offsetY = 0;
        initialX = 0;
        initialY = 0;
        positionFixed = false;
        image = null;
        isOverwrap = false;
        overwrapWidth  = 0;
        overwrapHeight = 0;
        overwrapAtlasX = 0;
        overwrapAtlasY = 0;
        suppressUpdate = false;
        
        isChild = false;
        parent  = -1;
        
        rowCount    = 0;
        columnCount = 0;
    }
    
    public void cc(QuickTiGame2dMapTile other) {
        gid   = other.gid;
        index = other.index;
        red   = other.red;
        green = other.green;
        blue  = other.blue;
        alpha = other.alpha;
        flip  = other.flip;
        width  = other.width;
        height = other.height;
        atlasX = other.atlasX;
        atlasY = other.atlasY;
        firstgid = other.firstgid;
        atlasWidth  = other.atlasWidth;
        atlasHeight = other.atlasHeight;
        offsetX = other.offsetX;
        offsetY = other.offsetY;
        initialX = other.initialX;
        initialY = other.initialY;
        positionFixed = other.positionFixed;
        isOverwrap = other.isOverwrap;
        overwrapWidth = other.overwrapWidth;
        overwrapHeight = other.overwrapHeight;
        overwrapAtlasX = other.overwrapAtlasX;
        overwrapAtlasY = other.overwrapAtlasY;
        suppressUpdate = other.suppressUpdate;
        isChild        = other.isChild;
        parent         = other.parent;
        rowCount       = other.rowCount;
        columnCount    = other.columnCount;
    }
    
    public void indexcc(QuickTiGame2dMapTile other) {
    	this.cc(other);
    	index = other.index;
    }
    
    public String description() {
        return String.format("index:%d, gid:%d, firstgid:%d size:%fx%f, initial:%fx%f atlas:%fx%f atlas size:%fx%f offset:%fx%f overwrap:%fx%f overwrap atlas:%fx%f count:%dx%d parent:%d isChild:%s flip:%s",
        					index, gid, firstgid, width, height, initialX, initialY, atlasX, atlasY, atlasWidth, 
        					atlasHeight, offsetX, offsetY, overwrapWidth, overwrapHeight, overwrapAtlasX, overwrapAtlasY,
        					rowCount, columnCount, parent, isChild ? "TRUE" : "FALSE", flip ? "TRUE" : "FALSE"); 
    }

    public void clearViewProperty(QuickTiGame2dMapSprite map) {
        gid   = 0;
        red   = 1;
        green = 1;
        blue  = 1;
        alpha = 1;
        flip  = false;
        isOverwrap = false;
        isChild = false;
        parent = -1;
        suppressUpdate = false;
        
        width   = map.getTileWidth();
        height  = map.getTileHeight();
        offsetX = map.getTileOffsetX();
        offsetY = map.getTileOffsetY();
        
        rowCount = 0;
        columnCount = 0;
    }

}