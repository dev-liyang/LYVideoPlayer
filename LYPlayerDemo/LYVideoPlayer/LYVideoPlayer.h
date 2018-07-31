//
//  LYVideoPlayer.h
//  LYPlayerDemo
//
//  Created by liyang on 16/11/4.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class LYVideoPlayer;

@protocol LYVideoPlayerDelegate <NSObject>

@optional
/**
 开始缓冲
 */
- (void)videoPlayerDidStartBuffer;
/**
 缓冲完成
 */
- (void)videoPlayerDidEndBuffer;

/**
 播放器已经开始播放了
 */
- (void)videoPlayerDidPlay;
/**
 播放器已经暂停了播放
 */
- (void)videoPlayerDidPause;
/**
 播放器播放结束
 */
- (void)videoPlayerDidPlayToEnd;

// ------------------------- 回调一些视频信息 ---------------------------
/**
 @param totalTime 视频总长度（秒）
 */
- (void)videoPlayer:(LYVideoPlayer *)videoPlayer totalTime:(NSInteger)totalTime;

/**
 @param currentTime 当前播放进度（秒）
 */
- (void)videoPlayer:(LYVideoPlayer *)videoPlayer currentTime:(NSInteger)currentTime;

/**
 @param bufferProgress 当前缓冲进度比例（0~1）
 */
- (void)videoPlayer:(LYVideoPlayer *)videoPlayer bufferProgress:(CGFloat)bufferProgress;

@end

@interface LYVideoPlayer : NSObject

@property (nonatomic, weak)   id <LYVideoPlayerDelegate> delegate;

/// 静音 default is NO
@property (nonatomic, assign) BOOL mute;

/// 当APP进入后台时是否暂停播放，default is YES
@property (nonatomic, assign) BOOL stopWhenAppDidEnterBackground;

/// 当视频播放结束时是否重新播放 default is NO
@property (nonatomic, assign) BOOL replayWhenVideoPlayEnd;

/// 可给定video尺寸大小,若尺寸超过view大小时作截断处理
@property (nonatomic, assign) CGSize videoSize;

/**
 根据url播放视频（初始化播放）
 */
- (void)playWithUrl:(NSString *)url showView:(UIView *)showView;

/**
 播放
 */
- (void)playVideo;

/**
 暂停
 */
- (void)pauseVideo;

/**
 停止播放/清空播放器
 */
- (void)stopVideo;

/**
 @param toTime 从指定的时间开始播放（秒）
 */
- (void)seekToTimePlay:(float)toTime;

/**
 横竖屏转换
 */
- (void)fullScreenChanged:(CGRect)frame;

@end

