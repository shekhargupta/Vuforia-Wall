//
//  TouchImageView.m
//  vuforia-wall
//
//  Created by Edo on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TouchImageView.h"



@interface TouchImageView()

//- (void)handleNewGestureTransform:(CGAffineTransform)newTransform withSender:(UIGestureRecognizer*)sender;

@end


@implementation TouchImageView

@synthesize active;

- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		
		
		x = 0.0;
		y = 0.0;
		rotation = 0.0;
		scale = 1.0;
		
		dx = 0.0;
		dy = 0.0;
		drotation = 0.0;
		dscale = 1.0;
		
		[self createGestureRecognizers];
		self.userInteractionEnabled = YES;
		self.multipleTouchEnabled = YES;
    }
    return self;
}

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
	
		
	UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
													  initWithTarget:self action:@selector(handleLongPressGesture:)];
//	longPressGesture.minimumPressDuration = 1.0;
	longPressGesture.numberOfTapsRequired = 1;
	longPressGesture.numberOfTouchesRequired = 1;
//	longPressGesture.allowableMovement = 1.0;
	[self addGestureRecognizer:longPressGesture];//	[longPressGesture release];
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender;
{
	dx = [sender translationInView:self].x;
	dy = [sender translationInView:self].y;
	[self updateImageTransform];	
	if (sender.state == UIGestureRecognizerStateEnded) {
		x = x + dx;
		y = y + dy;
	}
	dx = 0.0;
	dy = 0.0;
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender;
{
	dscale = [sender scale];
	NSLog(@"ds = %f\n", dscale);
	[self updateImageTransform];
	if (sender.state == UIGestureRecognizerStateEnded) {
		scale = scale * dscale;
	}
	dscale = 1.0;

}

- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender;
{
	drotation = [sender rotation] * 50.0;
	[self updateImageTransform];
	if (sender.state == UIGestureRecognizerStateEnded) {
		rotation = rotation + drotation;
	}
	drotation = 0.0;
}

- (IBAction)handleSingleDoubleTapGesture:(UIGestureRecognizer *)sender;
{
    //CGPoint tapPoint = [sender locationInView:sender.view.superview];
	self.active = !self.active;
	/*
    [UIView beginAnimations:nil context:NULL];
    sender.view.center = tapPoint;
    [UIView commitAnimations];
	 */
}

- (IBAction)handleLongPressGesture:(UILongPressGestureRecognizer *)sender;
{
	//self.active = !self.active;
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationTouchImageViewRemoved object:self];
}


- (void)updateImageTransform;
{
	float x_new = x + dx;
	float y_new = y + dy;
	float rotation_new = rotation + drotation;
	float scale_new = scale * dscale;
	NSLog(@"Update with [tx,ty,scale,rotation] = %f,%f,%f,%f\n", x_new,y_new,scale_new,rotation_new);
	
	CGAffineTransform t_translate = CGAffineTransformMakeTranslation(x_new, y_new);
	CGAffineTransform t_rotation = CGAffineTransformMakeRotation(rotation_new / 180.0 * 3.14); // convert to radian
	CGAffineTransform t_scale = CGAffineTransformMakeScale(scale_new, scale_new);
	
	self.transform = CGAffineTransformConcat(CGAffineTransformConcat(t_translate, t_rotation), t_scale);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	[super drawRect:rect];
	if (active) {
		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSetRGBFillColor(ctx, 1.0, 1.0, 0.0, 1.0);
		CGContextBeginPath(ctx);
		CGContextAddRect(ctx, rect);
		CGContextFillPath(ctx);
	}
    // Drawing code
}





- (float)myX;
{
	return x;
}
- (float)myY;
{
	return y;
}
- (float)myRotation;
{
	return rotation;
}
- (float)myScale;
{
	return scale;
}



@end
