//
//  glPrograms.m
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-18.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//



#import "glPrograms.h"

NSString *const pixellate = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 
 uniform highp float fractionalWidthOfPixel;
 uniform highp float aspectRatio;
 
 void main()
 {
     highp vec2 sampleDivisor = vec2(fractionalWidthOfPixel, fractionalWidthOfPixel / aspectRatio);
     
     highp vec2 samplePos = textureCoordinate - mod(textureCoordinate, sampleDivisor) + 0.5 * sampleDivisor;
     gl_FragColor = texture2D(inputImageTexture, samplePos );
 }
 );
@interface glPrograms ()

@property (nonatomic ,strong) GLProgram *currentProgram;

@end

@implementation glPrograms

@synthesize preventRendering = _preventRendering;

- (void)setup2 {
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        filterProgram2 = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:pixellate];
        
        if (!filterProgram2.initialized)
        {
            [self initializeAttributes2];
            
            if (![filterProgram2 link])
            {
                NSString *progLog = [filterProgram2 programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [filterProgram2 fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [filterProgram2 vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                filterProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        filterPositionAttribute = [filterProgram2 attributeIndex:@"position"];
        filterTextureCoordinateAttribute = [filterProgram2 attributeIndex:@"inputTextureCoordinate"];
        filterInputTextureUniform = [filterProgram2 uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
        fractionalWidthOfAPixelUniform = [filterProgram2 uniformIndex:@"fractionalWidthOfPixel"];
        aspectRatioUniform = [filterProgram2 uniformIndex:@"aspectRatio"];
        [self setFloat:1.0 / 100.0 forUniform:fractionalWidthOfAPixelUniform program:filterProgram2];
        [self setFloat:1.0 forUniform:aspectRatioUniform program:filterProgram2];

        [GPUImageContext setActiveShaderProgram:filterProgram];
        
        glEnableVertexAttribArray(filterPositionAttribute);
        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
    });

}

- (void)initializeAttributes2;
{
    [filterProgram2 addAttribute:@"position"];
	[filterProgram2 addAttribute:@"inputTextureCoordinate"];
    
    // Override this, calling back to this super method, in order to add new attributes to your vertex shader
}


- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
{
    if (!(self = [super initWithVertexShaderFromString:vertexShaderString fragmentShaderFromString:fragmentShaderString]))
    {
		return nil;
    }
    
//    uniformStateRestorationBlocks = [NSMutableDictionary dictionaryWithCapacity:10];
//    preparedToCaptureImage = NO;
//    _preventRendering = NO;
//    currentlyReceivingMonochromeInput = NO;
//    inputRotation = kGPUImageNoRotation;
//    backgroundColorRed = 0.0;
//    backgroundColorGreen = 0.0;
//    backgroundColorBlue = 0.0;
//    backgroundColorAlpha = 0.0;
//    
//    runSynchronouslyOnVideoProcessingQueue(^{
//        [GPUImageContext useImageProcessingContext];
//        
//        filterProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:vertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
//        
//        if (!filterProgram.initialized)
//        {
//            [self initializeAttributes];
//            
//            if (![filterProgram link])
//            {
//                NSString *progLog = [filterProgram programLog];
//                NSLog(@"Program link log: %@", progLog);
//                NSString *fragLog = [filterProgram fragmentShaderLog];
//                NSLog(@"Fragment shader compile log: %@", fragLog);
//                NSString *vertLog = [filterProgram vertexShaderLog];
//                NSLog(@"Vertex shader compile log: %@", vertLog);
//                filterProgram = nil;
//                NSAssert(NO, @"Filter shader link failed");
//            }
//        }
//        
//        filterPositionAttribute = [filterProgram attributeIndex:@"position"];
//        filterTextureCoordinateAttribute = [filterProgram attributeIndex:@"inputTextureCoordinate"];
//        filterInputTextureUniform = [filterProgram uniformIndex:@"inputImageTexture"]; // This does assume a name of "inputImageTexture" for the fragment shader
//        
//        [GPUImageContext setActiveShaderProgram:filterProgram];
//        
//        glEnableVertexAttribArray(filterPositionAttribute);
//        glEnableVertexAttribArray(filterTextureCoordinateAttribute);
//    });
    
    
    [self setup2];
    
    _currentProgram = filterProgram;
    
    return self;
}

- (void)use2 {
//    [GPUImageContext setActiveShaderProgram:filterProgram2];
    _currentProgram = filterProgram2;
}

- (void)use1 {
    _currentProgram = filterProgram;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
{
    if (self.preventRendering)
    {
        return;
    }
    
    [GPUImageContext setActiveShaderProgram:_currentProgram];
    [self setFilterFBO];
    [self setUniformsForProgramAtIndex:0];
    
    glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT);
    
	glActiveTexture(GL_TEXTURE2);
	glBindTexture(GL_TEXTURE_2D, sourceTexture);
	
	glUniform1i(filterInputTextureUniform, 2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, 0, vertices);
	glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, textureCoordinates);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end
