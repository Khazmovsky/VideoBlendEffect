//
//  YXVideoBlendFrameRollFilter.m
//  多着色器程序演示
//
//  Created by Khazmovsky on 14-5-26.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "YXVideoBlendFrameRollFilter.h"
#import "GPUImagePicture.h"


NSString *const kYXVideoBlendFrameRollDownTranslationTransistionFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 highp vec2 textureCoordinateToUse;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 uniform lowp float progress;
 
 void main()
 {
     highp float offset = 1.0 - progress;
     
     if(textureCoordinate.y > progress) {
         textureCoordinateToUse = vec2(textureCoordinate2.x, textureCoordinate2.y - progress);
         gl_FragColor = texture2D(inputImageTexture2, textureCoordinateToUse);
     } else {
         textureCoordinateToUse = vec2(textureCoordinate.x, textureCoordinate.y + offset);
         gl_FragColor = texture2D(inputImageTexture, textureCoordinateToUse);
     }
 }
 );

@interface YXVideoBlendFrameRollFilter ()

@property (nonatomic ,strong) GPUImagePicture *transitionPicture;
@property (nonatomic ,assign) CGFloat progress;
@property (nonatomic ,assign) CGFloat maxEndControlTime;

@end

@implementation YXVideoBlendFrameRollFilter {
    GLint progressUniform;
}

- (id)init {
    if (self = [super initWithFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString]) {
        self.isBlending = NO;
    }
    return self;
}

- (void)setCurrentVideoFrameTime:(GLfloat)currentVideoFrameTime {
    if (_currentVideoFrameTime != currentVideoFrameTime) {
        _currentVideoFrameTime = currentVideoFrameTime;
        for (NSNumber *number in self.controlTimes.allKeys) {
            CGFloat start = [number floatValue];
            CGFloat end = [self.controlTimes[number] floatValue];
            if (_currentVideoFrameTime > start && _currentVideoFrameTime < end) {
                _startTime = start;
                _endTime = end;
                [self enableEffect];
            } else if(_currentVideoFrameTime > _endTime && _currentVideoFrameTime < start) {
                [self disableEffect];
            }
        }
    }
    _maxEndControlTime = [self getMaxValue:self.controlTimes];
    if (_currentVideoFrameTime > _maxEndControlTime) {
        [self disableEffect];
    }
}

- (CGFloat)getMaxValue:(NSDictionary *)dic {
    float max = 0.0;
    for (NSNumber *number in dic) {
        float v = [dic[number] floatValue];
        max = max > v ? max : v;
    }
    return max;
}


- (void)enableEffect {
    if (_isBlending) {
        self.progress = (self.currentVideoFrameTime - self.startTime) * 1.0 / (self.endTime - self.startTime);
        return;
    }
    _isBlending = YES;
    CGImageRef acgimage = [self newCGImageFromCurrentlyProcessedOutputWithOrientation:UIImageOrientationUp];
    _transitionPicture = [[GPUImagePicture alloc] initWithCGImage:acgimage];
    CFRelease(acgimage);
    
    [self switchToVertexShaderString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderString:kYXVideoBlendFrameRollDownTranslationTransistionFragmentShaderString];
    
    [self activeSecondInputUniforms];
    runSynchronouslyOnVideoProcessingQueue(^{
        progressUniform = [filterProgram uniformIndex:@"progress"];
    });
    [_transitionPicture addTarget:self atTextureLocation:1];
    [_transitionPicture processImage];}

- (void)disableEffect {
    if (!_isBlending) {
        return;
    }
    _isBlending = NO;
    [self switchToVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
}

- (void)setProgress:(CGFloat)progress {
    [self setFloat:progress forUniform:progress program:filterProgram];
}

@end
