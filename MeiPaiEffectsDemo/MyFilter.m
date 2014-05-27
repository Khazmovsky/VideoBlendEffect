//
//  MyFilter.m
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-17.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "MyFilter.h"

NSString *const kVignetteFragmentShaderString = SHADER_STRING
(
 uniform sampler2D inputImageTexture;
 varying highp vec2 textureCoordinate;
 
 uniform lowp vec2 vignetteCenter;
 uniform lowp vec3 vignetteColor;
 uniform highp float vignetteStart;
 uniform highp float vignetteEnd;
 
 void main()
 {
     lowp vec4 sourceImageColor = texture2D(inputImageTexture, textureCoordinate);
     lowp float d = distance(textureCoordinate, vec2(vignetteCenter.x, vignetteCenter.y));
     lowp float percent = smoothstep(vignetteStart, vignetteEnd, d);
     gl_FragColor = vec4(mix(sourceImageColor.rgb, vignetteColor, percent), sourceImageColor.a);
 }
 );


NSString *const ksMultiplyBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     lowp vec4 base = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 overlayer = texture2D(inputImageTexture2, textureCoordinate2);
     mediump vec4 whiteColor = vec4(1.0);
     gl_FragColor = whiteColor - ((whiteColor - overlayer) * (whiteColor - base));
 }
 );

@interface MyFilter ()

@property (nonatomic ,strong) YXActionMovie *tail_video;

@end

@implementation MyFilter {
    BOOL playEnded;
}

- (id)init {
    if (self = [super initWithVertexShaderFromString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderFromString:kGPUImagePassthroughFragmentShaderString]) {
        [self disableSecondFrameCheck];
        _mode = PASS;
    }
    return self;
}

-(void)actionMovie:(YXActionMovie *)aMovie currentFrameTime:(CGFloat)currentFrameTime {
    if (playEnded) {
        _mode = PASS;
        playEnded = NO;
        [self switchToVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
    } else if (currentFrameTime >= _source_video_duration - 2.0 && _mode != BLEND) {
        _mode = BLEND;
        [self switchToVertexShaderString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderString:ksMultiplyBlendFragmentShaderString];
        _tail_video = [[YXActionMovie alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"bg_1" withExtension:@"mov"]];
        _tail_video.playAtActualSpeed = YES;
        [_tail_video addTarget:self];
        [_tail_video startProcessing];
    }
}


- (void)setCurrent_video_frame_time:(CGFloat)current_video_frame_time {
    if (current_video_frame_time >= _source_video_duration - 2.0 && _mode != BLEND && current_video_frame_time < _source_video_duration) {
        _mode = BLEND;
        [self switchToVertexShaderString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderString:ksMultiplyBlendFragmentShaderString];
        _tail_video = [[YXActionMovie alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"bg_1" withExtension:@"mov"]];
//        _tail_video.playAtActualSpeed = YES;
        [_tail_video addTarget:self];
        [_tail_video startProcessing];
    }
    _current_video_frame_time = current_video_frame_time;
}

- (void)didCompletePlayingMovie:(YXActionMovie *)aMovie {
//    playEnded = YES;
//    _mode = PASS;
}


- (void)switchToVertexShaderString:(NSString *)newVertexShader fragmentShaderString:(NSString *)newFragmentShader {
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        filterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:newVertexShader fragmentShaderString:newFragmentShader];
        
        if (!filterProgram.initialized)
        {
            [self initializeAttributes];
            
            if (![filterProgram link])
            {
                NSString *progLog = [filterProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [filterProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [filterProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                filterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        filterPositionAttribute = [filterProgram attributeIndex:@"position"];
        filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
        filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        
        [GPUImageContext setActiveShaderProgram:filterProgram];
        
        
        [self bindUniformsWithMode:_mode];
        
        glEnableVertexAttribArray(filterPositionAttribute);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
        
        /*
        secondFilterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:newVertexShader fragmentShaderString:newFragmentShader];

        if (!secondFilterProgram.initialized)
        {
            [self initializeSecondaryAttributes];

            if (![secondFilterProgram link])
            {
                NSString *progLog = [secondFilterProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [secondFilterProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [secondFilterProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                secondFilterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }

        secondFilterPositionAttribute = [secondFilterProgram attributeIndex:@"position"];
        secondFilterTextureCoordinateAttribute = [secondFilterProgram attributeIndex:@"inputTextureCoordinate"];
        secondFilterInputTextureUniform = [secondFilterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        secondFilterInputTextureUniform2 = [secondFilterProgram uniformIndex:@"inputImageTexture2"]; // This does assume a name of "inputImageTexture2" for second input texture in the fragment shader
        horizontalPassTexelWidthOffsetUniform = [secondFilterProgram uniformIndex:@"texelWidthOffset"];
        horizontalPassTexelHeightOffsetUniform = [secondFilterProgram uniformIndex:@"texelHeightOffset"];
        [GPUImageContext setActiveShaderProgram:secondFilterProgram];

        glEnableVertexAttribArray(secondFilterPositionAttribute);
        glEnableVertexAttribArray(secondFilterTextureCoordinateAttribute);
         */
        
        [self setupFilterForSize:[self sizeOfFBO]];
        glFinish();
    });

}


- (void)bindUniformsWithMode:(ShaderMode)mode {
    switch (mode) {
        case PASS: {
            
        }
            break;
        case VIG: {
            vignetteCenterUniform = [filterProgram uniformIndex:@"vignetteCenter"];
            vignetteColorUniform = [filterProgram uniformIndex:@"vignetteColor"];
            vignetteStartUniform = [filterProgram uniformIndex:@"vignetteStart"];
            vignetteEndUniform = [filterProgram uniformIndex:@"vignetteEnd"];
            [self setPoint:CGPointMake(0.5, 0.5) forUniform:vignetteCenterUniform program:filterProgram];
            [self setVec3:(GPUVector3){0,0,0} forUniform:vignetteColorUniform program:filterProgram];
            [self setFloat:0.3 forUniform:vignetteStartUniform program:filterProgram];
            [self setFloat:0.75 forUniform:vignetteEndUniform program:filterProgram];
        }
            break;
        case BLEND: {
            filterSecondTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate2"];
            filterInputTextureUniform2 = [filterProgram uniformIndex:@"inputImageTexture2"];
            glEnableVertexAttribArray(filterSecondTextureCoordinateAttribute);
        }
            break;
        case BLINK: {
            
        }
            break;
    }
}

- (void)acitonMovieReplayed:(YXActionMovie *)aMovie {
    
}

@end
