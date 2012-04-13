//
//  TouchImageView.m
//  vuforia-wall
//
//  Created by Edo on 13.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TouchImageView.h"

@implementation TouchImageView

@synthesize active;
@synthesize currentImageFrame;


- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		[self createGestureRecognizers];
    }
    return self;
}

- (void)createGestureRecognizers;
{
	UITapGestureRecognizer *singleFingerDTap = [[UITapGestureRecognizer alloc]
												initWithTarget:self action:@selector(handleSingleDoubleTap:)];
    singleFingerDTap.numberOfTapsRequired = 2;
    [self addGestureRecognizer:singleFingerDTap];
//	[singleFingerDTap release];
	
	
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]
										  initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
//	[panGesture release];
	
	
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]
											  initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
//	[pinchGesture release];
	
	
	UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc]
													initWithTarget:self action:@selector(handleRotationGesture:)];
	[self addGestureRecognizer:rotationGesture];
//	[rotationGesture release];
	
	
	UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]
													  initWithTarget:self action:@selector(handleLongPressGesture:)];
//	longPressGesture.minimumPressDuration = 1.0;
	longPressGesture.numberOfTapsRequired = 1;
	longPressGesture.numberOfTouchesRequired = 1;
//	longPressGesture.allowableMovement = 1.0;
	[self addGestureRecognizer:longPressGesture];
//	[longPressGesture release];
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender;
{
    CGPoint translate = [sender translationInView:self];
	
	if (sender.state == UIGestureRecognizerStateBegan) {
		self.currentImageFrame = sender.view.frame;
	}
	
    CGRect newFrame = currentImageFrame;
    newFrame.origin.x += translate.x;
    newFrame.origin.y += translate.y;
    sender.view.frame = newFrame;
	
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.currentImageFrame = newFrame;
	}
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender;
{
    CGFloat factor = [sender scale];
    self.transform = CGAffineTransformMakeScale(factor, factor);
}

- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender;
{
	CGAffineTransform rotate = CGAffineTransformMakeRotation( 1.0 / 180.0 * 3.14 );
	[self setTransform:rotate];
}

- (IBAction)handleSingleDoubleTapGesture:(UIGestureRecognizer *)sender {
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


@end
