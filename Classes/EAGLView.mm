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
		
		// Support gestures in this view
		[self createGestureRecognizers];
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = YES;
		activeIndex = -1;
		
    }
    return self;
}

- (void)setup3dObjects
{
    // build the array of objects we want drawn and their texture
    // in our app, the textures are not static files but comes from uiimage data.
    
	NSLog(@"EAGLView setup3dObjects");
	
	[objects3D removeAllObjects];
    for (int i=0; i < [ImageWall sharedInstance].images.count; i++) {
		TouchImageView* imageView = [[ImageWall sharedInstance].images objectAtIndex:i];
		
		Plane3D *obj3D = [[Plane3D alloc] init];
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
    }
}

- (void)update3dObjects;
{
	for (int i=0; i < objects3D.count; i++)
    {
		Plane3D *obj3D = [objects3D objectAtIndex:i];
		TouchImageView* imageView = [[ImageWall sharedInstance].images objectAtIndex:i];
		
		obj3D.dx = [imageView myX];
		obj3D.dy = [imageView myY];
		obj3D.rotation = [imageView myRotation];
		obj3D.scale = [imageView myScale];
		
		NSLog(@"Update3Dobject: image info [w,h,tx,ty,scale,rotation] = [%f,%f,%f,%f,%f,%f]",
			  imageView.image.size.width,
			  imageView.image.size.height,
			  obj3D.dx,
			  obj3D.dy,
			  obj3D.scale,
			  obj3D.rotation
		);
    }
}


// called after QCAR is initialised but before the camera starts
- (void)postInitQCAR
{
    // These two calls to setHint tell QCAR to split work over multiple
    // frames.  Depending on your requirements you can opt to omit these.
    QCAR::setHint(QCAR::HINT_IMAGE_TARGET_MULTI_FRAME_ENABLED, 1);
    QCAR::setHint(QCAR::HINT_IMAGE_TARGET_MILLISECONDS_PER_MULTI_FRAME, 25);
	
    // Here we could also make a QCAR::setHint call to set the maximum
    // number of simultaneous targets                
    QCAR::setHint(QCAR::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, 1);
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
        currentModelViewMatrix = QCAR::Tool::convertPose2GLMatrix(trackable->getPose());
        
		for (int j=0; j<objects3D.count; j++) {
			QCAR::Matrix44F modelViewMatrix = currentModelViewMatrix;
			
			QCAR::Tool::convertPose2GLMatrix(trackable->getPose());
			
			
			Object3D *obj3D = [objects3D objectAtIndex:j];
			
			// TODO use active variable to render image differently (for example with a glowing bounding box)
			bool active = activeIndex == j;
			
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
				QCAR::Matrix44F modelViewProjection = [self calculateMVP:obj3D withModelViewMatrix:modelViewMatrix withIndex:j];
				
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


- (QCAR::Matrix44F)calculateMVP:(Object3D*)obj3D withModelViewMatrix:(QCAR::Matrix44F)modelViewMatrix withIndex:(int)index;
{
	QCAR::Matrix44F modelViewProjection;
	
	ShaderUtils::scalePoseMatrix(kObjectScale, kObjectScale, kObjectScale, &modelViewMatrix.data[0]);
	ShaderUtils::translatePoseMatrix(0, 0, 0.001*index, &modelViewMatrix.data[0]);
	
	ShaderUtils::rotatePoseMatrix(-obj3D.rotation, 0, 0, 1, &modelViewMatrix.data[0]);
	ShaderUtils::translatePoseMatrix(obj3D.dx * 0.01, obj3D.dy * -0.01, 0, &modelViewMatrix.data[0]);
	ShaderUtils::scalePoseMatrix(obj3D.scale, obj3D.scale, 1.0, &modelViewMatrix.data[0]);
	
	ShaderUtils::multiplyMatrix(&qUtils.projectionMatrix.data[0], &modelViewMatrix.data[0], &modelViewProjection.data[0]);
	
	return modelViewProjection;
}



#pragma mark - Gestures

- (void)createGestureRecognizers;
{
	UITapGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc]
												initWithTarget:self action:@selector(handleSingleDoubleTapGesture:)];
    singleFingerDTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:singleFingerDTap];//	[singleFingerDTap release];
	
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
										  initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];//	[panGesture release];
	
	
	UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc]
													initWithTarget:self action:@selector(handleRotationGesture:)];
	[self addGestureRecognizer:rotationGesture];//	[rotationGesture release];
	
	
	
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
											  initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pinchGesture];//	[pinchGesture release];
	
	
	/*
	UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
													  initWithTarget:self action:@selector(handleLongPressGesture:)];
	//	longPressGesture.minimumPressDuration = 1.0;
	longPressGesture.numberOfTapsRequired = 1;
	longPressGesture.numberOfTouchesRequired = 1;
	//	longPressGesture.allowableMovement = 1.0;
	[self addGestureRecognizer:longPressGesture];//	[longPressGesture release];
	 */
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender;
{
	NSLog(@"handle Pan gesture");
	if (activeIndex == -1) {
		dx = [sender translationInView:self].x;
		dy = [sender translationInView:self].y;
		if (sender.state == UIGestureRecognizerStateEnded) {
			x = x + dx;
			y = y + dy;
		}
		dx = 0.0;
		dy = 0.0;
	} else {
		[[[ImageWall sharedInstance].images objectAtIndex:activeIndex] handlePanGesture:sender];
		[self update3dObjects];
	}
}



- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender;
{
	NSLog(@"pinch gesture");
	if (activeIndex == -1) {
		dscale = [sender scale];
		NSLog(@"ds = %f\n", dscale);
		if (sender.state == UIGestureRecognizerStateEnded) {
			scale = scale * dscale;
		}
		dscale = 1.0;
	} else {
		[[[ImageWall sharedInstance].images objectAtIndex:activeIndex] handlePinchGesture:sender];
		[self update3dObjects];
	}
}



- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender;
{
	NSLog(@"rotation gesture");
	if (activeIndex == -1) {
		drotation = [sender rotation] * 50.0;
		if (sender.state == UIGestureRecognizerStateEnded) {
			rotation = rotation + drotation;
		}
		drotation = 0.0;
	} else {
		[[[ImageWall sharedInstance].images objectAtIndex:activeIndex] handleRotationGesture:sender];
		[self update3dObjects];
	}
}



- (IBAction)handleSingleDoubleTapGesture:(UIGestureRecognizer *)sender;
{
    NSLog(@"single double tap gesture");
	if (activeIndex == -1) {
		CGPoint tapPoint = [sender locationInView:sender.view.superview];
		
		// hit test
		for (int i=objects3D.count-1; i>=0; i--) {
			Plane3D* obj3D = [objects3D objectAtIndex:i];
			if ([self isPoint:tapPoint inPlane:obj3D]) {
				activeIndex = i;
				NSLog(@"set active index %d\n", activeIndex);
				break;
			}
		}
		
		// TODO, currently, the hit test doesn't work, so just pick a fixed value for demonstration purposes
		activeIndex = objects3D.count-1;
		NSLog(@"set active Index to 0\n");
	} else {
		activeIndex = -1;
	}
}



- (IBAction)handleLongPressGesture:(UILongPressGestureRecognizer *)sender;
{
	/*
	NSLog(@"long press gesture");
	if (activeIndex == -1) {
		CGPoint tapPoint = [sender locationInView:sender.view.superview];
		
		// hit test
		for (int i=objects3D.count-1; i>=0; i--) {
			Plane3D* obj3D = [objects3D objectAtIndex:i];
			if ([self isPoint:tapPoint inPlane:obj3D]) {
				activeIndex = i;
				NSLog(@"set active index %d\n", activeIndex);
				break;
			}
		}
	} else {
		activeIndex = -1;
	}
	 */
}




#pragma mark - Geometric computations



- (BOOL)isPoint:(CGPoint)point inPlane:(Plane3D*)plane;
{
	if (QCAR::GL_11 & qUtils.QCARFlags) {
		return false;
	}
#ifndef USE_OPENGL1
	else {
	
		QCAR::Matrix44F modelViewProjection = [self calculateMVP:plane withModelViewMatrix:currentModelViewMatrix withIndex:0];
	
		// Manually multiply MVP matrix with point
	
		float pointA[4] = {plane.vertices[0], plane.vertices[1], plane.vertices[2], 1.0};
		float pointB[4] = {plane.vertices[3], plane.vertices[4], plane.vertices[5], 1.0};
		float pointC[4] = {plane.vertices[6], plane.vertices[7], plane.vertices[8], 1.0};
		float pointD[4] = {plane.vertices[9], plane.vertices[10], plane.vertices[11], 1.0};
		
		float P[2]; P[0] = point.x; P[1] = point.y;
		float* A = [self multiplyMatrix:modelViewProjection withVertex:pointA];
		float* B = [self multiplyMatrix:modelViewProjection withVertex:pointB];
		float* C = [self multiplyMatrix:modelViewProjection withVertex:pointC];
		float* D = [self multiplyMatrix:modelViewProjection withVertex:pointD];
		
		
		BOOL result = (
				[self isPoint:P inTriangleWithV1:A andV2:B andV3:C] &&
				[self isPoint:P inTriangleWithV1:B andV2:C andV3:D]
				);
		
		delete[] A;
		delete[] B;
		delete[] C;
		delete[] D;
		return result;
	}
#endif
	
}



-(float*)multiplyMatrix:(QCAR::Matrix44F)modelViewProjection withVertex:(float[4])v;
{
	float result[4];
	
	// matrix multiplication
	for (int i=0; i<4; i++) {
		result[i] = 0;
		for (int j=0; j<4; j++) {
			result[i] += modelViewProjection.data[i*4+j] * v[j];
		}
	}
	
	// homogenization
	for (int i=0; i<3; i++) {
		result[i] = result[i] / result[3];
	}
	
	float* vec2D = new float[2];
	vec2D[0] = result[0];
	vec2D[1] = result[1];
	return vec2D;
}



-(float)signWithP1:(float[2])p1 andP2:(float[2])p2 andP3:(float[2])p3;
{
	return (p1[0] - p3[0]) * (p2[1] - p3[1]) - (p2[0] - p3[0]) * (p1[1] - p3[1]);
}



-(BOOL)isPoint:(float[2])pt inTriangleWithV1:(float[2])v1 andV2:(float[2])v2 andV3:(float[2])v3;
{
	bool b1, b2, b3;
	
	b1 = [self signWithP1:pt andP2:v1 andP3:v2] < 0.0f;
	b2 = [self signWithP1:pt andP2:v2 andP3:v3] < 0.0f;
	b3 = [self signWithP1:pt andP2:v3 andP3:v1] < 0.0f;
	
	return ((b1 == b2) && (b2 == b3));
}


@end
