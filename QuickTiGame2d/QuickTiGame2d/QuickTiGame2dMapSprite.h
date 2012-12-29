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
#import "QuickTiGame2dSprite.h"
#import "QuickTiGame2dParticlesTypes.h"

@interface QuickTiGame2dMapSprite : QuickTiGame2dSprite {
    GLfloat   *quads;
    GLushort  *indices;
    
    NSMutableArray* tiles;
    NSMutableDictionary* updatedTiles;
    
	float tileWidth;
	float tileHeight;
    
    GLuint tileCount;
    NSInteger tileCountX;
    NSInteger tileCountY;
    
	GLuint verticesID;
    
    BOOL tileChanged;
    
    NSInteger firstgid;
    
    NSInteger orientation;
    
    float tileTiltFactorX;
    float tileTiltFactorY;
    
    NSMutableArray* tilesetgids;
    NSMutableDictionary* tilesets;
    NSMutableDictionary* gidproperties;
    
    float tileOffsetX;
    float tileOffsetY;
    
    BOOL useFixedTileCount;
    
    BOOL isTopLayer;
    BOOL isSubLayer;
}
@property (readwrite) float tileWidth;
@property (readwrite) float tileHeight;
@property (readonly)  GLuint tileCount;
@property (readonly)  NSInteger tileCountX;
@property (readonly)  NSInteger tileCountY;
@property (readwrite) NSInteger firstgid;
@property (readwrite) NSInteger orientation;
@property (readwrite) float tileTiltFactorX;
@property (readwrite) float tileTiltFactorY;
@property (readwrite) float tileOffsetX;
@property (readwrite) float tileOffsetY;
@property (readonly)  NSMutableDictionary* gidproperties;
@property (readwrite) BOOL isTopLayer;
@property (readwrite) BOOL isSubLayer;

-(void)onLoad;
-(void)bindVertex;
-(void)drawFrame:(QuickTiGame2dEngine*)engine;
-(void)onDispose;

-(BOOL)updateTileCount;

-(NSArray*)getTiles;
-(QuickTiGame2dMapTile*)getTileAtPosition:(float)sx sy:(float)sy;
-(QuickTiGame2dMapTile*)getTile:(NSInteger)index;
-(BOOL)setTile:(NSInteger)index tile:(QuickTiGame2dMapTile*)tile;
-(void)setTiles:(NSArray*)data;
-(BOOL)removeTile:(NSInteger)index;
-(BOOL)flipTile:(NSInteger)index;
-(void)addTileset:(NSDictionary*)prop;
-(NSDictionary*)tilesets;
-(BOOL)setFrameIndex:(NSInteger)index force:(BOOL)force;
-(void)animateTile:(NSInteger)tileIndex start:(NSInteger)start
        count:(NSInteger)count interval:(NSInteger)interval loop:(NSInteger)loop;
-(void)animateTile:(NSInteger)tileIndex frames:(NSArray*)frames interval:(NSInteger)interval;
-(void)animateTile:(NSInteger)tileIndex frames:(NSArray*)frames interval:(NSInteger)interval loop:(NSInteger)loop;

-(float)defaultX:(QuickTiGame2dMapTile*)tile;
-(float)defaultY:(QuickTiGame2dMapTile*)tile;

-(float)screenX:(QuickTiGame2dMapTile*)tile;
-(float)screenY:(QuickTiGame2dMapTile*)tile;

-(float)scaledTileWidth;
-(float)scaledTileHeight;

-(float)scaledTileWidth:(QuickTiGame2dMapTile*)tile;
-(float)scaledTileHeight:(QuickTiGame2dMapTile*)tile;

-(BOOL)hasChild:(QuickTiGame2dMapTile*)tile;
-(NSInteger)getTileRowCount:(QuickTiGame2dMapTile*)tile;
-(NSInteger)getTileColumnCount:(QuickTiGame2dMapTile*)tile;

- (BOOL)canUpdate:(NSInteger)index tile:(QuickTiGame2dMapTile*)tile;

- (void)updateGIDProperties:(NSDictionary*)info firstgid:(NSInteger)firstgid;
- (void)updateMapSize:(NSInteger)_x ycount:(NSInteger)_y;
@end
