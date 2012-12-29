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
#import "QuickTiGame2dMapSprite.h"
#import "QuickTiGame2dEngine.h"

@interface QuickTiGame2dMapSprite (PrivateMethods)
- (float)tex_coord_startX:(QuickTiGame2dMapTile*)tile;
- (float)tex_coord_startY:(QuickTiGame2dMapTile*)tile;
- (float)tileCoordStartX:(QuickTiGame2dMapTile*)tile;
- (float)tileCoordEndX:(QuickTiGame2dMapTile*)tile;
- (float)tileCoordStartY:(QuickTiGame2dMapTile*)tile;
- (float)tileCoordEndY:(QuickTiGame2dMapTile*)tile;
- (void)createQuadBuffer;
- (void)updateQuad:(NSInteger)index tile:(QuickTiGame2dMapTile*)cctile;
- (void)addTileToArray:(QuickTiGame2dMapTile*)tile array:(NSMutableArray*)array;
- (void)updateTileProperty:(QuickTiGame2dMapTile*)tile;
- (NSInteger)getChildTileRowCount:(QuickTiGame2dMapTile*)tile;
- (BOOL)isHalfTile:(QuickTiGame2dMapTile*)tile;
- (void)reloadQuadBuffer;
- (BOOL)useLayeredMap;
@end

@interface QuickTiGame2dMapTile (PrivateMethods)
-(void)clearViewProperty:(QuickTiGame2dMapSprite*)map;
@end

@implementation QuickTiGame2dMapTile
@synthesize gid, red, green, blue, alpha, flip, width, height;
@synthesize atlasX, atlasY, firstgid, margin, border, atlasWidth, atlasHeight;
@synthesize offsetX, offsetY, initialX, initialY, positionFixed;
@synthesize image, index, suppressUpdate, isOverwrap, overwrapWidth, overwrapHeight;
@synthesize overwrapAtlasX, overwrapAtlasY, isChild, parent;
@synthesize rowCount, columnCount;

-(id)init {
    self = [super init];
    if (self != nil) {
        gid   = 0;
        red   = 1;
        green = 1;
        blue  = 1;
        alpha = 1;
        flip  = FALSE;
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
        positionFixed = FALSE;
        index = 0;
        parent = -1;
        
        suppressUpdate = FALSE;
        isOverwrap     = FALSE;
        isChild        = FALSE;
        overwrapWidth  = 0;
        overwrapHeight = 0;
        overwrapAtlasX = 0;
        overwrapAtlasY = 0;
        
        rowCount = 0;
        columnCount = 0;
    }
    return self;
}

-(void)cc:(QuickTiGame2dMapTile*)other {
    gid   = other.gid;
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
    
    suppressUpdate = other.suppressUpdate;
    isOverwrap     = other.isOverwrap;
    overwrapWidth  = other.overwrapWidth;
    overwrapHeight = other.overwrapHeight;
    overwrapAtlasX = other.overwrapAtlasX;
    overwrapAtlasY = other.overwrapAtlasY;
    isChild        = other.isChild;
    parent         = other.parent;
    
    rowCount    = other.rowCount;
    columnCount = other.columnCount;
}

-(void)indexcc:(QuickTiGame2dMapTile*)other {
    [self cc:other];
    index = other.index;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"index:%d, gid:%d, firstgid:%d size:%fx%f, initial:%fx%f atlas:%fx%f atlas size:%fx%f offset:%fx%f overwrap:%fx%f overwrap atlas:%fx%f count:%dx%d, parent=%d, isChild=%@, flip=%@",
            index, gid, firstgid, width, height, initialX, initialY, atlasX,
            atlasY, atlasWidth, atlasHeight, offsetX, offsetY, overwrapWidth, overwrapHeight, overwrapAtlasX, overwrapAtlasY,
            rowCount, columnCount, parent, isChild ? @"TRUE" : @"FALSE", flip ? @"TRUE" : @"FALSE"];
}

-(void)clearViewProperty:(QuickTiGame2dMapSprite*)map {
    gid   = 0;
    red   = 1;
    green = 1;
    blue  = 1;
    alpha = 1;
    flip  = FALSE;
    isOverwrap = FALSE;
    isChild    = FALSE;
    parent     = -1;
    suppressUpdate = FALSE;
    
    width   = map.tileWidth;
    height  = map.tileHeight;
    offsetX = map.tileOffsetX;
    offsetY = map.tileOffsetY;
    
    rowCount    = 0;
    columnCount = 0;
}
@end

@implementation QuickTiGame2dMapSprite
@synthesize tileWidth, tileHeight, tileCount, tileCountX, tileCountY;
@synthesize firstgid, tileTiltFactorX, tileTiltFactorY;
@synthesize tileOffsetX, tileOffsetY, gidproperties, isTopLayer, isSubLayer;

-(id)init {
    self = [super init];
    if (self != nil) {
        tiles = [[NSMutableArray alloc] init];
        updatedTiles = [[NSMutableDictionary alloc] init];
        
        tileChanged = FALSE;
        
        verticesID = 0;
        firstgid = 1;
        
        orientation = MAP_ORIENTATION_ORTHOGONAL;
        
        tileTiltFactorX = 1;
        tileTiltFactorY = 1;
        
        tilesets = [[NSMutableDictionary alloc] init];
        tilesetgids = [[NSMutableArray alloc] init];
        
        gidproperties = [[NSMutableDictionary alloc] init];
        
        useFixedTileCount = FALSE;
        
        isTopLayer = FALSE;
        isSubLayer = FALSE;
    }
    return self;
}

-(void)dealloc {
    [tiles release];
    [updatedTiles release];
    [tilesets release];
    [tilesetgids release];
    [gidproperties release];
    
	if (quads)   free(quads);
	if (indices) free(indices);
    
	glDeleteBuffers(1, &verticesID);
    
    [super dealloc];
}

-(BOOL)updateTileCount {
    if (tileWidth <= 0 || tileHeight <= 0) return FALSE;
    
    if (useFixedTileCount) {
        tileCount  = tileCountX * tileCountY;
        
        if (orientation == MAP_ORIENTATION_ISOMETRIC) {
            self.width  = (int)(tileWidth  * tileCountX * tileTiltFactorX * 2);
            self.height = (int)(self.width * 0.5f);
        } else {
            self.width  = (int)(tileWidth  * tileCountX * tileTiltFactorX);
            self.height = (int)(tileHeight * tileCountY * tileTiltFactorY);
        }
        
    } else {
        if (orientation != MAP_ORIENTATION_HEXAGONAL) {
            tileCountX = ceilf(width  / (tileWidth  * tileTiltFactorX));
            tileCountY = ceilf(height / (tileHeight * tileTiltFactorY));
        
            tileCount  = tileCountX * tileCountY;
        } else {
            tileCountX = ceilf(width  / (tileWidth  * tileTiltFactorX));
            tileCountY = ceilf(height / (tileHeight * tileTiltFactorY));
        
            tileCount = (tileCountX * tileCountY) - (tileCountY / 2);
        }
    }
    return TRUE;
}

-(void)onLoad {
    if (loaded) return;
    
    [super onLoad];
    
    if (tileWidth  == 0) tileWidth  = width;
    if (tileHeight == 0) tileHeight = height;
    
    if ([self updateTileCount]) {
        [self createQuadBuffer];
    }
}

-(void)reloadQuadBuffer {
    if (!loaded) return;
    
    @synchronized(beforeCommandQueue) {
        CommandBlock command = [^{
            if (quads)   free(quads);
            if (indices) free(indices);
            
            if ([self updateTileCount]) {
                [self createQuadBuffer];
            }
        } copy];
        
        [beforeCommandQueue push:command];
        [command release];
    }
}

-(void)onDispose {
    [super onDispose];
}

-(void)bindVertex {
    // overwrite parent function..to do nothing
}

/*
 * Returns TRUE if this map uses layered map
 * that uses depth buffer to order & render tiles but disables perspective view
 */
- (BOOL)useLayeredMap {
    return isTopLayer || isSubLayer;
}

-(void)drawFrame:(QuickTiGame2dEngine*)engine {
    
    @synchronized(beforeCommandQueue) {
        while ([beforeCommandQueue count] > 0) {
            ((CommandBlock)[beforeCommandQueue poll])();
        }
    }
    
    //
    // synchronize child layers position & scale
    //
    @synchronized (children) {
        for (QuickTiGame2dSprite* child in children) {
            child.x = self.x;
            child.y = self.y;
            child.scaleX = self.scaleX;
            child.scaleY = self.scaleY;
            child.scaleCenter = self.scaleCenter;
        }
    }
    
    @synchronized (transforms) {
        [self onTransform];
    }
    
    @synchronized (animations) {
        if (animating && [animations count] > 0) {
            for (NSString* name in animations) {
                double uptime = [QuickTiGame2dEngine uptime];
                QuickTiGame2dAnimationFrame* animation = [animations objectForKey:name];
                if ([animation getLastOnAnimationDelta:uptime] < animation.interval) {
                    continue;
                }
                int index = animation.nameAsInt;
                if (index >= 0) {
                    QuickTiGame2dMapTile* cctile = [self getTile:index];
                    QuickTiGame2dMapTile* updateTileCache = [[QuickTiGame2dMapTile alloc] init];
                    [updateTileCache indexcc:cctile];
                    
                    updateTileCache.gid = [animation getNextIndex:tileCount withIndex:updateTileCache.gid];
                    
                    [self setTile:index tile:updateTileCache];
                    
                    [updateTileCache release];
                }
                animation.lastOnAnimationInterval = uptime;
            }
        }
    }
    
    @synchronized (updatedTiles) {
        tileChanged = [updatedTiles count] > 0;
        if (tileChanged) {
            for (NSNumber* num in updatedTiles) {
                [self updateQuad:[num intValue] tile:[updatedTiles objectForKey:num]];
            }
            [updatedTiles removeAllObjects];
        }
    }
    
    if ([self useLayeredMap]) {
        [engine updateOrthoViewport];
        
        glDepthFunc(GL_LEQUAL);
        glEnable(GL_DEPTH_TEST);
        
        // Cut off alpha of sub layer to blend with top layer
        // sublayer should not use half-translucent alpha
        if (isSubLayer) {
            glEnable(GL_ALPHA_TEST);
            glAlphaFunc(GL_GREATER, 0.5);
        }
    }
    
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity(); 
    
    glEnableClientState(GL_COLOR_ARRAY);
    
    // unbind all buffers
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
	glBindBuffer(GL_ARRAY_BUFFER, 0);
	glBindTexture(GL_TEXTURE_2D, 0);
    	
    // update position
    glTranslatef(x * orthFactorX, y * orthFactorY, 0);
	
    // rotate angle, center x, center y, center z, axis
    glTranslatef(param_rotate[1], param_rotate[2], param_rotate[3]);
    if (param_rotate[4] == AXIS_X) {
        glRotatef(param_rotate[0], 1, 0, 0);
    } else if (param_rotate[4] == AXIS_Y) {
        glRotatef(param_rotate[0], 0, 1, 0);
    } else {
        glRotatef(param_rotate[0], 0, 0, 1);
    }
    glTranslatef(-param_rotate[1], -param_rotate[2], -param_rotate[3]);
	
    // scale param x, y, z, center x, center y, center z
    glTranslatef(param_scale[3], param_scale[4], param_scale[5]);
    glScalef(param_scale[0], param_scale[1], param_scale[2]);
    glTranslatef(-param_scale[3], -param_scale[4], -param_scale[5]);
    
	glBindBuffer(GL_ARRAY_BUFFER, verticesID);

    // Update the buffer when the tile data has been changed
    if (tileChanged) {
        glBufferSubData(GL_ARRAY_BUFFER, 0, 144 * tileCount, quads);
        tileChanged = FALSE;
    }
    
	// Configure the vertex pointer which will use the currently bound VBO for its data
    glVertexPointer(3, GL_FLOAT, 36, 0);
    glColorPointer(4, GL_FLOAT,  36,   (GLvoid*)(4 * 5));
    glTexCoordPointer(2, GL_FLOAT, 36, (GLvoid*)(4 * 3));
    
	if (hasTexture) {
        glEnable(GL_TEXTURE_2D);
        glBindTexture(GL_TEXTURE_2D, self.texture.textureId);
    }
	
    glBlendFunc(srcBlendFactor, dstBlendFactor);
	
    glDrawElements(GL_TRIANGLES, tileCount * 6, GL_UNSIGNED_SHORT, indices);
    
	glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    
    if ([self useLayeredMap]) {
        glDisable(GL_ALPHA_TEST);
        glDisable(GL_DEPTH_TEST);
        glDepthFunc(GL_LESS);
        
        [engine forceUpdateViewport];
    }
    
    glDisableClientState(GL_COLOR_ARRAY);
    
    @synchronized(afterCommandQueue) {
        while ([beforeCommandQueue count] == 0 && [afterCommandQueue count] > 0) {
            ((CommandBlock)[afterCommandQueue poll])();
        }
    }
    
}

-(NSInteger)getTileNumber:(QuickTiGame2dMapTile*)tile {
    return tile.gid - tile.firstgid - (self.firstgid - 1);
}

-(float)tex_coord_startX:(QuickTiGame2dMapTile*)tile {
    int tileNo = [self getTileNumber:tile];
    if ([tilesets count] > 1) {
        float awidth = tile.atlasWidth > 0 ? tile.atlasWidth : width;
        float twidth = tile.isOverwrap ? tile.overwrapWidth : tile.width > 0 ? tile.width : tileWidth;
        
        int xcount = (int)round((awidth - (tile.margin * 2) + tile.border) / (float)(twidth  + tile.border));
        int xindex = tileNo % xcount;

        float atlasX = tile.atlasX;
        if (tile.flip && tile.isOverwrap) {
            atlasX = (tile.overwrapAtlasX * 2) - tile.atlasX - tile.width + tile.overwrapWidth;
        }
        
        return atlasX + ((tile.border + twidth) * xindex) + tile.margin;
    } else {
        int xcount = (int)round((self.texture.width - (margin * 2) + border) / (float)(tileWidth  + border));
        int xindex = tileNo % xcount;
        
        return ((border + tileWidth) * xindex) + margin;
    }
}

-(float)tex_coord_startY:(QuickTiGame2dMapTile*)tile {
    int tileNo = [self getTileNumber:tile];
    
    if ([tilesets count] > 1) {
        float awidth  = tile.atlasWidth  > 0 ? tile.atlasWidth  : width;
        float aheight = tile.atlasHeight > 0 ? tile.atlasHeight : height;
        float twidth  = tile.isOverwrap ? tile.overwrapWidth  : tile.width  > 0 ? tile.width  : tileWidth;
        float theight = tile.isOverwrap ? tile.overwrapHeight : tile.height > 0 ? tile.height : tileHeight;
        int xcount = (int)round((awidth  - (tile.margin * 2) + tile.border) / (float)(twidth  + tile.border));
        int ycount = (int)round((aheight - (tile.margin * 2) + tile.border) / (float)(theight + tile.border));
        int yindex = [self flipY] ? ycount - (tileNo / xcount) - 1 : (tileNo / xcount);
                
        return tile.atlasY + ((tile.border + theight) * yindex) + tile.margin;
    } else {
        int xcount = (int)round((self.texture.width - (margin * 2) + border) / (float)(tileWidth  + border));
        int ycount = (int)round((self.texture.height - (margin * 2) + border) / (float)(tileHeight + border));
        int yindex = [self flipY] ? ycount - (tileNo / xcount) - 1 : (tileNo / xcount);
        
        return ((border + tileHeight) * yindex) + margin;
    }
}

-(float)tileCoordStartX:(QuickTiGame2dMapTile*)tile {
    return [self tex_coord_startX:tile] / (float)self.texture.glWidth + [self getTexelHalfX];
}

-(float)tileCoordEndX:(QuickTiGame2dMapTile*)tile {
    float twidth = tile.width > 0 ? tile.width : tileWidth;
    float value  = (float)([self tex_coord_startX:tile] + twidth) / (float)self.texture.glWidth - [self getTexelHalfX];
    
    return value > 1.0f ? 1.0f : value;
}

-(float)tileCoordStartY:(QuickTiGame2dMapTile*)tile {
    float theight = tile.height > 0 ? tile.height : tileHeight;
    float value   = (float)([self tex_coord_startY:tile] + theight) / (float)self.texture.glHeight - [self getTexelHalfY];
    
    return value > 1.0f ? 1.0f : value;
}

-(float)tileCoordEndY:(QuickTiGame2dMapTile*)tile {
    return [self tex_coord_startY:tile] / (float)self.texture.glHeight + [self getTexelHalfY];
}

- (void)createQuadBuffer {
    clearGLErrors(@"before createQuadBuffer");
    
    //
    // quad = ([vertex x, vertex y, vertex z, texture x, texture y, red, green, blue, alpha] * 4) = 9 * 4 * (float=4bytes) = 144 bytes
    //
    quads   = calloc(sizeof(float) * 9 * 4, tileCount);
    indices = calloc(sizeof(GLushort),   tileCount * 6);
    
    [tiles removeAllObjects];
    [updatedTiles removeAllObjects];
    
    for( int i = 0; i < tileCount; i++) {
		indices[i * 6 + 0] = i * 4 + 0;
		indices[i * 6 + 1] = i * 4 + 1;
		indices[i * 6 + 2] = i * 4 + 2;
		
		indices[i * 6 + 3] = i * 4 + 2;
		indices[i * 6 + 4] = i * 4 + 3;
		indices[i * 6 + 5] = i * 4 + 0;
        
		QuickTiGame2dMapTile* tile = [[QuickTiGame2dMapTile alloc] init];
        
        tile.alpha = 0;
        tile.index = i;
        
        [tiles addObject:tile];
        
        [self updateQuad:i tile:tile];
        
        [tile release];
	}

    //
	// initialize texture vertex
    //
    NSInteger index = 0;
    for(int ty = 0; ty < tileCountY; ty++) {
        for (int tx = 0; tx < tileCountX; tx++) {
            int vi = index * 36;
            
            if (orientation == MAP_ORIENTATION_ISOMETRIC) {
                float iso_startX = (tx * tileTiltFactorX  * tileWidth)  - (ty * tileTiltFactorX  * tileWidth);
                float iso_startY = (ty * tileTiltFactorY * tileHeight) + (tx * tileTiltFactorY * tileHeight);
                
                quads[vi + 0] = iso_startX;  // vertex  x
                quads[vi + 1] = iso_startY;  // vertex  y
                quads[vi + 2] = 0;           // vertex  z
                
                // -----------------------------
                quads[vi + 9] = iso_startX;               // vertex  x
                quads[vi + 10] = iso_startY + tileHeight; // vertex  y
                quads[vi + 11] = 0;                       // vertex z
                
                // -----------------------------
                quads[vi + 18] = iso_startX + tileWidth;  // vertex  x
                quads[vi + 19] = iso_startY + tileHeight; // vertex  y
                quads[vi + 20] = 0;                       // vertex z
                
                // -----------------------------
                quads[vi + 27] = iso_startX + tileWidth;  // vertex  x
                quads[vi + 28] = iso_startY;              // vertex  y
                quads[vi + 29] = 0;                       // vertex z
            } else if (orientation == MAP_ORIENTATION_HEXAGONAL) {
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
                quads[vi + 9] = hex_startX;               // vertex x
                quads[vi + 10] = hex_startY + tileHeight; // vertex y
                quads[vi + 11] = 0;                       // vertex z
                
                // -----------------------------
                quads[vi + 18] = hex_startX + tileWidth;  // vertex  x
                quads[vi + 19] = hex_startY + tileHeight; // vertex  y
                quads[vi + 20] = 0;                       // vertex z
                
                // -----------------------------
                quads[vi + 27] = hex_startX + tileWidth;  // vertex  x
                quads[vi + 28] = hex_startY;              // vertex  y
                quads[vi + 29] = 0;                       // vertex z

            } else {
                quads[vi + 0] = tx * tileWidth;  // vertex  x
                quads[vi + 1] = ty * tileHeight; // vertex  y
                quads[vi + 2] = 0;               // vertex  z
                
                // -----------------------------
                quads[vi + 9]  = (tx * tileWidth);                // vertex  x
                quads[vi + 10] = (ty * tileHeight) + tileHeight;  // vertex  y
                quads[vi + 11] = 0;                               // vertex  z
                
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
    
    // Generate the vertices VBO
    if (verticesID == 0) {
        glGenBuffers(1, &verticesID);
    }
    glBindBuffer(GL_ARRAY_BUFFER, verticesID);
    glBufferData(GL_ARRAY_BUFFER, 144 * tileCount, quads, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
	
    clearGLErrors(@"createQuadBuffer");
}

- (void)updateQuad:(NSInteger)index tile:(QuickTiGame2dMapTile*)cctile{
    if (index >= [tiles count]) return;
    
    int vi = index * 36;
    
    QuickTiGame2dMapTile* tile = [tiles objectAtIndex:index];
    [tile cc:cctile];
    
    if ([self getTileNumber:tile] < 0) tile.alpha = 0;
    
    float parentAlpha = [self alpha];
    
    quads[vi + 3] = tile.flip ? [self tileCoordEndX:tile] : [self tileCoordStartX:tile]; // texture x
    quads[vi + 4] = [self tileCoordEndY:tile]; // texture y
    
    quads[vi + 5] = tile.red * tile.alpha * parentAlpha;   // red
    quads[vi + 6] = tile.green * tile.alpha * parentAlpha; // green
    quads[vi + 7] = tile.blue * tile.alpha * parentAlpha;  // blue
    quads[vi + 8] = tile.alpha * parentAlpha; // alpha
    
    // -----------------------------
    quads[vi + 12] = tile.flip ? [self tileCoordEndX:tile] : [self tileCoordStartX:tile];
    quads[vi + 13] = [self tileCoordStartY:tile];
    
    quads[vi + 14] = tile.red * tile.alpha * parentAlpha;   // red
    quads[vi + 15] = tile.green * tile.alpha * parentAlpha; // green
    quads[vi + 16] = tile.blue * tile.alpha * parentAlpha;  // blue
    quads[vi + 17] = tile.alpha * parentAlpha; // alpha
    
    // -----------------------------
    quads[vi + 21] = tile.flip ? [self tileCoordStartX:tile] : [self tileCoordEndX:tile];
    quads[vi + 22] = [self tileCoordStartY:tile];
    
    quads[vi + 23] = tile.red * tile.alpha * parentAlpha;   // red
    quads[vi + 24] = tile.green * tile.alpha * parentAlpha; // green
    quads[vi + 25] = tile.blue * tile.alpha * parentAlpha;  // blue
    quads[vi + 26] = tile.alpha * parentAlpha; // alpha
    
    // -----------------------------
    
    quads[vi + 30] = tile.flip ? [self tileCoordStartX:tile] : [self tileCoordEndX:tile];
    quads[vi + 31] = [self tileCoordEndY:tile];
    
    quads[vi + 32] = tile.red * tile.alpha * parentAlpha;   // red
    quads[vi + 33] = tile.green * tile.alpha * parentAlpha; // green
    quads[vi + 34] = tile.blue * tile.alpha * parentAlpha;  // blue
    quads[vi + 35] = tile.alpha * parentAlpha; // alpha
    
    if (tile.width > 0 && tile.height > 0) {
        
        if (!tile.positionFixed) {
            tile.initialX = quads[vi + 0];
            tile.initialY = quads[vi + 1];
            tile.positionFixed = TRUE;
        }
        
        float tilez = ![self useLayeredMap] ? 0 : tile.alpha > 0 ? index : -1;
        
        quads[vi + 0] = tile.initialX + tile.offsetX;  // vertex  x
        quads[vi + 1] = tile.initialY + tile.offsetY;  // vertex  y
        quads[vi + 2] = tilez;                         // vertex  z
            
        quads[vi + 9]  = tile.initialX + tile.offsetX; // vertex  x
        quads[vi + 10] = quads[vi + 1] + tile.height;  // vertex  y
        quads[vi + 11] = tilez;                        // vertex  z
        // -----------------------------
        
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

-(NSInteger)getChildTileRowCount:(QuickTiGame2dMapTile*)tile {
    return (NSInteger)(tile.width / tileWidth);
}

-(NSInteger)getTileRowCount:(QuickTiGame2dMapTile*)tile {
    if (tile.rowCount <= 0) {
        return [self getChildTileRowCount:tile];
    } else {
        return tile.rowCount;
    }
}

-(NSInteger)getTileColumnCount:(QuickTiGame2dMapTile*)tile {
    if (tile.columnCount <= 0) {
        return [self getChildTileRowCount:tile];
    } else {
        return tile.columnCount;
    }
}

-(BOOL)isHalfTile:(QuickTiGame2dMapTile*)tile {
    NSInteger row    = [self getTileRowCount:tile];
    NSInteger column = [self getTileColumnCount:tile];
    
    return (row > 1 || column > 1) && (row != column);
}

/*
 * check if this tile consists of multiple tiles
 * this assumes tile has same tile count for X&Y axis (2x2, 3x3, 4x4)
 */
-(BOOL)hasChild:(QuickTiGame2dMapTile*)tile {
    return [self getChildTileRowCount:tile] > 1;
}

- (void)updateGIDProperties:(NSDictionary*)info firstgid:(NSInteger)_firstgid {
    for (id key in info) {
        int gid = _firstgid + [key intValue];
        [gidproperties setObject:[info objectForKey:key] forKey:[NSNumber numberWithInt:gid]];
    }
}

-(void)updateTileProperty:(QuickTiGame2dMapTile*)tile {
    // Update tile properties
    if ([tilesets count] > 0) {
        if (tile.gid <= 0) {
            tile.image = [[tilesetgids objectAtIndex:0] objectForKey:@"image"];
        } else if (tile.image == nil) {
            for (id gids in tilesetgids) {
                NSInteger tsgid = [[gids objectForKey:@"firstgid"] intValue];
                if (tsgid > tile.gid) {
                    break;
                }
                tile.image = [gids objectForKey:@"image"];
            }
        }
        
        if (tile.image != nil) {
            NSDictionary* prop = [tilesets objectForKey:tile.image];
            
            tile.width  = [[prop objectForKey:@"tilewidth"]  floatValue];
            tile.height = [[prop objectForKey:@"tileheight"] floatValue];
            tile.firstgid = [[prop objectForKey:@"firstgid"] intValue];
            tile.margin = [[prop objectForKey:@"margin"] floatValue];
            tile.border = [[prop objectForKey:@"border"] floatValue];
            
            tile.offsetX  = [[prop objectForKey:@"offsetX"]  floatValue];
            tile.offsetY  = [[prop objectForKey:@"offsetY"]  floatValue];
            
            tile.atlasX = [[prop objectForKey:@"atlasX"] floatValue];
            tile.atlasY = [[prop objectForKey:@"atlasY"] floatValue];
            tile.atlasWidth  = [[prop objectForKey:@"atlasWidth"] floatValue];
            tile.atlasHeight = [[prop objectForKey:@"atlasHeight"] floatValue];
            
            tile.rowCount    = [[prop objectForKey:@"rowCount"] intValue];
            tile.columnCount = [[prop objectForKey:@"columnCount"] intValue];
        }
    }
}

-(BOOL)isTileSpaceUsed:(QuickTiGame2dMapTile*)tile row:(NSInteger)row column:(NSInteger)column {
    if (tile == nil) return FALSE;
    
    NSInteger targetColumn = tile.flip ? row : column;
    NSInteger targetRow    = tile.flip ? column : row;
    
    if (tile.columnCount > 0 && tile.columnCount <= targetColumn) {
        return FALSE;
    }
    if (tile.rowCount > 0 && tile.rowCount <= targetRow) {
        return FALSE;
    }
    
    return TRUE;
}

-(BOOL)canUpdate:(NSInteger)index tile:(QuickTiGame2dMapTile*)tile {
    if ([self getChildTileRowCount:tile] < 2) return TRUE;
    
    int rowCount    = tile.flip ? tile.columnCount : tile.rowCount;
    int columnCount = tile.flip ? tile.rowCount : tile.columnCount;
    
    for (int row = 0; row < rowCount; row++) {
        for (int column = 0; column < columnCount; column++) {
            if (row == 0 && column == 0) continue;
            
            QuickTiGame2dMapTile* target = [self getTile:index + column + (row * tileCountX)];
            if (target == nil) continue;
            
            if (target.isChild) {
                if (target.parent == index) {
                    continue;
                } else {
                    return FALSE;
                }
            } else if (target.gid > 0) {
                return FALSE;
            } else if ([self hasChild:target]) {
                return FALSE;
            }
        }
    }
    
    return TRUE;
}

-(BOOL)setTile:(NSInteger)index tile:(QuickTiGame2dMapTile*)tile {
    
    if ([self getTile:index].isChild) {
        NSLog(@"[DEBUG] Tile %d can not be replaced because it is part of multiple tiles.", index);
        return FALSE;
    }
    
    [self updateTileProperty:tile];
    
    if (![self canUpdate:index tile:tile]) {
        NSLog(@"[DEBUG] Tile %d can not be replaced because another tile is found.", index);
        return FALSE;
    }
    
    // check if this tile consists of multiple tiles
    // this assumes tile has same tile count for X&Y axis (2x2, 3x3, 4x4)
    int childRowCount = [self getChildTileRowCount:tile];
    if (childRowCount >= 2) {

        // Fill out neighboring tile with empty tile
        for (int row = 0; row < childRowCount; row++) {
            for (int column = 1; column < childRowCount; column++) {
                
                int index2 = index + column + (row * tileCountX);
                QuickTiGame2dMapTile* target = [self getTile:index2];
                QuickTiGame2dMapTile* neighbor = [[QuickTiGame2dMapTile alloc] init];
                
                if (target != nil) {
                    [neighbor cc:target];
                }
                
                [self updateTileProperty:neighbor];
                
                neighbor.index = index2;
                neighbor.isChild = TRUE;
                neighbor.suppressUpdate = TRUE;
                neighbor.alpha = 0;
                neighbor.parent = index;
                neighbor.gid = tile.gid;
                
                if (![self isTileSpaceUsed:tile row:row column:column]) {
                    // Clear neighboring tile that is not used
                    if (target != nil && target.parent == index) {
                        [neighbor clearViewProperty:self];
                    } else {
                        [neighbor release];
                        continue;
                    }
                }
                
                @synchronized (updatedTiles) {
                    [updatedTiles setObject:neighbor forKey:[NSNumber numberWithInt:neighbor.index]];
                }
                
                [neighbor release];
            }
        }
        
        float baseTileHeight = tileWidth * 0.5f;
        float baseTileMargin = tile.height - (childRowCount * baseTileHeight);
        for (int i = 1; i < childRowCount; i++) {
            
            QuickTiGame2dMapTile* tile2 = [[QuickTiGame2dMapTile alloc] init];
            
            [tile2 cc:tile];
            
            tile2.index    = index + (i * tileCountX);
            
            QuickTiGame2dMapTile* target2 = [self getTile:tile2.index];
            if (target2 != nil) {
                tile2.initialX = target2.initialX;
                tile2.initialY = target2.initialY;
            } else {
                tile2.positionFixed = FALSE;
            }
            
            tile2.width    = tileWidth;
            tile2.height   = baseTileHeight + baseTileMargin;
            tile2.atlasX   = tile.atlasX + ((childRowCount - i - 1) * tileWidth * 0.5f);
            tile2.atlasY   = tile.atlasY + (baseTileHeight * 0.5f) * i;
            
            tile2.overwrapWidth  = tile.width;
            tile2.overwrapHeight = tile.height;
            tile2.overwrapAtlasX = tile.atlasX;
            tile2.overwrapAtlasY = tile.atlasY;
            tile2.isOverwrap      = TRUE;
            tile2.isChild         = TRUE;
            tile2.offsetX = -tileWidth * 0.5f;
            tile2.offsetY = tile.offsetY;
            tile2.parent  = index;
            
            tile2.suppressUpdate = TRUE;
            
            if (![self isTileSpaceUsed:tile row:i column:0]) {
                if (target2.parent == index) {
                    [tile2 clearViewProperty:self];
                    tile2.alpha = 0;
                    tile2.suppressUpdate = FALSE;
                } else {
                    [tile2 release];
                    continue;
                }
            }
            
            @synchronized (updatedTiles) {
                [updatedTiles setObject:tile2 forKey:[NSNumber numberWithInt:tile2.index]];
            }
            
            [tile2 release];
        }
    }
    
    @synchronized (updatedTiles) {
        [updatedTiles setObject:tile forKey:[NSNumber numberWithInt:index]];
    }
    
    return TRUE;
}

-(void)setTiles:(NSArray*)data {
    
    [self reloadQuadBuffer];
    
    @synchronized(beforeCommandQueue) {
        CommandBlock command = [^{
            for (int i = 0; i < [data count]; i++) {
                
                QuickTiGame2dMapTile* overwrap = [updatedTiles objectForKey:[NSNumber numberWithInt:i]];
                if (overwrap != nil && overwrap.suppressUpdate) {
                    overwrap.suppressUpdate = FALSE;
                    continue;
                }
                
                QuickTiGame2dMapTile* tile = [[QuickTiGame2dMapTile alloc] init];
                tile.gid = [[data objectAtIndex:i] intValue];
                tile.alpha = 1;
                tile.index = i;
                
                [self setTile:i tile:tile];
                
                [tile release];
            }
        } copy];
        
        [beforeCommandQueue push:command];
        [command release];
    }

}

-(void)updateImageSize {
    // map width and height should be updated manually!
}

-(BOOL)removeTile:(NSInteger)index {
    if (index >= [tiles count]) return FALSE;
    
    QuickTiGame2dMapTile* target = [self getTile:index];
    if (target == nil) return FALSE;
    
    if (target.isChild) {
        NSLog(@"[DEBUG] Tile %d can not be removed because it is part of multiple tiles.", index);
        return FALSE;
    }
    
    // check if this tile consists of multiple tiles
    // this assumes tile has same tile count for X&Y axis (2x2, 3x3, 4x4)
    NSInteger childRowCount = [self getChildTileRowCount:target];
    // Fill out neighboring tile with empty tile
    for (int row = 0; row < childRowCount; row++) {
        for (int column = 0; column < childRowCount; column++) {
            
            QuickTiGame2dMapTile* target2 = [self getTile:index + column + (row * tileCountX)];
            if (target2 == nil) continue;
            
            if (target2.index != index && (!target2.isChild || target2.parent != index)) {
                continue;
            }
            
            QuickTiGame2dMapTile* tile2 = [[QuickTiGame2dMapTile alloc] init];
            [tile2 indexcc:target2];
            
            [tile2 clearViewProperty:self];
            tile2.alpha  = 0;
            
            @synchronized (updatedTiles) {
                [updatedTiles setObject:tile2 forKey:[NSNumber numberWithInt:tile2.index]];
            }
            
            [tile2 release];
        }
    }
    
    return TRUE;
}

-(BOOL)flipTile:(NSInteger)index {
    if (index < 0 || index >= [tiles count]) return FALSE;
    
    QuickTiGame2dMapTile* tile = [tiles objectAtIndex:index];
    tile.flip = !tile.flip;
    
    @synchronized (updatedTiles) {
        [updatedTiles setObject:tile forKey:[NSNumber numberWithInt:index]];
    }
    
    return TRUE;
}

-(BOOL)collidesIsometric:(float)otherX otherY:(float)otherY withTile:(QuickTiGame2dMapTile*) tile {
    otherX = otherX - tileOffsetX - tile.initialX;
    otherY = otherY - (tileHeight * tileTiltFactorY) - tile.initialY;
    
    float dHeight = tileHeight - (tileHeight * tileTiltFactorY);
    float ratio = MIN(tileWidth, dHeight) / MAX(tileWidth, dHeight);
    float rHeight = dHeight * ratio;
    
    float a1 = (ratio * otherX) - rHeight;
    float a2 = (ratio * otherX) + rHeight;
    float a3 = -(ratio * otherX) + rHeight;
    float a4 = -(ratio * otherX) + (3 * rHeight);
    
    return (otherY > a1 && otherY < a2 && otherY > a3 && otherY < a4);
}

/*
 * Get tiles from position of the screen
 */
-(QuickTiGame2dMapTile*)getTileAtPosition:(float)sx sy:(float)sy {

    float posX = (sx - x)  / self.scaleX;
    float posY = (sy - y)  / self.scaleY;
    
    float tiltStepX = (tileWidth  * tileTiltFactorX);
    float tiltStepY = (tileHeight * tileTiltFactorY);
    
    if (orientation == MAP_ORIENTATION_ISOMETRIC) {
        
        //
        // poor implementation but this is enough this time
        //
        NSInteger localX = ((int)(posX / tiltStepX)) * tiltStepX;
        NSInteger localY = ((int)(posY / tiltStepY)) * tiltStepY - tiltStepY;
        
        float a = localX / tileTiltFactorX / tileWidth;
        float b = localY / tileTiltFactorY / tileHeight;
        
        int indexX = (int)floor((a + b) / 2);
        int indexY = (int)floor(indexX - a);
        
        QuickTiGame2dMapTile* tile = [self getTile:(indexX + (tileCountX * indexY))];
        
        if (tile != nil && [self collidesIsometric:posX otherY:posY withTile:tile]) {
            return tile;
        }
        
        //
        // Check other tiles around because tiles can be overwrapped
        //
        tile = [self getTile:((indexX + 1) + (tileCountX * indexY))];
        if (tile != nil && [self collidesIsometric:posX otherY:posY withTile:tile]) {
            return tile;
        }
        
        tile = [self getTile:(indexX + (tileCountX * (indexY + 1)))];
        if (tile != nil && [self collidesIsometric:posX otherY:posY withTile:tile]) {
            return tile;
        }
        
        tile = [self getTile:(indexX + (tileCountX * (indexY - 1)))];
        if (tile != nil && [self collidesIsometric:posX otherY:posY withTile:tile]) {
            return tile;
        }
        
        tile = [self getTile:((indexX - 1) + (tileCountX * indexY))];
        if (tile != nil && [self collidesIsometric:posX otherY:posY withTile:tile]) {
            return tile;
        }
        
        return nil;
        
    } else {
        int indexX = posX / tiltStepX;
        int indexY = posY / tiltStepY;
        
        return [self getTile:(indexX + (tileCountX * indexY))];
    }
    
    return nil;
}

-(QuickTiGame2dMapTile*)getTile:(NSInteger)index {
    if (index < 0 || index >= [tiles count]) return nil;
    
    return [tiles objectAtIndex:index];
}

-(NSArray*)getTiles {
    NSMutableArray* data = [[NSMutableArray alloc] init];
    
    if ([tiles count] == 0) {
        for (int i = 0; i < [updatedTiles count]; i++) {
            [data addObject:[NSNumber numberWithInt:-1]];
        }
        for (NSNumber* num in updatedTiles) {
            [data replaceObjectAtIndex:[num intValue] withObject: 
                [NSNumber numberWithInt:((QuickTiGame2dMapTile*)[updatedTiles objectForKey:num]).gid]];
        }
    } else {
        for (int i = 0; i < [tiles count]; i++) {
            QuickTiGame2dMapTile* tile = [tiles objectAtIndex:i];
            [data addObject:[NSNumber numberWithInt:tile.gid]];
        }
    }
    
    
    return [data autorelease];
}

-(void)setAlpha:(float)alpha {
    [super setAlpha:alpha];
    
    // Update all tiles to reload buffers
    @synchronized (updatedTiles) {
        for (int i = 0; i < [tiles count]; i++) {
                [updatedTiles setObject:[tiles objectAtIndex:i] forKey:[NSNumber numberWithInt:i]];
        }
    }
}

-(void)setOrientation:(NSInteger)value {
    orientation = value;
    
    if (orientation == MAP_ORIENTATION_ISOMETRIC) {
        tileTiltFactorX = 0.5f;
        tileTiltFactorY = 0.25f;
    } else if (orientation == MAP_ORIENTATION_HEXAGONAL) {
        tileTiltFactorX = 0.5f;
        tileTiltFactorY = 0.75f;
    } else {
        tileTiltFactorX = 1.0f;
        tileTiltFactorY = 1.0f;
    }
}

-(NSInteger)orientation {
    return orientation;
}

-(void)addTileset:(NSDictionary*)prop {

    NSArray* checker = [NSArray arrayWithObjects:
            @"image", @"tilewidth", @"tileheight", @"offsetX", @"offsetY",
            @"firstgid", @"margin", @"border", @"atlasX",
            @"atlasY", @"atlasWidth", @"atlasHeight", nil];

    for (id key in checker) {
        if ([prop objectForKey:key] == nil) {
            NSLog(@"[ERROR] '%@' property not found for tileset", key);
            return;
        }
    }
    
    if ([tilesets count] == 0) {
        self.tileWidth  = [[prop objectForKey:@"tilewidth"]  floatValue];
        self.tileHeight = [[prop objectForKey:@"tileheight"] floatValue];
        self.tileOffsetX =[[prop objectForKey:@"offsetX"] floatValue];
        self.tileOffsetY =[[prop objectForKey:@"offsetY"] floatValue];
    }
    
    [tilesetgids addObject:[NSDictionary dictionaryWithObjectsAndKeys:
            [prop objectForKey:@"firstgid"], @"firstgid",
            [prop objectForKey:@"image"], @"image",
            nil]];
    [tilesets setObject:prop forKey:[prop objectForKey:@"image"]];
}

-(NSDictionary*)tilesets {
    return tilesets;
}

// disable frame animation
-(BOOL)setFrameIndex:(NSInteger)index force:(BOOL)force {
    return true;
}

-(void)animateTile:(NSInteger)tileIndex start:(NSInteger)start count:(NSInteger)count interval:(NSInteger)interval loop:(NSInteger)loop {
    QuickTiGame2dAnimationFrame* animation = [[QuickTiGame2dAnimationFrame alloc] init];
    
    animation.name  = [NSString stringWithFormat:@"%d", tileIndex];
    [animation updateNameAsInt];
    animation.start = start;
    animation.count = count;
    animation.interval = interval;
    animation.loop     = loop;
    
    [self addAnimation:animation];
    
    [animation release];
    
    animating = TRUE;
}

-(void)animateTile:(NSInteger)tileIndex frames:(NSArray*)frames interval:(NSInteger)interval {
    [self animateTile:tileIndex frames:frames interval:interval loop:0];
}

-(void)animateTile:(NSInteger)tileIndex frames:(NSArray*)frames interval:(NSInteger)interval loop:(NSInteger)loop {
    QuickTiGame2dAnimationFrame* animation = [[QuickTiGame2dAnimationFrame alloc] init];
    
    animation.name  = [NSString stringWithFormat:@"%d", tileIndex];
    [animation updateNameAsInt];
    animation.count = [frames count];
    animation.interval = interval;
    animation.loop     = loop;
    
    if ([frames count] > 0) {
        animation.start = [[frames objectAtIndex:0] intValue];
    }
    
    [animation initializeIndividualFrames];
    for (int i = 0; i < [frames count]; i++) {
        [animation setFrame:i withValue:[[frames objectAtIndex:i] intValue]];
    }
    
    [self addAnimation:animation];
    
    [animation release];
    
    animating = TRUE;
}

-(float)defaultX:(QuickTiGame2dMapTile*)tile {
    return self.x + tile.initialX * self.scaleX;
}

-(float)defaultY:(QuickTiGame2dMapTile*)tile {
    return self.y + tile.initialY * self.scaleY;
}

-(float)screenX:(QuickTiGame2dMapTile*)tile {
    return self.x + (tile.initialX + tile.offsetX) * self.scaleX;
}

-(float)screenY:(QuickTiGame2dMapTile*)tile {
    return self.y + (tile.initialY + tile.offsetY) * self.scaleY;
}

-(float)scaledTileWidth {
    return self.tileWidth  * self.scaleX;
}

-(float)scaledTileHeight {
    return self.tileHeight * self.scaleY;
}

-(float)scaledTileWidth:(QuickTiGame2dMapTile*)tile {
    return tile.width * self.scaleX;
}

-(float)scaledTileHeight:(QuickTiGame2dMapTile*)tile {
    return tile.height * self.scaleY;
}

-(void)updateMapSize:(NSInteger)_x ycount:(NSInteger)_y {
    tileCountX = _x;
    tileCountY = _y;
    
    useFixedTileCount = TRUE;
    [self updateTileCount];
}
@end
