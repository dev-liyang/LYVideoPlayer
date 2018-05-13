//
//  LYVideoPlayVC.m
//  LYPlayerDemo
//
//  Created by liyang on 16/11/4.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//

#import "LYVideoPlayVC.h"
#import "LYVideoPresenter.h"

@interface LYVideoPlayVC () <LYVideoPresenterDelegate>

@property (nonatomic ,strong) UIView *videoPlayBGView;
@property (nonatomic ,copy)   NSString*videoUrl;
@property (nonatomic, strong) LYVideoPresenter *videpPresenter;

@end

@implementation LYVideoPlayVC{
    BOOL _isHalfScreen;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self presenter];
}

- (void)presenter{
    
    _isHalfScreen = YES;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.videoPlayBGView = [[UIView alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, self.view.frame.size.width * 0.6)];
    self.videoPlayBGView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoPlayBGView];
    
    self.videoUrl = @"http://videoplay.elearnmooc.com/moocMain/video/e08956a5-df94-4856-96ad-e35bdbc884c4.mp4";
    
    _videpPresenter = [[LYVideoPresenter alloc] init];
    _videpPresenter.delegate = self;
    [_videpPresenter playWithUrl:self.videoUrl addInView:self.videoPlayBGView];
}

- (void)videoPresenterDidBackBtnClick{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

