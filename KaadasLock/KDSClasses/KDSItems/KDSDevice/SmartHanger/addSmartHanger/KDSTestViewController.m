//
//  KDSTestViewController.m
//  KaadasLock
//
//  Created by kaadas on 2021/1/27.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSTestViewController.h"

@interface KDSTestViewController ()

@end

@implementation KDSTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor  whiteColor];
    
    UILabel   * text = [UILabel  new];
    text.text = @"测试的视图";
    [self.view addSubview:text];
    [text  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
    
}


@end
