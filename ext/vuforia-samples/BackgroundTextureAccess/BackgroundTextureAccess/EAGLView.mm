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
#import <QCAR/VideoBackgroundTextureInfo.h>

#import "QCARutils.h"

#ifndef USE_OPENGL1
#import "ShaderUtils.h"
#import "Shaders/BGShader.fsh"
#import "Shaders/BGShader.vsh"
#endif

namespace {
    // Teapot texture filenames
    const char* textureFilenames[] = {
        "TextureTeapotRed.png",
    };

    // Model scale factor
    const float kObjectScale = 3.0f;
    
    // These values indicate how many rows and columns we want for our video background texture polygon
    const int vbNumVertexCols = 10;
    const int vbNumVertexRows = 10;
    
    // These are the variables for the vertices, coords and inidices
    const int vbNumVertexValues=vbNumVertexCols*vbNumVertexRows*3;      // Each vertex has three values: X, Y, Z
    const int vbNumTexCoord=vbNumVertexCols*vbNumVertexRows*2;          // Each texture coordinate has 2 values: U and V
    const int vbNumIndices=(vbNumVertexCols-1)*(vbNumVertexRows-1)*6;   // Each square is composed of 2 triangles which in turn 
    // have 3 vertices each, so we need 6 indices
    
    // These are the data containers for the vertices, texcoords and indices in the CPU
    float   vbOrthoQuadVertices     [vbNumVertexValues]; 
    float   vbOrthoQuadTexCoords    [vbNumTexCoord]; 
    GLbyte  vbOrthoQuadIndices      [vbNumIndices]; 
    
    // This will hold the data for the projection matrix passed to the vertex shader
    float   vbOrthoProjMatrix[16];
}


@interface EAGLView(PrivateMethods)
- (void)CreateVideoBackgroundMesh;
- (void)handleUserTouchEventAtXCoord:(float)x YCoord:(float)y;
@end

@implementation EAGLView

@synthesize touchLocation_X, touchLocation_Y;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self)
    {
        // create list of textures we want loading - ARViewController will do this for us
        int nTextures = sizeof(textureFilenames) / sizeof(textureFilenames[0]);
        for (int i = 0; i < nTextures; ++i)
        {
            [textureList addObject: [NSString stringWithUTF8String:textureFilenames[i]]];
        }
        
        touchLocation_X = -100.0;
        touchLocation_Y = -100.0;
        
        self.userInteractionEnabled = NO;
    }
    return self;
}

- (void) setup3dObjects
{
    // build the array of objects we want drawn and their texture
    // in this example we have 2 targets and 2 textures, requiring 2 models
    // but using the same underlying 3D model of a teapot
    
    for (int i=0; i < [textures count]; i++)
    {
        Object3D *obj3D = [[Object3D alloc] init];

        obj3D.numVertices = NUM_TEAPOT_OBJECT_VERTEX;
        obj3D.vertices = teapotVertices;
        obj3D.normals = teapotNormals;
        obj3D.texCoords = teapotTexCoords;
        
        obj3D.numIndices = NUM_TEAPOT_OBJECT_INDEX;
        obj3D.indices = teapotIndices;
        
        obj3D.texture = [textures objectAtIndex:i];

        [objects3D addObject:obj3D];
        [obj3D release];
    }
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
    
    // Clear color and depth buffer 
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Get the state from QCAR and mark the beginning of a rendering section
    QCAR::State state = QCAR::Renderer::getInstance().begin();
    
    ////////////////////////////////////////////////////////////////////////////
    // This section renders the video background with a 
    // custom shader defined in Shaders.h
    QCAR::Renderer::getInstance().bindVideoBackground(0);
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    // Load the shader and upload the vertex/texcoord/index data
    glViewport(qUtils->viewport.posX, qUtils->viewport.posY, qUtils->viewport.sizeX, qUtils->viewport.sizeY);
    
    // We need a finer mesh for this background 
    // We have to create it here because it will request the texture info of the video background
    if (!videoBackgroundShader.vbMeshInitialized)
    {
        [self CreateVideoBackgroundMesh];
    }
    
    glUseProgram(videoBackgroundShader.vbShaderProgramID);
    glVertexAttribPointer(videoBackgroundShader.vbVertexPositionHandle, 3, GL_FLOAT, GL_FALSE, 0, vbOrthoQuadVertices);
    glVertexAttribPointer(videoBackgroundShader.vbVertexTexCoordHandle, 2, GL_FLOAT, GL_FALSE, 0, vbOrthoQuadTexCoords);
    glUniform1i(videoBackgroundShader.vbTexSampler2DHandle, 0);
    glUniformMatrix4fv(videoBackgroundShader.vbProjectionMatrixHandle, 1, GL_FALSE, &vbOrthoProjMatrix[0]);
    glUniform1f(videoBackgroundShader.vbTouchLocationXHandle, ([self touchLocation_X]*2.0)-1.0);
    glUniform1f(videoBackgroundShader.vbTouchLocationYHandle, (2.0-([self touchLocation_Y]*2.0))-1.0);
    
    // Render the video background with the custom shader
    glEnableVertexAttribArray(videoBackgroundShader.vbVertexPositionHandle);
    glEnableVertexAttribArray(videoBackgroundShader.vbVertexTexCoordHandle);
    // TODO: it might be more efficient to use Vertex Buffer Objects here
    glDrawElements(GL_TRIANGLES, vbNumIndices, GL_UNSIGNED_BYTE, vbOrthoQuadIndices);
    glDisableVertexAttribArray(videoBackgroundShader.vbVertexPositionHandle);
    glDisableVertexAttribArray(videoBackgroundShader.vbVertexTexCoordHandle);
    
    // Wrap up this rendering    
    glUseProgram(0);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    ShaderUtils::checkGlError("Rendering of the background failed");
    
    ////////////////////////////////////////////////////////////////////////////
    // The following section is similar to image targets
    // we still render the teapot on top of the targets
    glEnable(GL_DEPTH_TEST);
    glEnable(GL_CULL_FACE);
    
    // Did we find any trackables this frame?
    for (int tIdx = 0; tIdx < state.getNumActiveTrackables(); tIdx++)
    {
        // Get the trackable:
        const QCAR::Trackable* trackable = state.getActiveTrackable(tIdx);
        QCAR::Matrix44F modelViewMatrix =
        QCAR::Tool::convertPose2GLMatrix(trackable->getPose());        
        
        // We have ony one texture, so use it
        Object3D *obj3D = [objects3D objectAtIndex:0];
        
        QCAR::Matrix44F modelViewProjection;
        
        ShaderUtils::translatePoseMatrix(0.0f, 0.0f, kObjectScale,
                                         &modelViewMatrix.data[0]);
        ShaderUtils::scalePoseMatrix(kObjectScale, kObjectScale, kObjectScale,
                                     &modelViewMatrix.data[0]);
        ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0],
                                    &modelViewMatrix.data[0] ,
                                    &modelViewProjection.data[0]);
        
        glUseProgram(shaderProgramID);
        
        glVertexAttribPointer(vertexHandle, 3, GL_FLOAT, GL_FALSE, 0,
                              (const GLvoid*) &teapotVertices[0]);
        glVertexAttribPointer(normalHandle, 3, GL_FLOAT, GL_FALSE, 0,
                              (const GLvoid*) &teapotNormals[0]);
        glVertexAttribPointer(textureCoordHandle, 2, GL_FLOAT, GL_FALSE, 0,
                              (const GLvoid*) &teapotTexCoords[0]);
        
        glEnableVertexAttribArray(vertexHandle);
        glEnableVertexAttribArray(normalHandle);
        glEnableVertexAttribArray(textureCoordHandle);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, [obj3D.texture textureID]);
        glUniformMatrix4fv(mvpMatrixHandle, 1, GL_FALSE,
                           (GLfloat*)&modelViewProjection.data[0] );
        glDrawElements(GL_TRIANGLES, NUM_TEAPOT_OBJECT_INDEX, GL_UNSIGNED_SHORT,
                       (const GLvoid*) &teapotIndices[0]);
        
        glDisableVertexAttribArray(vertexHandle);
        glDisableVertexAttribArray(normalHandle);
        glDisableVertexAttribArray(textureCoordHandle);
        
        ShaderUtils::checkGlError("BackgroundTextureAccess renderFrame");
        
    }
    
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_CULL_FACE);
    
    ////////////////////////////////////////////////////////////////////////////
    // It is always important to tell the QCAR Renderer that we are finished
    QCAR::Renderer::getInstance().end();
    
    [self presentFramebuffer];
}


////////////////////////////////////////////////////////////////////////////////
// This function creates the shader program with the vertex and fragment shaders
// defined in Shader.h. It also gets handles to the position of the variables
// for later usage. It also defines a standard orthographic projection matrix
- (void)initShaders
{
    // OpenGL 2 initialisation...
    
    // Initialise augmentation shader data (our parent class can do this for us)
    [super initShaders];
    
    // Define clear color
    glClearColor(0.0f, 0.0f, 0.0f, QCAR::requiresAlpha() ? 0.0f : 1.0f);
    
    // Initialise video background shader data
    videoBackgroundShader.vbShaderProgramID = ShaderUtils::createProgramFromBuffer(vertexShaderSrc, fragmentShaderSrc);
    
    if (0 < videoBackgroundShader.vbShaderProgramID) {
        // Retrieve handler for vertex position shader attribute variable
        videoBackgroundShader.vbVertexPositionHandle = glGetAttribLocation(videoBackgroundShader.vbShaderProgramID, "vertexPosition");
        
        // Retrieve handler for texture coordinate shader attribute variable
        videoBackgroundShader.vbVertexTexCoordHandle = glGetAttribLocation(videoBackgroundShader.vbShaderProgramID, "vertexTexCoord");
        
        // Retrieve handler for texture sampler shader uniform variable
        videoBackgroundShader.vbTexSampler2DHandle = glGetUniformLocation(videoBackgroundShader.vbShaderProgramID, "texSampler2D");
        
        // Retrieve handler for projection matrix shader uniform variable
        videoBackgroundShader.vbProjectionMatrixHandle = glGetUniformLocation(videoBackgroundShader.vbShaderProgramID, "projectionMatrix");
        
        // Retrieve handler for projection matrix shader uniform variable
        videoBackgroundShader.vbTouchLocationXHandle = glGetUniformLocation(videoBackgroundShader.vbShaderProgramID, "touchLocation_x");
        
        // Retrieve handler for projection matrix shader uniform variable
        videoBackgroundShader.vbTouchLocationYHandle = glGetUniformLocation(videoBackgroundShader.vbShaderProgramID, "touchLocation_y");
        
        ShaderUtils::checkGlError("Getting the handles to the shader variables");
        
        // Set the orthographic matrix
        ShaderUtils::setOrthoMatrix(-1.0, 1.0, -1.0, 1.0, -1.0, 1.0, vbOrthoProjMatrix);
    }
    else {
        NSLog(@"Could not initialise video background shader");
    }
}


////////////////////////////////////////////////////////////////////////////////
// This function adds the values to the vertex, coord and indices variables.
// Essentially it defines a mesh from -1 to 1 in X and Y with 
// vbNumVertexRows rows and vbNumVertexCols columns. Thus, if we were to assign
// vbNumVertexRows=10 and vbNumVertexCols=10 we would have a mesh composed of 
// 100 little squares (notice, however, that we work with triangles so it is 
// actually not composed of 100 squares but of 200 triangles). The example
// below shows 4 triangles composing 2 squares.
//      D---E---F
//      | \ | \ |
//      A---B---C
- (void)CreateVideoBackgroundMesh
{
    // Get the texture and image dimensions from QCAR
    const QCAR::VideoBackgroundTextureInfo texInfo=QCAR::Renderer::getInstance().getVideoBackgroundTextureInfo();
    
    // If there is no image data yet then return;
    if ((texInfo.mImageSize.data[0]==0)||(texInfo.mImageSize.data[1]==0)) return;
    
    // These calculate a slope for the texture coords
    float uRatio=((float)texInfo.mImageSize.data[0]/(float)texInfo.mTextureSize.data[0]);
    float vRatio=((float)texInfo.mImageSize.data[1]/(float)texInfo.mTextureSize.data[1]);
    float uSlope=uRatio/(vbNumVertexCols-1);
    float vSlope=vRatio/(vbNumVertexRows-1);
    
    // These calculate a slope for the vertex values in this case we have a span of 2, from -1 to 1
    float totalSpan=2.0f;
    float colSlope=totalSpan/(vbNumVertexCols-1);
    float rowSlope=totalSpan/(vbNumVertexRows-1);
    
    // Some helper variables
    int currentIndexPosition=0; 
    int currentVertexPosition=0;
    int currentCoordPosition=0;
    int currentVertexIndex=0;
    
    for (int j=0; j<vbNumVertexRows; j++)
    {
        for (int i=0; i<vbNumVertexCols; i++)
        {
            // We populate the mesh with a regular grid
            vbOrthoQuadVertices[currentVertexPosition   /*X*/] = ((colSlope*i)-(totalSpan/2.0f));   // We subtract this because the values range from -totalSpan/2 to totalSpan/2
            vbOrthoQuadVertices[currentVertexPosition+1 /*Y*/] = ((rowSlope*j)-(totalSpan/2.0f));
            vbOrthoQuadVertices[currentVertexPosition+2 /*Z*/] = 0.0f;                              // It is all a flat polygon orthogonal to the view vector
            
            // We also populate its associated texture coordinate
            vbOrthoQuadTexCoords[currentCoordPosition   /*U*/] = uSlope*i;
            vbOrthoQuadTexCoords[currentCoordPosition+1 /*V*/] = vRatio - (vSlope*j);
            
            // Now we populate the triangles that compose the mesh
            // First triangle is the upper right of the vertex
            if (j<vbNumVertexRows-1)
            {
                if (i<vbNumVertexCols-1) // In the example above this would make triangles ABD and BCE
                {
                    vbOrthoQuadIndices[currentIndexPosition  ]=currentVertexIndex;
                    vbOrthoQuadIndices[currentIndexPosition+1]=currentVertexIndex+1;
                    vbOrthoQuadIndices[currentIndexPosition+2]=currentVertexIndex+vbNumVertexCols;
                    currentIndexPosition+=3;
                }
                if (i>0) // In the example above this would make triangles BED and CFE
                {
                    vbOrthoQuadIndices[currentIndexPosition  ]=currentVertexIndex;
                    vbOrthoQuadIndices[currentIndexPosition+1]=currentVertexIndex+vbNumVertexCols;
                    vbOrthoQuadIndices[currentIndexPosition+2]=currentVertexIndex+vbNumVertexCols-1;
                    currentIndexPosition+=3;
                }
            }
            currentVertexPosition+=3;
            currentCoordPosition+=2;
            currentVertexIndex+=1;
        }
    }
    
    videoBackgroundShader.vbMeshInitialized=true;
}


// The user touched the screen
- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self touchesMoved:touches withEvent:event];
}


- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    CGRect rect = [self bounds];
    
    [self handleUserTouchEventAtXCoord:(point.x / rect.size.width) YCoord:(point.y / rect.size.height)];
}


- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    [self handleUserTouchEventAtXCoord:-100 YCoord:-100];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // needs implementing even if it does nothing
    [self handleUserTouchEventAtXCoord:-100 YCoord:-100];
}

- (void)handleUserTouchEventAtXCoord:(float)x YCoord:(float)y
{
    // Use touch coordinates for the Loupe effect.  Note: the value -100.0 is
    // simply used as a flag for the shader to ignore the position
    
    // Thread-safe access to touch location data members
    [self setTouchLocation_X:x];
    [self setTouchLocation_Y:y];
}

@end
