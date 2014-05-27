//
//  OutroGen.h
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-17.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YXActionMovie.h"
@class MyGaussianBlurFilter;
@class MyFilter;

@interface OutroGen : NSObject <YXActionMovieDelegate>

@property (nonatomic ,strong) MyFilter *blend_filter;
@property (nonatomic ,strong) MyGaussianBlurFilter *gaussian_blur_filter;
@property (nonatomic ,strong) YXActionMovie *source_video;
@property (nonatomic ,strong) id<GPUImageInput> renderTarget;

- (void)exportAsynchronouslyToDestinationURL:(NSURL *)to completionHandler:(void (^)())block;

@end
