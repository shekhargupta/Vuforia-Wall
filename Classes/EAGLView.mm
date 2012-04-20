/*==============================================================================
 Copyright (c) 2012 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

// Subclassed from AR_EAGLView
#import "EAGLView.h"
#import "Teapot.h"
#import "Texture.h"

#import <QCAR/Renderer.h>

#import "QCARutils.h"

#ifndef USE_OPENGL1
#import "ShaderUtils.h"
#endif


#import "Plane3D.h"
#import "ImageWall.h"
#import "TouchImageView.h"

namespace {
    // Teapot texture filenames
    const char* textureFilenames[] = {
		"target.png",
//        "TextureTeapotBrass.png",
        "target.png",
        "target.png"
    };

    // Model scale factor
    const float kObjectScale = 50.0f;
}


@implementation EAGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self)
    {
		NSLog(@"EAGLView initWithFrame");
		
        // create list of textures we want loading - ARViewController will do this for us
        int nTextures = sizeof(textureFilenames) / sizeof(textureFilenames[0]);
        for (int i = 0; i < nTextures; ++i) {
            [textureList addObject: [NSString stringWithUTF8String:textureFilenames[i]]];
		}
		
    }
    return self;
}

- (void)setup3dObjects
{
    // build the array of objects we want drawn and their texture
    // in this example we have 3 targets and require 3 models
    // but using the same underlying 3D model of a teapot, differentiated
    // by using a different texture for each
    
	NSLog(@"EAGLView setup3dObjects");
	
	NSLog(@" ImageWall count %d", [ImageWall sharedInstance].images.count);
    for (int i=0; i < [ImageWall sharedInstance].images.count; i++)
    {
		Plane3D *obj3D = [[Plane3D alloc] init];
		TouchImageView* imageView = [[ImageWall sharedInstance].images objectAtIndex:i];
		
		
		obj3D.dx = [imageView myX];
		obj3D.dy = [imageView myY];
		obj3D.rotation = [imageView myRotation];
		obj3D.scale = [imageView myScale];
		
		
		NSLog(@"Setup3dObjects: image info [w,h,tx,ty,scale,rotation] = [%f,%f,%f,%f,%f,%f]",
			  imageView.image.size.width,
			  imageView.image.size.height,
			  obj3D.dx,
			  obj3D.dy,
			  obj3D.scale,
			  obj3D.rotation
		);
		
		[obj3D setTextureWithImage:imageView.image];
		
		[objects3D addObject:obj3D];
//ARCfix        [obj3D release];
    }
}


// called after QCAR is initialised but before the camera starts
- (void) postInitQCAR
{
    // These two calls to setHint tell QCAR to split work over multiple
    // frames.  Depending on your requirements you can opt to omit these.
    QCAR::setHint(QCAR::HINT_IMAGE_TARGET_MULTI_FRAME_ENABLED, 1);
    QCAR::setHint(QCAR::HINT_IMAGE_TARGET_MILLISECONDS_PER_MULTI_FRAME, 25);
    
    // Here we could also make a QCAR::setHint call to set the maximum
    // number of simultaneous targets                
    // QCAR::setHint(QCAR::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, 2);
}

// modify renderFrameQCAR here if you want a different 3D rendering model
////////////////////////////////////////////////////////////////////////////////
// Draw the current frame using OpenGL
//
// This method is called by QCAR when it wishes to render the current frame to
// the screen.
//
// *** QCAR will call this method on a single background thread ***
- (void)renderFrameQCAR
{
    [self setFramebuffer];
    
    // Clear colour and depth buffers
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Render video background and retrieve tracking state
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    QCAR::Renderer::getInstance().drawVideoBackground();
    
    //NSLog(@"active trackables: %d", state.getNumActiveTrackables());
    
    if (QCAR::GL_11 & qUtils.QCARFlags) {
        glEnable(GL_TEXTURE_2D);
        glDisable(GL_LIGHTING);
        glEnableClientState(GL_VERTEX_ARRAY);
        glEnableClientState(GL_NORMAL_ARRAY);
        glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    }
    
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
	if (state.getNumActiveTrackables() > 0) {
//    for (int i = 0; i < state.getNumActiveTrackables(); ++i) {
		int i = 0;
		
        // Get the trackable
        const QCAR::Trackable* trackable = state.getActiveTrackable(i);
        
        // Choose the texture based on the target name
        int targetIndex = 0; // "stones"
        if (!strcmp(trackable->getName(), "chips"))
            targetIndex = 1;
        else if (!strcmp(trackable->getName(), "tarmac"))
            targetIndex = 2;
        
		for (int j=0; j<objects3D.count; j++) {
			QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());
			
			Object3D *obj3D = [objects3D objectAtIndex:j];
			
			// Render using the appropriate version of OpenGL
			if (QCAR::GL_11 & qUtils.QCARFlags) {
				// Load the projection matrix
				glMatrixMode(GL_PROJECTION);
				glLoadMatrixf(qUtils.projectionMatrix.data);
				
				// Load the model-view matrix
				glMatrixMode(GL_MODELVIEW);
				glLoadMatrixf(modelViewMatrix.data);
				
				//            glTranslatef(0.0f, 0.0f, -kObjectScale);
				glScalef(kObjectScale, kObjectScale, kObjectScale);
				
				// Draw object
				glTranslatef(0, 0, 0.00001*j);
				glTranslatef(obj3D.dx * 0.01, obj3D.dy * -0.01, 0.0);
				glRotatef(-obj3D.rotation, 0, 0, 1);
				glScalef(obj3D.scale, obj3D.scale, 1.0);
				
				glBindTexture(GL_TEXTURE_2D, obj3D.texture.textureID);
				glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid*)obj3D.texCoords);
				glVertexPointer(3, GL_FLOAT, 0, (const GLvoid*)obj3D.vertices);
				glNormalPointer(GL_FLOAT, 0, (const GLvoid*)obj3D.normals);
				glDrawElements(GL_TRIANGLES, obj3D.numIndices, GL_UNSIGNED_SHORT, (const GLvoid*)obj3D.indices);
			}
#ifndef USE_OPENGL1
			else {
				// OpenGL 2
				QCAR::Matrix44F modelViewProjection;
				
				ShaderUtils::scalePoseMatrix(kObjectScale, kObjectScale, kObjectScale, &modelViewMatrix.data[0]);
				ShaderUtils::translatePoseMatrix(0, 0, 0.00001*j, &modelViewMatrix.data[0]);
				
				ShaderUtils::rotatePoseMatrix(-obj3D.rotation, 0, 0, 1, &modelViewMatrix.data[0]);
				ShaderUtils::translatePoseMatrix(obj3D.dx * 0.01, obj3D.dy * -0.01, 0, &modelViewMatrix.data[0]);
				ShaderUtils::scalePoseMatrix(obj3D.scale, obj3D.scale, 1.0, &modelViewMatrix.data[0]);
				
				ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
				
				glUseProgram(shaderProgramID);
				
				glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)obj3D.vertices);
				glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)obj3D.normals);
				glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)obj3D.texCoords);
				
				glEnableVertexAttribArray(vertexHandle);
				glEnableVertexAttribArray(normalHandle);
				glEnableVertexAttribArray(textureCoordHandle);
				
				
				glActiveTexture(GL_TEXTURE0);
				glBindTexture(GL_TEXTURE_2D, [obj3D.texture textureID]);
				glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (const GLfloat*)&modelViewProjection.data[0]);
				glDrawElements(GL_TRIANGLES, obj3D.numIndices, GL_UNSIGNED_SHORT, (const GLvoid*)obj3D.indices);
				
				ShaderUtils::checkGlError("EAGLView renderFrameQCAR");
			}
#endif
		}
	}
	
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    if (QCAR::GL_11 & qUtils.QCARFlags) {
        glDisable(GL_TEXTURE_2D);
        glDisableClientState(GL_VERTEX_ARRAY);
        glDisableClientState(GL_NORMAL_ARRAY);
        glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    }
#ifndef USE_OPENGL1
    else {
        glDisableVertexAttribArray(vertexHandle);
        glDisableVertexAttribArray(normalHandle);
        glDisableVertexAttribArray(textureCoordHandle);
    }
#endif
    
    QCAR::Renderer::getInstance().end();
    [self presentFramebuffer];
}

@end
