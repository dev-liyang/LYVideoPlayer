//
//  LYDownloadManager.m
//  LYPlayerDemo
//
//  Created by liyang on 16/11/4.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//

#import "LYDownloadManager.h"

@interface LYDownloadManager ()<NSURLSessionDataDelegate>

@property (nonatomic ,strong) NSURLSession *session;
@property (nonatomic ,strong) NSURLSessionDataTask *dataTask;

@property (nonatomic ,strong) NSFileHandle  *fileHandle;
@property (nonatomic ,strong) NSFileManager *fileManager;

@property (nonatomic ,assign) NSInteger curruentLength;
@property (nonatomic ,assign) NSInteger totalLength;

@property (nonatomic ,copy)   NSString *videoUrl;
@property (nonatomic ,copy)   NSString *videoTempPath;
@property (nonatomic ,copy)   NSString *videoCachePath;

@end

@implementation LYDownloadManager

- (instancetype)initWithURL:(NSString *)videoUrl withDelegate:(id)delegate
{
    self = [super init];
    if (self) {
        
        self.videoUrl = videoUrl;
        self.delegate = delegate;
        
        [self fileJudge];
    }
    return self;
}
- (void)fileJudge{
    
    //自定的操作
    _fileManager = [NSFileManager defaultManager];
    
    NSString *videoName = [[self.videoUrl componentsSeparatedByString:@"/"] lastObject];
    
    //定义文件的临时下载路径
    self.videoTempPath = [NSString tempFilePathWithFileName:videoName];
    
    //定义文件的缓存路径
    self.videoCachePath = [NSString cacheFilePathWithName:videoName];
    
    NSLog(@"videoTempPath === %@", self.videoTempPath);
    
    if ([_fileManager fileExistsAtPath:self.videoCachePath]) {//缓存目录下已存在下载完成的文件

        if (self.delegate && [self.delegate respondsToSelector:@selector(didFileExistedWithManager:Path:)]) {
            [self.delegate didFileExistedWithManager:self Path:self.videoCachePath];
        }
        
    }else{
        //判断当前目录下有无已有下载的临时文件
        if ([_fileManager fileExistsAtPath:self.videoTempPath]) {
            //可以读到
            _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.videoTempPath];
            //存在已下载数据的文件
            _curruentLength = [_fileHandle seekToEndOfFile];
            
        }else{
            //不存在文件
            _curruentLength = 0;
            //创建文件
            [_fileManager createFileAtPath:self.videoTempPath contents:nil attributes:nil];
            //创建之后再读
            _fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:self.videoTempPath];
        }
        
        [self sendHttpRequst];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didNoCacheFileWithManager:)]) {
            [self.delegate didNoCacheFileWithManager:self];
        }
    }
}
- (NSURLSession *)session{
    if (!_session) {
        _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

//网路请求方法
- (void)sendHttpRequst
{
    [_fileHandle seekToEndOfFile];
    NSURL *url = [NSURL URLWithString:_videoUrl];
    NSMutableURLRequest *requeset = [NSMutableURLRequest requestWithURL:url];
    
    //指定头信息  当前已下载的进度
    [requeset setValue:[NSString stringWithFormat:@"bytes=%ld-", _curruentLength] forHTTPHeaderField:@"Range"];
    
    //创建请求
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithRequest:requeset];
    self.dataTask = dataTask;
    
    //发起请求
    [self.dataTask resume];
}

-(void)URLSession:(NSURLSession *)session dataTask:(nonnull NSURLSessionDataTask *)dataTask
didReceiveResponse:(nonnull NSURLResponse *)response
completionHandler:(nonnull void (^)(NSURLSessionResponseDisposition))completionHandler {

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    NSDictionary *dic = (NSDictionary *)[httpResponse allHeaderFields] ;
    NSString *content = [dic valueForKey:@"Content-Range"];
    NSArray *array = [content componentsSeparatedByString:@"/"];
    NSString *length = array.lastObject;
    
    NSUInteger videoLength;
    if ([length integerValue] == 0) {
        videoLength = (NSUInteger)httpResponse.expectedContentLength;
    } else {
        videoLength = [length integerValue];
    }
    
    //接受到响应的时候 告诉系统如何处理服务器返回的数据
    completionHandler(NSURLSessionResponseAllow);
    //得到请求文件的数据大小
    _totalLength = response.expectedContentLength + _curruentLength;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didStartReceiveManager:VideoLength:)]) {
        [self.delegate didStartReceiveManager:self VideoLength:videoLength];
    }
}
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    //使用文件句柄指针来写数据（边写边移动）
    [_fileHandle writeData:data];
    
    //累加已经下载的文件数据大小
    _curruentLength += data.length;
    
    //计算文件的下载进度 = 已经下载的 / 文件的总大小
    CGFloat progress = 1.0 * _curruentLength / _totalLength;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didReceiveManager:Progress:)]) {
        [self.delegate didReceiveManager:self Progress:progress];
    }
    
    NSLog(@"progress = %f",progress);

}
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error == nil) { //下载成功
        //当前下载的文件路径
        NSURL *tempPathURL = [NSURL fileURLWithPath:self.videoTempPath];
    
        NSURL *cachefileURL = [NSURL fileURLWithPath:self.videoCachePath];
        
        NSLog(@"videoCachePath === %@", self.videoCachePath);

        // 如果没有该文件夹，创建文件夹
        if (![self.fileManager fileExistsAtPath:self.videoCachePath]) {
            [self.fileManager createDirectoryAtPath:self.videoCachePath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        // 如果该路径下文件已经存在，就要先将其移除，在移动文件
        if ([self.fileManager fileExistsAtPath:[cachefileURL path] isDirectory:NULL]) {
            [self.fileManager removeItemAtURL:cachefileURL error:NULL];
        }
        //移动文件至缓存目录
        [self.fileManager moveItemAtURL:tempPathURL toURL:cachefileURL error:NULL];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFinishLoadingWithManager:fileSavePath:)]) {
            [self.delegate didFinishLoadingWithManager:self fileSavePath:self.videoCachePath];
        }
    }else{//下载失败
        if (self.delegate && [self.delegate respondsToSelector:@selector(didFailLoadingWithManager:WithError:)]) {
            [self.delegate didFailLoadingWithManager:self WithError:error];
        }
    }
}

//开始/继续
- (void)start{
    if (self.dataTask == nil) {
        [self sendHttpRequst];
    }else{
        
        [self.dataTask resume];
    }
}
- (void)suspend{
    [self.dataTask suspend];
}
- (void)cancel{
    [self.dataTask cancel];
    self.dataTask = nil;
}

@end
