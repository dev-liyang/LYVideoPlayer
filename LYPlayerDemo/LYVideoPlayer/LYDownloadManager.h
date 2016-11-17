//
//  LYDownloadManager.h
//  LYPlayerDemo
//
//  Created by liyang on 16/11/4.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class LYDownloadManager;

@protocol LYDownloadManagerDelegate <NSObject>

@optional

/** 没有完整的缓存文件，告诉播放器自己去用 网络地址 进行播放 */
- (void)didNoCacheFileWithManager:(LYDownloadManager *)manager;

/** 已经存在下载好的这个文件了，告诉播放器可以直接利用filePath播放 */
-(void)didFileExistedWithManager:(LYDownloadManager *)manager Path:(NSString *)filePath;

/** 开始下载数据(包括长度和类型) */
- (void)didStartReceiveManager:(LYDownloadManager *)manager VideoLength:(NSUInteger)videoLength;

/** 正在下载 */
- (void)didReceiveManager:(LYDownloadManager *)manager Progress:(CGFloat)progress;

/** 完成下载 */
- (void)didFinishLoadingWithManager:(LYDownloadManager *)manager fileSavePath:(NSString *)filePath;

/** 下载失败(错误码) */
- (void)didFailLoadingWithManager:(LYDownloadManager *)manager WithError:(NSError *)errorCode;

@end

@interface LYDownloadManager : NSObject

@property(nonatomic, weak) id <LYDownloadManagerDelegate> delegate;

//定义初始化方法 传入videoUrl参数（NSString）
- (instancetype)initWithURL:(NSString *)videoUrl withDelegate:(id)delegate;

/** 开始下载 */
- (void)start;
/** 暂停 */
- (void)suspend;
/** 关闭 */
- (void)cancel;

@end
