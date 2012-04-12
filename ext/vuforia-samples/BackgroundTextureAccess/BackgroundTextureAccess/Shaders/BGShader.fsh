/*==============================================================================
            Copyright (c) 2012 QUALCOMM Austria Research Center GmbH.
            All Rights Reserved.
            Qualcomm Confidential and Proprietary
==============================================================================*/


#define STRINGIFY(x) #x

static const char fragmentShaderSrc[] = STRINGIFY(
    precision mediump float;
    varying vec2 texCoord;
    uniform sampler2D texSampler2D;
    void main ()
    {
        vec3 incoming = texture2D(texSampler2D, texCoord).rgb;
        float colorOut=1.0- ((incoming.r+incoming.g+incoming.b)/3.0);
        gl_FragColor.rgba = vec4(colorOut, colorOut, colorOut, 1.0);
    }
);
