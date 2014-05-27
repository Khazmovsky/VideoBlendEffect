//
//  EffectShaderString.h
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-16.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//


#import "GPUImage.h"

//高斯模糊

NSString *const kGaussianBlurVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 uniform float texelWidthOffset;
 uniform float texelHeightOffset;
 
 varying vec2 blurCoordinates[15];
 
 void main()
 {
     gl_Position = position;
     
     vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
     blurCoordinates[0] = inputTextureCoordinate.xy;
     blurCoordinates[1] = inputTextureCoordinate.xy + singleStepOffset * 1.492347;
     blurCoordinates[2] = inputTextureCoordinate.xy - singleStepOffset * 1.492347;
     blurCoordinates[3] = inputTextureCoordinate.xy + singleStepOffset * 3.482150;
     blurCoordinates[4] = inputTextureCoordinate.xy - singleStepOffset * 3.482150;
     blurCoordinates[5] = inputTextureCoordinate.xy + singleStepOffset * 5.471968;
     blurCoordinates[6] = inputTextureCoordinate.xy - singleStepOffset * 5.471968;
     blurCoordinates[7] = inputTextureCoordinate.xy + singleStepOffset * 7.461809;
     blurCoordinates[8] = inputTextureCoordinate.xy - singleStepOffset * 7.461809;
     blurCoordinates[9] = inputTextureCoordinate.xy + singleStepOffset * 9.451682;
     blurCoordinates[10] = inputTextureCoordinate.xy - singleStepOffset * 9.451682;
     blurCoordinates[11] = inputTextureCoordinate.xy + singleStepOffset * 11.441595;
     blurCoordinates[12] = inputTextureCoordinate.xy - singleStepOffset * 11.441595;
     blurCoordinates[13] = inputTextureCoordinate.xy + singleStepOffset * 13.431555;
     blurCoordinates[14] = inputTextureCoordinate.xy - singleStepOffset * 13.431555;
 }
);

NSString *const kGaussianBlurFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 uniform highp float texelWidthOffset;
 uniform highp float texelHeightOffset;
 
 varying highp vec2 blurCoordinates[15];
 
 uniform lowp int is_need_blur;
 
 void main()
 {
     lowp vec4 sum = vec4(0.0);
         sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.058055;
         sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.113199;
         sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.113199;
         sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.102271;
         sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.102271;
         sum += texture2D(inputImageTexture, blurCoordinates[5]) * 0.085191;
         sum += texture2D(inputImageTexture, blurCoordinates[6]) * 0.085191;
         sum += texture2D(inputImageTexture, blurCoordinates[7]) * 0.065427;
         sum += texture2D(inputImageTexture, blurCoordinates[8]) * 0.065427;
         sum += texture2D(inputImageTexture, blurCoordinates[9]) * 0.046329;
         sum += texture2D(inputImageTexture, blurCoordinates[10]) * 0.046329;
         sum += texture2D(inputImageTexture, blurCoordinates[11]) * 0.030246;
         sum += texture2D(inputImageTexture, blurCoordinates[12]) * 0.030246;
         sum += texture2D(inputImageTexture, blurCoordinates[13]) * 0.018206;
         sum += texture2D(inputImageTexture, blurCoordinates[14]) * 0.018206;
         gl_FragColor = sum;
 }
);


//格栅效果

NSString *const kTwoInputTextureVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 attribute vec4 inputTextureCoordinate2;
 
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
     textureCoordinate2 = inputTextureCoordinate2.xy;
 }
 );


NSString *const kMultiplyBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     lowp vec4 base = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 overlayer = texture2D(inputImageTexture2, textureCoordinate2);
     
     gl_FragColor = overlayer * base + overlayer * (1.0 - base.a) + base * (1.0 - overlayer.a);
 }
 );

/**
 *  S变形
 */

NSString *const kStwistFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp vec2 facotr;
 
 void main()
 {
     highp float offset;
     highp vec2 textureCoordinateToUse;
     if(textureCoordinate.y >= 0.0 && textureCoordinate.y <= 0.6) {
         offset = -0.5 * pow(textureCoordinate.y, 2.0) + 0.3 * textureCoordinate.y - 0.05;
     } else if (textureCoordinate.y > 0.6 && textureCoordinate.y <= 0.9) {
         offset = 0.6 * (textureCoordinate.y - 0.3) * (textureCoordinate.y - 0.9) + 0.004;
     } else {
         offset = -0.9 * pow((textureCoordinate.y - 0.9), 2.0) + 0.004;
     }
     
     offset = facotr * offset;
     
     textureCoordinateToUse = vec2(textureCoordinate.x + offset, textureCoordinate.y);
     gl_FragColor = texture2D(inputImageTexture, textureCoordinateToUse);
 }
 );


