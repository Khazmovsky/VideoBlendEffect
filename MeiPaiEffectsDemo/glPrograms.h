//
//  glPrograms.h
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-18.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "GPUImageFilter.h"

@interface glPrograms : GPUImageFilter {
    GLProgram *filterProgram2;
    GLint fractionalWidthOfAPixelUniform,aspectRatioUniform;
}

- (void)setup2;
- (void)use2;
- (void)use1;

@end
