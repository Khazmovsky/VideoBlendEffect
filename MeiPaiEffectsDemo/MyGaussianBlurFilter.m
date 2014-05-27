//
//  MyGaussianBlurFilter.m
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-17.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//
//高斯模糊

#import "GPUImage.h"
NSString *const kmYGaussianBlurVertexShaderString = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 uniform float texelWidthOffset;
 uniform float texelHeightOffset;
 
 varying vec2 blurCoordinates[5];
 
 void main()
 {
     gl_Position = position;
     
     vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
     blurCoordinates[0] = inputTextureCoordinate.xy;
     blurCoordinates[1] = inputTextureCoordinate.xy + singleStepOffset * 1.407333;
     blurCoordinates[2] = inputTextureCoordinate.xy - singleStepOffset * 1.407333;
     blurCoordinates[3] = inputTextureCoordinate.xy + singleStepOffset * 3.294215;
     blurCoordinates[4] = inputTextureCoordinate.xy - singleStepOffset * 3.294215;
 }
 );

NSString *const kmYGaussianBlurFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 uniform highp float texelWidthOffset;
 uniform highp float texelHeightOffset;
 
 varying highp vec2 blurCoordinates[5];
 
 void main()
 {
     lowp vec4 sum = vec4(0.0);
     sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.204164;
     sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.304005;
     sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.304005;
     sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.093913;
     sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.093913;
     gl_FragColor = sum;
 }
 );


#import "MyGaussianBlurFilter.h"

@implementation MyGaussianBlurFilter {
    BOOL isBluring;
}

- (id)init {
    if (self = [super initWithFirstStageVertexShaderFromString:kGPUImageTwoInputTextureVertexShaderString firstStageFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString secondStageVertexShaderFromString:kGPUImageTwoInputTextureVertexShaderString secondStageFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString]) {
        
    }
    return self;
}


//- (void)actionMovie:(YXActionMovie *)aMovie currentFrameTime:(CGFloat)currentFrameTime {
//    if (currentFrameTime > _source_video_duration - 2.0 && !isBluring) {
//        isBluring = YES;
//        [self switchToVertexShaderString:kmYGaussianBlurVertexShaderString fragmentShaderString:kmYGaussianBlurFragmentShaderString];
//    } else if (isBluring) {
//        self.blurPasses = (int)(( _source_video_duration - currentFrameTime ) / 10.f * 20.f);
//    }
//}

- (void)setCurrent_video_frame_time:(CGFloat)current_video_frame_time {
    if (current_video_frame_time >= _source_video_duration - 2.0 && !isBluring) {
        isBluring = YES;
        [self switchToVertexShader:kmYGaussianBlurVertexShaderString fragmentShader:kmYGaussianBlurFragmentShaderString];
    } else if (isBluring) {
        int new_blur_passes = (int)((current_video_frame_time + 2.0 - _source_video_duration) / 2.0 * 20.0);
        if (self.blurPasses != new_blur_passes) {
            self.blurPasses = new_blur_passes;
        }
        printf("blurpasses : %lu\n",self.blurPasses);
    }
    _current_video_frame_time = current_video_frame_time;
}

- (void)didCompletePlayingMovie:(YXActionMovie *)aMovie {
    isBluring = NO;
    [self switchToVertexShader:kmYGaussianBlurVertexShaderString fragmentShader:kmYGaussianBlurFragmentShaderString];
}

- (void)acitonMovieReplayed:(YXActionMovie *)aMovie {
//    isBluring = NO;
//    self.blurPasses = 1;
//    [self switchToVertexShader:kGPUImageTwoInputTextureVertexShaderString fragmentShader:kGPUImagePassthroughFragmentShaderString];
}

@end
