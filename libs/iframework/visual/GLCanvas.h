//
//  GLView.h
//  blockit
//
//  Created by Efim Voinov on 13.03.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "View.h"
#import "Font.h"
#import "Text.h"
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>

// Touch functions return TRUE if touch was handled, FALSE otherwise
@protocol TouchDelegate <NSObject>
- (bool)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (bool)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (bool)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (bool)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
@end

// opengl es based view
@interface GLCanvas : UIView 
{
@protected

	// the only context object
	EAGLContext* context;
	
	// The pixel dimensions of the backbuffer
    GLint backingWidth;
    GLint backingHeight;
    
    // OpenGL names for the renderbuffer and framebuffers used to render to this view
    GLuint viewRenderbuffer, viewFramebuffer;
    
    // OpenGL name for the depth buffer that is attached to viewFramebuffer, if it exists (0 if it does not exist)
    GLuint depthRenderbuffer;
	
	// FPS meter font
	Font* fpsFont;
	Text* fpsText;
	
	id<TouchDelegate> touchDelegate;	
}

@property (assign) id<TouchDelegate> touchDelegate;

// FPS drawer
- (id) initWithFrame:(CGRect)frame;
- (void) initFPSMeterWithFont:(Font*)font;
- (void) show;
- (void) hide;
- (void) drawFPS:(float)fps;
// present render buffer
- (void)swapBuffers;

-(void) setDefaultProjection;
@end
