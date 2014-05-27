//
//  MyGroupFilter.m
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-17.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "MyGroupFilter.h"
#import "GPUImageGaussianBlurFilter.h"

@interface MyGroupFilter ()

@property (nonatomic ,strong) GPUImageGaussianBlurFilter *gaussianBlurFilter;

@end


@implementation MyGroupFilter

- (id)init {
    if (self = [super init]) {
        _blendFilter = [MyFilter new];
        _gaussianBlurFilter = [GPUImageGaussianBlurFilter new];
        _filterGroup = [GPUImageFilterGroup new];
        [_gaussianBlurFilter addTarget:_blendFilter];
        
        [_filterGroup addFilter:_blendFilter];
        [_filterGroup addFilter:_gaussianBlurFilter];
        
        _filterGroup.initialFilters = @[_gaussianBlurFilter];
        _filterGroup.terminalFilter = _blendFilter;
    }
    return self;
}

@end
