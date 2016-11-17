//
//  LYVideoPlayer.h
//  LYPlayerDemo
//
//  Created by liyang on 16/11/4.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class LYVideoPlayer;

@protocol LYVideoPlayerDelegate <NSObject>

@optional

- (void)videoPlayerDidBackButtonClick;
- (void)videoPlayerDidFullScreenButtonClick;

@end

@interface LYVideoPlayer : NSObject

@property (nonatomic, assign) BOOL showTopControl;    //显示顶部控制视频界面view   default is YES
@property (nonatomic, assign) BOOL showBototmControl; //显示底部控制视频界面view   default is YES

@property (nonatomic, weak)   id <LYVideoPlayerDelegate> delegate;

@property (nonatomic, assign) BOOL mute; // 静音 default is NO

@property (nonatomic, assign) BOOL stopWhenAppDidEnterBackground; // default is YES

@property (nonatomic, assign) CGSize videoSize; // 可给定video尺寸大小,若尺寸超过view大小时作截断处理



- (void)playWithUrl:(NSString *)url showView:(UIView *)showView;

/** 播放 */
- (void)playVideo;
/** 暂停 */
- (void)pauseVideo;
/** 停止播放/清空播放器 */
- (void)stopVideo;

//横竖屏转换
- (void)fullScreenChanged:(BOOL)isFullScreen;

@end
