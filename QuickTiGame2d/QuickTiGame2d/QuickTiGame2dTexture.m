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
#import "QuickTiGame2dTexture.h"
#import "QuickTiGame2dUtil.h"
#import "QuickTiGame2dEngine.h"

@interface QuickTiGame2dTexture (PrivateMethods)
-(void)loadTexture;
@end

@implementation QuickTiGame2dTexture
@synthesize loaded;
@synthesize textureId;
@synthesize width, height, glWidth, glHeight;
@synthesize data;
@synthesize hasAlpha;
@synthesize freed;
@synthesize isPVRTC_2, isPVRTC_4, isPNG;
@synthesize dataLength;
@synthesize name;
@synthesize framebufferId, framebufferOldId;
@synthesize isSnapshot;

- (id)init {
    self = [super init];
    if (self != nil) {
        freed = FALSE;
        data  = nil;
        
        isPVRTC_2  = FALSE;
        isPVRTC_4  = FALSE;
        dataLength = 0;
        textureId  = 0;
        
        isSnapshot = FALSE;
        framebufferId    = 0;
        framebufferOldId = 0;
        
        useCustomFilter = FALSE;
        textureFilter   = GL_NEAREST;
    }
    return self;
}

-(BOOL)onLoad {
    if (loaded) return FALSE;
    if (isSnapshot) return FALSE;
    
    if (loadImage(name, self)) {
        [self loadTexture];
        loaded = TRUE;
        if ([QuickTiGame2dEngine debug]) NSLog(@"[DEBUG] load Texture: %@", name);
    } else {
        return FALSE;
    }
    
    [self fireOnLoadTexture];
    
    return TRUE;
}

-(BOOL)onLoad:(NSData*)texdata {
    if (loaded) return FALSE;
    if (isSnapshot) return FALSE;
    
    if (loadImageWithData(name, self, texdata)) {
        [self loadTexture];
        loaded = TRUE;
        if ([QuickTiGame2dEngine debug]) NSLog(@"[DEBUG] load Texture: %@", name);
    } else {
        return FALSE;
    }
    
    [self fireOnLoadTexture];
    
    return TRUE;
}

-(BOOL)onLoadWithBytes {
    if (loaded) return FALSE;
    if (isSnapshot) return FALSE;
    
    self.textureId = -1;
    self.hasAlpha  = TRUE;
    self.freed     = FALSE;
    
    [self loadTexture];
    loaded = TRUE;
    if ([QuickTiGame2dEngine debug]) NSLog(@"[DEBUG] load Texture: %@", name);
    
    [self fireOnLoadTexture];
    
    return TRUE;
}


-(void)loadTexture {
    glWidth  = nextPowerOfTwo(width);
    glHeight = nextPowerOfTwo(height);
    
    [self genTextures];
    
    glEnable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, textureId);
    
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, [self textureFilter]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, [self textureFilter]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    if (isPVRTC_2) {
        glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_2BPPV1_IMG,
                               width, height, 0, dataLength, data);
    } else if (isPVRTC_4) {
        glCompressedTexImage2D(GL_TEXTURE_2D, 0, GL_COMPRESSED_RGBA_PVRTC_4BPPV1_IMG,
                               width, height, 0, dataLength, data);
    } else if (hasAlpha) {
        if (isPowerOfTwo(width) && isPowerOfTwo(height)) {
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
        } else {
            GLubyte* holder = (GLubyte*)malloc(sizeof(GLubyte) * glWidth * glHeight * 4);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, glWidth, glHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, holder);
            glTexSubImage2D(GL_TEXTURE_2D, 0, 
                        0, 0, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
            free(holder);
        }
    } else {
        if (isPowerOfTwo(width) && isPowerOfTwo(height)) {
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, data);
        } else {
            GLubyte* holder = (GLubyte*)malloc(sizeof(GLubyte) * glWidth * glHeight * 3);
            glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, glWidth, glHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, holder);
            glTexSubImage2D(GL_TEXTURE_2D, 0, 
                            0, 0, width, height, GL_RGB, GL_UNSIGNED_BYTE, data);
            free(holder);
        }
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    glDisable(GL_TEXTURE_2D);
}

-(void)fireOnLoadTexture {
    NSDictionary* userInfo = [NSDictionary dictionaryWithObject:name forKey:@"name"];
    [[QuickTiGame2dEngine sharedNotificationCenter] postNotificationName:@"onLoadTexture" object:self userInfo:userInfo];
}

-(BOOL)onLoadSnapshot:(NSInteger)_width height:(NSInteger)_height {
    name   = @SNAPSHOT_TEXTURE_NAME;
    
    width  = _width;
    height = _height;
    
    glWidth  = width;
    glHeight = height;
    
	glEnable(GL_TEXTURE_2D);
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &framebufferOldId);
    
    glGenFramebuffers(1, &framebufferId);
    glBindFramebuffer(GL_FRAMEBUFFER, framebufferId);
    
    [self genTextures];
    
    glBindTexture(GL_TEXTURE_2D, textureId);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, NULL);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, textureId, 0);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, [self textureFilter]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, [self textureFilter]);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
        [self onDispose];
        NSLog(@"[WARN] could not create snapshot buffer");
        return FALSE;
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, framebufferOldId);
    framebufferOldId = 0;

    isSnapshot = TRUE;
    loaded = TRUE;
    
    return TRUE;
}

-(void)onDispose {
    if (!loaded) return;
    loaded = FALSE;
    
    if (textureId > 0) {
        glDeleteTextures(1, &textureId);
        textureId = 0;
    }
    
    [self freeData];
    
    if (framebufferId > 0) {
        glDeleteFramebuffers(1, &framebufferId);
        framebufferId = 0;
    }
    
    framebufferOldId = 0;
    
    if ([QuickTiGame2dEngine debug] && !isSnapshot) NSLog(@"[DEBUG] unload Texture: %@", name);
}

-(void)genTextures {
	glGenTextures(1, &textureId);
}

-(void)freeData {
    if (freed || data == nil) return;
    free(data);
    freed = TRUE;
    data = nil;
}

-(void)dealloc {
    [name release];
    [super dealloc];
}

-(float)maxS {
    return width / (float)glWidth;
}

-(float)maxT {
    return height / (float)glHeight;
}

-(GLint)textureFilter {
    if (useCustomFilter) {
        return textureFilter;
    } else {
        return [QuickTiGame2dEngine textureFilter];
    }
}

-(void)setTextureFilter:(GLint)filter {
    useCustomFilter = TRUE;
    textureFilter   = filter;
}

@end
