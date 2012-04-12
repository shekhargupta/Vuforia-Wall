/*==============================================================================
Copyright (c) 2012 QUALCOMM Austria Research Center GmbH .
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/


#import "EAGLView.h"
#import "Cube.h"
#import "BowlAndSpoonModel.h"
#include <sys/time.h>

#import "QCARutils.h"
#import "Texture.h"
#import <QCAR/Renderer.h>
#import <QCAR/MultiTarget.h>

#ifndef USE_OPENGL1
#import "ShaderUtils.h"
#endif


namespace {
    // Texture filenames
    const char* textureFilenames[] = {
        "TextureWireframe.png",
        "TextureBowlAndSpoon.png"
    };
    
    // Constants:
    const float kCubeScaleX = 120.0f * 0.75f / 2.0f;
    const float kCubeScaleY = 120.0f * 1.00f / 2.0f;
    const float kCubeScaleZ = 120.0f * 0.50f / 2.0f;
    
    const float kBowlScaleX = 120.0f * 0.15f;
    const float kBowlScaleY = 120.0f * 0.15f;
    const float kBowlScaleZ = 120.0f * 0.15f;
        
    void initMIT();
    void animateBowl(QCAR::Matrix44F& modelViewMatrix);
    
    
    QCAR::MultiTarget* mit = NULL;
}


@implementation EAGLView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self)
    {
        // create list of textures we want loading - ARViewController will do this for us
        int nTextures = sizeof(textureFilenames) / sizeof(textureFilenames[0]);
        for (int i = 0; i < nTextures; ++i)
            [textureList addObject: [NSString stringWithUTF8String:textureFilenames[i]]];
    }
    return self;
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


////////////////////////////////////////////////////////////////////////////////
// Draw the current frame using OpenGL
//
// This method is called by QCAR when it wishes to render the current frame to
// the screen.
//
// *** QCAR will call this method on a background thread ***
- (void)renderFrameQCAR
{
    if (APPSTATUS_CAMERA_RUNNING == qUtils.appStatus) {
        [super setFramebuffer];
        
        //LOG("Java_com_qualcomm_QCARSamples_MultiTargets_GLRenderer_renderFrame");
        ShaderUtils::checkGlError("Check gl errors prior render Frame");
        
        // Clear color and depth buffer 
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        // Render video background:
        QCAR::State state = QCAR::Renderer::getInstance().begin();
        QCAR::Renderer::getInstance().drawVideoBackground();        
        
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        
        // Did we find any trackables this frame?
        if (state.getNumActiveTrackables())
        {
            // Get the trackable:
            const QCAR::Trackable* trackable=NULL;
            int numTrackables=state.getNumActiveTrackables();
            
            // Browse trackables searching for the MultiTarget
            for (int j=0;j<numTrackables;j++)
            {
                trackable = state.getActiveTrackable(j);
                if (trackable->getType() == QCAR::Trackable::MULTI_TARGET) break;
                trackable=NULL;
            }
            
            // If it was not found exit
            if (trackable==NULL)
            {
                // Clean up and leave
                glDisable(GL_BLEND);
                glDisable(GL_DEPTH_TEST);
                
                QCAR::Renderer::getInstance().end();
                return;
            }
            
            
            QCAR::Matrix44F modelViewMatrix =
            QCAR::Tool::convertPose2GLMatrix(trackable->getPose());        
            QCAR::Matrix44F modelViewProjection;
            ShaderUtils::scalePoseMatrix(kCubeScaleX, kCubeScaleY, kCubeScaleZ,
                                         &modelViewMatrix.data[0]);
            ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0],
                                        &modelViewMatrix.data[0],
                                        &modelViewProjection.data[0]);
            
            glUseProgram(shaderProgramID);
            
            // Draw the cube:
            
            glEnable(GL_CULL_FACE);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0,
                                  (const GLvoid*) &cubeVertices[0]);
            
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0,
                                  (const GLvoid*) &cubeNormals[0]);
            
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0,
                                  (const GLvoid*) &cubeTexCoords[0]);
            
            glEnableVertexAttribArray(vertexHandle);
            
            glEnableVertexAttribArray(normalHandle);
            
            glEnableVertexAttribArray(textureCoordHandle);
            
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, [[textures objectAtIndex:0] textureID]);
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE,
                               (GLfloat*)&modelViewProjection.data[0] );
            glDrawElements(GL_TRIANGLES, NUM_CUBE_INDEX, GL_UNSIGNED_SHORT,
                           (const GLvoid*) &cubeIndices[0]);
            glDisable(GL_CULL_FACE);
            
            // Draw the bowl:
            modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());  
            
            // Remove the following line to make the bowl stop spinning:
            animateBowl(modelViewMatrix);
            
            ShaderUtils::translatePoseMatrix(0.0f, -0.50f*120.0f, 1.35f*120.0f,
                                             &modelViewMatrix.data[0]);
            ShaderUtils::rotatePoseMatrix(-90.0f, 1.0f, 0, 0,
                                          &modelViewMatrix.data[0]);
            
            ShaderUtils::scalePoseMatrix(kBowlScaleX, kBowlScaleY, kBowlScaleZ,
                                         &modelViewMatrix.data[0]);
            ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0],
                                        &modelViewMatrix.data[0],
                                        &modelViewProjection.data[0]);
            
            glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0,
                                  (const GLvoid*) &objectVertices[0]);
            glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0,
                                  (const GLvoid*) &objectNormals[0]);
            glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0,
                                  (const GLvoid*) &objectTexCoords[0]);
            
            glBindTexture(GL_TEXTURE_2D, [[textures objectAtIndex:1] textureID]);
            
            glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE,
                               (GLfloat*)&modelViewProjection.data[0] );
            
            glDrawElements(GL_TRIANGLES, NUM_OBJECT_INDEX, GL_UNSIGNED_SHORT,
                           (const GLvoid*) &objectIndices[0]);
            
            ShaderUtils::checkGlError("MultiTargets renderFrameQCAR");
            
        }
        
        glDisable(GL_BLEND);
        glDisable(GL_DEPTH_TEST);
        
        glDisableVertexAttribArray(vertexHandle);
        glDisableVertexAttribArray(normalHandle);
        glDisableVertexAttribArray(textureCoordHandle);
        
        QCAR::Renderer::getInstance().end();
        [super presentFramebuffer];
    }
}



namespace {
    void
    initMIT()
    {
        //
        // This function checks the current tracking setup for completeness. If
        // it finds that something is missing, then it creates it and configures it:
        // Any MultiTarget and Part elements missing from the config.xml file
        // will be created.
        //
        
        NSLog(@"Beginning to check the tracking setup");
        
        // Configuration data - identical to what is in the config.xml file
        //
        // If you want to recreate the trackable assets using the on-line TMS server 
        // using the original images provided in the sample's media folder, use the
        // following trackable sizes on creation to get identical visual results:
        // create a cuboid with width = 90 ; height = 120 ; length = 60.
        
        const char* names[6]   = { "FlakesBox.Front", "FlakesBox.Back", "FlakesBox.Left", "FlakesBox.Right", "FlakesBox.Top", "FlakesBox.Bottom" };
        const float trans[3*6] = { 0.0f,  0.0f,  30.0f, 
            0.0f,  0.0f, -30.0f,
            -45.0f, 0.0f,  0.0f, 
            45.0f, 0.0f,  0.0f,
            0.0f,  60.0f, 0.0f,
            0.0f, -60.0f, 0.0f };
        const float rots[4*6]  = { 1.0f, 0.0f, 0.0f,   0.0f,
            0.0f, 1.0f, 0.0f, 180.0f,
            0.0f, 1.0f, 0.0f, -90.0f,
            0.0f, 1.0f, 0.0f,  90.0f,
            1.0f, 0.0f, 0.0f, -90.0f,
            1.0f, 0.0f, 0.0f,  90.0f };
        
        mit = [[QCARutils getInstance] findMultiTarget];
        if (mit == NULL)
            return;
        
        // Try to find each ImageTarget. If we find it, this actually means that it
        // is not part of the MultiTarget yet: ImageTargets that are part of a
        // MultiTarget don't show up in the list of Trackables.
        // Each ImageTarget that we found, is then made a part of the
        // MultiTarget and a correct pose (reflecting the pose of the
        // config.xml file) is set).
        // 
        int numAdded = 0;
        for(int i=0; i<6; i++)
        {
            if(QCAR::ImageTarget* it = [[QCARutils getInstance] findImageTarget:names[i]])
            {
                NSLog(@"ImageTarget '%s' found -> adding it as to the MultiTarget",
                      names[i]);
                
                int idx = mit->addPart(it);
                QCAR::Vec3F t(trans+i*3),a(rots+i*4);
                QCAR::Matrix34F mat;
                
                QCAR::Tool::setTranslation(mat, t);
                QCAR::Tool::setRotation(mat, a, rots[i*4+3]);
                mit->setPartOffset(idx, mat);
                numAdded++;
            }
        }
        
        NSLog(@"Added %d ImageTarget(s) to the MultiTarget", numAdded);
        
        if(mit->getNumParts()!=6)
        {
            NSLog(@"ERROR: The MultiTarget should have 6 parts, but it reports %d parts",
                  mit->getNumParts());
        }
        
        NSLog(@"Finished checking the tracking setup");
    }
    
    double
    getCurrentTime()
    {
        struct timeval tv;
        gettimeofday(&tv, NULL);
        double t = tv.tv_sec + tv.tv_usec/1000000.0;
        return t;
    }
    
    
    void
    animateBowl(QCAR::Matrix44F& modelViewMatrix)
    {
        static float rotateBowlAngle = 0.0f;
        
        static double prevTime = getCurrentTime();
        double time = getCurrentTime();             // Get real time difference
        float dt = (float)(time-prevTime);          // from frame to frame
        
        rotateBowlAngle += dt * 180.0f/3.1415f;     // Animate angle based on time
        
        ShaderUtils::rotatePoseMatrix(rotateBowlAngle, 0.0f, 1.0f, 0.0f,
                                      &modelViewMatrix.data[0]);
        
        prevTime = time;
    }
}

@end
