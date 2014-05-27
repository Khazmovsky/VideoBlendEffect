//
//  StwistFilter.m
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-19.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "StwistFilter.h"
#import "GPUImagePicture.h"

static NSString *const kStwistFragmentShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float facotr;
 
 void main()
 {
     highp float offset;
     highp vec2 textureCoordinateToUse;
     if(textureCoordinate.y >= 0.0 && textureCoordinate.y <= 0.6) {
         offset = -0.5 * pow(textureCoordinate.y, 2.0) + 0.3 * textureCoordinate.y - 0.05;
     } else if (textureCoordinate.y > 0.6 && textureCoordinate.y <= 0.9) {
         offset = 0.6 * (textureCoordinate.y - 0.3) * (textureCoordinate.y - 0.9) + 0.004;
     } else {
         offset = -0.9 * pow((textureCoordinate.y - 0.9), 2.0) + 0.004;
     }
     
     offset = facotr * offset;
     
     textureCoordinateToUse = vec2(textureCoordinate.x + offset, textureCoordinate.y);
     gl_FragColor = texture2D(inputImageTexture, textureCoordinateToUse);
 }
 );


typedef GPUVector3 TimeRangeControl;

static TimeRangeControl time_control[] = {
    (TimeRangeControl){2.0,3.0,-0.5},
    (TimeRangeControl){3.0,4.0,1},
    (TimeRangeControl){4.0,4.1,1},
    (TimeRangeControl){5.0,5.5,1},
    (TimeRangeControl){7.0,7.05,0.5},
    (TimeRangeControl){7.05,9.0,1},
    (TimeRangeControl){9.1,9.2,1},
};

@interface StwistFilter ()

@property (nonatomic ,assign) CGFloat facotr;

@property (nonatomic ,strong) GPUImagePicture *over_layer_pic1;
@property (nonatomic ,strong) GPUImagePicture *over_layer_pic2;
@property (nonatomic ,strong) GPUImagePicture *over_layer_pic3;
@property (nonatomic ,strong) GPUImagePicture *over_layer_pic4;

@end

@implementation StwistFilter

- (id)init {
    if (self = [super initWithFragmentShaderFromString:kStwistFragmentShaderString ]) {
        runSynchronouslyOnVideoProcessingQueue(^{
            twistFactorUniform = [filterProgram uniformIndex:@"facotr"];
            [self disableSecondFrameCheck];
        });
    }
    return self;
}

- (void)initOverlayerPictures {
    _over_layer_pic1 = [[GPUImagePicture alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"strips" withExtension:@"jpg"]];
    _over_layer_pic2 = [[GPUImagePicture alloc] initWithURL:[[NSBundle mainBundle] URLForResource:@"strips3" withExtension:@"png"]];
}

- (void)setCurrent_frame_time:(CGFloat)current_frame_time {
    if (_current_frame_time != current_frame_time) {
        _current_frame_time = current_frame_time;
        if (_current_frame_time >= time_control[0].one && _current_frame_time <= time_control[0].two) {
            [self setFacotr:time_control[0].three];
        } else if (_current_frame_time > time_control[1].one && _current_frame_time <= time_control[1].two) {
            [self setFacotr:time_control[1].three];
        } else if (_current_frame_time >= time_control[2].one && _current_frame_time <= time_control[2].two){
            [self setFacotr:time_control[2].three];
        } else if (_current_frame_time > time_control[3].one && _current_frame_time <= time_control[3].two){
            [self setFacotr:time_control[3].three];
        } else if (_current_frame_time > time_control[4].one && _current_frame_time <= time_control[4].two){
            [self setFacotr:time_control[4].three];
        } else if (_current_frame_time > time_control[5].one && _current_frame_time <= time_control[5].two){
            [self setFacotr:time_control[5].three];
        } else if (_current_frame_time > time_control[6].one && _current_frame_time <= time_control[6].two){
            [self setFacotr:time_control[6].three];
        } else {
            [self setFacotr:0];
        }
    }
}

- (void)setFacotr:(CGFloat)facotr {
    if (_facotr != facotr) {
        _facotr = facotr;
        [self setFloat:_facotr forUniform:twistFactorUniform program:filterProgram];
    }
}

@end
