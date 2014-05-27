//
//  MakeBlendFilter.m
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-18.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "MakeBlendFilter.h"

NSString *const xxx = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 
 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 
 void main()
 {
     lowp vec4 base = texture2D(inputImageTexture, textureCoordinate);
     lowp vec4 overlayer = texture2D(inputImageTexture2, textureCoordinate2);
     
     gl_FragColor = overlayer * base + overlayer * (1.0 - base.a) + base * (1.0 - overlayer.a);
 }
 );

@implementation MakeBlendFilter


- (id)init {
    if (self = [super initWithVertexShaderFromString:kGPUImageTwoInputTextureVertexShaderString fragmentShaderFromString:xxx]) {
        
    }
    return self;
}

- (void)setOverlayer_pic:(GPUImagePicture *)overlayer_pic {
    if (_overlayer_pic != overlayer_pic) {
        [_overlayer_pic removeAllTargets];
        _overlayer_pic = overlayer_pic;
        [overlayer_pic addTarget:self atTextureLocation:1];
        [overlayer_pic processImage];
    }
}

@end
