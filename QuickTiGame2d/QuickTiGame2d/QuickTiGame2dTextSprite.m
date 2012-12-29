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
#import "QuickTiGame2dTextSprite.h"
#import "QuickTiGame2dEngine.h"

@interface QuickTiGame2dTextSprite (PrivateMethods)
-(void)loadTextData;
@end

@implementation QuickTiGame2dTextSprite
@synthesize text, fontSize, fontFamily, textAlignment;

-(CGFloat)systemFontSize {
    return [UIFont systemFontSize];
}

-(CGSize)sizeWithText:(NSString*)value {
    UIFont* font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    if ([fontFamily length] > 0) {
        NSInteger size = fontSize > 0 ? fontSize : [UIFont systemFontSize];
        font = [UIFont fontWithName:fontFamily size:size];
    } else if (fontSize > 0) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
    CGSize textSize = CGSizeMake(0, 0);
    
    if ([text length] != 0) {
        textSize = [text sizeWithFont:font]; 
    }
    
    return textSize;
}

-(void)loadTextData {
    UIFont* font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    if ([fontFamily length] > 0) {
        NSInteger size = fontSize > 0 ? fontSize : [UIFont systemFontSize];
        font = [UIFont fontWithName:fontFamily size:size];
    } else if (fontSize > 0) {
        font = [UIFont systemFontOfSize:fontSize];
    }
    
    CGSize textSize = CGSizeMake(1, 1);
    
    if (shouldUpdateWidth) {
        if ([text length] == 0) {
            textSize = [@" " sizeWithFont:font]; 
        } else {
            textSize = [text sizeWithFont:font]; 
        }
    } else {
        textSize = CGSizeMake(width, height);
    }
    
    int textWidth  = textSize.width;
    int textHeight = textSize.height;
    
    NSUInteger blength = textWidth * textHeight * 4;
    
    GLubyte *bitmap = (GLubyte *)malloc(blength);
    memset(bitmap, 0, blength);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(bitmap, textWidth, textHeight,
                                                 8, textWidth * 4, colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    
    UIGraphicsPushContext(context);
    
    [[UIColor whiteColor] set];
    [text drawInRect:CGRectMake(0, 0, textWidth, textHeight) withFont:font
       lineBreakMode:UILineBreakModeWordWrap alignment:textAlignment];
    
    UIGraphicsPopContext();
    
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    labelTexture.name   = text;
    labelTexture.width  = textWidth;
    labelTexture.height = textHeight;
    labelTexture.data   = bitmap;
    labelTexture.dataLength = blength;
    labelTexture.textureFilter = GL_LINEAR; // anti alias
    
    [labelTexture onLoadWithBytes];
    [labelTexture freeData];
    
    self.width  = textWidth;
    self.height = textHeight;
}

-(void)reload {
    shouldReload = TRUE;
}

-(void)onLoad {
    [self loadTextData];
    
    hasTexture = TRUE;
 
    [self createTextureBuffer];
    [self bindVertex];
    
    shouldReload = FALSE;
    loaded = TRUE;
}

/*
 * returns whether Y axis of texture should flipped or not
 */
-(BOOL)flipY {
    return TRUE;
}

-(void)drawFrame:(QuickTiGame2dEngine*)engine {
    if (shouldReload) {
        [labelTexture onDispose];
        [self loadTextData];
        [self bindVertex];
        shouldReload = FALSE;
    }
    [super drawFrame:engine];
}

-(void)onDispose {
    [super onDispose];
}

-(void)setWidth:(NSInteger)_width {
    if (loaded) [self reload];
    shouldUpdateWidth = FALSE;
    [super setWidth:_width];
}

-(QuickTiGame2dTexture*)texture {
    return labelTexture;
}

- (id)init {
    self = [super init];
    if (self != nil) {
        labelTexture = [[QuickTiGame2dTexture alloc] init];
        labelTexture.width  = 1;
        labelTexture.height = 1;
        
        self.text = @"";
        self.fontFamily = nil;
        self.fontSize = 0;
        
        // default text color equals black
        [self color:0 green:0 blue:0];
        
        shouldReload = FALSE;
        shouldUpdateWidth = TRUE;
        
        textAlignment = UITextAlignmentLeft;
    }
    return self;
}

-(void)dealloc {
    [labelTexture onDispose];
    [labelTexture release];
    [text release];
    
    labelTexture = nil;
    text         = nil;
    fontFamily   = nil;
    hasTexture   = FALSE;
    
    [super dealloc];
}
@end

