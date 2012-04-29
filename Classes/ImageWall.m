//
//  ImageWall.m
//  vuforia-wall
//
//  Created by Eduard Feicho <eduard_DOT_feicho_AT_rwth-aachen_DOT_de> on 13.04.12.
//  Source: https://github.com/Duffycola/Vuforia-Wall
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "ImageWall.h"




@interface ImageWall()

- (void)actionImagePicked:(NSNotification*)notification;
- (void)actionImageRemoved:(NSNotification*)notification;

@end





@implementation ImageWall


@synthesize images;
@synthesize selectedImage;
@synthesize frame;


#pragma mark - Singleton

+ (ImageWall*)sharedInstance;
{
	static ImageWall *singleton;
	
	@synchronized(self)
	{
		if (!singleton) {
			singleton = [[ImageWall alloc] init];
			singleton.images = [[NSMutableArray alloc] initWithObjects:nil];
			[[NSNotificationCenter defaultCenter] addObserver:singleton selector:@selector(actionImagePicked:) name:notificationImagePickerFinished object:nil];
			[[NSNotificationCenter defaultCenter] addObserver:singleton selector:@selector(actionImageRemoved:) name:notificationTouchImageViewRemoved object:nil];
		}
		return singleton;
	}
}

- (void)actionImagePicked:(NSNotification*)notification;
{
	if (notification.object == nil) {
		return;
	}
	
	UIImage* image = notification.object;
	CGSize imageSize = [image size];
	imageSize = CGSizeMake(imageSize.width / 4.0, imageSize.height / 4.0);
	CGRect imageFrame = CGRectMake((self.frame.size.width-imageSize.width)/2.0, (self.frame.size.height-imageSize.height)/2.0, imageSize.width, imageSize.height);
	
	TouchImageView* touchImage = [[TouchImageView alloc] initWithFrame:imageFrame];
	touchImage.image = image;
	
	[self.images addObject:touchImage];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationImageWallAddImage object:touchImage];
}

- (void)actionImageRemoved:(NSNotification*)notification;
{
	if (!notification.object) {
		return;
	}
	
	TouchImageView* touchImage = notification.object;
	[self.images removeObject:touchImage];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationImageWallRemoveImage object:touchImage];
}


@end
