//
//  LYVideoPlayer.m
//  LYPlayerDemo
//
//  Created by liyang on 16/11/4.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//


#import "LYVideoPlayer.h"

@interface LYVideoPlayer ()

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerItem *currentPlayerItem;

@property (nonatomic, strong) AVPlayerLayer *currentPlayerLayer;

@property (nonatomic, strong) UIView *videoShowView;            //用于视频显示的View

@property (nonatomic, strong) NSString *videoUrl;               //视频地址

@property (nonatomic, strong) id timeObserve;   //监听播放进度

@property (nonatomic, assign) CGFloat duration; //视频时间总长度(秒)
@property (nonatomic, assign) CGFloat currentTime; //视频当前播放进度(秒)

@property (nonatomic, assign) BOOL playButtonState;//playButtonState 用于 缓冲达到要求值的情况时如果状态是暂停，则不会自动播放

@property (nonatomic, assign) BOOL isCanToGetLocalTime;     //是否能去获取本地时间（秒）
@property (nonatomic, assign) NSInteger localTime;          //当前本地时间
@property (nonatomic, strong) NSMutableArray *loadedTimeRangeArr;//存储缓冲范围的数组（当拖动滑块时，AVPlayerItem会生成另一个缓冲区域）

@property (nonatomic, assign) BOOL isPlaying;           //是否正在播放
@property (nonatomic, assign) BOOL isBufferEmpty;       //没有缓冲数据
@property (nonatomic, assign) CGFloat lastBufferValue;  //记录上次的缓冲值
@property (nonatomic, assign) CGFloat currentBufferValue;//当前的缓冲值

@end

@implementation LYVideoPlayer

- (void)playWithUrl:(NSString *)videoUrl showView:(UIView *)showView{
    self.videoUrl = videoUrl;
    
    _videoShowView = showView;
    _videoShowView.layer.masksToBounds = YES;
    
    NSURL *url = [NSURL URLWithString:self.videoUrl];
    [self getUrlToPlayVideo:url];
}

//播放前需要初始化的一些配置
- (void)configureAndNotification{
    
    self.stopWhenAppDidEnterBackground = YES;
    self.playButtonState = YES;
    self.isPlaying = NO;
    self.isCanToGetLocalTime = YES;
    self.loadedTimeRangeArr = [NSMutableArray array];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidPlayToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

#pragma mark - Setter/Getter
//静音
- (void)setMute:(BOOL)mute{
    _mute = mute;
    self.player.muted = _mute;
}
- (void)setVideoSize:(CGSize)videoSize{
    _videoSize = videoSize;
    
    if (self.currentPlayerLayer) {
        [self changePlayerLayerFrameWithVideoSize:_videoSize];
    }
}

#pragma mark - Private methods
//给定URL, 创建播放器 播放
- (void)getUrlToPlayVideo:(NSURL *)url{
    //清空配置
    [self stopVideo];
    
    //初始化一些配置
    [self configureAndNotification];
    
    //创建播放器
    self.currentPlayerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.currentPlayerItem];
    self.currentPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    
    //设置layer的frame
    [self changePlayerLayerFrameWithVideoSize:self.videoSize];
    
    //添加KVO
    [self addObserver];
}

- (void)changePlayerLayerFrameWithVideoSize:(CGSize)videoSize{
    
    if (videoSize.width) {
        
        CGSize size;
        size.width = self.videoShowView.bounds.size.width;
        size.height = size.width / videoSize.width * videoSize.height;
        
        CGFloat x = 0;
        CGFloat y = (self.videoShowView.bounds.size.height - size.height) * 0.5;
        
        self.currentPlayerLayer.frame = CGRectMake(x, y, size.width, size.height);
        
    }else{
        self.currentPlayerLayer.frame = CGRectMake(0, 0, _videoShowView.bounds.size.width, _videoShowView.bounds.size.height);
    }
    
}

//视频UI显示
-(void)handleShowViewSublayers{
    for (CALayer *layer in _videoShowView.subviews) {
        [layer removeFromSuperlayer];
    }
    [_videoShowView.layer addSublayer:self.currentPlayerLayer];
}

//拖动
- (void)seekToTimePlay:(float)toTime{
    
    if (self.player) {
        [self.player pause];
        
        //手动添加缓冲区域数组，最后根据toTime在数组中遍历以计算拖动的时间是否在缓冲区域内
        [self.loadedTimeRangeArr addObject:[self getLoadedTimeRange]];
        BOOL isShowActivity = [self judgeLoadedTimeIsShowActivity:toTime];
        if (isShowActivity) {
            [self delegateDidStartBuffer];
        }
        self.isCanToGetLocalTime = NO;  //拖动时停止获取本地时间
        __weak typeof(self) weak_self = self;
        [self.player seekToTime:CMTimeMake(toTime, 1) completionHandler:^(BOOL finished) {
            __strong typeof(weak_self) strong_self = weak_self;
            if (!strong_self) return;
            [strong_self play];
        }];
    }
}

//横竖屏转换
- (void)fullScreenChanged:(CGRect)frame{
    self.videoShowView.frame = frame;
    self.currentPlayerLayer.frame = frame;
}

// 计算缓冲总进度
- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [self.currentPlayerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;
    
    return result;
}

// 获取当前的缓冲区域
- (NSDictionary *)getLoadedTimeRange{
    NSArray *loadedTimeRanges = [self.currentPlayerItem loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSString *start = [NSString stringWithFormat:@"%.2f",startSeconds];
    NSString *duration = [NSString stringWithFormat:@"%.2f",durationSeconds];
    NSDictionary *timeRangeDic = @{@"start" : start, @"duration" : duration};
    
    return timeRangeDic;
}
//根据toTime和缓冲区域数组判断是否显示菊花
- (BOOL)judgeLoadedTimeIsShowActivity:(float)toTime{
    BOOL show = YES;
    
    for (NSDictionary *timeRangeDic in self.loadedTimeRangeArr) {
        float start = [timeRangeDic[@"start"] floatValue];
        float duration = [timeRangeDic[@"duration"] floatValue];
        if (start < toTime && toTime < start + duration) {
            show = NO;
            break;
        }
    }
    return show;
}
//获取本地时间（秒）
- (NSInteger)getLocalTime{
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:0];
    double ss = [date2 timeIntervalSinceNow];
    return fabs(ss);
}
//buffer值有时会不正常。所以只好这么处理
- (void)handleBuffer{
    
    if (self.playButtonState == YES) {
        
        if (self.isPlaying == NO) {
            
            if (self.currentBufferValue > self.lastBufferValue) {
                if ((self.currentBufferValue - self.lastBufferValue) > 5) {
                    [self playForActivity];
                }
                else if (self.currentBufferValue == self.duration){
                    [self playForActivity];
                }
                else if ((int)(self.currentBufferValue + self.lastBufferValue+1) >= (int)self.duration){
                    [self playForActivity];
                }
            }
            else{
                if (self.currentBufferValue > 10) {
                    [self playForActivity];
                }
                else if (self.currentBufferValue == self.duration){
                    [self playForActivity];
                }
                else if ((int)(self.currentBufferValue + self.duration + 1) >= (int)self.duration){
                    [self playForActivity];
                }
            }
        }
        
    }else{
        
        if (self.currentBufferValue > self.lastBufferValue) {
            if ((self.currentBufferValue - self.lastBufferValue) > 5) {
                [self delegateDidEndBuffer];
            }
            else if (self.currentBufferValue == self.duration){
                [self delegateDidEndBuffer];
            }
            else if ((int)(self.currentBufferValue + self.lastBufferValue+1) >= (int)self.duration){
                [self delegateDidEndBuffer];
            }
        }
        else{
            if (self.currentBufferValue > 10) {
                [self delegateDidEndBuffer];
            }
            else if (self.currentBufferValue == self.duration){
                [self delegateDidEndBuffer];
            }
            else if ((int)(self.currentBufferValue + self.duration + 1) >= (int)self.duration){
                [self delegateDidEndBuffer];
            }
        }
        
    }
}

- (void)delegateDidStartBuffer{
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerDidStartBuffer)]) {
        [_delegate videoPlayerDidStartBuffer];
    }
}
- (void)delegateDidEndBuffer{
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerDidEndBuffer)]) {
        [_delegate videoPlayerDidEndBuffer];
    }
}
//播放（菊花显示逻辑）
- (void)playForActivity{
    if (self.playButtonState) {
        [self.player play];
    }
    self.isBufferEmpty = NO;
    self.isPlaying = YES;
    [self delegateDidEndBuffer];
}
//播放
- (void)play{
    if (self.playButtonState) {
        [self.player play];
        if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerDidPlay)]) {
            [_delegate videoPlayerDidPlay];
        }
    }
}
#pragma mark - Public Methods
//播放（外部播放方法）
- (void)playVideo{
    if (_currentTime == _duration) {
        self.isPlaying = YES;
        self.playButtonState = YES;
        [self seekToTimePlay:0];
    }else{
        self.isPlaying = YES;
        self.playButtonState = YES;
        [self.player play];
        if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerDidPlay)]) {
            [_delegate videoPlayerDidPlay];
        }
    }
}
//暂停播放
- (void)pauseVideo{
    self.playButtonState = NO;
    [self.player pause];
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerDidPause)]) {
        [_delegate videoPlayerDidPause];
    }
}

//停止播放/清空播放器
- (void)stopVideo{
    
    if (!self.currentPlayerItem) return;
    [self.player pause];
    [self.player cancelPendingPrerolls];
    if (self.currentPlayerLayer) {
        [self.currentPlayerLayer removeFromSuperlayer];
    }
    [self removeObserver];
    self.player = nil;
    self.currentPlayerItem = nil;
    
    [self.loadedTimeRangeArr removeAllObjects];
    self.loadedTimeRangeArr = nil;
    
}

#pragma mark - Observer
- (void)addObserver {
    //监听播放进度
    __weak typeof(self) weakSelf = self;
    self.timeObserve = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        CGFloat current = CMTimeGetSeconds(time);
        CGFloat total = CMTimeGetSeconds(weakSelf.currentPlayerItem.duration);
        _currentTime = current;
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(videoPlayer:totalTime:)]) {
            [weakSelf.delegate videoPlayer:weakSelf totalTime:total];
        }
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(videoPlayer:currentTime:)]) {
            [weakSelf.delegate videoPlayer:weakSelf currentTime:current];
        }
        
        /***** 这里是比较蛋疼的，当拖动滑块到没有缓冲的地方并且没有开始播放时，也会走到这里 *************/
        if (weakSelf.isCanToGetLocalTime) {
            weakSelf.localTime = [weakSelf getLocalTime];
        }
        NSInteger timeNow = [weakSelf getLocalTime];
        if (timeNow - weakSelf.localTime > 1.5) {
            [weakSelf delegateDidEndBuffer];
            weakSelf.isCanToGetLocalTime = YES;
        }
    }];
    
    [self.currentPlayerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];//监听播放器的状态
    [self.currentPlayerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];//监听当前的缓冲进度
    [self.currentPlayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];//监听到当前没有缓冲数据
}

- (void)removeObserver {
    if (self.timeObserve) {
        [self.player removeTimeObserver:self.timeObserve];
        self.timeObserve = nil;
    }
    
    [self.currentPlayerItem removeObserver:self forKeyPath:@"status" context:nil];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"loadedTimeRanges" context:nil];
    [self.currentPlayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty" context:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.player replaceCurrentItemWithPlayerItem:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    
    AVPlayerItem *playerItem = (AVPlayerItem *)object;
    
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItemStatus status = playerItem.status;
        switch (status) {
            case AVPlayerItemStatusUnknown:{
                NSLog(@"======== 播放失败");
            }
                break;
                
            case AVPlayerItemStatusReadyToPlay:{
                self.player.muted = self.mute;
                [self play];
                
                [self handleShowViewSublayers];
                NSLog(@"========= 准备播放");
            }
                break;
                
            case AVPlayerItemStatusFailed:{
                NSLog(@"======== 播放失败");
            }
                break;
                
            default:
                break;
        }
    }
    else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval current = [self availableDuration];// 计算缓冲进度
        
        CMTime duration = playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        CGFloat progress = current / totalDuration;
        
        if (_delegate && [_delegate respondsToSelector:@selector(videoPlayer:bufferProgress:)]) {
            [_delegate videoPlayer:self bufferProgress:progress];
        }
        
        self.duration = totalDuration;
        self.currentBufferValue = current;
        
        [self handleBuffer];
    }
    else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        self.isPlaying = NO;
        self.isBufferEmpty = YES;
        self.lastBufferValue = self.currentBufferValue;
        
        [self delegateDidStartBuffer];
        NSLog(@"====playbackBufferEmpty");
    }
}

#pragma mark - NSNotification
//播放结束
- (void)playerItemDidPlayToEnd:(NSNotification *)notification{
    
    //重新开始播放
    if (_replayWhenVideoPlayEnd) {
        __weak typeof(self) weak_self = self;
        [self.player seekToTime:CMTimeMake(0, 1) completionHandler:^(BOOL finished) {
            __strong typeof(weak_self) strong_self = weak_self;
            if (!strong_self) return;
            [strong_self.player play];
        }];
    }else{
        [self pauseVideo];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(videoPlayerDidPlayToEnd)]) {
        [_delegate videoPlayerDidPlayToEnd];
    }
}
//进入后台
- (void)appDidEnterBackground{
    if (self.stopWhenAppDidEnterBackground) {
        [self pauseVideo];
    }
}
//进入前台
- (void)appDidEnterForeground{
    [self playVideo];
}

@end

