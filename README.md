# LYVideoPlayer
基于AVPlayer封装视频播放器（具有边下边播、离线缓存、自定义滑块、进度条、手势快进快退、手势加减音量等功能）


###实现的效果:

![播放器播放效果.gif](https://github.com/Developer-LiYang/LYVideoPlayer/blob/master/播放效果.gif)

![自定义滑块2.png](https://github.com/Developer-LiYang/LYVideoPlayer/blob/master/个性化滑块1.png)

![自定义滑块3.png](https://github.com/Developer-LiYang/LYVideoPlayer/blob/master/个性化滑块2.png)

###使用方法

1.记得在你的pch文件里导入LVVideoPlayer的头文件LYPlayerHeader.h

2.播放器的实例化，即如下两步就可现实视频的播放
```
    self.videoPlayer = [[LYVideoPlayer alloc] init];
    [self.videoPlayer playWithUrl:self.videoUrl showView:self.view];
```
如需获得返回按钮和全屏播放按钮的回调，则需遵循协议<LYVideoPlayerDelegate>,并设置代理
```
    self.videoPlayer.delegate = self;
```
3.滑块的自定义 - 在实例化LYSlider的时候传入设置相应属性的值就可自定义自己想要的效果

````
    [_videoSlider setThumbImage:normalImage forState:UIControlStateNormal];//可设置滑块默认状态下的图片
    [_videoSlider setThumbImage:highlightImage forState:UIControlStateHighlighted];//可设置滑块高亮状态下的图片
    _videoSlider.trackHeight = 1.5;//设置轨道的高度
    _videoSlider.thumbVisibleSize = 12;//设置滑块（可见的）大小
```
