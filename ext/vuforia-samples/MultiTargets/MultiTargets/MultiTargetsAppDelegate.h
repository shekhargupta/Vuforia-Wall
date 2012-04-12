/*==============================================================================
Copyright (c) 2012 QUALCOMM Austria Research Center GmbH .
All Rights Reserved.
Qualcomm Confidential and Proprietary
==============================================================================*/


#import <UIKit/UIKit.h>
#import "EAGLView.h"

@class ARParentViewController;

@interface MultiTargetsAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    ARParentViewController *arParentViewController;
    UIImageView *splashV;
}

@end
