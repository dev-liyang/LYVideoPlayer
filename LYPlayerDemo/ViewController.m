//
//  ViewController.m
//  LYPlayerDemo
//
//  Created by liyang on 16/11/4.
//  Copyright © 2016年 com.liyang.player. All rights reserved.
//

#import "ViewController.h"
#import "LYVideoPlayVC.h"

@interface ViewController ()

@end

@implementation ViewController{
    BOOL _isHalfScreen;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
}
- (IBAction)toPlayVideo:(id)sender {
    LYVideoPlayVC *videoVC = [[LYVideoPlayVC alloc] init];
    [self presentViewController:videoVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
