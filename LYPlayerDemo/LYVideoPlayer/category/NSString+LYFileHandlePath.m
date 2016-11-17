//
//  NSString+LYFileHandlePath.m
//  LYPlayerDemo
//
//  Created by liyang on 16/11/5.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//


#import "NSString+LYFileHandlePath.h"

@implementation NSString (LYFileHandlePath)

+ (NSString *)tempFilePathWithFileName:(NSString *)name {
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:name];
}

+ (NSString *)tempFilePathWithUrlString:(NSString *)urlString{
    NSString *name = [[urlString componentsSeparatedByString:@"/"] lastObject];
    return [[NSHomeDirectory( ) stringByAppendingPathComponent:@"tmp"] stringByAppendingPathComponent:name];
}

+ (NSString *)cacheFilePathWithName:(NSString *)name{
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cacheFolderPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Moment_Videos/%@",name]];
    return cacheFolderPath;
}

+ (NSString *)cacheFilePathWithUrlString:(NSString *)urlString{
    NSString *name = [[urlString componentsSeparatedByString:@"/"] lastObject];
    NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cacheFolderPath = [cachePath stringByAppendingPathComponent:[NSString stringWithFormat:@"/Moment_Videos/%@",name]];
    return cacheFolderPath;
}

+ (NSString *)fileNameWithUrlString:(NSString *)url{
    return [[url componentsSeparatedByString:@"/"] lastObject];
}

@end
