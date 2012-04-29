//
//  Plane3D.h
//  vuforia-wall
//
//  Created by Edo on 16.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AR_EAGLView.h"

@interface Plane3D : Object3D

- (void)scaleWidth:(float)width andHeight:(float)height;
- (void)setTextureWithImage:(UIImage*)image;

@end
