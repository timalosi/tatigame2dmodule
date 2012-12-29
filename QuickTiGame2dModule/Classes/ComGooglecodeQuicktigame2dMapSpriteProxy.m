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
#import "ComGooglecodeQuicktigame2dMapSpriteProxy.h"
#import "TiUtils.h"

@interface ComGooglecodeQuicktigame2dMapSpriteProxy (PrivateMethods) {    
}
-(void)updateTileInfoProxyCache:(NSMutableDictionary*)dic tile:(QuickTiGame2dMapTile*)tile;
@end

@implementation ComGooglecodeQuicktigame2dMapSpriteProxy

- (id)init {
    self = [super init];
    if (self != nil) {
        // we don't want parent sprite instance so release it here.
        [sprite release];
        
        // create our particles instance
        sprite = [[QuickTiGame2dMapSprite alloc] init];
        
        tileInfoCache = [[NSMutableDictionary alloc] init];
        mapSizeInfoCache  = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)dealloc {
    [tileInfoCache release];
    [mapSizeInfoCache release];
    [super dealloc];
}

/*
 * notification event that is issued by game engine
 * onload, ongainedfocus, enterframe, onlostfocus, ondispose
 */
- (void)onNotification:(NSString*)type userInfo:(NSDictionary*)userInfo {
    
    if ([type isEqualToString:@"onload"]) {
        if (sprite.width  == 0) sprite.width  = [[userInfo objectForKey:@"width"]  intValue];
        if (sprite.height == 0) sprite.height = [[userInfo objectForKey:@"height"] intValue];
    }
    
    [super onNotification:type userInfo:userInfo];
}

-(QuickTiGame2dMapSprite*)mapsprite {
    return (QuickTiGame2dMapSprite*)sprite;
}

#pragma Public APIs

-(id)isSubLayer {
    return NUMBOOL([self mapsprite].isSubLayer);
}

-(void)setIsSubLayer:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [self mapsprite].isSubLayer = [value boolValue];
}

-(id)isTopLayer {
    return NUMBOOL([self mapsprite].isTopLayer);
}

-(void)setIsTopLayer:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [self mapsprite].isTopLayer = [value boolValue];
}

-(id)getTileAtPosition:(id)args {
    float sx = [[args objectAtIndex:0] floatValue]; 
    float sy = [[args objectAtIndex:1] floatValue];
    
    QuickTiGame2dMapTile* tile = [[self mapsprite] getTileAtPosition:sx sy:sy];
    
    if (tile != nil) {
        [self updateTileInfoProxyCache:tileInfoCache tile:tile];
    } else {
        return nil;
    }
    
    return tileInfoCache;
}

-(void)updateTileInfoProxyCache:(NSMutableDictionary*)dic tile:(QuickTiGame2dMapTile*)tile {
    QuickTiGame2dMapSprite* mapSprite = [self mapsprite];
    
    [dic setValue:NUMINT(tile.index)    forKey:@"index"];
    [dic setValue:NUMINT(tile.gid)      forKey:@"gid"];
    [dic setValue:NUMFLOAT(tile.red)    forKey:@"red"];
    [dic setValue:NUMFLOAT(tile.green)  forKey:@"green"];
    [dic setValue:NUMFLOAT(tile.blue)   forKey:@"blue"];
    [dic setValue:NUMFLOAT(tile.alpha)  forKey:@"alpha"];
    [dic setValue:NUMBOOL(tile.flip)    forKey:@"flip"];
    [dic setValue:NUMBOOL(tile.isChild) forKey:@"isChild"];
    [dic setValue:NUMBOOL([mapSprite hasChild:tile]) forKey:@"hasChild"];
    [dic setValue:NUMINT([mapSprite getTileRowCount:tile]) forKey:@"rowCount"];
    [dic setValue:NUMINT([mapSprite getTileColumnCount:tile]) forKey:@"columnCount"];
    [dic setValue:NUMINT(tile.parent)   forKey:@"parent"];
    [dic setValue:NUMFLOAT([mapSprite screenX:tile]) forKey:@"x"];
    [dic setValue:NUMFLOAT([mapSprite screenY:tile]) forKey:@"y"];
    [dic setValue:NUMFLOAT([mapSprite defaultX:tile]) forKey:@"defaultX"];
    [dic setValue:NUMFLOAT([mapSprite defaultY:tile]) forKey:@"defaultY"];
    
    [dic setValue:NUMFLOAT(tile.width  > 0 ? 
                           [mapSprite scaledTileWidth:tile]  : [mapSprite scaledTileWidth])
                           forKey:@"width"];
    [dic setValue:NUMFLOAT(tile.height > 0 ? 
                           [mapSprite scaledTileHeight:tile] : [mapSprite scaledTileHeight])
                           forKey:@"height"];
    [dic setValue:NUMFLOAT(tile.margin)  forKey:@"margin"];
    [dic setValue:NUMFLOAT(tile.border)  forKey:@"border"];
    
    NSDictionary* properties = [mapSprite.gidproperties objectForKey:[NSNumber numberWithInt:tile.gid]];
     
    if (properties != nil) {
        [dic setObject:properties forKey:@"properties"];
    } else {
        [dic removeObjectForKey:@"properties"];
    }
}

-(id)getTile:(id)args {
    ENSURE_SINGLE_ARG(args, NSNumber);
    NSInteger index = [args intValue];
    
    QuickTiGame2dMapTile*  tile = [[self mapsprite] getTile:index];
    
    if (tile != nil) {
        [self updateTileInfoProxyCache:tileInfoCache tile:tile];
    } else {
        return nil;
    }
    
    return tileInfoCache;
}

-(id)canUpdate:(id)args {
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSInteger index  = [TiUtils intValue:@"index"  properties:args def:-1];
    
    QuickTiGame2dMapSprite* mapSprite = [self mapsprite];
    QuickTiGame2dMapTile* target = [mapSprite getTile:index];
    if (target == nil) return NUMBOOL(TRUE);
    
    QuickTiGame2dMapTile* tile = [[[QuickTiGame2dMapTile alloc] init] autorelease];
    [tile indexcc:target];
    
    if ([args objectForKey:@"flip"] != nil) {
        tile.flip = [TiUtils boolValue:@"flip" properties:args def:tile.flip];
    }

    return NUMBOOL([mapSprite canUpdate:index tile:tile]);
}

-(id)updateTile:(id)args {
    ENSURE_SINGLE_ARG(args, NSDictionary);
    
    NSInteger index  = [TiUtils intValue:@"index"  properties:args  def:-1];
    NSInteger gid    = [TiUtils intValue:@"gid"    properties:args  def:-1];
    float     red    = [TiUtils floatValue:@"red"    properties:args  def:-1];
    float     green  = [TiUtils floatValue:@"green"  properties:args  def:-1];
    float     blue   = [TiUtils floatValue:@"blue"   properties:args  def:-1];
    float     alpha  = [TiUtils floatValue:@"alpha"  properties:args  def:-1];
    
    QuickTiGame2dMapSprite* mapSprite = [self mapsprite];
    QuickTiGame2dMapTile* target = [mapSprite getTile:index];
    
    if (target == nil) return NUMBOOL(FALSE);
    
    QuickTiGame2dMapTile* tile = [[QuickTiGame2dMapTile alloc] init];
    [tile cc:target];
    
    if (gid   >= 0) tile.gid   = gid;
    if (red   >= 0) tile.red   = red;
    if (green >= 0) tile.green = green;
    if (blue  >= 0) tile.blue  = blue;
    if (alpha >= 0) tile.alpha = alpha;
    
    if ([args objectForKey:@"flip"] != nil) {
        tile.flip = [TiUtils boolValue:@"flip"  properties:args def:FALSE];
    }
    
    BOOL isUpdated = [mapSprite setTile:index tile:tile];
    
    [tile release];
    
    return NUMBOOL(isUpdated);
}

-(id)updateTiles:(id)args {
    if ([[args objectAtIndex:0] isKindOfClass:[NSDictionary class]]) {
        NSMutableArray* data = [[NSMutableArray alloc] init];
        
        for (NSDictionary* value in args) {
            [data addObject:[value objectForKey:@"gid"]];
        }
        
        [[self mapsprite] setTiles:data];
        
        [data release];
    } else {
        [[self mapsprite] setTiles:args];
    }
    
    return NUMBOOL(TRUE);
}

-(id)removeTile:(id)args {
    ENSURE_SINGLE_ARG(args, NSNumber);
    NSInteger index = [args intValue];
    
    return NUMBOOL([[self mapsprite] removeTile:index]);
}

-(id)setTile:(id)args {
    return [self updateTile:args];
}

-(id)flipTile:(id)args {
    ENSURE_SINGLE_ARG(args, NSNumber);
    NSInteger index = [args intValue];
    
    return NUMBOOL([[self mapsprite] flipTile:index]);
}

- (id)border {
    return NUMINT(sprite.border);
}

- (void)setBorder:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    sprite.border = [value intValue];
}

- (id)margin {
    return NUMINT(sprite.margin);
}

- (void)setMargin:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    sprite.margin = [value intValue];
}

- (id)tileWidth {
    return NUMINT([self mapsprite].tileWidth);
}

- (void)setTileWidth:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [self mapsprite].tileWidth = [value intValue];
    [[self mapsprite] updateTileCount];
}

- (id)tileHeight {
    return NUMINT([self mapsprite].tileHeight);
}

- (void)setTileHeight:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [self mapsprite].tileHeight = [value intValue];
    [[self mapsprite] updateTileCount];
}

- (id)firstgid {
    return NUMINT([self mapsprite].firstgid);
}

- (void)setFirstgid:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [self mapsprite].firstgid = [value intValue];
}

- (id)orientation {
    return NUMINT([self mapsprite].orientation);
}

- (void)setOrientation:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [self mapsprite].orientation = [value intValue];
    [[self mapsprite] updateTileCount];
}

- (id)mapSize {
    [mapSizeInfoCache setValue:NUMINT([self mapsprite].tileCountX) forKey:@"width"];
    [mapSizeInfoCache setValue:NUMINT([self mapsprite].tileCountY) forKey:@"height"];
    
    return mapSizeInfoCache;
}

- (void)setMapSize:(id)value {
    ENSURE_SINGLE_ARG(value, NSDictionary);
    NSInteger width  = [TiUtils intValue:@"width"   properties:value def:0];
    NSInteger height = [TiUtils intValue:@"height"  properties:value def:0];
    
    if (width > 0 && height > 0) {
        [[self mapsprite] updateMapSize:width ycount:height];
    }
}

- (id)tileCount {
    return NUMINT([self mapsprite].tileCount);
}

- (id)tileCountX {
    return NUMINT([self mapsprite].tileCountX);
}

- (id)tileCountY {
    return NUMINT([self mapsprite].tileCountY);
}

- (id)tiles {
    return [[self mapsprite] getTiles];
}

- (void)setTiles:(id)value {
    [self updateTiles:value];
}

- (void)setWidth:(id)value {
    [super setWidth:value];
    [[self mapsprite] updateTileCount];
}

- (void)setHeight:(id)value {
    [super setHeight:value];
    [[self mapsprite] updateTileCount];
}

- (id)tileTiltFactorX {
    return NUMFLOAT([self mapsprite].tileTiltFactorX);
}

- (void)setTileTiltFactorX:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [self mapsprite].tileTiltFactorX = [value floatValue];
}

- (id)tileTiltFactorY {
    return NUMFLOAT([self mapsprite].tileTiltFactorY);
}

- (void)setTileTiltFactorY:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    [self mapsprite].tileTiltFactorY = [value floatValue];
}

- (id)tilesets {
    return [[self mapsprite] tilesets];
}

- (void)setTilesets:(id)args {
    for (NSUInteger i = 0; i < [args count]; i++) {
        NSMutableDictionary* param = [[NSMutableDictionary alloc] init];
        
        [param setObject:@"0" forKey:@"offsetX"];
        [param setObject:@"0" forKey:@"offsetY"];
        
        [param setObject:@"0" forKey:@"rowCount"];
        [param setObject:@"0" forKey:@"columnCount"];
        
        NSDictionary* info = [args objectAtIndex:i];
        for (id key in info) {
            id value = [info objectForKey:key];
            if ([key isEqualToString:@"atlas"]) {
                for (id property in value) {
                    if ([property isEqualToString:@"x"]) {
                        [param setObject:[value objectForKey:property] forKey:@"atlasX"];
                    } else if ([property isEqualToString:@"y"]) {
                        [param setObject:[value objectForKey:property] forKey:@"atlasY"];
                    } else if ([property isEqualToString:@"w"]) {
                        [param setObject:[value objectForKey:property] forKey:@"atlasWidth"];
                    } else if ([property isEqualToString:@"h"]) {
                        [param setObject:[value objectForKey:property] forKey:@"atlasHeight"];
                    }
                }
            } else if ([key isEqualToString:@"properties"]) {
                for (id property in value) {
                    if ([property isEqualToString:@"rowCount"]) {
                        [param setObject:[value objectForKey:property] forKey:@"rowCount"];
                    } else if ([property isEqualToString:@"columnCount"]) {
                        [param setObject:[value objectForKey:property] forKey:@"columnCount"];
                    }
                }
            } else if ([key isEqualToString:@"tileproperties"] && [info objectForKey:@"firstgid"] != nil) {
                [[self mapsprite] updateGIDProperties:value firstgid:[[info objectForKey:@"firstgid"] intValue]];
            } else {
                [param setObject:value forKey:key];
            }
        }
        [[self mapsprite] addTileset:param];
        [param release];
    }
}

-(void)stop:(id)args {
    ENSURE_SINGLE_ARG(args, NSNumber);
    [[self mapsprite] deleteAnimation:[NSString stringWithFormat:@"%d", [args intValue]]];
}

- (void)animate:(id)args {
    if ([args count] >= 3 && [[args objectAtIndex:1] isKindOfClass:[NSArray class]]) {
        NSInteger tileIndex = [[args objectAtIndex:0] intValue];
        NSArray* frames     =  [args objectAtIndex:1];
        NSInteger interval  = [[args objectAtIndex:2] intValue];
        
        if ([args count] == 3) {
            [[self mapsprite] animateTile:tileIndex frames:frames interval:interval];
        } else {
            [[self mapsprite] animateTile:tileIndex frames:frames interval:interval loop:[[args objectAtIndex:3] intValue]];
        }
        return;
    }
    
    if ([args count] < 5) {
        NSLog(@"Too few arguments for sprite.animate(index, start, count, interval, loop)");
        return;
    }
    
    NSInteger tileIndex = [[args objectAtIndex:0] intValue];
    NSInteger start = [[args objectAtIndex:1] intValue];
    NSInteger count = [[args objectAtIndex:2] intValue];
    NSInteger interval = [[args objectAtIndex:3] intValue];
    NSInteger loop = [[args objectAtIndex:4] intValue];
    
    [[self mapsprite] animateTile:tileIndex start:start count:count interval:interval loop:loop];
}

- (id)center {
    if ([self mapsprite].orientation == MAP_ORIENTATION_ISOMETRIC) {
        [centerInfoCache setValue:NUMFLOAT(sprite.x) forKey:@"x"];
        [centerInfoCache setValue:NUMFLOAT(sprite.y + sprite.scaledHeight * 0.5) forKey:@"y"];
        return centerInfoCache;
    } else {
        return [super center];
    }
}

- (void)setCenter:(id)value {
    if ([self mapsprite].orientation == MAP_ORIENTATION_ISOMETRIC) {
        ENSURE_SINGLE_ARG(value, NSDictionary);
        float x  = [TiUtils floatValue:@"x"  properties:value  def:0];
        float y  = [TiUtils floatValue:@"y"  properties:value  def:0];
        
        if ([value objectForKey:@"x"] != nil) sprite.x = x;
        if ([value objectForKey:@"y"] != nil) sprite.y = y - sprite.scaledHeight * 0.5;
    } else {
        return [super setCenter:value];
    }
}

- (void)addChildLayer:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dSpriteProxy);
    [sprite addChild:[args sprite]];
}

- (void)removeChildLayer:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dSpriteProxy);
    [sprite removeChild:[args sprite]];
}

@end
 