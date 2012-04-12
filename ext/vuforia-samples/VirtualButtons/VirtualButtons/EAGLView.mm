/*==============================================================================
Copyright (c) 2012 QUALCOMM Austria Research Center GmbH .
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/


#import <QuartzCore/QuartzCore.h>
#import "EAGLView.h"
#import "Texture.h"
#import "QCARutils.h"
#import <QCAR/Renderer.h>
#import <QCAR/Rectangle.h>
#import <QCAR/VirtualButton.h>
#import <QCAR/UpdateCallback.h>

#import "Teapot.h"

#ifndef USE_OPENGL1
#import "ShaderUtils.h"
#define MAKESTRING(x) #x
#import "Shaders/VBShader.fsh"
#import "Shaders/VBShader.vsh"
#endif

namespace {
    enum tagButtons {
        BUTTON_1 = 1,
        BUTTON_2 = 1 << 1,
        BUTTON_3 = 1 << 2,
        BUTTON_4 = 1 << 3,
        NUM_BUTTONS = 4
    };
        
    // Virtual button mask
    int buttonMask;

    // Model scale factor
    const float kObjectScale = 3.0f;
    
    // Virtual button names
    const char* virtualButtonColors[] = {
        "red",
        "blue",
        "yellow",
        "green"
    };
    
    // Teapot texture filenames
    const char* textureFilenames[] = {
        "TextureTeapotBrass.png",
        "TextureTeapotRed.png",
        "TextureTeapotBlue.png",
        "TextureTeapotYellow.png",
        "TextureTeapotGreen.png"
    };
    
    class VirtualButton_UpdateCallback : public QCAR::UpdateCallback {
        virtual void QCAR_onUpdate(QCAR::State& state);
    } qcarUpdate;
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
        
        buttonMask = 0;
    }
    return self;
}

- (void)initShaders
{
    // Initialise shader used for augmentation
    [super initShaders];
    
    // Initialise shader used for virtual buttons    
#ifndef USE_OPENGL1
        // OpenGL 2 initialisation
        vbShaderProgramID = ShaderUtils::createProgramFromBuffer(lineVertexShader, lineFragmentShader);
        
        if (0 < vbShaderProgramID) {
            vbVertexHandle = glGetAttribLocation(shaderProgramID, "vertexPosition");
        }
        else {
            NSLog(@"Could not initialise augmentation shader");
        }
#endif
    
}


////////////////////////////////////////////////////////////////////////////////
// Do the things that need doing after initialisation
// called after QCAR is initialised but before the camera starts
- (void)postInitQCAR
{
    // These two calls to setHint tell QCAR to split work over multiple
    // frames.  Depending on your requirements you can opt to omit these.
    QCAR::setHint(QCAR::HINT_IMAGE_TARGET_MULTI_FRAME_ENABLED, 1);
    QCAR::setHint(QCAR::HINT_IMAGE_TARGET_MILLISECONDS_PER_MULTI_FRAME, 25);
    
    // Here we could also make a QCAR::setHint call to set the maximum
    // number of simultaneous targets                
    // QCAR::setHint(QCAR::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, 2);

    // register for our call back after tracker processing is done
    QCAR::registerCallback(&qcarUpdate);
}


////////////////////////////////////////////////////////////////////////////////
// Draw the current frame using OpenGL
//
// This method is called by QCAR when it wishes to render the current frame to
// the screen.
//
// *** QCAR will call this method on a single background thread ***
- (void)renderFrameQCAR
{
    if (APPSTATUS_CAMERA_RUNNING == qUtils.appStatus) {
        [self setFramebuffer];
        
        // Clear colour and depth buffers
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        // Render video background and retrieve tracking state
        QCAR::State state = QCAR::Renderer::getInstance().begin();
        QCAR::Renderer::getInstance().drawVideoBackground();        
        
        if (QCAR::GL_11 & qUtils.QCARFlags) {
            glDisable(GL_LIGHTING);
            glEnableClientState(GL_VERTEX_ARRAY);
            glEnableClientState(GL_NORMAL_ARRAY);
            glEnableClientState(GL_TEXTURE_COORD_ARRAY);
        }
        
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        
        for (int i = 0; i < state.getNumActiveTrackables(); ++i) {
            // Get the trackable
            const QCAR::Trackable* trackable = state.getActiveTrackable(i);
            QCAR::Matrix44F modelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());
            
            // The image target
            const QCAR::ImageTarget* target = static_cast<const QCAR::ImageTarget*>(trackable);
            
            // Set the texture index for the teapot model
            int textureIndex = 0;

            GLfloat vbVertices[96];
            unsigned char vbCounter=0;
            
            // Iterate through this target's virtual buttons:
            for (int i = 0; i < target->getNumVirtualButtons(); ++i) {
                const QCAR::VirtualButton* button = target->getVirtualButton(i);
                
                // If the button is pressed, then use the appropriate texture
                if (button->isPressed()) {
                    // Run through button name array to find texture index
                    for (int j = 0; j < NUM_BUTTONS; ++j) {
                        if (strcmp(button->getName(), virtualButtonColors[j]) == 0) {
                            textureIndex = j+1;
                            break;
                        }
                    }
                }
                
                const QCAR::Area* vbArea = &button->getArea();
                assert(vbArea->getType() == QCAR::Area::RECTANGLE);
                const QCAR::Rectangle* vbRectangle = static_cast<const QCAR::Rectangle*>(vbArea);
                
                // We add the vertices to a common array in order to have one single 
                // draw call. This is more efficient than having multiple glDrawArray calls
                vbVertices[vbCounter   ]=vbRectangle->getLeftTopX();
                vbVertices[vbCounter+ 1]=vbRectangle->getLeftTopY();
                vbVertices[vbCounter+ 2]=0.0f;
                vbVertices[vbCounter+ 3]=vbRectangle->getRightBottomX();
                vbVertices[vbCounter+ 4]=vbRectangle->getLeftTopY();
                vbVertices[vbCounter+ 5]=0.0f;
                vbVertices[vbCounter+ 6]=vbRectangle->getRightBottomX();
                vbVertices[vbCounter+ 7]=vbRectangle->getLeftTopY();
                vbVertices[vbCounter+ 8]=0.0f;
                vbVertices[vbCounter+ 9]=vbRectangle->getRightBottomX();
                vbVertices[vbCounter+10]=vbRectangle->getRightBottomY();
                vbVertices[vbCounter+11]=0.0f;
                vbVertices[vbCounter+12]=vbRectangle->getRightBottomX();
                vbVertices[vbCounter+13]=vbRectangle->getRightBottomY();
                vbVertices[vbCounter+14]=0.0f;
                vbVertices[vbCounter+15]=vbRectangle->getLeftTopX();
                vbVertices[vbCounter+16]=vbRectangle->getRightBottomY();
                vbVertices[vbCounter+17]=0.0f;
                vbVertices[vbCounter+18]=vbRectangle->getLeftTopX();
                vbVertices[vbCounter+19]=vbRectangle->getRightBottomY();
                vbVertices[vbCounter+20]=0.0f;
                vbVertices[vbCounter+21]=vbRectangle->getLeftTopX();
                vbVertices[vbCounter+22]=vbRectangle->getLeftTopY();
                vbVertices[vbCounter+23]=0.0f;
                vbCounter+=24;
            }

            if (vbCounter>0)
            {
                
                // Render a frame around the button using the appropriate
                // version of OpenGL
                if (QCAR::GL_11 & qUtils.QCARFlags) {
                    // Load the projection matrix
                    glMatrixMode(GL_PROJECTION);
                    glLoadMatrixf(qUtils.projectionMatrix.data);
                    
                    // Load the model-view matrix
                    glMatrixMode(GL_MODELVIEW);
                    glLoadMatrixf(modelViewMatrix.data);
                    
                    glColor4f(1.0f, 1.0f, 1.0f, 1.0f);
                    glVertexPointer(3, GL_FLOAT, 0, (const GLvoid*) &vbVertices[0]);

                    // We multiply by 8 because that's the number of vertices per button
                    // The reason is that GL_LINES considers only pairs. So some vertices
                    // must be repeated.
                    glDrawArrays(GL_LINES, 0, target->getNumVirtualButtons()*8); 
                }
#ifndef USE_OPENGL1
                else {
                    QCAR::Matrix44F modelViewProjection;
                    
                    ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
                    glUseProgram(vbShaderProgramID);
                    glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*) &vbVertices[0]);
                    glEnableVertexAttribArray(vertexHandle);
                    glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (GLfloat*)&modelViewProjection.data[0] );
                    glDrawArrays(GL_LINES, 0, target->getNumVirtualButtons()*8);
                    glDisableVertexAttribArray(vertexHandle);
                }
#endif
            }
            
            // Get the teapot texture at the appropriate index
            const Texture* const thisTexture = [textures objectAtIndex:textureIndex];
            
            // Render using the appropriate version of OpenGL
            if (QCAR::GL_11 & qUtils.QCARFlags) {
                glEnable(GL_TEXTURE_2D);
                
                // Load the projection matrix
                glMatrixMode(GL_PROJECTION);
                glLoadMatrixf(qUtils.projectionMatrix.data);
                
                // Load the model-view matrix
                glMatrixMode(GL_MODELVIEW);
                glLoadMatrixf(modelViewMatrix.data);
                glTranslatef(0.0f, 0.0f, -kObjectScale);
                glScalef(kObjectScale, kObjectScale, kObjectScale);
                
                // Draw object
                glBindTexture(GL_TEXTURE_2D, [thisTexture textureID]);
                glTexCoordPointer(2, GL_FLOAT, 0, (const GLvoid*)&teapotTexCoords[0]);
                glVertexPointer(3, GL_FLOAT, 0, (const GLvoid*) &teapotVertices[0]);
                glNormalPointer(GL_FLOAT, 0, (const GLvoid*)&teapotNormals[0]);
                glDrawElements(GL_TRIANGLES, NUM_TEAPOT_OBJECT_INDEX, GL_UNSIGNED_SHORT, (const GLvoid*)&teapotIndices[0]);
                
                glDisable(GL_TEXTURE_2D);
            }
#ifndef USE_OPENGL1
            else {
                // OpenGL 2
                QCAR::Matrix44F modelViewProjectionScaled;
                
                ShaderUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScale, &modelViewMatrix.data[0]);
                ShaderUtils::scalePoseMatrix(kObjectScale, kObjectScale, kObjectScale, &modelViewMatrix.data[0]);
                ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjectionScaled.data[0]);
                
                glUseProgram(shaderProgramID);
                
                glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)&teapotVertices[0]);
                glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)&teapotNormals[0]);
                glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, (const GLvoid*)&teapotTexCoords[0]);
                
                glEnableVertexAttribArray(vertexHandle);
                glEnableVertexAttribArray(normalHandle);
                glEnableVertexAttribArray(textureCoordHandle);
                
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, [thisTexture textureID]);
                glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE, (const GLfloat*)&modelViewProjectionScaled.data[0]);
                glDrawElements(GL_TRIANGLES, NUM_TEAPOT_OBJECT_INDEX, GL_UNSIGNED_SHORT, (const GLvoid*)&teapotIndices[0]);
                
                ShaderUtils::checkGlError("EAGLView renderFrameQCAR");
            }
#endif
        }
        
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_CULL_FACE);
        
        if (QCAR::GL_11 & qUtils.QCARFlags) {
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
}


////////////////////////////////////////////////////////////////////////////////
// Callback for other UI to change the button state
- (void) updateButtonState:(int)newState
{
    buttonMask = newState;
}

////////////////////////////////////////////////////////////////////////////////
// Create or destroy a virtual button at runtime
//
// Note: This will NOT work if the tracker is active!
bool
toggleVirtualButton(QCAR::ImageTarget* imageTarget, const char* name, float left, float top, float right, float bottom)
{
    QCARutils *qUtils = [QCARutils getInstance];
    
    NSLog(@"toggleVirtualButton");
    [qUtils allowDataSetModification];
    
    bool buttonToggleSuccess = false;
    QCAR::VirtualButton* virtualButton = imageTarget->getVirtualButton(name);
    
    if (virtualButton){
        NSLog(@"Destroying Virtual Button");
        buttonToggleSuccess = imageTarget->destroyVirtualButton(virtualButton);
    }
    else {
        NSLog(@"Creating Virtual Button");
        QCAR::Rectangle vbRectangle(left, top, right, bottom);
        QCAR::VirtualButton* virtualButton = imageTarget->createVirtualButton(name, vbRectangle);
        
        if (virtualButton) {
            // This is just a showcase; the values used here are set by default
            // on virtual button creation
            virtualButton->setEnabled(true);
            virtualButton->setSensitivity(QCAR::VirtualButton::MEDIUM);
            buttonToggleSuccess = true;
        }
    }
    
    [qUtils saveDataSetModifications];   
    
    return buttonToggleSuccess;
}


////////////////////////////////////////////////////////////////////////////////
// Callback function called by the tracker when each tracking cycle has finished

void VirtualButton_UpdateCallback::QCAR_onUpdate(QCAR::State& state)
{
    QCARutils *qUtils = [QCARutils getInstance];
    
    // Set the active/inactive state of the virtual buttons (if the user has
    // made a selection from the menu)
    
    if (buttonMask) {
        // Update runs in the tracking thread therefore it is guaranteed that
        // the tracker is not doing anything at this point. => Reconfiguration
        // is possible.
        
        QCAR::ImageTarget* imageTarget = [qUtils getImageTarget:0];
               
        if (buttonMask & BUTTON_1) {
            NSLog(@"Toggle Button 1");
            toggleVirtualButton(imageTarget, virtualButtonColors[0],
                                -108.68f, -53.52f, -75.75f, -65.87f);
        }
        
        if (buttonMask & BUTTON_2) {
            NSLog(@"Toggle Button 2");
            toggleVirtualButton(imageTarget, virtualButtonColors[1], 
                                -45.28f, -53.52f, -12.35f, -65.87f);
        }
        
        if (buttonMask & BUTTON_3) {
            NSLog(@"Toggle Button 3");
            toggleVirtualButton(imageTarget, virtualButtonColors[2], 
                                14.82f, -53.52f, 47.75f, -65.87f);
        }
        
        if (buttonMask & BUTTON_4) {
            NSLog(@"Toggle Button 4");
            toggleVirtualButton(imageTarget, virtualButtonColors[3], 
                                76.57f, -53.52f, 109.50f, -65.87f);
        }
        
        buttonMask = 0;
    }
}

@end
