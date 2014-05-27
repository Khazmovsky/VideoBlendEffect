//
//  YXVideoPlayer.m
//  YXVideo
//
//  Created by Jeakin on 13-10-28.
//  Copyright (c) 2013年 Jeakin. All rights reserved.
//

#import "YXVideoPlayer.h"
#import "GPUImage.h"
#import "MyFilter.h"


CGSize getVideoSize (NSURL *videoURL) {
    NSLog(@"%@",videoURL);
    AVAsset *asset              = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    NSLog(@"%@",asset);
    NSLog(@"%@",[asset tracksWithMediaType:AVMediaTypeVideo]);
    AVAssetTrack *videoTrack    = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    CGSize naturalSize          = [videoTrack naturalSize];
    CGSize normalSize           = CGSizeApplyAffineTransform(naturalSize, videoTrack.preferredTransform);
    normalSize.width = fabs(normalSize.width);
    normalSize.height = fabs(normalSize.height);
    return normalSize;
}

CGSize getPlayerSize (NSURL *videoURL) {
    CGSize currentSize  = CGSizeMake(320, 320);
    CGSize videoSize    = getVideoSize(videoURL);
    NSLog(@"====>%@",NSStringFromCGSize(videoSize));
    CGFloat ratio = currentSize.width/videoSize.width > currentSize.height/videoSize.height ?
    currentSize.width/videoSize.width : currentSize.height/videoSize.height;
    
    CGSize ratioVideo;
    ratioVideo.height = videoSize.height * ratio;
    ratioVideo.width  = videoSize.width * ratio;
    return ratioVideo;
}


@interface YXVideoPlayer () <GPUImageInput> {
    GLuint inputTextureForDisplay;
    GLuint displayRenderbuffer, displayFramebuffer;
    
    GLProgram *displayProgram;
    GLint displayPositionAttribute, displayTextureCoordinateAttribute;
    GLint displayInputTextureUniform;
    
    CGSize inputImageSize;
    GLfloat imageVertices[8];
    GLfloat backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha;
    GPUImageRotationMode inputRotation;
    __unsafe_unretained id<GPUImageTextureDelegate> textureDelegate;
}

@property (nonatomic,strong) UIScrollView *videoView;

@property (nonatomic,strong) id timeObserver;
@property (nonatomic,strong) NSURL      *URL;
@property (nonatomic,readwrite,strong) AVPlayer *player;
@property (nonatomic,readwrite,strong) AVPlayerLayer *playerLayer;

#pragma mark - filter 相关
@property (nonatomic ,assign) CGSize showSize;
@property (nonatomic ,strong) CIContext *CIContext;
@property (nonatomic ,strong) AVPlayerItemVideoOutput *videoOutput;
@property (nonatomic ,strong) CADisplayLink *displayLink;
@property (nonatomic ,strong) AVPlayerItem *playerItem;
@property (nonatomic ,strong) AVAsset *asset;

#pragma mark - gpu 相关
@property(assign, nonatomic) CGSize sizeInPixels;
@property(nonatomic ,assign) GPUImageFillModeType fillMode;
@property (nonatomic ,assign) BOOL enabled;
@property (nonatomic ,strong) MyFilter *tail_filter;

@end
 
@implementation YXVideoPlayer {
    YXActionMovie *ddd;
}

- (void)dealloc {
    NSLog(@"dealloc %@",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}


- (id)initWithFrame:(CGRect)frame withURL:(NSURL *)URL
{
    self = [super initWithFrame:frame];
    if (self) {
		playerMode = 1;
        self.videoView = [[UIScrollView alloc] initWithFrame:self.bounds];
        self.videoView.delegate = self;
        CGRect frame = CGRectZero;
        frame.size = getPlayerSize(URL);
        self.videoView.contentSize = frame.size;
        [self addSubview:self.videoView];
        
        self.player = [AVPlayer playerWithURL:URL];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [_playerLayer setFrame:frame];
        [self.videoView.layer insertSublayer:_playerLayer atIndex:0];
        
		currentRate = 1.0;
        
		if(!self.syncContainer)
		{
			_syncContainer = [[UIView alloc] initWithFrame:CGRectZero];
			[self addSubview:_syncContainer];
		}
		[self addObserverForPlayer];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
		playerMode = 2;
		self.clipsToBounds = YES;
		self.player = [[AVPlayer alloc] init];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [_playerLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
		[self.layer insertSublayer:_playerLayer atIndex:0];
		currentRate = 1.0;
		
		if(!self.syncContainer)
		{
			_syncContainer = [[UIView alloc] initWithFrame:CGRectZero];
			[self addSubview:_syncContainer];
		}
		[self addObserverForPlayer];
    }
    return self;
}

-(void)resetFrame:(CGRect)frame
{
	self.frame = frame;
	[_playerLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
}

- (void)play {

	//    [self.player play];
    if (ddd) {
        [ddd startProcessing];
    }
	[self.player setRate:currentRate];
}

- (void)pause {

    [self.player pause];
}

-(void)playOrPause
{
 
    
	if([self isPlaying])
	{
		[self pause];
	}
	else
	{
		[self play];
	}
}

- (void)stop {
    

    
    
    [self.player pause];
    [self.player seekToTime:kCMTimeZero];
}

- (BOOL)isPlaying {
    if (self.player.rate) {
        return YES;
    }
    return NO;
}

-(void)seekTo:(float)second
{
	[_player pause];
	[_player seekToTime:CMTimeMakeWithSeconds(second, NSEC_PER_SEC)];
    [_player play];
    
}

-(void)playFrom:(CMTime)begin to:(CMTime)to
{
	[self removeTimeObserver];
	[_player pause];
	[_player seekToTime:begin];
	_playFrom = begin;
	_playTo = to;
	//	isPlayingRange = YES;
	[self addTimeObserver];
}

-(void)preparePlayFromWithRate:(float)rate begin:(float)begin to:(float)to
{
	[self removeTimeObserver];
	_playFrom = CMTimeMakeWithSeconds(begin, NSEC_PER_SEC);
	_playTo = CMTimeMakeWithSeconds(to, NSEC_PER_SEC);
	[_player seekToTime:_playFrom];
	currentRate = rate;
	[_player pause];
	//	isPlayingRange = YES;
	[self addTimeObserver];
}

-(void)normalPlay
{
	[self removeTimeObserver];
	//	isPlayingRange = NO;
	[_player pause];
	[_player seekToTime:CMTimeMakeWithSeconds(0, NSEC_PER_SEC)];
	[self addTimeObserver];
}

- (CGPoint)getVideoOffset {
	return self.videoView.contentOffset;
}

- (void) playFinished {
    [self.player pause];
    [_player seekToTime:kCMTimeZero];
}

- (void)setPlayItem:(AVPlayerItem *)playerItem {
    [_player  replaceCurrentItemWithPlayerItem:playerItem];
	
    ddd = [[YXActionMovie alloc] initWithPlayerItem:playerItem];
    [ddd addTarget:_tail_filter];
    [_tail_filter addTarget:self];
    _tail_filter.source_video_duration = CMTimeGetSeconds(playerItem.asset.duration);
    [_playerLayer removeFromSuperlayer];
    _playerLayer = nil;
    
    
	if(playerMode==3){
		_playerItem = playerItem;
		_asset = playerItem.asset;
		[self resetOutput];
	}
}

- (void)setPlayItem:(AVPlayerItem *)playerItem andSynchronizedLayer:(AVSynchronizedLayer*)syncLayer
{
	[self setPlayItem:playerItem];
	for (CALayer*layer in _syncContainer.layer.sublayers) {
		[layer removeFromSuperlayer];
	}
	if (syncLayer) {
		[_syncContainer.layer addSublayer:syncLayer];
		[self updateSyncLayerPositionAndTransform:CGSizeMake(480, 480)];
	}
}

- (void)updateSyncLayerPositionAndTransform:(CGSize)presentationSize
{
	CGSize viewSize = self.bounds.size;
	CGFloat scale = fmin(viewSize.width/presentationSize.width, viewSize.height/presentationSize.height);
	CGRect videoRect = AVMakeRectWithAspectRatioInsideRect(presentationSize, self.bounds);
	_syncContainer.center = CGPointMake( CGRectGetMidX(videoRect), CGRectGetMidY(videoRect));
	_syncContainer.transform = CGAffineTransformMakeScale(scale, scale);
}

- (BOOL)isCanScroll {
    if (CGSizeEqualToSize(self.frame.size, self.videoView.contentSize)) {
        return NO;
    }
    return YES;
}

#pragma mark - observer
- (void)removeObserverFromPlayer
{
	if (_timeObserver)
	{
		[_player removeTimeObserver:_timeObserver];
		_timeObserver = nil;
	}
	[_player removeObserver:self forKeyPath:@"rate"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)addObserverForPlayer
{
	[_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:nil];
	
	//	__unsafe_unretained typeof(self) weakSelf = self;
	//	[[NSNotificationCenter defaultCenter]
	//	 addObserverForName:AVPlayerItemDidPlayToEndTimeNotification
	//	 object:nil
	//	 queue:[NSOperationQueue mainQueue]
	//	 usingBlock:^(NSNotification *note) {
	//		 if(weakSelf.player)
	//		 {
	//			 if(!isPlayingRange)
	//			 {
	//				 [weakSelf.player pause];
	//				 [weakSelf.player seekToTime:kCMTimeZero];
	//			 }
	//			 else [weakSelf.player seekToTime:weakSelf.playFrom];
	//			 if(weakSelf.playerDelegate && [weakSelf.playerDelegate respondsToSelector:@selector(stopPlaying)])
	//			 {
	//				 [weakSelf.playerDelegate stopPlaying];
	//			 }
	//		 }
	//	 }];
}

-(void)addTimeObserver
{
	if(!_timeObserver)
	{
		__unsafe_unretained typeof(self) weakSelf = self;
		_timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.01, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
			if(/*weakSelf->isPlayingRange && */CMTimeCompare(time, weakSelf.playTo)>=0)
			{
				[weakSelf.player pause];
				[weakSelf.player seekToTime:weakSelf.playFrom];
				if(weakSelf.playerDelegate)
				{
                    if ([weakSelf.playerDelegate respondsToSelector:@selector(stopPlaying)]) {
                        [weakSelf.playerDelegate stopPlaying];
                    }
				}
			}
			if(weakSelf.playerDelegate)
			{
				[weakSelf.playerDelegate CurrentPlayingTime:time];
			}
		}];
	}
}

-(void)removeTimeObserver
{
	if (_timeObserver)
	{
		[_player removeTimeObserver:_timeObserver];
		_timeObserver = nil;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (_player && object == _player && [keyPath isEqualToString:@"rate"]) {
		float newRate = [[change objectForKey:@"new"] floatValue];
		
		[self.displayLink setPaused:!(newRate>0)];
		
		if(_playerDelegate && [_playerDelegate respondsToSelector:@selector(CurrentPlayingRate:)])
		{
			[_playerDelegate CurrentPlayingRate:newRate];
		}
    }
}

#pragma mark - filter相关
- (id)initFilterPlayerWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
		playerMode = 3;
		self.clipsToBounds = YES;
        
		if(!self.syncContainer)
		{
			_syncContainer = [[UIView alloc] initWithFrame:CGRectZero];
			[self addSubview:_syncContainer];
		}
        CGFloat factor = [UIScreen mainScreen].scale;
        self.showSize = CGSizeMake(frame.size.width * factor, frame.size.height * factor);
        [self setupContext];
        [self setupAVPlayer];
		
		currentRate = 1.0;
		[self addObserverForPlayer];
		
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(AVPlayerItemDidPlayToEndTime) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    }
    return self;
}


- (void)setupContext
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if(self.context && [EAGLContext setCurrentContext:self.context])
    {
        NSLog(@"openGL ES 2 init done.");
    }
    
    self.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    self.CIContext = [CIContext contextWithEAGLContext:self.context];
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
}

- (void)setupAVPlayer
{
    self.player = [[AVPlayer alloc] init];
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
    
    outputQueue = dispatch_queue_create("videoOutputQueue", DISPATCH_QUEUE_SERIAL);
    [((AVPlayerItemVideoOutput *)self.videoOutput) setDelegate:self queue:outputQueue];
    
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.displayLink setPaused:YES];
}

- (void)resetAVPlayer
{
    [self setPlayItem:[AVPlayerItem playerItemWithAsset:_asset]];
    [self resetOutput];
    [self removeTimeObserver];
    [self.displayLink setPaused:YES];
}

- (void)resetOutput
{
    [self.playerItem removeOutput:self.videoOutput];
    NSDictionary *pixBuffAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange)};
    self.videoOutput = [[AVPlayerItemVideoOutput alloc] initWithPixelBufferAttributes:pixBuffAttributes];
    [self.playerItem addOutput:self.videoOutput];
    [self.videoOutput requestNotificationOfMediaDataChangeWithAdvanceInterval:0.03];
    [((AVPlayerItemVideoOutput *)self.videoOutput) setDelegate:self queue:outputQueue];
}

#pragma mark - display link callback

- (void)displayLinkCallback:(CADisplayLink *)sender
{
    @autoreleasepool
    {
        CMTime outputItemTime = kCMTimeInvalid;
        
        // 计算下次同步时间
        CFTimeInterval nextVSync = ([sender timestamp] + [sender duration]);
        
        outputItemTime = [self.videoOutput itemTimeForHostTime:nextVSync];
        
        CVPixelBufferRef pixelBuffer = NULL;
        
        if ([self.videoOutput hasNewPixelBufferForItemTime:outputItemTime])
        {
            CMTime time;
            
            pixelBuffer = [self.videoOutput copyPixelBufferForItemTime:outputItemTime itemTimeForDisplay:&time];
            
            if (!pixelBuffer) {
                return;
            }
            
            CIImage *ci = [CIImage imageWithCVPixelBuffer:pixelBuffer];
            
            /*
             注意释放
             */
			CFRelease(pixelBuffer);
            
			//            if(_currentFilter)
			//            {
			//                if([_currentFilter.name isEqualToString:@"CISourceOverCompositing"])
			//                {
			//                    [_currentFilter setValue:ci forKey:kCIInputBackgroundImageKey];
			//                }
			//                else
			//                    [_currentFilter setValue:ci forKey:kCIInputImageKey];
			//
			//                ci = _currentFilter.outputImage;
			//            }
//			if(_currentProcesser)ci =  [self.currentProcesser processImage:ci];
			
            CGRect rect = ci.extent;
            if(CGRectIsInfinite(rect))
            {
                rect = CGRectMake(0, 0, 480, 480);
            }
            
            
            [_CIContext drawImage:ci inRect:CGRectMake(0, 0, _showSize.width, _showSize.height) fromRect:rect];
            [self.context presentRenderbuffer:GL_RENDERBUFFER];
        }
    }
}

#pragma mark - playerItem delegate

- (void)outputMediaDataWillChange:(AVPlayerItemOutput *)sender
{
    [self.displayLink setPaused:NO];
}

#pragma mark - notification

- (void)AVPlayerItemDidPlayToEndTime
{
	//    [self.displayLink setPaused:YES];
	//    [self removeTimeObserver];
	//    [self playFinished];
	//    [self resetAVPlayer];
	[self resetOutput];
}


#pragma mark - gpuimage input delegate

+ (Class)layerClass
{
	return [CAEAGLLayer class];
}

- (id)initForVideoBlendingWithFrame:(CGRect)frame
{
    if (!(self = [super initWithFrame:frame]))
    {
		return nil;
    }
    
    playerMode = 2;
    self.clipsToBounds = YES;
    self.player = [[AVPlayer alloc] init];
//    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
//    [_playerLayer setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//    [self.layer insertSublayer:_playerLayer atIndex:0];
    currentRate = 1.0;
    
    if(!self.syncContainer)
    {
        _syncContainer = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:_syncContainer];
    }
    [self addObserverForPlayer];
    
    
    _tail_filter = [MyFilter new];
    
    
    [self commonInit];
    
    
    
    return self;
}

-(id)initWithCoder:(NSCoder *)coder
{
	if (!(self = [super initWithCoder:coder]))
    {
        return nil;
	}
    
    [self commonInit];
    
	return self;
}

- (void)commonInit
{
    if ([self respondsToSelector:@selector(setContentScaleFactor:)])
    {
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    
    inputRotation = kGPUImageNoRotation;
    self.opaque = YES;
    self.hidden = NO;
    CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
    eaglLayer.opaque = YES;
    eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
    
    self.enabled = YES;
    
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext useImageProcessingContext];
        
        displayProgram = [[GPUImageContext sharedImageProcessingContext] programForVertexShaderString:kGPUImageVertexShaderString fragmentShaderString:kGPUImagePassthroughFragmentShaderString];
        if (!displayProgram.initialized)
        {
            [displayProgram addAttribute:@"position"];
            [displayProgram addAttribute:@"inputTextureCoordinate"];
            
            if (![displayProgram link])
            {
                NSString *progLog = [displayProgram programLog];
                NSLog(@"Program link log: %@", progLog);
                NSString *fragLog = [displayProgram fragmentShaderLog];
                NSLog(@"Fragment shader compile log: %@", fragLog);
                NSString *vertLog = [displayProgram vertexShaderLog];
                NSLog(@"Vertex shader compile log: %@", vertLog);
                displayProgram = nil;
                NSAssert(NO, @"Filter shader link failed");
            }
        }
        
        displayPositionAttribute = [displayProgram attributeIndex:@"position"];
        displayTextureCoordinateAttribute = [displayProgram attributeIndex:@"inputTextureCoordinate"];
        displayInputTextureUniform = [displayProgram uniformIndex:@"inputImageTexture"];
        
        [GPUImageContext setActiveShaderProgram:displayProgram];
        glEnableVertexAttribArray(displayPositionAttribute);
        glEnableVertexAttribArray(displayTextureCoordinateAttribute);
        
        [self setBackgroundColorRed:0.0 green:0.0 blue:0.0 alpha:1.0];
        _fillMode = kGPUImageFillModePreserveAspectRatio;
        [self createDisplayFramebuffer];
    });
    
    [self addObserver:self forKeyPath:@"frame" options:0 context:NULL];
}

#pragma mark -
#pragma mark Managing the display FBOs

- (void)createDisplayFramebuffer
{
    [GPUImageContext useImageProcessingContext];
    
	glGenFramebuffers(1, &displayFramebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
	
	glGenRenderbuffers(1, &displayRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
	
	[[[GPUImageContext sharedImageProcessingContext] context] renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
	
    GLint backingWidth, backingHeight;
    
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);
    
    if ( (backingWidth == 0) || (backingHeight == 0) )
    {
        [self destroyDisplayFramebuffer];
        return;
    }
    
    _sizeInPixels.width = (CGFloat)backingWidth;
    _sizeInPixels.height = (CGFloat)backingHeight;
    
    //	NSLog(@"Backing width: %d, height: %d", backingWidth, backingHeight);
    
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, displayRenderbuffer);
	
    GLuint framebufferCreationStatus = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    NSAssert(framebufferCreationStatus == GL_FRAMEBUFFER_COMPLETE, @"Failure with display framebuffer generation for display of size: %f, %f", self.bounds.size.width, self.bounds.size.height);
}

- (void)destroyDisplayFramebuffer
{
    [GPUImageContext useImageProcessingContext];
    
    if (displayFramebuffer)
	{
		glDeleteFramebuffers(1, &displayFramebuffer);
		displayFramebuffer = 0;
	}
	
	if (displayRenderbuffer)
	{
		glDeleteRenderbuffers(1, &displayRenderbuffer);
		displayRenderbuffer = 0;
	}
}

- (void)setDisplayFramebuffer
{
    if (!displayFramebuffer)
    {
        [self createDisplayFramebuffer];
    }
    
    glBindFramebuffer(GL_FRAMEBUFFER, displayFramebuffer);
    
    glViewport(0, 0, (GLint)_sizeInPixels.width, (GLint)_sizeInPixels.height);
}

- (void)presentFramebuffer
{
    glBindRenderbuffer(GL_RENDERBUFFER, displayRenderbuffer);
    [[GPUImageContext sharedImageProcessingContext] presentBufferForDisplay];
}

#pragma mark -
#pragma mark Handling fill mode

- (void)recalculateViewGeometry
{
    runSynchronouslyOnVideoProcessingQueue(^{
        CGFloat heightScaling, widthScaling;
        
        CGSize currentViewSize = self.bounds.size;
        
        //    CGFloat imageAspectRatio = inputImageSize.width / inputImageSize.height;
        //    CGFloat viewAspectRatio = currentViewSize.width / currentViewSize.height;
        
        CGRect insetRect = AVMakeRectWithAspectRatioInsideRect(inputImageSize, self.bounds);
        
        switch(_fillMode)
        {
            case kGPUImageFillModeStretch:
            {
                widthScaling = 1.0;
                heightScaling = 1.0;
            }; break;
            case kGPUImageFillModePreserveAspectRatio:
            {
                widthScaling = insetRect.size.width / currentViewSize.width;
                heightScaling = insetRect.size.height / currentViewSize.height;
            }; break;
            case kGPUImageFillModePreserveAspectRatioAndFill:
            {
                //            CGFloat widthHolder = insetRect.size.width / currentViewSize.width;
                widthScaling = currentViewSize.height / insetRect.size.height;
                heightScaling = currentViewSize.width / insetRect.size.width;
            }; break;
        }
        
        imageVertices[0] = -widthScaling;
        imageVertices[1] = -heightScaling;
        imageVertices[2] = widthScaling;
        imageVertices[3] = -heightScaling;
        imageVertices[4] = -widthScaling;
        imageVertices[5] = heightScaling;
        imageVertices[6] = widthScaling;
        imageVertices[7] = heightScaling;
    });
    
    //    static const GLfloat imageVertices[] = {
    //        -1.0f, -1.0f,
    //        1.0f, -1.0f,
    //        -1.0f,  1.0f,
    //        1.0f,  1.0f,
    //    };
}

- (void)setBackgroundColorRed:(GLfloat)redComponent green:(GLfloat)greenComponent blue:(GLfloat)blueComponent alpha:(GLfloat)alphaComponent
{
    backgroundColorRed = redComponent;
    backgroundColorGreen = greenComponent;
    backgroundColorBlue = blueComponent;
    backgroundColorAlpha = alphaComponent;
}

+ (const GLfloat *)textureCoordinatesForRotation:(GPUImageRotationMode)rotationMode
{
    //    static const GLfloat noRotationTextureCoordinates[] = {
    //        0.0f, 0.0f,
    //        1.0f, 0.0f,
    //        0.0f, 1.0f,
    //        1.0f, 1.0f,
    //    };
    
    static const GLfloat noRotationTextureCoordinates[] = {
        0.0f, 1.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        1.0f, 0.0f,
    };
    
    static const GLfloat rotateRightTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateLeftTextureCoordinates[] = {
        0.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat verticalFlipTextureCoordinates[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    
    static const GLfloat horizontalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        0.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotateRightVerticalFlipTextureCoordinates[] = {
        1.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 0.0f,
        0.0f, 1.0f,
    };
    
    static const GLfloat rotateRightHorizontalFlipTextureCoordinates[] = {
        1.0f, 1.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        0.0f, 0.0f,
    };
    
    static const GLfloat rotate180TextureCoordinates[] = {
        1.0f, 0.0f,
        0.0f, 0.0f,
        1.0f, 1.0f,
        0.0f, 1.0f,
    };
    
    switch(rotationMode)
    {
        case kGPUImageNoRotation: return noRotationTextureCoordinates;
        case kGPUImageRotateLeft: return rotateLeftTextureCoordinates;
        case kGPUImageRotateRight: return rotateRightTextureCoordinates;
        case kGPUImageFlipVertical: return verticalFlipTextureCoordinates;
        case kGPUImageFlipHorizonal: return horizontalFlipTextureCoordinates;
        case kGPUImageRotateRightFlipVertical: return rotateRightVerticalFlipTextureCoordinates;
        case kGPUImageRotateRightFlipHorizontal: return rotateRightHorizontalFlipTextureCoordinates;
        case kGPUImageRotate180: return rotate180TextureCoordinates;
    }
}

#pragma mark -
#pragma mark GPUInput protocol

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex
{
    runSynchronouslyOnVideoProcessingQueue(^{
        [GPUImageContext setActiveShaderProgram:displayProgram];
        [self setDisplayFramebuffer];
        
        glClearColor(backgroundColorRed, backgroundColorGreen, backgroundColorBlue, backgroundColorAlpha);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glActiveTexture(GL_TEXTURE4);
        glBindTexture(GL_TEXTURE_2D, inputTextureForDisplay);
        glUniform1i(displayInputTextureUniform, 4);
        
        glVertexAttribPointer(displayPositionAttribute, 2, GL_FLOAT, 0, 0, imageVertices);
        glVertexAttribPointer(displayTextureCoordinateAttribute, 2, GL_FLOAT, 0, 0, [[self class] textureCoordinatesForRotation:inputRotation]);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        
        [self presentFramebuffer];
    });
}

- (NSInteger)nextAvailableTextureIndex {
    return 0;
}

- (void)setInputTexture:(GLuint)newInputTexture atIndex:(NSInteger)textureIndex {
    inputTextureForDisplay = newInputTexture;
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex {
    inputRotation = newInputRotation;
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex {
    runSynchronouslyOnVideoProcessingQueue(^{
        CGSize rotatedSize = newSize;
        
        if (GPUImageRotationSwapsWidthAndHeight(inputRotation))
        {
            rotatedSize.width = newSize.height;
            rotatedSize.height = newSize.width;
        }
        
        if (!CGSizeEqualToSize(inputImageSize, rotatedSize))
        {
            inputImageSize = rotatedSize;
            [self recalculateViewGeometry];
        }
    });
}

- (CGSize)maximumOutputSize;
{
    if ([self respondsToSelector:@selector(setContentScaleFactor:)])
    {
        CGSize pointSize = self.bounds.size;
        return CGSizeMake(self.contentScaleFactor * pointSize.width, self.contentScaleFactor * pointSize.height);
    }
    else
    {
        return self.bounds.size;
    }
}

- (void)endProcessing
{
}

- (BOOL)shouldIgnoreUpdatesToThisTarget;
{
    return NO;
}

- (void)setTextureDelegate:(id<GPUImageTextureDelegate>)newTextureDelegate atIndex:(NSInteger)textureIndex;
{
    textureDelegate = newTextureDelegate;
}

- (void)conserveMemoryForNextFrame;
{
    
}

- (BOOL)wantsMonochromeInput;
{
    return NO;
}

- (void)setCurrentlyReceivingMonochromeInput:(BOOL)newValue;
{
    
}

#pragma mark -
#pragma mark Accessors

- (CGSize)sizeInPixels;
{
    if (CGSizeEqualToSize(_sizeInPixels, CGSizeZero))
    {
        return [self maximumOutputSize];
    }
    else
    {
        return _sizeInPixels;
    }
}

- (void)setFillMode:(GPUImageFillModeType)newValue;
{
    _fillMode = newValue;
    [self recalculateViewGeometry];
}



@end
