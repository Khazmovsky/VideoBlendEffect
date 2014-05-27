//
//  YXVideoAlphaTransitionFilter.m
//  多着色器程序演示
//
//  Created by Khazmovsky on 14-5-21.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "YXVideoAlphaTransitionFilter.h"
#import "GPUImagePicture.h"

NSString *const xxxxxz = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float mixturePercent;
 
 void main()
 {
	 lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
	 lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
	 
	 gl_FragColor = vec4(mix(textureColor.rgb, textureColor2.rgb, textureColor2.a * mixturePercent), textureColor.a);
 } );

@interface YXVideoAlphaTransitionFilter ()

@property (nonatomic ,strong) GPUImagePicture *currentPic;

@end

@implementation YXVideoAlphaTransitionFilter

- (id)init {
    if (self = [super initWithFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString]) {

    }
    return self;
}

- (void)setCurrentVideoFrameTime:(GLfloat)currentVideoFrameTime {
    if (_currentVideoFrameTime != currentVideoFrameTime) {
        _currentVideoFrameTime = currentVideoFrameTime;
        if (_currentVideoFrameTime >= _startTime && _currentVideoFrameTime < _endTime) {
            [self enableEffect];
        } else {
            [self disableEffect];
        }
    }
}

- (void)enableEffect {
    if (_isBlending) {
        self.intensity -= 1.0f / 30;
        return;
    }
    _isBlending = YES;
    
    self.intensity = 1;
    
    CGImageRef currentCGImage = [self newCGImageFromCurrentlyProcessedOutputWithOrientation:UIImageOrientationUp];
    
    _currentPic = [[GPUImagePicture alloc] initWithCGImage:currentCGImage];
    
    CFRelease(currentCGImage);
    
    [self destroyFilterFBO];
    [self switchToVertexShaderString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderString:xxxxxz];
    
    [self activeSecondInputUniforms];
    
    runSynchronouslyOnVideoProcessingQueue(^{
        mixIntensityUniform = [filterProgram uniformIndex:@"mixturePercent"];
    });
    
    [_currentPic addTarget:self atTextureLocation:1];
    
    [_currentPic processImage];
}

- (void)disableEffect {
    if (!_isBlending) {
        return;
    }
    self.intensity = .8;
    _isBlending = NO;
    [self destroyFilterFBO];
    [self switchToVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
}

- (void)setIntensity:(CGFloat)intensity {
    if (_intensity != intensity) {
        _intensity = intensity;
        [self setFloat:intensity forUniform:mixIntensityUniform program:filterProgram];
    }
//    printf("%.2f\n",intensity);
}

@end
