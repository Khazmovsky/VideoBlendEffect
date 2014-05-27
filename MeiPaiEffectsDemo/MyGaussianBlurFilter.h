//
//  MyGaussianBlurFilter.h
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-17.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "GPUImageGaussianBlurFilter.h"
#import "YXActionMovie.h"

@interface MyGaussianBlurFilter : GPUImageGaussianBlurFilter <YXActionMovieDelegate>

@property (nonatomic ,assign) CGFloat source_video_duration;
@property (nonatomic ,assign) CGFloat current_video_frame_time;
- (void)acitonMovieReplayed:(YXActionMovie *)aMovie;
@end
