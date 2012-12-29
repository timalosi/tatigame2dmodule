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
#import "ComGooglecodeQuicktigame2dBox2dWorldProxy.hh"
#import "ComGooglecodeQuicktigame2dSpriteProxy.h"
#import <Box2D/Box2D.h>

@interface ComGooglecodeQuicktigame2dBox2dBodyProxy : TiProxy
{	
	b2Body *body;
	ComGooglecodeQuicktigame2dSpriteProxy *viewproxy;
    ComGooglecodeQuicktigame2dGameViewProxy *surface;
    NSLock *lock;
}

-(id)initWithBody:(b2Body*)body viewproxy:(ComGooglecodeQuicktigame2dSpriteProxy*)vp
                            surface:(ComGooglecodeQuicktigame2dGameViewProxy*)surface;
-(ComGooglecodeQuicktigame2dSpriteProxy*)viewproxy;
-(b2Body*)body;


@end
