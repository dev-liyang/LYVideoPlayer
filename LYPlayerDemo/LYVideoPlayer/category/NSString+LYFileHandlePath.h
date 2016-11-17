//
//  NSString+LYFileHandlePath.h
//  LYURLSession
//
//  Created by liyang on 16/11/5.
//  Copyright © 2016年 com.liyang.xmpp_test. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LYFileHandlePath)


/** 临时文件路径 */
+ (NSString *)tempFilePathWithFileName:(NSString *)name;
/**  临时文件路径 */
+ (NSString *)tempFilePathWithUrlString:(NSString *)urlString;

/** 缓存文件夹路径 */
+ (NSString *)cacheFilePathWithName:(NSString *)name;
/** 缓存文件夹路径 */
+ (NSString *)cacheFilePathWithUrlString:(NSString *)urlString;

/**  获取网址中的文件名 */
+ (NSString *)fileNameWithUrlString:(NSString *)url;


@end
