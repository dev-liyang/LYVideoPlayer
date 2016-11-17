//
//  LYSlider.h
//  LYPlayerDemo
//
//  Created by liyang on 16/11/5.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYSlider : UIControl


@property (nonatomic, assign) CGFloat value;            //0 - 1. 播放进度
@property (nonatomic, assign) CGFloat bufferProgress;   //0 - 1. 缓冲进度

@property (nonatomic, assign) CGFloat trackHeight;      //轨道高度

@property (nonatomic, assign) CGFloat thumbTouchSize;   //滑块触发大小的宽高
@property (nonatomic, assign) CGFloat thumbVisibleSize; //滑块可视大小的宽高

@property (nonatomic, strong) UIColor *trackColor;      //轨道的颜色
@property (nonatomic, strong) UIColor *bufferColor;     //缓冲的颜色
@property (nonatomic, strong) UIColor *thumbValueColor; //播放进度的颜色

/** 可为滑块设置图片 */
- (void)setThumbImage:(UIImage *)thumbImage forState:(UIControlState)state;

//横竖屏转换
- (void)fullScreenChanged:(BOOL)isFullScreen;

@end
