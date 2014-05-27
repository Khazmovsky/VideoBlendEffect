//
//  MakeBlendFilter.h
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-18.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "GPUImageTwoInputFilter.h"
#import "GPUImage.h"

@interface MakeBlendFilter : GPUImageTwoInputFilter

@property (nonatomic ,strong) GPUImagePicture *overlayer_pic;

@end
