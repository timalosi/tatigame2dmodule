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
#import "QuickTiGame2dUtil.h"
#import "CoreGraphics/CoreGraphics.h"
#import "UIKit/UIKit.h"
#import "math.h"

bool isPowerOfTwo(int x) {
	return (x != 0) && ((x & (x - 1)) == 0);
}

int nextPowerOfTwo(int minimum) {
	if(isPowerOfTwo(minimum)) {
		return minimum;
	}
	int i = 0;
	while(true) {
		i++;
		if(pow(2, i) >= minimum) {
			return (int)pow(2, i);
		}
	}
}

/*
 * clear all OpenGL errors
 */
void clearGLErrors(NSString* msg) {
    for (GLint error = glGetError(); error; error = glGetError()) {
        if (error != GL_NO_ERROR) {
            NSLog(@"[INFO] %@ err code=0x%x", msg, error);
        }
    }
}

BOOL checkGLErrors(NSString* msg) {
    BOOL result = TRUE;
    for (GLint error = glGetError(); error; error = glGetError()) {
        if (error != GL_NO_ERROR) {
            NSLog(@"[WARN] %@ err code=0x%x", msg, error);
            result = FALSE;
        }
    }
    return result;
}

/*
 * Convert file url into absolute path (file://localhost/a/b.png -> /a/b.png)
 */
NSString* replaceFileSchemeFromString(NSString* filename) {
    NSRange schemeRange = [filename rangeOfString:@"://"];
    if (schemeRange.location != NSNotFound) {
        filename = [filename substringFromIndex:(schemeRange.location + 3)];
        schemeRange = [filename rangeOfString:@"/"];
        if (schemeRange.location != NSNotFound) {
            filename = [filename substringFromIndex:schemeRange.location];
        }
        filename = [filename stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return filename;
}

NSString* deleteFilenameFromPath(NSString* path) {
    NSRange pathRange = [path rangeOfString:@"/"];
    if (pathRange.location == NSNotFound) return path;
    
    NSRange range = [path rangeOfString:@"/" options:NSBackwardsSearch];
    return [path substringToIndex:range.location + 1];
}

/* 
 * load png image size from resource
 */
static BOOL loadPngSize(NSString* filename, int *width, int *height) {
    NSString* path = nil;

    filename = replaceFileSchemeFromString(filename);
    
    if ([filename hasPrefix:@"/"]) {
        path = filename;
        NSFileManager* filemanager = [NSFileManager defaultManager];
        if (![filemanager fileExistsAtPath:path]) {
            NSLog(@"[WARN] loadPngSize: resource is not found %@", filename);
            return FALSE;
        }
    } else {
        path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
        // if resource is not found, search for the module assets directory
        if (path == nil) {
            path = [[NSBundle mainBundle] pathForResource:
                    [NSString stringWithFormat:@"modules/%@/%@", @SHARED_MODULE_NAME, filename] ofType:nil];
        }
        if (path == nil) {
            NSLog(@"[WARN] loadPngSize: resource is not found %@", filename);
            return FALSE;
        }
    }
	
    UIImage* uiimage = [UIImage imageWithContentsOfFile:path];
    
    CGImageRef image = uiimage.CGImage;
    *width = CGImageGetWidth(image);
    *height = CGImageGetHeight(image);
	
    return width > 0 && height > 0;
}

/* 
 * load png image from resource
 */
static BOOL loadPng(NSString* filename, QuickTiGame2dTexture* imageInfo) {
    NSString* path = nil;
    
    filename = replaceFileSchemeFromString(filename);
    
    if ([filename hasPrefix:@"/"]) {
        path = filename;
        NSFileManager* filemanager = [NSFileManager defaultManager];
        if (![filemanager fileExistsAtPath:path]) {
            NSLog(@"[WARN] loadPng: resource is not found %@", filename);
            return FALSE;
        }
    } else {
        path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
        // if resource is not found, search for the module assets directory
        if (path == nil) {
            path = [[NSBundle mainBundle] pathForResource:
                    [NSString stringWithFormat:@"modules/%@/%@", @SHARED_MODULE_NAME, filename] ofType:nil];
        }
        if (path == nil) {
            NSLog(@"[WARN] loadPng: resource is not found %@", filename);
            return FALSE;
        }
    }
	
    UIImage* uiimage = [UIImage imageWithContentsOfFile:path];

    CGImageRef image = uiimage.CGImage;
    NSInteger width = CGImageGetWidth(image);
    NSInteger height = CGImageGetHeight(image);
    
    imageInfo.textureId = -1;
    imageInfo.width  = width;
    imageInfo.height = height;
    
    GLubyte* data = (GLubyte*)malloc(width * height * 4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmpContext =
    CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(bmpContext, CGRectMake(0, 0, width, height));
    CGContextDrawImage(bmpContext, CGRectMake(0, 0, width, height), image);
    CGContextRelease(bmpContext);
	
    imageInfo.hasAlpha = true;
	imageInfo.data = data;
    imageInfo.dataLength = width * height * 4;
    imageInfo.isPNG = TRUE;
	
    return TRUE;
}
/*
 * Constants and data types for PVR Texture
 */
#define PVR_TEXTURE_FLAG_TYPE_MASK	0xff

static char gPVRTexIdentifier[4] = "PVR!";

enum {
    kPVRTextureFlagTypePVRTC_2 = 24,
    kPVRTextureFlagTypePVRTC_4
};

typedef struct _PVRTexHeader {
	uint32_t headerLength;
	uint32_t height;
	uint32_t width;
	uint32_t numMipmaps;
	uint32_t flags;
	uint32_t dataLength;
	uint32_t bpp;
	uint32_t bitmaskRed;
	uint32_t bitmaskGreen;
	uint32_t bitmaskBlue;
	uint32_t bitmaskAlpha;
	uint32_t pvrTag;
	uint32_t numSurfs;
} PVRTexHeader;

/* 
 * load pvr image size from resource
 */
static BOOL loadPvrSize(NSString* filename, int *width, int *height) {
    NSString* path = nil;
    
    filename = replaceFileSchemeFromString(filename);
    
    if ([filename hasPrefix:@"/"]) {
        path = filename;
        NSFileManager* filemanager = [NSFileManager defaultManager];
        if (![filemanager fileExistsAtPath:path]) {
            NSLog(@"[WARN] loadPvrSize: resource is not found %@", filename);
            return FALSE;
        }
    } else {
        path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
        // if resource is not found, search for the module assets directory
        if (path == nil) {
            path = [[NSBundle mainBundle] pathForResource:
                    [NSString stringWithFormat:@"modules/%@/%@", @SHARED_MODULE_NAME, filename] ofType:nil];
        }
        if (path == nil) {
            NSLog(@"[WARN] loadPvrSize: resource is not found %@", filename);
            return FALSE;
        }
    }
    
    NSData* data = [NSData dataWithContentsOfFile:path];
	PVRTexHeader* header = (PVRTexHeader *)[data bytes];
	
	uint32_t pvrTag = CFSwapInt32LittleToHost(header->pvrTag);
    
	if (gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
		gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
		gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
		gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff)) {
		return FALSE;
	}
	
	uint32_t flags = CFSwapInt32LittleToHost(header->flags);
	uint32_t formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
	
	if (formatFlags == kPVRTextureFlagTypePVRTC_4 || formatFlags == kPVRTextureFlagTypePVRTC_2){
		*width  = CFSwapInt32LittleToHost(header->width);
		*height = CFSwapInt32LittleToHost(header->height);
	} else {
        return FALSE;
    }
	
	return TRUE;
}

/* 
 * load pvr image from resource
 */
static BOOL loadPvr(NSString* filename, QuickTiGame2dTexture* imageInfo) {
    NSString* path = nil;
    
    filename = replaceFileSchemeFromString(filename);
    
    if ([filename hasPrefix:@"/"]) {
        path = filename;
        NSFileManager* filemanager = [NSFileManager defaultManager];
        if (![filemanager fileExistsAtPath:path]) {
            NSLog(@"[WARN] loadPvr: resource is not found %@", filename);
            return FALSE;
        }
    } else {
        path = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
        // if resource is not found, search for the module assets directory
        if (path == nil) {
            path = [[NSBundle mainBundle] pathForResource:
                    [NSString stringWithFormat:@"modules/%@/%@", @SHARED_MODULE_NAME, filename] ofType:nil];
        }
        if (path == nil) {
            NSLog(@"[WARN] loadPvr: resource is not found %@", filename);
            return FALSE;
        }
    }
    
    NSData* data = [NSData dataWithContentsOfFile:path];
	PVRTexHeader* header = (PVRTexHeader *)[data bytes];
	
	uint32_t pvrTag = CFSwapInt32LittleToHost(header->pvrTag);
    
	if (gPVRTexIdentifier[0] != ((pvrTag >>  0) & 0xff) ||
		gPVRTexIdentifier[1] != ((pvrTag >>  8) & 0xff) ||
		gPVRTexIdentifier[2] != ((pvrTag >> 16) & 0xff) ||
		gPVRTexIdentifier[3] != ((pvrTag >> 24) & 0xff)) {
		return FALSE;
	}
	
	uint32_t flags = CFSwapInt32LittleToHost(header->flags);
	uint32_t formatFlags = flags & PVR_TEXTURE_FLAG_TYPE_MASK;
	
	if (formatFlags == kPVRTextureFlagTypePVRTC_4 || formatFlags == kPVRTextureFlagTypePVRTC_2){
		if (formatFlags == kPVRTextureFlagTypePVRTC_4) {
			imageInfo.isPVRTC_4 = TRUE;
        } else if (formatFlags == kPVRTextureFlagTypePVRTC_2) {
			imageInfo.isPVRTC_2 = TRUE;
        }
		imageInfo.width  = CFSwapInt32LittleToHost(header->width);
		imageInfo.height = CFSwapInt32LittleToHost(header->height);
		
		if (CFSwapInt32LittleToHost(header->bitmaskAlpha)) {
			imageInfo.hasAlpha = TRUE;
        } else {
			imageInfo.hasAlpha = FALSE;
        }
		
		imageInfo.dataLength = CFSwapInt32LittleToHost(header->dataLength);
        
        GLubyte* rawData = (GLubyte *)malloc(sizeof(GLubyte) * imageInfo.dataLength);
        memcpy(rawData, [data bytes] + sizeof(PVRTexHeader), imageInfo.dataLength);
		imageInfo.data = rawData;
        
        imageInfo.textureId = -1;
        
	} else {
        return FALSE;
    }
	
	return TRUE;
}

BOOL loadImageSize(NSString* filename, int *width, int *height) {
    if ([[filename lowercaseString] hasSuffix:@".png"]) return loadPngSize(filename, width, height);
    if ([[filename lowercaseString] hasSuffix:@".pvr"]) return loadPvrSize(filename, width, height);
    return FALSE;
}

BOOL loadImage(NSString* filename, QuickTiGame2dTexture* imageInfo) {
    if ([[filename lowercaseString] hasSuffix:@".png"]) return loadPng(filename, imageInfo);
    if ([[filename lowercaseString] hasSuffix:@".pvr"]) return loadPvr(filename, imageInfo);
    return FALSE;
}

BOOL loadImageWithData(NSString* filename, QuickTiGame2dTexture* imageInfo, NSData* texdata) {
    UIImage* uiimage = [UIImage imageWithData:texdata];
    
    CGImageRef image = uiimage.CGImage;
    NSInteger width = CGImageGetWidth(image);
    NSInteger height = CGImageGetHeight(image);
    
    imageInfo.textureId = -1;
    imageInfo.width  = width;
    imageInfo.height = height;
    
    GLubyte* data = (GLubyte*)malloc(width * height * 4);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef bmpContext =
    CGBitmapContextCreate(data, width, height, 8, width * 4, colorSpace, kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(bmpContext, CGRectMake(0, 0, width, height));
    CGContextDrawImage(bmpContext, CGRectMake(0, 0, width, height), image);
    CGContextRelease(bmpContext);
	
    imageInfo.hasAlpha = true;
	imageInfo.data = data;
    imageInfo.dataLength = width * height * 4;
    
    return TRUE;
}

void gluLookAt(GLfloat eyex, GLfloat eyey, GLfloat eyez,
               GLfloat centerx, GLfloat centery, GLfloat centerz,
               GLfloat upx, GLfloat upy, GLfloat upz) {
    GLfloat m[16];
    GLfloat x[3], y[3], z[3];
    GLfloat mag;
    
    /* Make rotation matrix */
    
    /* Z vector */
    z[0] = eyex - centerx;
    z[1] = eyey - centery;
    z[2] = eyez - centerz;
    mag = sqrt(z[0] * z[0] + z[1] * z[1] + z[2] * z[2]);
    if (mag) {          /* mpichler, 19950515 */
        z[0] /= mag;
        z[1] /= mag;
        z[2] /= mag;
    }
    
    /* Y vector */
    y[0] = upx;
    y[1] = upy;
    y[2] = upz;
    
    /* X vector = Y cross Z */
    x[0] = y[1] * z[2] - y[2] * z[1];
    x[1] = -y[0] * z[2] + y[2] * z[0];
    x[2] = y[0] * z[1] - y[1] * z[0];
    
    /* Recompute Y = Z cross X */
    y[0] = z[1] * x[2] - z[2] * x[1];
    y[1] = -z[0] * x[2] + z[2] * x[0];
    y[2] = z[0] * x[1] - z[1] * x[0];
    
    /* mpichler, 19950515 */
    /* cross product gives area of parallelogram, which is < 1.0 for
     * non-perpendicular unit-length vectors; so normalize x, y here
     */
    
    mag = sqrt(x[0] * x[0] + x[1] * x[1] + x[2] * x[2]);
    if (mag) {
        x[0] /= mag;
        x[1] /= mag;
        x[2] /= mag;
    }
    
    mag = sqrt(y[0] * y[0] + y[1] * y[1] + y[2] * y[2]);
    if (mag) {
        y[0] /= mag;
        y[1] /= mag;
        y[2] /= mag;
    }
    
#define M(row,col)  m[col*4+row]
    M(0, 0) = x[0];
    M(0, 1) = x[1];
    M(0, 2) = x[2];
    M(0, 3) = 0.0;
    M(1, 0) = y[0];
    M(1, 1) = y[1];
    M(1, 2) = y[2];
    M(1, 3) = 0.0;
    M(2, 0) = z[0];
    M(2, 1) = z[1];
    M(2, 2) = z[2];
    M(2, 3) = 0.0;
    M(3, 0) = 0.0;
    M(3, 1) = 0.0;
    M(3, 2) = 0.0;
    M(3, 3) = 1.0;
#undef M
    glMultMatrixf(m);
    
    /* Translate Eye to Origin */
    glTranslatef(-eyex, -eyey, -eyez);
    
}

void gluPerspective(GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar) {
    GLfloat f = 1.0f / tanf(fovy * (M_PI/360.0));
	GLfloat m [16];
    
	m[0] = f / aspect;
	m[1] = 0.0;
	m[2] = 0.0;
	m[3] = 0.0;
    
	m[4] = 0.0;
	m[5] = f;
	m[6] = 0.0;
	m[7] = 0.0;
    
	m[8] = 0.0;
	m[9] = 0.0;
	m[10] = (zFar + zNear) / (zNear - zFar);
	m[11] = -1.0;
    
	m[12] = 0.0;
	m[13] = 0.0;
	m[14] = 2.0 * zFar * zNear / (zNear - zFar);
	m[15] = 0.0;
    
	glMultMatrixf(m);
}