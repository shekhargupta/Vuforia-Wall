/*==============================================================================
            Copyright (c) 2012 QUALCOMM Incorporated.
            All Rights Reserved.
            Qualcomm Confidential and Proprietary
==============================================================================*/

#define STRINGIFY(x) #x

static const char passThroughVertexShader[] = STRINGIFY(
    attribute vec4 vertexPosition;
    attribute vec2 vertexTexCoord;
    uniform mat4 modelViewProjectionMatrix;
    varying vec2 texCoord;

    void main()
    {
        gl_Position = modelViewProjectionMatrix * vertexPosition;
        texCoord = vertexTexCoord;
    }
);

static const char passThroughFragmentShader[] = STRINGIFY(
    precision mediump float;
    varying vec2 texCoord;
    uniform sampler2D texSamplerVideo;

    void main ()
    {
        gl_FragColor = texture2D(texSamplerVideo, texCoord);
    }
);

static const char occlusionFragmentShader[] = STRINGIFY(
    precision mediump float;
    varying vec2 texCoord;
    uniform sampler2D texSamplerMask;
    uniform sampler2D texSamplerVideo;
    uniform vec2 viewportOrigin;
    uniform vec2 viewportSize;
    uniform vec2 textureRatio;

    void main ()
    {
        vec2 screenCoord;
        screenCoord.x = (gl_FragCoord.x-viewportOrigin.x)/viewportSize.x *   textureRatio.x;
        screenCoord.y = ((1.0 - ((gl_FragCoord.y-viewportOrigin.y)/viewportSize.y)) * textureRatio.y);
        vec3 videoColor = texture2D(texSamplerVideo, screenCoord.xy).rgb;
        float maskColor  = texture2D(texSamplerMask, texCoord.xy).x;
        gl_FragColor.rgba = vec4(videoColor.r, videoColor.g, videoColor.b, maskColor);
    }
);

