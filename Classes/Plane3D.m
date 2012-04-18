//
//  Plane3D.m
//  vuforia-wall
//
//  Created by Edo on 16.04.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Plane3D.h"
#include "Texture.h"


@implementation Plane3D

#define PLANE3D_NUM_VERTICES 4
#define PLANE3D_NUM_INDICES (2*3)



static float planeVertices[PLANE3D_NUM_VERTICES*3] =
{
	-1.0, +1.0, 0,
	+1.0, +1.0, 0,
	-1.0, -1.0, 0,
	+1.0, -1.0, 0,
};


static float planeNormals[PLANE3D_NUM_VERTICES*3] =
{
	0.0, 0.0, -1.0,
	0.0, 0.0, -1.0,
	0.0, 0.0, -1.0,
	0.0, 0.0, -1.0,
};


static float planeTexCoords[PLANE3D_NUM_VERTICES*2] =
{
	1.0, 1.0,
	0.0, 1.0,
	1.0, 0.0,
	0.0, 0.0,
};


static unsigned short planeIndices[PLANE3D_NUM_INDICES] =
{
	0, 2, 1,
	2, 3, 1,
};


-(id)init;
{
	self = [super init];
    if (self) {
        // Custom initialization
		self.numVertices = PLANE3D_NUM_VERTICES;
		self.numIndices = PLANE3D_NUM_INDICES;
		
		vertices  = planeVertices;
		normals   = planeNormals;
		texCoords = planeTexCoords;
		indices   = planeIndices;
    }
    return self;
}

- (void)scaleWidth:(float)width andHeight:(float)height;
{
	for (int i=0; i<PLANE3D_NUM_VERTICES; i++) {
		planeVertices[i*3]   = planeVertices[i*3] * width;
		planeVertices[i*3+1] = planeVertices[i*3+1] * height;
	}
}

- (void)setTextureWithImage:(UIImage*)image;
{
	GLuint nID;
	Texture *theTexture = [[Texture alloc] init];
	[theTexture loadImageDirect:image];
	
	glGenTextures(1, &nID);
	[theTexture setTextureID: nID];
	glBindTexture(GL_TEXTURE_2D, nID);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, [theTexture width], [theTexture height], 0, GL_RGBA, GL_UNSIGNED_BYTE, (GLvoid*)[theTexture pngData]);
	
	self.texture = theTexture;
}

@end
