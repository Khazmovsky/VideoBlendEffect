//
//  MyFilter.h
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-17.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"
#import <AVFoundation/AVFoundation.h>
#import "YXActionMovie.h"


typedef NS_ENUM(NSInteger, ShaderMode) {
    PASS,
    VIG,
    BLEND,
    BLINK
};


@interface MyFilter : GPUImageTwoInputFilter <YXActionMovieDelegate> {
    GLint vignetteCenterUniform,vignetteColorUniform,vignetteStartUniform,vignetteEndUniform;
}

@property (nonatomic ,assign) ShaderMode mode;
@property (nonatomic ,assign) CGFloat source_video_duration;
@property (nonatomic ,assign) CGFloat current_video_frame_time;
- (void)acitonMovieReplayed:(YXActionMovie *)aMovie;

@end
