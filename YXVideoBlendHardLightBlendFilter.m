//
//  YXVideoBlendScreenBlendFilter.m
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-20.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "YXVideoBlendHardLightBlendFilter.h"
#import "YXActionMovie.h"

NSString *const kYXVideoBlendHardLightBlendFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     //     mediump vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
     //     mediump vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     //     mediump vec4 whiteColor = vec4(1.0);
     //     gl_FragColor = whiteColor - ((whiteColor - textureColor2) * (whiteColor - textureColor));
     mediump vec4 base = texture2D(inputImageTexture, textureCoordinate);
     mediump vec4 overlay = texture2D(inputImageTexture2, textureCoordinate2);
     
     highp float ra;
     if (2.0 * overlay.r < overlay.a) {
         ra = 2.0 * overlay.r * base.r + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
     } else {
         ra = overlay.a * base.a - 2.0 * (base.a - base.r) * (overlay.a - overlay.r) + overlay.r * (1.0 - base.a) + base.r * (1.0 - overlay.a);
     }
     
     highp float ga;
     if (2.0 * overlay.g < overlay.a) {
         ga = 2.0 * overlay.g * base.g + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
     } else {
         ga = overlay.a * base.a - 2.0 * (base.a - base.g) * (overlay.a - overlay.g) + overlay.g * (1.0 - base.a) + base.g * (1.0 - overlay.a);
     }
     
     highp float ba;
     if (2.0 * overlay.b < overlay.a) {
         ba = 2.0 * overlay.b * base.b + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
     } else {
         ba = overlay.a * base.a - 2.0 * (base.a - base.b) * (overlay.a - overlay.b) + overlay.b * (1.0 - base.a) + base.b * (1.0 - overlay.a);
     }
     
     gl_FragColor = vec4(ra, ga, ba, 1.0);
 }
 );

@interface YXVideoBlendHardLightBlendFilter ()

@property (nonatomic ,strong) AVPlayer *player;
@property (nonatomic ,strong) AVPlayerItem *playerItem;

@end

@implementation YXVideoBlendHardLightBlendFilter {
    AVPlayer *player;
    AVPlayerItem *playerItem;
}

@synthesize playerItem = playerItem,player = player;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)init {
    if (self = [super initWithFragmentShaderFromString:kYXVideoBlendHardLightBlendFragmentShaderString]) {
        //        [[NSNotificationCenter defaultCenter] addObserverForName:AVPlayerItemDidPlayToEndTimeNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        //
        //            if (note.object == _overlayerVideo.playerItem) {
        //                if (_overlayerVideo) {
        //                    [_overlayerVideo endProcessing];
        //                }
        //            }
        //
        //        }];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayedToEnded:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        self.passThroughTexture = YES;
    }
    return self;
}


- (void)playerItemDidPlayedToEnded:(NSNotification *)note {
    if (note.object == _overlayerVideo.playerItem) {
        [_overlayerVideo endProcessing];
    }
}

- (void)setOverlayerVideo:(YXActionMovie *)overlayerVideo {
    if (_overlayerVideo != overlayerVideo) {
        _overlayerVideo = overlayerVideo;
        if (_overlayerVideo) {
            player = [AVPlayer playerWithPlayerItem:_overlayerVideo.playerItem];
            [_overlayerVideo addTarget:self atTextureLocation:1];
            playerItem = _overlayerVideo.playerItem;
            [_overlayerVideo startProcessing];
        }
    }
}

- (void)setCurrentVideoFrameTime:(GLfloat)currentVideoFrameTime {
    if (_currentVideoFrameTime != currentVideoFrameTime) {
        _currentVideoFrameTime = currentVideoFrameTime;
        if (_currentVideoFrameTime >= _startTime && _currentVideoFrameTime < 100.0) {
            [self enableEffect];
        } else if (_currentVideoFrameTime >= _sourceVideoDuration - 2.0) {
            [self disableEffect];
        } else {
            [self disableEffect];
        }
    }
}

- (void)changeOutputTexutreBackAtFrameTime:(CMTime)frameTime {
    for (id<GPUImageInput> currentTarget in targets)
    {
        if (currentTarget != self.targetToIgnoreForUpdates)
        {
            NSInteger indexOfObject = [targets indexOfObject:currentTarget];
            NSInteger textureIndex = [[targetTextureIndices objectAtIndex:indexOfObject] integerValue];
            
            [self setInputTextureForTarget:currentTarget atIndex:textureIndex];
            
            //            [currentTarget setInputSize:[self outputFrameSize] atIndex:textureIndex];
            [currentTarget newFrameReadyAtTime:frameTime atIndex:textureIndex];
        }
    }
}



- (void)enableEffect {
    if (_isBlending) {
        return;
    }
    _isBlending = YES;
    self.passThroughTexture = NO;
    //    [self switchToVertexShaderString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderString:kYXVideoBlendScreenBlendFragmentShaderString];
    //    [_overlayerVideo startProcessing];
    [player play];
}


- (void)disableEffect {
    if (!_isBlending) {
        return;
    }
    _isBlending = NO;
    self.passThroughTexture = YES;
    //    [self switchToVertexShaderString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
    //    [_overlayerVideo endProcessing];
}

@end
