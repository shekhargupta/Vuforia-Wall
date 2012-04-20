//
//  TouchImageView.h
//  vuforia-wall
//
//  Created by Edo on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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

- (void)createGestureRecognizers;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender; // Dragging
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender; // Zooming
- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender; // Rotating
- (IBAction)handleSingleDoubleTapGesture:(UIGestureRecognizer *)sender; // Single Double Tap
- (IBAction)handleLongPressGesture:(UILongPressGestureRecognizer *)sender; // Single Double Tap


- (void)updateImageTransform;

@end
