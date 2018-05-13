//
//  LYVideoPresenter.m
//  LYPlayerDemo
//
//  Created by liyang on 2018/5/8.
//  Copyright © 2018年 com.liyang.player. All rights reserved.
//

#import "LYVideoPresenter.h"
#import "LYVideoPlayerControl.h"
#import "LYVideoPlayer.h"

@interface LYVideoPresenter () <LYVideoPlayerControlDelegate, LYVideoPlayerDelegate>

@property (nonatomic, strong) UIView *backgroundView;

///用于视频显示的View
@property (nonatomic, strong) UIView *videoShowView;

///用于控制视频播放界面的View
@property (nonatomic, strong) LYVideoPlayerControl *videoPlayControl;

@property (nonatomic, strong) LYVideoPlayer *videoPlayer;

///是否为全屏
@property (nonatomic, assign) BOOL isFullScreen;

@property (nonatomic, assign) CGRect originFrame;

@end

@implementation LYVideoPresenter

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self addObserver];
    }
    return self;
}
- (void)dealloc
{
    [self removeObserver];
}

//根据url播放视频（初始化播放）
- (void)playWithUrl:(NSString *)url addInView:(UIView *)view{
    
    self.backgroundView = view;
    self.originFrame = view.frame;
    
    ///播放器
    [self.videoPlayer playWithUrl:url showView:self.videoShowView];
    
    ///控制界面
    [self videoPlayControl];
    _videoPlayControl.halfScreenPanGestureEnabled = YES;
}

//监听通知
- (void)addObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}
//移除通知
- (void)removeObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//横竖屏切换
- (void)changeRotate:(NSNotification*)noti {
    
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
        || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        //竖屏
        _isFullScreen = NO;
    } else {
        //横屏
        _isFullScreen = YES;
    }
    
    [self autoSetDeviceRotate:[[UIDevice currentDevice] orientation]];
}

//自动横竖屏切换
- (void)autoSetDeviceRotate:(UIDeviceOrientation)orientation{
    [UIView animateWithDuration:0.25 animations:^{
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
        [self setSubViewFrames];
    }];
}

//横竖屏切换
- (void)setDeviceRotate{
    UIDeviceOrientation orientation;
    if (_isFullScreen) {
        orientation = UIDeviceOrientationLandscapeLeft;
    }else{
        orientation = UIDeviceOrientationPortrait;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
        [self setSubViewFrames];
    }];
}

- (void)setSubViewFrames{
    
    CGRect frame;
    if (_isFullScreen) {
        frame = [UIScreen mainScreen].bounds;
    }else{
        frame = _originFrame;
    }
    
    self.backgroundView.frame = frame;
    
    [_videoPlayer fullScreenChanged:self.backgroundView.bounds];
    [_videoPlayControl fullScreenChanged:_isFullScreen frame:self.backgroundView.bounds];
    
}

#pragma mark - 懒加载
- (LYVideoPlayer *)videoPlayer{
    if (!_videoPlayer) {
        _videoPlayer = [[LYVideoPlayer alloc] init];
        _videoPlayer.delegate = self;
    }
    return _videoPlayer;
}
- (UIView *)videoShowView{
    if (!_videoShowView) {
        _videoShowView = [[UIView alloc] initWithFrame:self.backgroundView.bounds];
        [self.backgroundView addSubview:_videoShowView];
    }
    return _videoShowView;
}

- (LYVideoPlayerControl *)videoPlayControl{
    if (!_videoPlayControl) {
        _videoPlayControl = [[LYVideoPlayerControl alloc] initWithFrame:self.backgroundView.bounds];
        _videoPlayControl.delegate = self;
        [self.backgroundView addSubview:_videoPlayControl];
    }
    return _videoPlayControl;
}

#pragma mark - Public Method
/**
 播放
 */
- (void)playVideo{
    [_videoPlayer playVideo];
}

/**
 暂停
 */
- (void)pauseVideo{
    [_videoPlayer pauseVideo];
}

/**
 停止播放/清空播放器
 */
- (void)stopVideo{
    [_videoPlayer stopVideo];
}

/**
 @param toTime 从指定的时间开始播放（秒）
 */
- (void)seekToTimePlay:(float)toTime{
    [_videoPlayer seekToTimePlay:toTime];
}

#pragma mark - LYVideoPlayerControlDelegate
/**
 返回按钮被点击
 */
- (void)videoControlDidBackBtnClick{
    
    //全屏状态下，点击返回按钮，是置为竖屏
    if (_isFullScreen) {
        
        _isFullScreen = !_isFullScreen;
        [self setDeviceRotate];
    
    }else{//竖屏状态下，点击返回按钮
        
        //首先要释放播放器
        [_videoPlayer stopVideo];
        
        if (_delegate && [_delegate respondsToSelector:@selector(videoPresenterDidBackBtnClick)]) {
            [_delegate videoPresenterDidBackBtnClick];
        }
    }
}

/**
 全屏按钮被点击
 */
- (void)videoControlDidFullScreenBtnClick{
    
    _isFullScreen = !_isFullScreen;
    
    [self setDeviceRotate];
}

/**
 @param isPause YES:暂停  NO:播放
 */
- (void)videoControl:(LYVideoPlayerControl*)videoControl didPlayBtnIsPause:(BOOL)isPause{
    if (isPause) {
        [_videoPlayer pauseVideo];
    }else{
        [_videoPlayer playVideo];
    }
}

/**
 @param time 播放指定的时间（秒）
 */
- (void)videoControl:(LYVideoPlayerControl*)videoControl didPlayToTime:(CGFloat)time{
    [_videoPlayer seekToTimePlay:time];
}

#pragma mark - LYVideoPlayerDelegate
/**
 开始缓冲
 */
- (void)videoPlayerDidStartBuffer{
    [_videoPlayControl videoPlayerDidLoading];
}
/**
 缓冲完成
 */
- (void)videoPlayerDidEndBuffer{
    [_videoPlayControl videoPlayerDidBeginPlay];
}

/**
 播放器已经开始播放了
 */
- (void)videoPlayerDidPlay{
    [_videoPlayControl playerControlPlay];
}
/**
 播放器已经暂停了播放
 */
- (void)videoPlayerDidPause{
    [_videoPlayControl playerControlPause];
}

/**
 @param totalTime 视频总长度（秒）
 */
- (void)videoPlayer:(LYVideoPlayer *)videoPlayer totalTime:(NSInteger)totalTime{
    _videoPlayControl.totalTime = totalTime;
}

/**
 @param currentTime 当前播放进度（秒）
 */
- (void)videoPlayer:(LYVideoPlayer *)videoPlayer currentTime:(NSInteger)currentTime{
    _videoPlayControl.currentTime = currentTime;
    _videoPlayControl.playValue = (CGFloat)_videoPlayControl.currentTime/(CGFloat)_videoPlayControl.totalTime;
}

/**
 @param bufferProgress 当前缓冲进度比例（0~1）
 */
- (void)videoPlayer:(LYVideoPlayer *)videoPlayer bufferProgress:(CGFloat)bufferProgress{
    _videoPlayControl.progress = bufferProgress;
}

@end
