//
//  LYVideoPresenter.h
//  LYPlayerDemo
//
//  Created by liyang on 2018/5/8.
//  Copyright © 2018年 com.liyang.player. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LYVideoPresenter;
@protocol LYVideoPresenterDelegate <NSObject>
@optional
- (void)videoPresenterDidBackBtnClick;
@end

@interface LYVideoPresenter : NSObject

@property (nonatomic, weak)   id <LYVideoPresenterDelegate> delegate;

///根据url播放视频（初始化播放）
- (void)playWithUrl:(NSString *)url addInView:(UIView *)view;

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



@end
