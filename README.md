# LYVideoPlayer
基于AVPlayer封装视频播放器（具有边下边播、离线缓存、自定义滑块、进度条、手势快进快退、手势加减音量等功能）


<br>###实现的效果:

![播放器播放效果.gif](http://upload-images.jianshu.io/upload_images/2942639-a151f8db2fd70f83.gif?imageMogr2/auto-orient/strip)

![自定义滑块2.png](http://upload-images.jianshu.io/upload_images/2942639-7c46f02993798eb9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

![自定义滑块3.png](http://upload-images.jianshu.io/upload_images/2942639-03ed301dfbda289e.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


<br>###使用方法
<br>1.记得在你的pch文件里导入LVVideoPlayer的头文件LYPlayerHeader.h

<br>2.播放器的实例化，即如下两步就可现实视频的播放
```
    self.videoPlayer = [[LYVideoPlayer alloc] init];
    [self.videoPlayer playWithUrl:self.videoUrl showView:self.view];
```
<br> //如需获得返回按钮和全屏播放按钮的回调，则需遵循协议<LYVideoPlayerDelegate>,并设置代理
<br>self.videoPlayer.delegate = self;

<br>3.滑块的自定义
<br>在实例化LYSlider的时候传入设置相应属性的值就可自定义自己想要的效果

<br>[_videoSlider setThumbImage:normalImage forState:UIControlStateNormal];//可设置滑块默认状态下的图片
<br>[_videoSlider setThumbImage:highlightImage forState:UIControlStateHighlighted];//可设置滑块高亮状态下的图片

<br>_videoSlider.trackHeight = 1.5;//设置轨道的高度
<br>_videoSlider.thumbVisibleSize = 12;//设置滑块（可见的）大小
