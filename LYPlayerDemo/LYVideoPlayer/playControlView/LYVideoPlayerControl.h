//
//  LYVideoPlayerControl.h
//  LYPlayerDemo
//
//  Created by liyang on 16/11/5.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LYSlider.h"

@class LYVideoPlayerControl;
@protocol LYVideoPlayerControlDelegate <NSObject>
@optional

/**
 返回按钮被点击
 */
- (void)videoControlDidBackBtnClick;

/**
 全屏按钮被点击
 */
- (void)videoControlDidFullScreenBtnClick;

/**
 @param isPause YES:暂停  NO:播放
 */
- (void)videoControl:(LYVideoPlayerControl*)videoControl didPlayBtnIsPause:(BOOL)isPause;

/**
 @param time 播放指定的时间（秒）
 */
- (void)videoControl:(LYVideoPlayerControl*)videoControl didPlayToTime:(CGFloat)time;

@end

@interface LYVideoPlayerControl : UIView

@property (nonatomic, weak)   id <LYVideoPlayerControlDelegate> delegate;

@property (nonatomic, assign) NSInteger  currentTime;
@property (nonatomic, assign) NSInteger  totalTime;
@property (nonatomic, assign) CGFloat  playValue;   //播放进度
@property (nonatomic, assign) CGFloat  progress;    //缓冲进度

//播放器调用方法
- (void)videoPlayerDidLoading;

- (void)videoPlayerDidBeginPlay;

- (void)videoPlayerDidEndPlay;

- (void)videoPlayerDidFailedPlay;

//外部方法播放
- (void)playerControlPlay;
//外部方法暂停
- (void)playerControlPause;

//横竖屏转换
- (void)fullScreenChanged:(BOOL)isFullScreen frame:(CGRect)frame;

@end

