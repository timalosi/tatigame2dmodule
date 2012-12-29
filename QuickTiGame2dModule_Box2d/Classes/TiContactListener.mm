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

#import "TiContactListener.h"

TiContactListener::TiContactListener(TiProxy *proxy_) : _contacts() 
{
	proxy = [proxy_ retain];
}

TiContactListener::~TiContactListener() 
{
	[proxy release];
}

NSDictionary* TiContactListener::CreateEvent(TiContact *myContact, NSString *phase)
{
	id a = (id)myContact->fixtureA->GetBody()->GetUserData();
	id b = (id)myContact->fixtureB->GetBody()->GetUserData();
	
	if (a==nil && b==nil)
	{
		return nil;
	}
	
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	[dict setObject:phase forKey:@"phase"];
	if (a)
	{
		[dict setObject:a forKey:@"a"];
	}
	if (b)
	{
		[dict setObject:b forKey:@"b"];
	}
	return dict;
}

void TiContactListener::BeginContact(b2Contact* contact) 
{
    // We need to copy out the data because the b2Contact passed in
    // is reused.
    TiContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(myContact);
	
	NSDictionary *event = this->CreateEvent(&myContact,@"begin");
	if (event)
	{
		[proxy fireEvent:@"collision" withObject:event];
	}
}

void TiContactListener::EndContact(b2Contact* contact) 
{
    TiContact myContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<TiContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), myContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }

	NSDictionary *event = this->CreateEvent(&myContact,@"end");
	if (event)
	{
		[proxy fireEvent:@"collision" withObject:event];
	}
}

void TiContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) 
{
}

void TiContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) 
{
}

