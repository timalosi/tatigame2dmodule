/**
 *  Copyright 2011 Jeff Haynie
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

#import <Box2D/Box2D.h>
#import <vector>
#import <algorithm>
#import "TiProxy.h"

struct TiContact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const TiContact& other) const
    {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

class TiContactListener : public b2ContactListener {

public:
    std::vector<TiContact>_contacts;
    
    TiContactListener(TiProxy *proxy);
    ~TiContactListener();
    
	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
	virtual void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);    
	virtual void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);

private:
    TiProxy *proxy;
	NSDictionary* CreateEvent(TiContact *myContact,NSString *phase);
};
