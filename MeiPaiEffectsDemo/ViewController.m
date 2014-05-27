//
//  ViewController.m
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-16.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "ViewController.h"
#import "EffectShaderString.h"
#import "MultiProgramsFilter.h"
#import "MyFilter.h"
#import "YXActionMovie.h"
#import "YXVideoPlayer.h"
#import "MyGroupFilter.h"
#import "MyGaussianBlurFilter.h"
#import "OutroGen.h"
#import "glPrograms.h"
#import "MakeBlendFilter.h"
#import "StwistFilter.h"
#define MP4(_name) [[NSBundle mainBundle] URLForResource:(@#_name) withExtension:(@"mp4")]
#define MOV(_name) [[NSBundle mainBundle] URLForResource:(@#_name) withExtension:(@"mov")]
#define JPG(_name) [[NSBundle mainBundle] URLForResource:(@#_name) withExtension:(@"jpg")]
#define PNG(_name) [[NSBundle mainBundle] URLForResource:(@#_name) withExtension:(@"png")]
#define EXPORT_PATH  [NSTemporaryDirectory() stringByAppendingPathComponent:@"export_1.mp4"]
#define EXPORT_URL   [NSURL fileURLWithPath:EXPORT_PATH]
#define WEAK_OBJ(_obj,_wobj) __unsafe_unretained typeof(_obj) (_wobj) = (_obj)

@interface ViewController () <YXActionMovieDelegate>

@property (nonatomic ,strong) GPUImageVideoCamera *camera;
@property (nonatomic ,strong) GPUImageView *imageView;
@property (nonatomic ,strong) GPUImageGaussianBlurFilter *blur_base_filter;
@property (nonatomic ,strong) GPUImageGaussianBlurFilter *gaussian_blur_filter;
@property (nonatomic ,strong) GPUImageTwoInputFilter *blend_filter;
@property (nonatomic ,strong) GPUImagePicture *stripe;
@property (nonatomic ,strong) MultiProgramsFilter *group_filter;
@property (nonatomic ,strong) YXActionMovie *video;
@property (nonatomic ,strong) YXActionMovie *video2;
@property (nonatomic ,strong) MyFilter *my;
@property (nonatomic ,strong) GPUImageMovieWriter *writer;
@property (nonatomic ,strong) YXVideoPlayer *player;
@property (nonatomic ,strong) GPUImageFilterGroup *group;
@property (nonatomic ,strong) MyGroupFilter *myGroup;
@property (nonatomic ,strong) MyGaussianBlurFilter *myGuassianBlur;
@property (nonatomic ,strong) OutroGen *gen;
@property (nonatomic ,strong) glPrograms *gl;
@property (nonatomic ,strong) GPUImageStretchDistortionFilter *stretch;
@property (nonatomic ,strong) StwistFilter *twistFilter;


@property (nonatomic ,strong) MakeBlendFilter *pic_over_layer;

@end

@implementation ViewController {
//    AVPlayer *player;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 320 * 1.333)];
    [self.view addSubview:_imageView];
//    _player = [[YXVideoPlayer alloc] initForVideoBlendingWithFrame:CGRectMake(0, 20, 320, 320)];
//    [self.view addSubview:_player];
    _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    _video = [[YXActionMovie alloc] initWithURL:MP4(line)];
    _video.playAtActualSpeed = YES;
    _video.shouldRepeat = YES;
    
    _video.yx_delegate = self;
    

//video twist
    
    
    _twistFilter = [StwistFilter new];
    
    [_video addTarget:_twistFilter];
    
    [_twistFilter addTarget:_imageView];
    
    [_video startProcessing];
    
    
//    [_camera startCameraCapture];
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    [_video startProcessing];
//    [self exportWithLastOutput:_pic_over_layer];
//    _gl = [[glPrograms alloc] initWithVertexShaderFromString:kGPUImageVertexShaderString fragmentShaderFromString:kGPUImagePassthroughFragmentShaderString];
//
//    [_video addTarget:_gl];
//
//    [_gl addTarget:_imageView];
//
//    
//    _video.playAtActualSpeed = YES;
//
//    

//    _gen = [OutroGen new];
//    _gen.source_video = _video;
//    _video.yx_delegate = _gen;
////    _gen.renderTarget = _imageView;
//    
//    [_gen exportAsynchronouslyToDestinationURL:EXPORT_URL completionHandler:^{
//        NSLog(@"done");
//    }];
    
    
//    _blur_base_filter = [GPUImageGaussianBlurFilter new];
//    [_video addTarget:_blur_base_filter];
//    
//    [_blur_base_filter addTarget:_imageView];
    
    
//    [_video startProcessing];
    
//
//    _video2 = [[YXActionMovie alloc] initWithURL:MOV(bg_1)];
//    _video2.playAtActualSpeed = YES;
//    _video2.shouldRepeat = YES;
//    
//    
//    _myGroup = [MyGroupFilter new];
//    _video.yx_delegate = _myGroup.blendFilter;
//    _myGroup.blendFilter.source_video_duration = CMTimeGetSeconds(_video.asset.duration);
//    
//    [_video addTarget:_myGroup.filterGroup];
//    
//    [_myGroup.filterGroup addTarget:_imageView];
//    
//    [_video startProcessing];
//    
    
    
//    _group = [GPUImageFilterGroup new];
//    
//
//    _blend_filter = [GPUImageAddBlendFilter new];
//    
//    [_blend_filter disableSecondFrameCheck];
//    
//    [_group addFilter:_blend_filter];
//    
//    _gaussian_blur_filter = [GPUImageGaussianBlurFilter new];
//    
//    [_group addFilter:_gaussian_blur_filter];
//    
//
//    [_gaussian_blur_filter addTarget:_blend_filter];
//    
//    [_group setInitialFilters:@[_gaussian_blur_filter]];
//    [_group setTerminalFilter:_blend_filter];
//    
//    
//    _gaussian_blur_filter.blurPasses = 10;
//    
//
//    
//    
//    [_camera addTarget:_group];
////    [_video addTarget:_blend_filter];
//    
////    [_video startProcessing];
//    
//    
//    [_group addTarget:_imageView];
//    
//    
//    [_camera startCameraCapture];
//    
//    [_video addTarget:_blend_filter];
//    [_video startProcessing];
    
//    _my = [[MyFilter alloc] initWithFirstStageVertexShaderFromString:kGaussianBlurVertexShaderString firstStageFragmentShaderFromString:kGaussianBlurFragmentShaderString secondStageVertexShaderFromString:kGaussianBlurVertexShaderString secondStageFragmentShaderFromString:kGaussianBlurFragmentShaderString];
////    _my = [[GPUImageFilter alloc] initWithFragmentShaderFromString:kGPUImagePassthroughFragmentShaderString];
//    
//    [_camera addTarget:_my];
//    
//    [_my addTarget:_imageView];
//    
//    
//    [_camera startCameraCapture];
    
//    _writer = [[GPUImageMovieWriter alloc] initWithMovieURL:EXPORT_URL size:CGSizeMake(480, 480)];
//    _writer.shouldPassthroughAudio = YES;
//    unlink(EXPORT_PATH.UTF8String);
//    WEAK_OBJ(_writer, wwriter);
//    [_writer setCompletionBlock:^{
//       [wwriter finishRecordingWithCompletionHandler:^{
//           NSLog(@"done");
//       }];
//    }];
//    
//    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:VIDEO(export)];
//    _video = [[YXActionMovie alloc] initWithPlayerItem:item];
////    player = [AVPlayer playerWithPlayerItem:item];
//    [_player setPlayItem:item];
//    _video.audioEncodingTarget = _writer;
//    [_video enableSynchronizedEncodingUsingMovieWriter:_writer];
//    _my = [MyFilter new];
//    _my.source_video_duration = CMTimeGetSeconds(_video.asset.duration);
//    [_video addTarget:_my];
//    [_my addTarget:_player];
//    
//    [_my addTarget:_writer];
//    
//    _video.playAtActualSpeed = YES;
//    
//    [_writer startRecording];
////    [_video startProcessing];
//    
//    [_player play];
    
}

- (void)time_control_pic {
    _pic_over_layer = [MakeBlendFilter new];
    [_pic_over_layer disableFirstFrameCheck];
    
    _pic_over_layer.control_times = @[@1,@3,@5];
    
    
    [_video addTarget:_pic_over_layer];
    
    
    
    [_pic_over_layer addTarget:_imageView];
}

- (void)actionMovie:(YXActionMovie *)aMovie currentFrameTime:(CGFloat)currentFrameTime {
    _pic_over_layer.current_video_frame_time = currentFrameTime;
    _twistFilter.current_frame_time = currentFrameTime;
}

- (void)exportWithLastOutput:(GPUImageOutput *)output {
    _writer = [[GPUImageMovieWriter alloc] initWithMovieURL:EXPORT_URL size:CGSizeMake(480, 480)];
    _writer.shouldPassthroughAudio = YES;
    [_video enableSynchronizedEncodingUsingMovieWriter:_writer];
    _video.audioEncodingTarget = _writer;
    unlink(EXPORT_PATH.UTF8String);
    WEAK_OBJ(_writer, wwriter);
    [output addTarget:_writer];
    
    [_writer setCompletionBlock:^{
        [wwriter finishRecordingWithCompletionHandler:^{
            NSLog(@"done");
        }];
    }];
    [_writer startRecording];
    [_video startProcessing];
}


- (IBAction)ex:(id)sender {
//    [_player seekTo:0];
//    [_gl use2];
    _stripe = [[GPUImagePicture alloc] initWithURL:PNG(strips3)];
    _pic_over_layer.overlayer_pic = _stripe;
}

- (IBAction)ex2:(id)sender {
    [_gl use1];
}




























- (void)setup {
    _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 320)];
    [self.view addSubview:_imageView];
    
    _blur_base_filter = [[GPUImageGaussianBlurFilter alloc] initWithFirstStageVertexShaderFromString:kGaussianBlurVertexShaderString firstStageFragmentShaderFromString:kGaussianBlurFragmentShaderString secondStageVertexShaderFromString:kGaussianBlurVertexShaderString secondStageFragmentShaderFromString:kGaussianBlurFragmentShaderString];
    _blur_base_filter.blurPasses = 2;
    
    [_camera addTarget:_blur_base_filter];
    [_blur_base_filter addTarget:_imageView];
    
    [_camera startCameraCapture];
    
}

- (void)setup2 {
    _camera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    _imageView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 20, 320, 320)];
    [self.view addSubview:_imageView];
    
    _blend_filter = [GPUImageMultiplyBlendFilter new];
    
    _stripe = [[GPUImagePicture alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"strips3" withExtension:@"png"]];
    
    [_camera addTarget:_blend_filter];
    [_stripe addTarget:_blend_filter];
    [_stripe processImage];
    [_blend_filter addTarget:_imageView];
    
    [_camera startCameraCapture];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sli:(UISlider *)sender {
    NSLog(@"%.2f",sender.value);
    CGFloat v = sender.value;
//    _blur_base_filter.blurPasses = v;
    _stretch.center = CGPointMake(v, 1);
}

@end
