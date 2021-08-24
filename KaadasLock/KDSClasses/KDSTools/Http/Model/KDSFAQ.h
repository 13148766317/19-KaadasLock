//
//  KDSFAQ.h
//  xiaokaizhineng
//
//  Created by orange on 2019/3/7.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///常见问题。
@interface KDSFAQ : NSObject <NSCoding>

///id
@property (nonatomic, strong) NSString *_id;
///问题描述。
@property (nonatomic, strong) NSString *question;
///问题答案。
@property (nonatomic, strong) NSString *answer;
///问题序号。
@property (nonatomic, assign) int sortNum;
///创建时间，距70年的本地时间秒数。
@property (nonatomic, assign) NSTimeInterval createTime;
///语言，1简体中文， 2繁体中文， 3英文， 4泰语。
@property (nonatomic, assign) int language;

@end

NS_ASSUME_NONNULL_END
