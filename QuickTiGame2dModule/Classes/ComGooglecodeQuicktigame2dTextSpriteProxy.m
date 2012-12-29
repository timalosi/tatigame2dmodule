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
#import "ComGooglecodeQuicktigame2dTextSpriteProxy.h"
#import "QuickTiGame2dTextSprite.h"
#import "TiUtils.h"

@implementation ComGooglecodeQuicktigame2dTextSpriteProxy

- (id)init {
    self = [super init];
    if (self != nil) {
        // we don't want parent sprite instance so release it here.
        [sprite release];
        
        // create our text instance
        sprite = [[QuickTiGame2dTextSprite alloc] init];
        
        sizeInfoCache = nil;
    }
    return self;
}

- (void)dealloc {
    [sizeInfoCache release];
    [super dealloc];
}

#pragma Public APIs

-(void)reload:(id)args {
    [(QuickTiGame2dTextSprite*)sprite reload];
}

-(id)text {
    return ((QuickTiGame2dTextSprite*)sprite).text;
}

-(void)setText:(id)value {
    ((QuickTiGame2dTextSprite*)sprite).text = [[[TiUtils stringValue:value] copy] autorelease];
    [(QuickTiGame2dTextSprite*)sprite reload];
}

-(id)fontFamily {
    return ((QuickTiGame2dTextSprite*)sprite).fontFamily;
}

-(void)setFontFamily:(id)value {
    ((QuickTiGame2dTextSprite*)sprite).fontFamily = [[[TiUtils stringValue:value] copy] autorelease];
    [(QuickTiGame2dTextSprite*)sprite reload];
}

- (id)fontSize {
    return NUMFLOAT(((QuickTiGame2dTextSprite*)sprite).fontSize);
}

- (void)setFontSize:(id)value {
    ENSURE_SINGLE_ARG(value, NSNumber);
    ((QuickTiGame2dTextSprite*)sprite).fontSize = [value floatValue];
    [(QuickTiGame2dTextSprite*)sprite reload];
}

-(id)textAlign {
    return NUMINT(((QuickTiGame2dTextSprite*)sprite).textAlignment);
}

-(void)setTextAlign:(id)value {
    [(QuickTiGame2dTextSprite*)sprite setTextAlignment:[TiUtils textAlignmentValue:value]];
    [(QuickTiGame2dTextSprite*)sprite reload];
}

-(id)sizeWithText:(id)value {
    CGSize size = [(QuickTiGame2dTextSprite*)sprite sizeWithText:[[[TiUtils stringValue:value] copy] autorelease]];
    
    if (sizeInfoCache == nil) {
        sizeInfoCache = [[NSMutableDictionary alloc] init];
    }
    
    [sizeInfoCache setValue:NUMFLOAT(size.width)  forKey:@"width"];
    [sizeInfoCache setValue:NUMFLOAT(size.height) forKey:@"height"];

    return sizeInfoCache;
}

@end
