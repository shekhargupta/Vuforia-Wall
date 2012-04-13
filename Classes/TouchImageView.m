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
@synthesize translation;
@synthesize scale;
@synthesize rotationAngle;
@synthesize currentImageTransform;



- (id)initWithFrame:(CGRect)frame;
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
		
		self.scale = 1.0;
		self.rotationAngle = 1.0;
		self.translation = CGPointMake(0, 0);
		
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
    CGPoint translate = [sender translationInView:self];
    CGAffineTransform gestureTransform = CGAffineTransformMakeTranslation(translate.x, translate.y);
	[self handleNewGestureTransform:gestureTransform withSender:sender];
	
	
	
	/*
	if (sender.state == UIGestureRecognizerStateBegan) {
		self.currentImageFrame = sender.view.frame;
		CGAffineTransformMakeTranslation(translate.x, translate.y);
	}
	
	CGPoint newTranslation = [sender translationInView:self];
    CGAffineTransform gestureTransform = CGAffineTransformMakeTranslation(translate.x, translate.y);
	CGAffineTransformTranslate(self.transform, translation.x, translation.y);
	
    if (sender.state == UIGestureRecognizerStateEnded) {
        self.currentImageFrame = newFrame;
	}
	*/
}

- (IBAction)handlePinchGesture:(UIPinchGestureRecognizer *)sender;
{
	CGFloat factor = [sender scale];
    CGAffineTransform gestureTransform = CGAffineTransformMakeScale(factor, factor);
	[self handleNewGestureTransform:gestureTransform withSender:sender];
	
	/*
    if (sender.state == UIGestureRecognizerStateBegan) {
		self.currentImageTransform = self.transform;
	}
	
	CGFloat factor = [sender scale];
    self.transform = CGAffineTransformConcat(self.currentImageTransform, CGAffineTransformMakeScale(self.currentImageScale*factor, self.currentImageScale*factor));
	
	if (sender.state == UIGestureRecognizerStateEnded) {
		//self.currentImageScale = self.currentImageScale * factor;
		self.currentImageTransform = self.transform;
	}
	*/
}

- (IBAction)handleRotationGesture:(UIRotationGestureRecognizer *)sender;
{
	CGFloat factor = [sender rotation] * 10.0 / 180.0 * 3.14;
    CGAffineTransform gestureTransform = CGAffineTransformMakeRotation( factor );
	[self handleNewGestureTransform:gestureTransform withSender:sender];
		
	/*
	if (sender.state == UIGestureRecognizerStateBegan) {
		self.currentImageTransform = self.transform;
	}
	
	CGFloat factor = [sender rotation];
    self.transform = CGAffineTransformConcat(self.currentImageTransform, CGAffineTransformMakeRotation( factor / 180.0 * 3.14 ));
	
	if (sender.state == UIGestureRecognizerStateEnded) {
		//self.currentImageScale = self.currentImageScale * factor;
		self.currentImageTransform = self.transform;
	}
	 */
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



- (void)handleNewGestureTransform:(CGAffineTransform)newTransform withSender:(UIGestureRecognizer*)sender;
{
	if (sender.state == UIGestureRecognizerStateBegan) {
		self.currentImageTransform = self.transform;
	}
	
    self.transform = CGAffineTransformConcat(self.currentImageTransform, newTransform);
	
	if (sender.state == UIGestureRecognizerStateEnded) {
		self.currentImageTransform = self.transform;
	}
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
