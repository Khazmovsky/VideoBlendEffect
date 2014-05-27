//
//  MyGroupFilter.h
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-17.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyFilter.h"
#import "GPUImage.h"
@interface MyGroupFilter : NSObject

@property (nonatomic ,strong) MyFilter *blendFilter;
@property (nonatomic ,strong) GPUImageFilterGroup *filterGroup;

@end
