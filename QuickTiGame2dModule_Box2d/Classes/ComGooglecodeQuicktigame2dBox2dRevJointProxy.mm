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
#import "ComGooglecodeQuicktigame2dBox2dRevJointProxy.hh"
#import "TiUtils.h"

@implementation ComGooglecodeQuicktigame2dBox2dRevJointProxy

-(id)initWithJoint:(b2RevoluteJoint*)joint_
{
    self = [super init];
    if (self != nil) {
		joint = joint_;
        lock = [[NSRecursiveLock alloc] init];
    }
    return self;    
}

-(void)dealloc
{
    RELEASE_TO_NIL(lock);
	[super dealloc];
}

-(b2Joint*)joint
{
    return joint;
}

-(void)setMotorSpeed:(id)args
{
    [lock lock];
    
    ENSURE_SINGLE_ARG(args,NSNumber);
    
    CGFloat speed = [TiUtils floatValue:args];
    joint->SetMotorSpeed(speed);
    
    [lock unlock];
}

-(void)setMaxMotorTorque:(id)args
{
    [lock lock];
    
    ENSURE_SINGLE_ARG(args,NSNumber);
    
    CGFloat t = [TiUtils floatValue:args];
    joint->SetMaxMotorTorque(t);
    
    [lock unlock];
}

-(id)getJointAngle:(id)args
{
    float angle = joint->GetJointAngle();
    return NUMFLOAT(angle);
}

-(id)getJointSpeed:(id)args
{
    float speed = joint->GetJointSpeed();
    return NUMFLOAT(speed);
}



@end
