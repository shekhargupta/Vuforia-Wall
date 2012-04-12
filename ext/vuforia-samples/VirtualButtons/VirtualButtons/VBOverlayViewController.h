/*==============================================================================
 Copyright (c) 2012 QUALCOMM Austria Research Center GmbH.
 All Rights Reserved.
 Qualcomm Confidential and Proprietary
 ==============================================================================*/

#import "OverlayViewController.h"

@interface VBOverlayViewController : OverlayViewController {
    id buttonStateUpdaterId;
    SEL buttonStateUpdaterSel;

    NSInteger redVbIx;          // index of red VB toggle button
    NSInteger blueVbIx;          // index of blue VB toggle button
    NSInteger yellowVbIx;          // index of yellow VB toggle button
    NSInteger greenVbIx;          // index of green VB toggle button
}

@property (nonatomic, assign) id buttonStateUpdaterId;
@property (nonatomic, assign) SEL buttonStateUpdaterSel;

@end
