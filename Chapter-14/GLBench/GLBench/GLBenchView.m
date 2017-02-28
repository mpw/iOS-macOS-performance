//
//  GLBenchView.m
//  Cocoa OpenGL
//
//  Created by Marcel Weiher on 1/1/14.
//
//

#import "GLBenchView.h"
#import <OpenGL/gl.h>
#import <ApplicationServices/ApplicationServices.h>
#import <EGOS_Cocoa/MPWCGDrawingContext.h>


//#import <OpenGL/glext.h>
//#import <OpenGL/glu.h>

@implementation GLBenchView



// pixel format definition
+ (NSOpenGLPixelFormat*) basicPixelFormat1
{
    NSOpenGLPixelFormatAttribute attributes [] = {
        NSOpenGLPFAWindow,
        NSOpenGLPFADoubleBuffer,	// double buffered
        NSOpenGLPFADepthSize, (NSOpenGLPixelFormatAttribute)16, // 16 bit depth buffer
        (NSOpenGLPixelFormatAttribute)nil
    };
    return [[NSOpenGLPixelFormat alloc] initWithAttributes:attributes];
}


-(id) initWithFrame: (NSRect) frameRect
{
	self = [super initWithFrame: frameRect];
    [self  setWantsBestResolutionOpenGLSurface:YES];
    return self;
}

- (void) resizeGL
{
	NSRect viewRect = [self convertRectToBacking:[self bounds]];
    glViewport (0, 0, viewRect.size.width, viewRect.size.width);
}


-(void)drawOn1:(id <MPWDrawingContext>)aContext inRect:(NSRect)dirtyRect
{
    int iterations=10000;
    NSLog(@"self: %@",self);
    CGContextRef context=[[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetRGBFillColor(context, 1.0,0.5,0.5,1.0 );
    CGContextAddRect( context, dirtyRect);
    CGContextFillPath( context );
    CGContextScaleCTM( context, [self frame].size.width,[self frame].size.height );
    CGContextTranslateCTM( context, 0.25 , 0.5);
    CGContextScaleCTM( context,0.2, 0.2);
    
    for (int i=0;i<iterations;i++) {
        float a =  (float)i / (float)iterations;
        CGContextSetRGBFillColor(context, 1.0f, 0.85f, 0.35f + a,0.4);
        a*=2;
        CGContextMoveToPoint( context, 0.0 + a,  0.6);
        CGContextAddLineToPoint( context, -0.2 + a, -0.3);
        CGContextAddLineToPoint( context, 0.2 + a , -0.3);
        CGContextClosePath(context);
        CGContextFillPath( context );
        
    }
}

-(void)drawOn:(id <MPWDrawingContext>)aContext inRect:(NSRect)dirtyRect
{
    NSLog(@"draw");
    int iterations=10000;
    [aContext ingsave:^(id<MPWDrawingContext> aContext) {
        [aContext setFillColor:[aContext colorRed:1.0 green:0.5 blue:0.5 alpha:1.0]];
//        [[aContext nsrect:dirtyRect] fill];
        
        [aContext scale:[self frame].size.width :[self frame].size.height];
        [aContext translate:0.1 :0.25];
        [aContext scale:0.4 :0.7];
        
        for (int i=0;i<iterations;i++) {
            float a =  (float)i / (float)iterations;
            [aContext setFillColor:[aContext colorRed:0.9 green:0.55 blue:0.35+a alpha:0.4]];
            a*=2;
            [aContext moveto:0.0+a :0.6];
            [aContext lineto:-0.2+a :-0.3];
            [aContext lineto:0.2+a :-0.3];
            [aContext closepath];
            [aContext fill];
            
        }
        
    }];
    NSLog(@"finish draw");
}



- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
    NSTimeInterval time=-[NSDate timeIntervalSinceReferenceDate];
    NSLog(@"frame width: %g height: %g",[self frame].size.width,[self frame].size.height);
    NSLog(@"bounds width: %g height: %g",[self bounds].size.width,[self bounds].size.height);
#if 1
    int iterations=10000;
    glClearColor(1.0, 0.5, 0.5, 0.5);
    glClear(GL_COLOR_BUFFER_BIT);
    glDisable(GL_BLEND);
//    glEnable (GL_BLEND);
//    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glPushMatrix();
    glScalef(0.4, 0.4, 1.0);
    for (int i=0;i<iterations;i++) {
        float a = -0.5 + (float)i / (float)iterations;
        glColor4f(1.0f, 0.85f, 0.35f + a,0.4);

        glBegin(GL_POLYGON);
        {
            a*=2;
            glVertex3f(  0.0 + a,  0.6, 0.0);
            glVertex3f( -0.2 + a, -0.3, 0.0);
            glVertex3f(  0.2 + a , -0.3 ,0.0);
            glVertex3f(  0.0 + a,  0.6, 0.0);
        }
        glEnd();
    }
    glPopMatrix();
    glFinish();
    
#else
    MPWCGDrawingContext *context=[MPWCGDrawingContext currentContext];
    [self drawOn:context inRect:dirtyRect];
    
   
#endif
    time+=[NSDate timeIntervalSinceReferenceDate];
    NSLog(@"finish drawRect in %g ms",time*1000);
}

@end
