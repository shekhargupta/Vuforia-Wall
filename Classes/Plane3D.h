//
//  Plane3D.h
//  vuforia-wall
//
//  Created by Eduard Feicho <eduard_DOT_feicho_AT_rwth-aachen_DOT_de> on 16.04.12.
//  Copyright (c) 2012 Eduard Feicho. All rights reserved.
//

#import "AR_EAGLView.h"

@interface Plane3D : Object3D

- (void)scaleWidth:(float)width andHeight:(float)height;
- (void)setTextureWithImage:(UIImage*)image;

@end
