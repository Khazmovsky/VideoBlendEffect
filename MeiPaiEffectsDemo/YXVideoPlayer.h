//
//  YXVideoPlayer.h
//  YXVideo
//
//  Created by Jeakin on 13-10-28.
//  Copyright (c) 2013年 Jeakin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <GLKit/GLKit.h>
//#import "YXVideoFileFilterProcesser.h"
//#import "YXVideoOutroGenerator.h"
//#import "YXVideoKit.h"
CGSize getVideoSize (NSURL *videoURL);
#import "GPUImage.h"
@protocol YXVideoPlayerDelegate <NSObject>
-(void)CurrentPlayingTime:(CMTime) time;
-(void)CurrentPlayingRate:(CGFloat) rate;
@optional
-(void)stopPlaying;
@end

@interface YXVideoPlayer : GLKView <UIScrollViewDelegate,AVPlayerItemOutputPullDelegate,GPUImageInput>
{
	id _timeObserver;
	//	BOOL isPlayingRange;
	CGFloat currentRate;
	
	GLuint _renderBuffer;
    dispatch_queue_t outputQueue;
	
	NSInteger playerMode;
	
}
@property (nonatomic,readonly,strong) AVPlayer *player;
@property(nonatomic, assign) id<YXVideoPlayerDelegate> playerDelegate;
@property (nonatomic, assign) CMTime playFrom;
@property (nonatomic, assign) CMTime playTo;
@property (nonatomic, retain) UIView *syncContainer;
//@property (nonatomic ,strong) CIFilter *currentFilter;
//@property (nonatomic ,strong) YXVideoFileFilterProcesser *currentProcesser;
//@property (nonatomic ,strong) YXVideoOutroGenerator *outroGenerator;

- (id)initWithFrame:(CGRect)frame withURL:(NSURL *)URL;
- (id)initWithFrame:(CGRect)frame;
- (id)initFilterPlayerWithFrame:(CGRect)frame;
//合并MP4预览使用
- (id)initForVideoBlendingWithFrame:(CGRect)frame;


- (void)play;
- (void)pause;
- (void)stop;
- (BOOL)isPlaying;
-(void)playOrPause;
-(void)seekTo:(float)second;
-(void)normalPlay;
-(void)playFrom:(CMTime)begin to:(CMTime)to;
-(void)preparePlayFromWithRate:(float)rate begin:(float)begin to:(float)to;

- (void)setPlayItem:(AVPlayerItem *)playerItem;
- (void)setPlayItem:(AVPlayerItem *)playerItem andSynchronizedLayer:(AVSynchronizedLayer*)syncLayer;

- (CGPoint)getVideoOffset;

- (void)playFinished;
- (BOOL)isCanScroll;

- (void)removeObserverFromPlayer;
-(void)addObserverForPlayer;
-(void)removeTimeObserver;

-(void)resetFrame:(CGRect)frame;
@end
