//
//  YXVideoBlendHardLightBlendFilter.h
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-27.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "YXVideoBlendBaseFilter.h"

@class YXActionMovie;

@interface YXVideoBlendHardLightBlendFilter : YXVideoBlendBaseFilter

@property (nonatomic ,strong) YXActionMovie *overlayerVideo;

@end
