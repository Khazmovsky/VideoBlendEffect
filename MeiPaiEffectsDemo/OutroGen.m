//
//  OutroGen.m
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-17.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "OutroGen.h"
#import "MyFilter.h"
#import "MyGaussianBlurFilter.h"
#import "GPUImageFilterGroup.h"
#import "GPUImageMovieWriter.h"
#define WEAK_OBJ(_obj,_wobj) __unsafe_unretained typeof(_obj) (_wobj) = (_obj)
@interface OutroGen ()

@property (nonatomic ,assign) CGFloat source_video_duration;
@property (nonatomic ,strong) GPUImageFilterGroup *filterGroup;

@end

@implementation OutroGen {
    GPUImageMovieWriter *writer;
}

- (id)init {
    if (self = [super init]) {
        _blend_filter = [MyFilter new];
        _gaussian_blur_filter = [MyGaussianBlurFilter new];
        _filterGroup = [GPUImageFilterGroup new];
        [_filterGroup addFilter:_blend_filter];
        [_filterGroup addFilter:_gaussian_blur_filter];
        [_gaussian_blur_filter addTarget:_blend_filter];
        _filterGroup.initialFilters = @[_gaussian_blur_filter];
        _filterGroup.terminalFilter = _blend_filter;
    }
    return self;
}


- (void)setSource_video:(YXActionMovie *)source_video {
    _source_video = source_video;
    _source_video_duration = CMTimeGetSeconds(source_video.asset.duration);
    _blend_filter.source_video_duration = _source_video_duration;
    _gaussian_blur_filter.source_video_duration = _source_video_duration;
    [_source_video addTarget:_filterGroup];
}

- (void)exportAsynchronouslyToDestinationURL:(NSURL *)to completionHandler:(void (^)())block {
    writer = [[GPUImageMovieWriter alloc] initWithMovieURL:to size:CGSizeMake(480, 480)];
    unlink(to.path.UTF8String);
    WEAK_OBJ(writer, wwriter);
    [writer setCompletionBlock:^{
       [wwriter finishRecordingWithCompletionHandler:^{
           block();
       }];
    }];
    
    
    writer.shouldPassthroughAudio = YES;
    _source_video.audioEncodingTarget = writer;
    [_source_video enableSynchronizedEncodingUsingMovieWriter:writer];
    [_filterGroup addTarget:writer];
    [writer startRecording];
    [_source_video startProcessing];
    
}

#pragma mark - yxaction movie delegate

- (void)acitonMovieReplayed:(YXActionMovie *)aMovie {
    [_blend_filter acitonMovieReplayed:aMovie];
    [_gaussian_blur_filter acitonMovieReplayed:aMovie];
}

- (void)actionMovie:(YXActionMovie *)aMovie currentFrameTime:(CGFloat)currentFrameTime {
    _blend_filter.current_video_frame_time = currentFrameTime;
    _gaussian_blur_filter.current_video_frame_time = currentFrameTime;
}

- (void)setRenderTarget:(id<GPUImageInput>)renderTarget {
    _renderTarget = renderTarget;
    [_filterGroup addTarget:_renderTarget];
}

@end
