//
//  TouchImageView.h
//  vuforia-wall
//
//  Created by Eduard Feicho <eduard_DOT_feicho_AT_rwth-aachen_DOT_de> on 13.04.12.
//  Source: https://github.com/Duffycola/Vuforia-Wall
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* notificationTouchImageViewRemoved = @"TouchImageViewRemovedNotification";

@interface TouchImageView : UIImageView
{
	BOOL active;
	
	float x,y;
	float rotation;
	float scale;
	
	float dx,dy;
	float drotation;
	float dscale;
}
@property (nonatomic, assign) BOOL active;


- (float)myX;
- (float)myY;
- (float)myRotation;
- (float)myScale;


- (void)createGestureRecognizers;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender; // Dragging
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender; // Zooming
- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender; // Rotating
- (IBAction)handleSingleDoubleTapGesture:(UIGestureRecognizer *)sender; // Single Double Tap
- (IBAction)handleLongPressGesture:(UILongPressGestureRecognizer *)sender; // Single Double Tap


- (void)updateImageTransform;

@end
