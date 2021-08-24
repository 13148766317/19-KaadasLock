//
//  KDSFAQ2ViewController.m
//  KaadasLock
//
//  Created by kaadas on 2021/1/25.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSFAQ2ViewController.h"
#import "YHSegmentView.h"
#import "KDSLockFAQViewController.h"
#import "KDSWashingMachineViewController.h"

@interface KDSFAQ2ViewController ()

@end

@implementation KDSFAQ2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"FAQ");
    self.view.backgroundColor = [UIColor whiteColor];
    NSArray *titleArr = @[@"门锁问题",@"晾衣机问题"];
    NSMutableArray *mutArr = [NSMutableArray array];
    KDSLockFAQViewController*tabVC = [KDSLockFAQViewController new];
    KDSWashingMachineViewController  * tabVC2   = [KDSWashingMachineViewController new];
//    [mutArr addObject:tabVC];
 //   [mutArr addObject:tabVC2];
    mutArr  = @[tabVC,tabVC2];
//    for (int i = 0; i < 2  ; i++) {
//        KDSLockFAQViewController*tabVC = [KDSLockFAQViewController new];
//        //tabVC.title = titleArr[i];
//        [mutArr addObject:tabVC];
//    }
    YHSegmentView *segmentView = [[YHSegmentView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, [UIScreen mainScreen].bounds.size.height - CGRectGetMaxY(self.navigationController.navigationBar.frame)) ViewControllersArr:[mutArr copy] TitleArr:titleArr TitleNormalSize:15 TitleSelectedSize:15 SegmentStyle:YHSegementStyleIndicate ParentViewController:self ReturnIndexBlock:^(NSInteger index) {
        NSLog(@"点击了%ld模块",(long)index);
    }];
    
    [self.view addSubview:segmentView];
}



@end
