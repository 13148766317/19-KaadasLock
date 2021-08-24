//
//  LoginViewController.m
//  lock
//
//  Created by zhaowz on 2017/5/25.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

//1.代理传值
@protocol XWCountryCodeControllerDelegate <NSObject>

@optional
-(void)returnCountryCode:(NSString *)countryCode;

@end

//2.block传值  typedef void(^returnBlock)(NSString *showText);
typedef void(^returnCountryCodeBlock) (NSString *countryCodeStr);

@interface XWCountryCodeController : UIViewController

//代理
@property (nonatomic, assign) id<XWCountryCodeControllerDelegate> deleagete;

//block
//block声明属性
@property (nonatomic, copy) returnCountryCodeBlock returnCountryCodeBlock;
//block声明方法
-(void)toReturnCountryCode:(returnCountryCodeBlock)block;


@end
