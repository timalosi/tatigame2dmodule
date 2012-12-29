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
#import "QuartzCore/QuartzCore.h"

#import "QuickTiGame2dView.h"
#import "QuickTiGame2dConstant.h"

@interface QuickTiGame2dView (PrivateMethods)
- (void)createFramebuffer;
- (void)deleteFramebuffer;
@end

@implementation QuickTiGame2dView

@synthesize width=framebufferWidth;
@synthesize height=framebufferHeight;
@synthesize eventDelegate;
@synthesize isRetina;
@synthesize framebuffer=defaultFramebuffer;
@dynamic context;

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
	if (self)
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        
        eaglLayer.opaque = TRUE;
        eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:FALSE], kEAGLDrawablePropertyRetainedBacking,
                                        kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat,
                                        nil];
    }
    
    return self;
}

- (void)dealloc
{
    [self deleteFramebuffer];    
    [context release];
    
    [super dealloc];
}

- (EAGLContext *)context
{
    return context;
}

- (void)setContext:(EAGLContext *)newContext
{
    if (context != newContext)
    {
        [self deleteFramebuffer];
        
        [context release];
        context = [newContext retain];
        
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)createFramebuffer
{
    if (context && !defaultFramebuffer)
    {
        [EAGLContext setCurrentContext:context];
		
		// detect retina display
		if (useRetina && UIGraphicsBeginImageContextWithOptions != NULL) {
			self.contentScaleFactor  = RETINA_SCALE_FACTOR;
			self.layer.contentsScale = RETINA_SCALE_FACTOR;
			isRetina = TRUE;
		} else {
			isRetina = FALSE;
		}
        
        glGenFramebuffers(1, &defaultFramebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
        
        glGenRenderbuffers(1, &colorRenderbuffer);
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);

        [context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);
        
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
        
        glGenRenderbuffers(1, &depthRenderbuffer);
        
        glBindRenderbuffer(GL_RENDERBUFFER, depthRenderbuffer);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, framebufferWidth, framebufferHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderbuffer);

        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        if (glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)
            NSLog(@"Failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
    }
}

- (void)deleteFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (defaultFramebuffer)
        {
            glDeleteFramebuffers(1, &defaultFramebuffer);
            defaultFramebuffer = 0;
        }
        
        if (colorRenderbuffer)
        {
            glDeleteRenderbuffers(1, &colorRenderbuffer);
            colorRenderbuffer = 0;
        }
        
        if (depthRenderbuffer)
        {
            glDeleteRenderbuffers(1, &depthRenderbuffer);
            depthRenderbuffer = 0;
        }
    }
}

- (void)setFramebuffer
{
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        if (!defaultFramebuffer)
            [self createFramebuffer];
        
        glBindFramebuffer(GL_FRAMEBUFFER, defaultFramebuffer);
    }
}

- (BOOL)presentFramebuffer
{
    BOOL success = FALSE;
    
    if (context)
    {
        [EAGLContext setCurrentContext:context];
        
        glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
        
        success = [context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}

- (void)layoutSubviews
{
    [self deleteFramebuffer];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (eventDelegate) {
		[eventDelegate touchesBegan:touches withEvent:event];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (eventDelegate) {
		[eventDelegate touchesMoved:touches withEvent:event];
	}	
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    /**
    // Save screenshot to Photo Album
    UIImage* screenShot = [self toImage];
    UIImageWriteToSavedPhotosAlbum(screenShot, self,
                                   @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:), nil);
     **/
	if (eventDelegate) {
		[eventDelegate touchesEnded:touches withEvent:event];
	}	
}

// Show alert when screenshot is saved
-(void)savingImageIsFinished:(UIImage*)image
    didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo{
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:nil
                                  message:@"Saved" delegate:nil
                        cancelButtonTitle:nil otherButtonTitles:@"OK", nil] autorelease];
    [alert show];
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	if (eventDelegate) {
		[eventDelegate touchesCancelled:touches withEvent:event];
	}	
}
- (void)enableRetina:(BOOL)enable {
	useRetina = enable;
}

-(UIImage*)toImage {
    NSInteger dataLength = framebufferWidth * framebufferHeight * 4;
    GLubyte *buffer =  (GLubyte *) malloc(dataLength);
    GLubyte *buffer2 = (GLubyte *) malloc(dataLength);
    glReadPixels(0, 0, framebufferWidth, framebufferHeight, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid *)buffer);
    for(int y = 0; y < framebufferHeight; y++) {
        memcpy(&buffer2[((framebufferHeight-1) - y) * framebufferWidth * 4],
               &buffer[y * 4 * framebufferWidth], sizeof(GLubyte) * framebufferWidth * 4);
    }
    free(buffer);
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer2, dataLength, NULL);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGImageRef imageRef = CGImageCreate(framebufferWidth, framebufferHeight,
                                        8, 32,
                                        4 * framebufferWidth, colorSpaceRef,
                                        kCGBitmapByteOrderDefault, provider,
                                        NULL, NO,
                                        kCGRenderingIntentDefault);
    UIImage *uiImage = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGColorSpaceRelease(colorSpaceRef);
    CGDataProviderRelease(provider);
    free(buffer2);
    
    return uiImage;
}
@end
