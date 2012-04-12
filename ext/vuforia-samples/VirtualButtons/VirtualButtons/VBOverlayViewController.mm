/*==============================================================================
 Copyright (c) 2012 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "VBOverlayViewController.h"
#import <QCAR/QCAR.h>
#import <QCAR/CameraDevice.h>
#import "QCARutils.h"

@implementation VBOverlayViewController

@synthesize buttonStateUpdaterId;
@synthesize buttonStateUpdaterSel;


// UIActionSheetDelegate event handlers

- (void)updateButtonState:(int)newState
{
    [buttonStateUpdaterId performSelector:buttonStateUpdaterSel withObject:(id)newState];
}

- (void) showOverlay
{
    // Show camera control action sheet
    mainOptionsAS = [[[UIActionSheet alloc] initWithTitle:nil
                                                 delegate:self
                                        cancelButtonTitle:nil
                                   destructiveButtonTitle:nil
                                        otherButtonTitles:nil] autorelease];
    
    // add torch and focus control buttons if supported by the device
    torchIx = -1;
    autofocusIx = -1;
    autofocusContIx = -1;
    
    redVbIx = [mainOptionsAS addButtonWithTitle:@"Toggle red virtual button"];
    
    blueVbIx = [mainOptionsAS addButtonWithTitle:@"Toggle blue virtual button"];
    
    yellowVbIx = [mainOptionsAS addButtonWithTitle:@"Toggle yellow virtual button"];
    
    greenVbIx = [mainOptionsAS addButtonWithTitle:@"Toggle green virtual button"];

    if (YES == cameraCapabilities.torch)
    {
        // set button text according to the current mode (toggle)
        BOOL torchMode = [[QCARutils getInstance] cameraTorchOn];
        NSString *text = YES == torchMode ? @"Torch off" : @"Torch on";
        torchIx = [mainOptionsAS addButtonWithTitle:text];
    }
    
    if (YES == cameraCapabilities.autofocus)
    {
        autofocusIx = [mainOptionsAS addButtonWithTitle:@"Autofocus"];
    }
    
    if (YES == cameraCapabilities.autofocusContinuous)
    {
        // set button text according to the current mode (toggle)
        BOOL contAFMode = [[QCARutils getInstance] cameraContinuousAFOn];
        NSString *text = YES == contAFMode ? @"Continuous autofocus off" : @"Continuous autofocus on";
        autofocusContIx = [mainOptionsAS addButtonWithTitle:text];
    }
    
    // add 'select target' if there is more than one target
    selectTargetIx = -1;
    if (qUtils.targetsList && [qUtils.targetsList count] > 1)
    {
        selectTargetIx = [mainOptionsAS addButtonWithTitle:@"Select Target"];
    }
    
    NSInteger cancelIx = [mainOptionsAS addButtonWithTitle:@"Cancel"];
    [mainOptionsAS setCancelButtonIndex:cancelIx];
    
    self.view.userInteractionEnabled = YES;
    [mainOptionsAS showInView:self.view];
}


// UIActionSheetDelegate event handlers

- (void) mainOptionClickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == selectTargetIx)
    {
        // Select targets from a sub menu
        [super targetSelectInView:self.view];
    }
    else
    {
        // else handle the button action
        if (redVbIx == buttonIndex)
        {
            // toggle the red virtual button
            [self updateButtonState:(1 << 0)];
        }
        else if (blueVbIx == buttonIndex)
        {
            // toggle the blue virtual button
            [self updateButtonState:(1 << 1)];
        }
        else if (yellowVbIx == buttonIndex)
        {
            // toggle the yellow virtual button
            [self updateButtonState:(1 << 2)];
        }
        else if (greenVbIx == buttonIndex)
        {
            // toggle the green virtual button
            [self updateButtonState:(1 << 3)];
        }
        else if (torchIx == buttonIndex)
        {
            // toggle camera torch mode
            BOOL newTorchMode = ![qUtils cameraTorchOn];
            [qUtils cameraSetTorchMode:newTorchMode];
        }
        else if (autofocusContIx == buttonIndex)
        {
            // toggle camera continuous autofocus mode
            BOOL newContAFMode = ![qUtils cameraContinuousAFOn];
            [qUtils cameraSetContinuousAFMode:newContAFMode];
        }
        else if (autofocusIx == buttonIndex)
        {
            // trigger camera autofocus
            [qUtils cameraTriggerAF];
        }
        
        self.view.userInteractionEnabled = NO;
    }
}


@end
