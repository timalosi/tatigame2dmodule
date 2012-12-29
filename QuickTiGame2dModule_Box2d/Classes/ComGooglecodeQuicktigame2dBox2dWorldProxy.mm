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

#import "ComGooglecodeQuicktigame2dBox2dWorldProxy.hh"
#import "ComGooglecodeQuicktigame2dBox2dRevJointProxy.hh"
#import "ComGooglecodeQuicktigame2dGameView.h"

@implementation ComGooglecodeQuicktigame2dBox2dWorldProxy

-(void)_destroy
{
	[lock lock];
	_destroyed = YES;
	[timer invalidate];
	timer = nil;
	if (world)
	{
		delete world;
		world = nil;
	}
	[lock unlock];
	[super _destroy];
}

-(void)dealloc
{
	[lock lock];
	[timer invalidate]; timer = nil;
	if (world)
	{
		delete world; 
		world = nil;
	}
	if (contactListener)
	{
		delete contactListener;
		contactListener = nil;
	}
    if (bodies)
    {
        [bodies removeAllObjects];
        RELEASE_TO_NIL(bodies);
    }
	[lock unlock];
	RELEASE_TO_NIL(surface);
	RELEASE_TO_NIL(lock);
	[super dealloc];
}

- (id)init {
    self = [super init];
    if (self != nil) {
		lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

-(void)setSurface:(id)args {
    ENSURE_SINGLE_ARG(args, ComGooglecodeQuicktigame2dGameViewProxy);
    [surface release];
    surface = [args retain];
}

-(id)surface {
    return surface;
}

-(b2World*)world
{
	return world;
}

-(void)_createWorld
{
	[lock lock];
	if (world) 
	{
		[lock unlock];
		return;
	}
	
	gravity.Set(0.0f, -9.81f); 
	
	// Construct a world object, which will hold and simulate the rigid bodies.
	world = new b2World(gravity, false); //TODO: make configurable sleep
	world->SetContinuousPhysics(true);
	
	if (contactListener)
	{
		world->SetContactListener(contactListener);
	}
	
	[lock unlock];
}

-(void)start:(id)args
{
	ENSURE_UI_THREAD_0_ARGS
	[lock lock];
	if (timer)
	{
		[timer invalidate];
		timer = nil;
	}
	timer = [NSTimer scheduledTimerWithTimeInterval:1.0/60.0f target:self selector:@selector(tick:) userInfo:nil repeats:YES];
	[lock unlock];
}

-(void)stop:(id)args
{
	ENSURE_UI_THREAD_0_ARGS
	[lock lock];
	if (timer)
	{
		[timer invalidate];
		timer = nil;
	}
	[lock unlock];
}

-(void)_listenerAdded:(NSString *)type count:(int)count 
{
	[lock lock];
	if (count == 1 && [type isEqualToString:@"collision"] && contactListener==nil)
	{
		contactListener = new TiContactListener(self);
		if (world)
		{
			world->SetContactListener(contactListener);
		}
	}
	[lock unlock];
}

-(void)_listenerRemoved:(NSString *)type count:(int)count 
{
	[lock lock];
	if (count == 0 && contactListener && [type isEqualToString:@"collision"])
	{
		world->SetContactListener(nil);
		delete contactListener;
		contactListener = nil;
	}
	[lock unlock];
}

-(void)setGravity:(id)args
{
	[lock lock];
	if (args && [args count] > 1 && world)
	{
		CGFloat x = [TiUtils floatValue:[args objectAtIndex:0]];
		CGFloat y = [TiUtils floatValue:[args objectAtIndex:1]];
		gravity.Set(x,y);
		world->SetGravity(gravity);
	}
	[lock unlock];
}

-(void)addBodyToView:(ComGooglecodeQuicktigame2dSpriteProxy*)viewproxy
{
	if (_destroyed==NO)
	{
		[self _createWorld];
		[(ComGooglecodeQuicktigame2dSceneProxy*)[surface topScene:nil] add:viewproxy];
	}
}

-(id)addBody:(id)args
{
	ComGooglecodeQuicktigame2dSpriteProxy *viewproxy = [args objectAtIndex:0];
	NSDictionary *props = [args count] > 1 ? [args objectAtIndex:1] : nil;
	
	[self performSelectorOnMainThread:@selector(addBodyToView:) withObject:viewproxy waitUntilDone:YES];
	QuickTiGame2dSprite *physicalView = [viewproxy sprite];
    
	// Define the dynamic body.
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	
	CGPoint p = physicalView.center;
	CGPoint boxDimensions = CGPointMake(physicalView.bounds.size.width/PTM_RATIO/2.0,physicalView.bounds.size.height/PTM_RATIO/2.0);
    bodyDef.angle = degreesToRadians(physicalView.angle);
	
	CGFloat height = [(ComGooglecodeQuicktigame2dGameView*)[surface view] gamebounds].size.height;
    
    // if GameView height is not yet set so we assume default size
    if (height == 0) {
        NSInteger orientation = [surface.orientation intValue];
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            if (UIGraphicsBeginImageContextWithOptions != NULL) {
                height = 640;
            } else {
                height = 320;
            }
        } else {
            if (UIGraphicsBeginImageContextWithOptions != NULL) {
                height = 960;
            } else {
                height = 480;
            }
        }
    }
    
	bodyDef.position.Set(p.x/PTM_RATIO, (height - p.y)/PTM_RATIO);
	
	[lock lock];
    
    if (bodies==nil)
    {
        bodies = [[NSMutableArray alloc] init];
    }
	
	ComGooglecodeQuicktigame2dBox2dBodyProxy *bp = nil;
	
	if (world && boxDimensions.x > 0 && boxDimensions.y > 0)
	{
        
		// Tell the physics world to create the body
		b2Body *body = world->CreateBody(&bodyDef);
        
		// Define the dynamic body fixture.
		b2FixtureDef fixtureDef;
		
		CGFloat radius = [TiUtils floatValue:@"radius" properties:props def:-1.0];
		if (radius > 0)
		{
			b2CircleShape circle;
			fixtureDef.shape = &circle;
			circle.m_radius = radius / PTM_RATIO;
		}
		else
		{
			// Define another box shape for our dynamic body.
			b2PolygonShape shape;
            id shapeValues = [props objectForKey:@"shape"];
            if (shapeValues!=nil)
            {
                NSArray *values = (NSArray*)shapeValues;
                int count = [values count];
                b2Vec2 *vertices = new b2Vec2[count/2];
                int x = 0;
                for (size_t c = 0; c < count; c+=2)
                {
                    vertices[x++] = b2Vec2([TiUtils floatValue:[values objectAtIndex:c]]/PTM_RATIO,[TiUtils floatValue:[values objectAtIndex:c+1]]/PTM_RATIO);
                }
                shape.Set(vertices, x);
                delete vertices;
            }
            else
            {
                shape.SetAsBox(boxDimensions.x, boxDimensions.y);
            }
			fixtureDef.shape = &shape;
		}	
		fixtureDef.density =  [TiUtils floatValue:@"density" properties:props def:3.0f];
		fixtureDef.friction = [TiUtils floatValue:@"friction" properties:props def:0.3f];
		fixtureDef.restitution = [TiUtils floatValue:@"restitution" properties:props def:0.5f]; // 0 is a lead ball, 1 is a super bouncy ball
        
		body->CreateFixture(&fixtureDef);
		
		NSString *bodyType = [TiUtils stringValue:@"type" properties:props def:@"dynamic"];
		if ([bodyType isEqualToString:@"dynamic"])
		{
			body->SetType(b2_dynamicBody);
		}
		else if ([bodyType isEqualToString:@"static"])
		{
			body->SetType(b2_staticBody);
		}
		else if ([bodyType isEqualToString:@"kinematic"])
		{
			body->SetType(b2_kinematicBody);
		}
		
		// we abuse the tag property as pointer to the physical body
		// physicalView.tag = (int)body;
		
		bp = [[ComGooglecodeQuicktigame2dBox2dBodyProxy alloc] initWithBody:body
                                                viewproxy:viewproxy surface:surface];
		
		body->SetUserData(bp);
	}
	
	[lock unlock];
	
	return bp;
}

-(void)destroyBody:(id)body
{
    ENSURE_SINGLE_ARG(body, ComGooglecodeQuicktigame2dBox2dBodyProxy);
    [lock lock];
    if (world)
    {
        world->DestroyBody([body body]);
    }
    ComGooglecodeQuicktigame2dSpriteProxy *viewproxy = [body viewproxy];
    [[surface topScene:nil] remove:[NSArray arrayWithObject:viewproxy]];
    [bodies removeObject:body];
    [lock unlock];
}

#define B2VEC2_ARRAY(v) [NSArray arrayWithObjects:NUMDOUBLE(v.x), NUMDOUBLE(v.y),nil];
#define ARRAY_B2VEC2(a,b) b2Vec2 b([TiUtils doubleValue:[a objectAtIndex:0]], [TiUtils doubleValue:[a objectAtIndex:1]]);

-(id)createJoint:(id)args
{
    NSDictionary *props = [args count] > 2 ? [args objectAtIndex:2] : nil;
    
    [lock lock];
    
    ComGooglecodeQuicktigame2dBox2dBodyProxy *TiBody1 = [args objectAtIndex:0];
    
    b2Body *body1 = TiBody1.body;
    
    ComGooglecodeQuicktigame2dBox2dBodyProxy *TiBody2 = [args objectAtIndex:1];
    
    b2Body *body2 = TiBody2.body;
    
    // Need to add other joint types...
    int jointType = [TiUtils intValue:@"type" properties:props def: 1];
    
    //by default
    b2RevoluteJointDef jointDef;
    ComGooglecodeQuicktigame2dBox2dRevJointProxy *jp;
    switch (jointType) {
        case 1:
            b2RevoluteJointDef jointDef;
            
            ComGooglecodeQuicktigame2dBox2dRevJointProxy *jp = nil;
            break;
    }    
    
    b2Vec2 p1([TiUtils floatValue:@"jointPoint" properties:props def:0.0f], 0.0f),p2([TiUtils floatValue:@"basePoint" properties:props def:0.0f], 0.0f);
    
    jointDef.localAnchorB.SetZero();
    jointDef.localAnchorA = p1;
    jointDef.bodyA = body1;
    
    jointDef.localAnchorB = p2;
    jointDef.bodyB = body2;
    
    
    if([TiUtils boolValue:@"enableLimit" properties:props def:false]) {
        jointDef.enableLimit = true;
        
        jointDef.upperAngle = [TiUtils floatValue:@"upperAngle" properties:props def:10.0f] * b2_pi;
        
        jointDef.lowerAngle = [TiUtils floatValue:@"lowerAngle" properties:props def:10.0f] * b2_pi;
        
    }
    
    if([TiUtils boolValue:@"enableMotor" properties:props def:false]) {
        jointDef.enableMotor = true;
        
        jointDef.maxMotorTorque = [TiUtils floatValue:@"maxMotorTorque" properties:props def:10.0f];
        
        jointDef.motorSpeed = [TiUtils floatValue:@"motorSpeed" properties:props def:10.0f];
        
    }
    
    jointDef.collideConnected = [TiUtils boolValue:@"collideConnected" properties:props def:true];
    
    // Need to add other joint types...
    switch (jointType) {
        case 1:
        default:
            b2RevoluteJoint *joint;
            joint = (b2RevoluteJoint*)world->CreateJoint(&jointDef);
            
            jp = [[ComGooglecodeQuicktigame2dBox2dRevJointProxy alloc] initWithJoint:joint];
            break;
    }
    
    [lock unlock];
    
    return jp;
    
}


-(void)tick:(NSTimer *)timer
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	[lock lock];
	
	if (world)
	{
		
		int32 velocityIterations = 8;
		int32 positionIterations = 1;
		
		// Instruct the world to perform a single step of simulation. It is
		// generally best to keep the time step and iterations fixed.
		world->Step(1.0f/60.0f, velocityIterations, positionIterations);
        
		CGSize size = [(ComGooglecodeQuicktigame2dGameView*)[surface view] gamebounds].size;
		
		//Iterate over the bodies in the physics world
		for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
		{
			void *ud = b->GetUserData();
			
			if (ud != NULL && sizeof(ud)==sizeof(id) && [(id)ud isKindOfClass:[ComGooglecodeQuicktigame2dBox2dBodyProxy class]])
			{
				QuickTiGame2dSprite *oneView = [[(ComGooglecodeQuicktigame2dBox2dBodyProxy *)ud viewproxy] sprite];
				
				// y Position subtracted because of flipped coordinate system
				CGPoint newCenter = CGPointMake(b->GetPosition().x * PTM_RATIO,
												size.height - b->GetPosition().y * PTM_RATIO);
				[oneView moveCenter:newCenter.x y:newCenter.y];
				[oneView rotate:radiansToDegrees(-b->GetAngle())];
			}
		}
	}
	
	[lock unlock];
}

@end
