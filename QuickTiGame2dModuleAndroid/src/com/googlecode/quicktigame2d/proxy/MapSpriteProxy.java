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
package com.googlecode.quicktigame2d.proxy;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.titanium.util.TiConvert;

import com.googlecode.quicktigame2d.QuickTiGame2dMapSprite;
import com.googlecode.quicktigame2d.QuickTiGame2dMapTile;
import com.googlecode.quicktigame2d.Quicktigame2dModule;

@Kroll.proxy(creatableInModule=Quicktigame2dModule.class)
public class MapSpriteProxy extends SpriteProxy {
	
	private HashMap<String, Object> mapSizeInfoCache = new HashMap<String, Object>();
	
	public MapSpriteProxy() {
		sprite = new QuickTiGame2dMapSprite();
	}
	
	public void onNotification(KrollDict info) {
		if (info.getString("eventName").equals("onload")) {
	        if (sprite.getWidth()  == 0) sprite.setWidth(info.getInt("width"));
	        if (sprite.getHeight() == 0) sprite.setHeight(info.getInt("height"));
	        
	        info.remove("width");
	        info.remove("height");
		}
		
		super.onNotification(info);
	}

	private QuickTiGame2dMapSprite getMapSprite() {
		return (QuickTiGame2dMapSprite)sprite;
	}
	
	@Override
    public void handleCreationDict(KrollDict options) {
    	super.handleCreationDict(options);
    	if (options.containsKey("border")) {
    		setBorder(options.getInt("border"));
    	}
    	if (options.containsKey("margin")) {
    		setMargin(options.getInt("margin"));
    	}
    	if (options.containsKey("tileWidth")) {
    		setTileWidth(options.getInt("tileWidth"));
    	}
    	if (options.containsKey("tileHeight")) {
    		setTileHeight(options.getInt("tileHeight"));
    	}
    }

	private void updateTileInfoProxyCache(HashMap<String, Object> info, QuickTiGame2dMapTile tile) {
		info.put("index", Integer.valueOf(tile.index));
		info.put("gid",   Integer.valueOf(tile.gid));
		info.put("red",   Double.valueOf(tile.red));
		info.put("green", Double.valueOf(tile.green));
		info.put("blue",  Double.valueOf(tile.blue));
		info.put("alpha", Double.valueOf(tile.alpha));
		info.put("flip",  Boolean.valueOf(tile.flip));
		info.put("isChild",  Boolean.valueOf(tile.isChild));
		info.put("hasChild", Boolean.valueOf(getMapSprite().hasChild(tile)));
		info.put("rowCount", Integer.valueOf(getMapSprite().getTileRowCount(tile)));
		info.put("columnCount", Integer.valueOf(getMapSprite().getTileColumnCount(tile)));
		info.put("parent",   Integer.valueOf(tile.parent));
		
		info.put("x",  Double.valueOf(getMapSprite().getScreenX(tile)));
		info.put("y",  Double.valueOf(getMapSprite().getScreenY(tile)));
		info.put("defaultX",  Double.valueOf(getMapSprite().getDefaultX(tile)));
		info.put("defaultY",  Double.valueOf(getMapSprite().getDefaultY(tile)));
		info.put("width",    Double.valueOf(tile.width  > 0 ? 
				getMapSprite().getScaledTileWidth(tile)  : getMapSprite().getScaledTileWidth()));
		info.put("height",   Double.valueOf(tile.height > 0 ?
				getMapSprite().getScaledTileHeight(tile) : getMapSprite().getScaledTileHeight()));
		info.put("margin",   Double.valueOf(tile.margin));
		info.put("border",   Double.valueOf(tile.border));
		
		Map<String, String> properties = getMapSprite().getGIDProperties(tile.gid);
		
		if (properties != null) {
			info.put("properties", properties);
		} else {
			info.remove("properties");
		}
	}
	
	@SuppressWarnings("rawtypes")
	@Kroll.method
	public HashMap getTileAtPosition(float sx, float sy) {
		HashMap<String, Object> info = new HashMap<String, Object>();
		
		QuickTiGame2dMapTile tile = getMapSprite().getTileAtPosition(sx, sy);
		
		if (tile == null) return null;
		
		updateTileInfoProxyCache(info, tile);
		
		return info;
	}

	@SuppressWarnings("rawtypes")
	@Kroll.method
	public HashMap getTile(int index) {
		HashMap<String, Object> info = new HashMap<String, Object>();
		
		QuickTiGame2dMapTile tile = getMapSprite().getTile(index);
		
		if (tile == null) return null;
		
		updateTileInfoProxyCache(info, tile);
		
		return info;
	}
	
	@Kroll.method
	public boolean setTile(@SuppressWarnings("rawtypes") HashMap info) {
		return updateTile(info);
	}

	@Kroll.method
	public boolean canUpdate(@SuppressWarnings("rawtypes") HashMap info) {
		int index = -1;
		if (info.containsKey("index")) {
			index = TiConvert.toInt(info.get("index"));
		}
		
	    QuickTiGame2dMapTile target = getMapSprite().getTile(index);
	    if (target == null) return false;
	    
	    QuickTiGame2dMapTile tile = new QuickTiGame2dMapTile();
	    tile.indexcc(target);
	    
		if (info.containsKey("flip")) {
			tile.flip = TiConvert.toBoolean(info.get("flip"));
		}
		
		return getMapSprite().canUpdate(index, tile);
	}
	
	@Kroll.method
	public boolean updateTile(@SuppressWarnings("rawtypes") HashMap info) {
		int index = -1;
		int gid   = -1;
		float red   = -1;
		float green = -1;
		float blue  = -1;
		float alpha = -1;
		
		if (info.containsKey("index")) {
			index = TiConvert.toInt(info.get("index"));
		}
		if (info.containsKey("gid")) {
			gid = TiConvert.toInt(info.get("gid"));
		}
		if (info.containsKey("red")) {
			red = (float)TiConvert.toDouble(info.get("red"));
		}
		if (info.containsKey("green")) {
			green = (float)TiConvert.toDouble(info.get("green"));
		}
		if (info.containsKey("blue")) {
			blue = (float)TiConvert.toDouble(info.get("blue"));
		}
		if (info.containsKey("alpha")) {
			alpha = (float)TiConvert.toDouble(info.get("alpha"));
		}
	    
	    QuickTiGame2dMapTile target = getMapSprite().getTile(index);
	    
	    if (target == null) return false;
	    
	    QuickTiGame2dMapTile tile = new QuickTiGame2dMapTile();
	    tile.cc(target);
	    
	    if (gid   >= 0) tile.gid   = gid;
	    if (red   >= 0) tile.red   = red;
	    if (green >= 0) tile.green = green;
	    if (blue  >= 0) tile.blue  = blue;
	    if (alpha >= 0) tile.alpha = alpha;
	    
		if (info.containsKey("flip")) {
			tile.flip = TiConvert.toBoolean(info.get("flip"));
		}
	    
	    return getMapSprite().setTile(index, tile);
	}
	
	@SuppressWarnings({ "unchecked", "rawtypes" })
	@Kroll.method
	public boolean updateTiles(List list) {
		if (list.get(0) instanceof Map) {
			List<Integer> data = new ArrayList<Integer>();
			
			for (Object e : list) {
				Map tile = (Map)e;
				if (tile.get("gid") == null) continue;
				data.add(Integer.valueOf(tile.get("gid").toString()));
			}
			getMapSprite().setTiles(data);
		} else {
			getMapSprite().setTiles(list);
		}
		
		return true;
	}
	
	@Kroll.method
	public boolean removeTile(int index) {
	    return getMapSprite().removeTile(index);
	}
	
	@Kroll.method
	public boolean flipTile(int index) {
	    return getMapSprite().flipTile(index);
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean getIsTopLayer() {
		return getMapSprite().isTopLayer();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setIsTopLayer(boolean enable) {
		getMapSprite().setTopLayer(enable);
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean getIsSubLayer() {
		return getMapSprite().isSubLayer();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setIsSubLayer(boolean enable) {
		getMapSprite().setSubLayer(enable);
	}
	
	@Kroll.getProperty @Kroll.method
	public int getBorder() {
		return sprite.getBorder();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setBorder(int border) {
		sprite.setBorder(border);
	}

	@Kroll.getProperty @Kroll.method
	public int getMargin() {
		return sprite.getMargin();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setMargin(int margin) {
		sprite.setMargin(margin);
	}
	
	@Kroll.getProperty @Kroll.method
	public float getTileWidth() {
		return getMapSprite().getTileWidth();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setTileWidth(float tileWidth) {
		getMapSprite().setTileWidth(tileWidth);
		getMapSprite().updateTileCount();
	}
	
	@Kroll.getProperty @Kroll.method
	public float getTileHeight() {
		return getMapSprite().getTileHeight();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setTileHeight(float tileHeight) {
		getMapSprite().setTileHeight(tileHeight);
		getMapSprite().updateTileCount();
	}
	
	@Kroll.getProperty @Kroll.method
	public int getFirstgid() {
		return getMapSprite().getFirstgid();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setFirstgid(int firstgid) {
		getMapSprite().setFirstgid(firstgid);
	}

	@Kroll.getProperty @Kroll.method
	public int getOrientation() {
		return getMapSprite().getOrientation();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setOrientation(int orientation) {
		getMapSprite().setOrientation(orientation);
		getMapSprite().updateTileCount();
	}
	
	@Kroll.getProperty @Kroll.method
	public int getTileCount() {
		return getMapSprite().getTileCount();
	}
	
	@Kroll.getProperty @Kroll.method
	public int getTileCountX() {
		return getMapSprite().getTileCountX();
	}
	
	@Kroll.getProperty @Kroll.method
	public int getTileCountY() {
		return getMapSprite().getTileCountY();
	}

	@Kroll.setProperty @Kroll.method
	public void setWidth(int width) {
		super.setWidth(width);
		getMapSprite().updateTileCount();
	}
	
	@Kroll.getProperty @Kroll.method
	public int getWidth() {
		return sprite.getWidth();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setHeight(int height) {
		super.setHeight(height);
		getMapSprite().updateTileCount();
	}

	@Kroll.getProperty @Kroll.method
	public int getHeight() {
		return sprite.getHeight();
	}
	
	@Kroll.getProperty @Kroll.method
	public Integer[] getTiles() {
		List<Integer> tiles = getMapSprite().getTiles();
		return tiles.toArray(new Integer[tiles.size()]);
	}
	
	@Kroll.setProperty @Kroll.method
	public void setTiles(Object[] tiles) {
		List<Integer> data = new ArrayList<Integer>();
		for (int i = 0; i < tiles.length; i++) {
			data.add(Integer.valueOf((int)Double.parseDouble((tiles[i].toString()))));
		}
		
		updateTiles(data);
	}
	
	@Kroll.getProperty @Kroll.method
	public float getTileTiltFactorX() {
		return getMapSprite().getTileTiltFactorX();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setTileTiltFactorX(float value) {
		getMapSprite().setTileTiltFactorX(value);
	}

	@Kroll.getProperty @Kroll.method
	public float getTileTiltFactorY() {
		return getMapSprite().getTileTiltFactorY();
	}
	
	@Kroll.setProperty @Kroll.method
	public void setTileTiltFactorY(float value) {
		getMapSprite().setTileTiltFactorY(value);
	}

	@Kroll.getProperty @Kroll.method
	public Map<String, Map<String, String>> getTilesets() {
		return getMapSprite().getTilesets();
	}

	@Kroll.setProperty @Kroll.method
	public void setMapSize(@SuppressWarnings("rawtypes") HashMap info) {
		if (info.containsKey("width") && info.containsKey("height")) {
			int width  = TiConvert.toInt(info.get("width"));
			int height = TiConvert.toInt(info.get("height"));
			
			getMapSprite().updateMapSize(width, height);
		}
	}

	@SuppressWarnings("rawtypes")
	@Kroll.getProperty @Kroll.method
	public HashMap getMapSize() {
		mapSizeInfoCache.put("width",  getMapSprite().getTileCountX());
		mapSizeInfoCache.put("height", getMapSprite().getTileCountY());
		
		return mapSizeInfoCache;
	}
	
	
	@SuppressWarnings("rawtypes")
	@Kroll.setProperty @Kroll.method
	public void setTilesets(Object[] args) {
		for (int i = 0; i < args.length; i++) {
			Map<String, String> param = new HashMap<String, String>();
			param.put("offsetX", "0");
			param.put("offsetY", "0");
			param.put("rowCount", "0");
			param.put("columnCount", "0");
			
			Map info = (Map) args[i];
			
			for (Object key : info.keySet()) {
				if ("atlas".equals(key)) {
					Map value = (Map) info.get(key);
					for (Object property : value.keySet()) {
						if ("x".equals(property)) {
							param.put("atlasX", String.valueOf(value.get(property)));
						} else if ("y".equals(property)) {
							param.put("atlasY", String.valueOf(value.get(property)));
						} else if ("w".equals(property)) {
							param.put("atlasWidth", String.valueOf(value.get(property)));
						} else if ("h".equals(property)) {
							param.put("atlasHeight", String.valueOf(value.get(property)));
						}
					}
				} else if ("properties".equals(key)) {
					Map value = (Map) info.get(key);
					for (Object property : value.keySet()) {
						if ("rowCount".equals(property)) {
							param.put("rowCount", String.valueOf(value.get(property)));
						} else if ("columnCount".equals(property)) {
							param.put("columnCount", String.valueOf(value.get(property)));
						}
					}
				} else if ("tileproperties".equals(key) && info.get("firstgid") != null) {
					Map value = (Map) info.get(key);
					Map<String, Map<String, String>> properties = new HashMap<String, Map<String, String>>();
					
					for (Object property : value.keySet()) {
						Map<String, String> holder = new HashMap<String, String>();
						
						Map subvalue = (Map)value.get(property);
						for (Object k : subvalue.keySet()) {
							holder.put(String.valueOf(k), String.valueOf(subvalue.get(k)));
						}
						
						properties.put(String.valueOf(property), holder);
					}
					getMapSprite().updateGIDProperties(properties, Integer.parseInt(String.valueOf(info.get("firstgid"))));
				} else {
					param.put(String.valueOf(key), String.valueOf(info.get(key)));
				}
			}
			
			getMapSprite().addTileset(param);
		}
	}

	@Kroll.method
	public void stop(int tileIndex) {
		getMapSprite().deleteAnimation(String.valueOf(tileIndex));
	}

	@Kroll.method
	public void animate(int tileIndex, Object arg1, int arg2, int arg3, int arg4) {
		if (arg1.getClass().isArray()) {
			Object[] framesObj = (Object[])arg1;
			
			int[] frames = new int[framesObj.length];
			for (int i = 0; i < frames.length; i++) {
				frames[i] = (int)Double.parseDouble(framesObj[i].toString());
			}
			
			getMapSprite().animateTile(tileIndex, frames, arg2, arg3);
		} else {
			getMapSprite().animateTile(tileIndex, (int)Double.parseDouble(arg1.toString()), arg2, arg3, arg4);
		}
	}
	
	@Override
	@Kroll.setProperty @Kroll.method
	public void setCenter(@SuppressWarnings("rawtypes") HashMap info) {
		if (info.containsKey("x")) {
			float x = (float)TiConvert.toDouble(info.get("x"));
			sprite.setX(x);
		}
		if (info.containsKey("y")) {
			float y = (float)TiConvert.toDouble(info.get("y"));
			sprite.setY(y - sprite.getScaledHeight() * 0.5f);
		}
	}
	
	@Override
	@SuppressWarnings("rawtypes")
	@Kroll.getProperty @Kroll.method
	public HashMap getCenter() {
		centerInfoCache.put("x" , sprite.getX());
		centerInfoCache.put("y" , sprite.getY() + sprite.getScaledHeight() * 0.5f);
		
		return centerInfoCache;
	}
	
	@Kroll.method
	public void addChildLayer(MapSpriteProxy child) {
		sprite.addChild(child.getSprite());
	}

	@Kroll.method
	public void removeChildLayer(MapSpriteProxy child) {
		sprite.removeChild(child.getSprite());
	}
}
