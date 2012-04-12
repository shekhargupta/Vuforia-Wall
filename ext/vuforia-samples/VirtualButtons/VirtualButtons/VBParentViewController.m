/*==============================================================================
 Copyright (c) 2012 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "VBParentViewController.h"
#import "ARViewController.h"
#import "VBOverlayViewController.h"
#import "EAGLView.h"


@implementation VBParentViewController // subclass of ARParentViewController

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    parentView = [[UIView alloc] initWithFrame:arViewRect];
    
    // Add the EAGLView
    arViewController = [[ARViewController alloc] init];
    
    // need to set size here to setup camera image size for AR
    arViewController.arViewSize = arViewRect.size;
    [parentView addSubview:arViewController.view];
    
     // Create an auto-rotating overlay view and its view controller (used for
    // displaying UI objects, such as the camera control menu)
    VBOverlayViewController *vboVC = [[VBOverlayViewController alloc] init];
    overlayViewController = vboVC;
    [parentView addSubview: overlayViewController.view];
    
    // give the overlay a way of updating the button state in the AR view.
    vboVC.buttonStateUpdaterId = arViewController.arView;
    vboVC.buttonStateUpdaterSel = @selector(updateButtonState:);
    
    self.view = parentView;
}


@end
