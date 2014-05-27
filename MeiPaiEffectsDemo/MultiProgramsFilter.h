//
//  MultiProgramsFilter.h
//  MeiPaiEffectsDemo
//
//  Created by Khazmovsky on 14-5-17.
//  Copyright (c) 2014年 Khazmovsky. All rights reserved.
//

#import "GPUImageFilter.h"

#define STRINGIZE(x) #x
#define STRINGIZE2(x) STRINGIZE(x)
#define SHADER_STRING(text) @ STRINGIZE2(text)

#define GPUImageHashIdentifier #
#define GPUImageWrappedLabel(x) x
#define GPUImageEscapedHashIdentifier(a) GPUImageWrappedLabel(GPUImageHashIdentifier)a

extern NSString *const kGPUImageVertexShaderString;
extern NSString *const kGPUImagePassthroughFragmentShaderString;

//struct GPUVector4 {
//    GLfloat one;
//    GLfloat two;
//    GLfloat three;
//    GLfloat four;
//};
//typedef struct GPUVector4 GPUVector4;
//
//struct GPUVector3 {
//    GLfloat one;
//    GLfloat two;
//    GLfloat three;
//};
//typedef struct GPUVector3 GPUVector3;
//
//struct GPUMatrix4x4 {
//    GPUVector4 one;
//    GPUVector4 two;
//    GPUVector4 three;
//    GPUVector4 four;
//};
//typedef struct GPUMatrix4x4 GPUMatrix4x4;
//
//struct GPUMatrix3x3 {
//    GPUVector3 one;
//    GPUVector3 two;
//    GPUVector3 three;
//};
//typedef struct GPUMatrix3x3 GPUMatrix3x3;

@interface MultiProgramsFilter : GPUImageOutput <GPUImageInput> {
    GLuint filterSourceTexture;
    
    GLuint filterFramebuffer;

    GLProgram *filterProgram,*filterProgram2;
    
    GLint filterPositionAttribute,filterPositionAttribute2, filterTextureCoordinateAttribute,filterTextureCoordinateAttribute2;
    GLint filterInputTextureUniform,filterInputTextureUniform2;
    GLfloat backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha;
    
    BOOL preparedToCaptureImage;
    
    // Texture caches are an iOS-specific capability
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CVOpenGLESTextureCacheRef filterTextureCache;
    CVPixelBufferRef renderTarget;
    CVOpenGLESTextureRef renderTexture;
#else
#endif
    
    CGSize currentFilterSize;
    GPUImageRotationMode inputRotation;
    
    BOOL currentlyReceivingMonochromeInput;
    
    NSMutableDictionary *uniformStateRestorationBlocks;
    
    GLint fractionalWidthOfAPixelUniform, aspectRatioUniform;
    
    
#pragma mark - viggnet
    
    GLint vignetteCenterUniform, vignetteColorUniform, vignetteStartUniform, vignetteEndUniform;

}

@property(readonly) CVPixelBufferRef renderTarget;
@property(readwrite, nonatomic) BOOL preventRendering;
@property(readwrite, nonatomic) BOOL currentlyReceivingMonochromeInput;

@property (nonatomic ,assign) CGFloat fractionalWidthOfAPixel;

//to do

- (void)setupProgram2VertexShaderString:(NSString *)vertexShaderString fragmentShaderString:(NSString *)fragmentShaderString;

- (void)use2 :(NSString *)v :(NSString *)f ;

/// @name Initialization and teardown

/**
 Initialize with vertex and fragment shaders
 
 You make take advantage of the SHADER_STRING macro to write your shaders in-line.
 @param vertexShaderString Source code of the vertex shader to use
 @param fragmentShaderString Source code of the fragment shader to use
 */
- (id)initWithVertexShaderFromString:(NSString *)vertexShaderString fragmentShaderFromString:(NSString *)fragmentShaderString;
/**
 Initialize with a fragment shader
 
 You may take advantage of the SHADER_STRING macro to write your shader in-line.
 @param fragmentShaderString Source code of fragment shader to use
 */
- (id)initWithFragmentShaderFromString:(NSString *)fragmentShaderString;
/**
 Initialize with a fragment shader
 @param fragmentShaderFilename Filename of fragment shader to load
 */
- (id)initWithFragmentShaderFromFile:(NSString *)fragmentShaderFilename;
- (void)initializeAttributes;
- (void)setupFilterForSize:(CGSize)filterFrameSize;
- (CGSize)rotatedSize:(CGSize)sizeToRotate forIndex:(NSInteger)textureIndex;
- (CGPoint)rotatedPoint:(CGPoint)pointToRotate forRotation:(GPUImageRotationMode)rotation;

- (void)recreateFilterFBO;

/// @name Managing the display FBOs
/** Size of the frame buffer object
 */
- (CGSize)sizeOfFBO;
- (void)createFilterFBOofSize:(CGSize)currentFBOSize;

/** Destroy the current filter frame buffer object
 */
- (void)destroyFilterFBO;
- (void)setFilterFBO;
- (void)setOutputFBO;
- (void)releaseInputTexturesIfNeeded;

/// @name Rendering
+ (const GLfloat *)textureCoordinatesForRotation:(GPUImageRotationMode)rotationMode;
- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates sourceTexture:(GLuint)sourceTexture;
- (void)informTargetsAboutNewFrameAtTime:(CMTime)frameTime;
- (CGSize)outputFrameSize;

/// @name Input parameters
- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent;
- (void)setInteger:(GLint)newInteger forUniformName:(NSString *)uniformName;
- (void)setFloat:(GLfloat)newFloat forUniformName:(NSString *)uniformName;
- (void)setSize:(CGSize)newSize forUniformName:(NSString *)uniformName;
- (void)setPoint:(CGPoint)newPoint forUniformName:(NSString *)uniformName;
- (void)setFloatVec3:(GPUVector3)newVec3 forUniformName:(NSString *)uniformName;
- (void)setFloatVec4:(GPUVector4)newVec4 forUniform:(NSString *)uniformName;
- (void)setFloatArray:(GLfloat *)array length:(GLsizei)count forUniform:(NSString*)uniformName;

- (void)setMatrix3f:(GPUMatrix3x3)matrix forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
- (void)setMatrix4f:(GPUMatrix4x4)matrix forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
- (void)setFloat:(GLfloat)floatValue forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
- (void)setPoint:(CGPoint)pointValue forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
- (void)setSize:(CGSize)sizeValue forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
- (void)setVec3:(GPUVector3)vectorValue forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
- (void)setVec4:(GPUVector4)vectorValue forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
- (void)setFloatArray:(GLfloat *)arrayValue length:(GLsizei)arrayLength forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;
- (void)setInteger:(GLint)intValue forUniform:(GLint)uniform program:(GLProgram *)shaderProgram;

- (void)setAndExecuteUniformStateCallbackAtIndex:(GLint)uniform forProgram:(GLProgram *)shaderProgram toBlock:(dispatch_block_t)uniformStateBlock;
- (void)setUniformsForProgramAtIndex:(NSUInteger)programIndex;

- (void)switchToVertexShader:(NSString *)newVertexShader fragmentShader:(NSString *)newFragmentShader;


@end
