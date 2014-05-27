//
//  YXActionMovie.h
//  GPUImageVideoBlendDemo
//
//  Created by yixia on 14-4-28.
//  Copyright (c) 2014年 yixia. All rights reserved.
//

#import "GPUImageMovie.h"


@class YXActionMovie;

@protocol YXActionMovieDelegate <NSObject>

@optional

- (void)didCompletePlayingMovie:(YXActionMovie *)aMovie;
- (void)actionMovie:(YXActionMovie *)aMovie currentFrameTime:(CGFloat)currentFrameTime;
- (void)currentMovieFrame:(CVPixelBufferRef)pixelBuffer currentSampleTime:(CMTime)currentSampleTime;
- (void)acitonMovieReplayed:(YXActionMovie *)aMovie;
@end


@interface YXActionMovie : GPUImageMovie

@property (nonatomic ,assign) id<YXActionMovieDelegate> yx_delegate;
@property (nonatomic ,assign) BOOL shouldFinishingRecordingWhenProcessingDone;
@property (nonatomic ,assign) BOOL isProcessing;

- (id)initWithAsset:(AVURLAsset *)asset;
- (id)initWithURL:(NSURL *)url;
- (id)initWithPlayerItem:(AVPlayerItem *)playerItem;
- (void)enableSynchronizedEncodingWithWriter:(GPUImageMovieWriter *)writer;


@end
