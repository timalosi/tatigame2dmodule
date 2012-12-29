/**
 *  Copyright 2012 QuickTiGame2d project
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */
#import "TiProxy.h"
#import "TiContactListener.h"
#import "ComGooglecodeQuicktigame2dGameViewProxy.h"
#import "ComGooglecodeQuicktigame2dBox2dBodyProxy.hh"
#import "Box2d/Box2D.h"

#define PTM_RATIO 32

@interface ComGooglecodeQuicktigame2dBox2dWorldProxy : TiProxy {
    
	b2Vec2 gravity;
	b2World *world;
	NSTimer *timer;
	ComGooglecodeQuicktigame2dGameViewProxy* surface;
	TiContactListener *contactListener;
	NSRecursiveLock *lock;
	BOOL _destroyed;
    NSMutableArray *bodies;
}

-(b2World*)world;

@end
