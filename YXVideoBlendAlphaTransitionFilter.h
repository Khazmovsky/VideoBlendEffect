//
//  YXVideoAlphaTransitionFilter.h
//  多着色器程序演示
//
//  Created by Khazmovsky on 14-5-21.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "YXVideoBlendBaseFilter.h"

@interface YXVideoAlphaTransitionFilter : YXVideoBlendBaseFilter {
    GLint mixIntensityUniform;
}

@property (nonatomic ,assign) CGFloat intensity;

@end
	