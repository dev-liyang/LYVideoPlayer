//
//  LYVideoPlayVC.m
//  LYPlayerDemo
//
//  Created by liyang on 16/11/4.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//

#import "LYVideoPlayVC.h"

#import "LYVideoPlayer.h"

@interface LYVideoPlayVC () <LYVideoPlayerDelegate>

@property (nonatomic ,strong) LYVideoPlayer *videoPlayer;
@property (nonatomic ,strong) UIView *videoPlayBGView;
@property (nonatomic ,copy)   NSString*videoUrl;

@end

@implementation LYVideoPlayVC{
    BOOL _isHalfScreen;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isHalfScreen = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.videoPlayBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width * 0.6)];
    self.videoPlayBGView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoPlayBGView];
    
    self.videoUrl = @"http://cdn.tumbo.com.cn/follomeFront//file/library/library_moment_video/2016/11/02/20161102171719373752095.mp4";
    
    self.videoPlayer = [[LYVideoPlayer alloc] init];
    self.videoPlayer.delegate = self;
    [self.videoPlayer playWithUrl:self.videoUrl showView:self.videoPlayBGView];
    
}

- (void)videoPlayerDidBackButtonClick{
    
    _isHalfScreen = !_isHalfScreen;
    
    if (_isHalfScreen) {
        [[UIDevice currentDevice]setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft]  forKey:@"orientation"];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        [UIView animateWithDuration:0.5 animations:^{
            self.videoPlayBGView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width * 0.6);
        } completion:^(BOOL finished) {
        }];
        
        [self.videoPlayer fullScreenChanged:!_isHalfScreen];
    }else{
        [self.videoPlayer stopVideo];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
- (void)videoPlayerDidFullScreenButtonClick{
    
    _isHalfScreen = !_isHalfScreen;
    
    if (_isHalfScreen) {
        [[UIDevice currentDevice]setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft]  forKey:@"orientation"];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait] forKey:@"orientation"];
        [UIView animateWithDuration:0.5 animations:^{
            self.videoPlayBGView.frame = CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width * 0.6);
        } completion:^(BOOL finished) {
        }];
    }else{
        
        [[UIDevice currentDevice]setValue:[NSNumber numberWithInteger:UIDeviceOrientationPortrait]  forKey:@"orientation"];
        [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIDeviceOrientationLandscapeLeft] forKey:@"orientation"];
        [UIView animateWithDuration:0.5 animations:^{
            self.videoPlayBGView.frame=self.view.bounds;
        } completion:^(BOOL finished) {
        }];
    }
    
    [self.videoPlayer fullScreenChanged:!_isHalfScreen];
}

- (BOOL)shouldAutorotate{
    return YES;
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    if (_isHalfScreen) { //如果是iPhone,且为竖屏的时候, 只支持竖屏
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskLandscape; //否者只支持横屏
    }
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
