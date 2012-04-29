/*==============================================================================
 Copyright (c) 2012 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "AR_EAGLView.h"
#import <QCAR/Renderer.h>

#import "Plane3D.h"

// This class wraps the CAEAGLLayer from CoreAnimation into a convenient UIView
// subclass.  The view content is basically an EAGL surface you render your
// OpenGL scene into.  Note that setting the view non-opaque will only work if
// the EAGL surface has an alpha channel.
@interface EAGLView : AR_EAGLView
{
	int activeIndex;
	QCAR::Matrix44F currentModelViewMatrix;
	
	float x,y;
	float rotation;
	float scale;
	
	float dx,dy;
	float drotation;
	float dscale;
}

- (QCAR::Matrix44F)calculateMVP:(Object3D*)obj3D withModelViewMatrix:(QCAR::Matrix44F)modelViewMatrix withIndex:(int)index;
- (void)createGestureRecognizers;



- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender; // Dragging
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender; // Zooming
- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender; // Rotating
- (IBAction)handleSingleDoubleTapGesture:(UIGestureRecognizer *)sender; // Single Double Tap
- (IBAction)handleLongPressGesture:(UILongPressGestureRecognizer *)sender; // Single Double Tap




- (BOOL)isPoint:(CGPoint)point inPlane:(Plane3D*)plane;
-(float*)multiplyMatrix:(QCAR::Matrix44F)modelViewProjection withVertex:(float[4])v;
-(float)signWithP1:(float[2])p1 andP2:(float[2])p2 andP3:(float[2])p3;
-(BOOL)isPoint:(float[2])pt inTriangleWithV1:(float[2])v1 andV2:(float[2])v2 andV3:(float[2])v3;

- (void)update3dObjects;


@end
