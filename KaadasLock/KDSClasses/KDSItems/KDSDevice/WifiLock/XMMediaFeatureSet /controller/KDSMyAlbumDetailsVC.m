//
//  KDSMyAlbumDetailsVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/9.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMyAlbumDetailsVC.h"
#import <Photos/Photos.h>
#import <AVKit/AVKit.h>

@interface KDSMyAlbumDetailsVC ()<UINavigationControllerDelegate>

@property (nonatomic, strong)AVPlayerViewController *playerVC;
///上个导航控制器的代理。
@property (nonatomic, weak) id<UINavigationControllerDelegate> preDelegate;

@end

@implementation KDSMyAlbumDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.blackColor;
    [self setUI];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.preDelegate = self.navigationController.delegate;
    self.navigationController.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.delegate = self.preDelegate;
}

- (void)setUI
{
    UIView * navView = [UIView new];
    navView.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:navView];
    [navView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.view);
        make.height.equalTo(@(kNavBarHeight+kStatusBarHeight+10));
    }];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    backBtn.frame = CGRectMake(0, kStatusBarHeight, 44, 44);
    [backBtn addTarget:self action:@selector(backBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:backBtn];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];//加粗
    titleLabel.textColor = UIColor.blackColor;
    titleLabel.text = @"我的相册";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(navView).offset(kStatusBarHeight + 11);
        make.centerX.equalTo(navView);
        make.left.mas_equalTo(navView.mas_left).offset(30);
        make.right.mas_equalTo(navView.mas_right).offset(-30);
        make.height.equalTo(@25);
    }];
    
    UILabel * lb = [UILabel new];
    lb.textColor = UIColor.blackColor;
    NSArray *array = [self.model.imageName componentsSeparatedByString:@"+"];
    lb.text = array[0];
    lb.font = [UIFont systemFontOfSize:12];
    lb.textAlignment = NSTextAlignmentCenter;
    [navView addSubview:lb];
    [lb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(navView);
        make.height.equalTo(@18);
    }];
    if (self.model.mp4Address.length >0) {
        ///使用系统的播放器
        self.playerVC = [[AVPlayerViewController alloc] init];
        self.playerVC.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:self.model.mp4Address]];
        self.playerVC.showsPlaybackControls = YES;
        self.playerVC.videoGravity = AVLayerVideoGravityResizeAspect;
        [self.view addSubview:self.playerVC.view];
        [self.playerVC.view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(navView.mas_bottom);
            make.left.right.equalTo(self.view);
            make.bottom.equalTo(@(-kBottomSafeHeight));
        }];
        if (self.playerVC.readyForDisplay) {
            [self.playerVC.player play];
        }
    }else{
        UIImageView * imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        NSData * imageData = [NSData dataWithData:self.model.lockCutData];
        imageView.image = [UIImage imageWithData:imageData];
        [self.view addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(navView.mas_bottom);
            make.left.right.bottom.equalTo(self.view);
        }];
    }
}

#pragma mark --点击事件

- (void)backBtnAction:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [navigationController setNavigationBarHidden:YES animated:YES];
}


@end
