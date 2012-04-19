//
//  TouchImageView.h
//  vuforia-wall
//
//  Created by Edo on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString* notificationTouchImageViewRemoved = @"TouchImageViewRemovedNotification";


@interface ImageTransform
{
	CGPoint translation;
	float scale;
	float rotationAngle;
}
@property (nonatomic, assign) CGPoint translation;
@property (nonatomic, assign) float scale;
@property (nonatomic, assign) float rotationAngle;
@end


@interface TouchImageView : UIImageView
{
	BOOL active;
	ImageTransform *currentTransform;
	ImageTransform *deltaTransform;
	
	CGAffineTransform currentImageTransform;
	CGRect currentBounds;
}
@property (nonatomic, assign) BOOL active;
@property (nonatomic, retain) ImageTransform *currentTransform;
@property (nonatomic, retain) ImageTransform *deltaTransform;
@property (nonatomic, assign) CGAffineTransform currentImageTransform;
@property (nonatomic, assign) CGRect currentBounds;



- (void)createGestureRecognizers;

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender; // Dragging
- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender; // Zooming
- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender; // Rotating
- (IBAction)handleSingleDoubleTapGesture:(UIGestureRecognizer *)sender; // Single Double Tap
- (IBAction)handleLongPressGesture:(UILongPressGestureRecognizer *)sender; // Single Double Tap


- (void)updateImageTransform;

@end
