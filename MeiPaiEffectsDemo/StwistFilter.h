//
//  StwistFilter.h
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-19.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"

@interface StwistFilter : GPUImageTwoInputFilter {
    GLint twistFactorUniform;
}

@property (nonatomic ,assign) CGFloat current_frame_time;

@end
