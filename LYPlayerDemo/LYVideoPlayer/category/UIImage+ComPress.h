//
//  UIImage+ComPress.h
//  LYPlayerDemo
//
//  Created by liyang on 16/11/6.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface UIImage (ComPress)

/** 缩放到指定大小 */
- (UIImage*)imageCompressWithSimple:(UIImage*)image scaledToSize:(CGSize)size;

/** 根据颜色和圆的半径来创建一个 Image */
+ (UIImage *)createImageWithColor:(UIColor *)color radius:(CGFloat)radius;

/** 根据一个view来创建一个 Image */
+ (UIImage*)creatImageWithView:(UIView *)theView;
@end
