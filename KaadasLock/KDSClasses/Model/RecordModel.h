//
//  RecordModel.h
//  lock
//
//  Created by zhaowz on 2017/5/12.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RecordModel : NSObject
@property (nonatomic, copy) NSString *user_num;  //用户编号
@property (nonatomic, copy) NSString *type;      //开门类型
@property (nonatomic, assign) NSTimeInterval timeInterval;      //时间戳
@property (nonatomic, copy) NSString *time;
@property (nonatomic, copy) NSString *yearStr;
@property (nonatomic ,copy) NSString *monthStr;
@property (nonatomic, copy) NSString *dayStr;
@property (nonatomic, copy) NSString *hourStr;
@property (nonatomic, copy) NSString *minuteStr;
@property (nonatomic, copy) NSString *secondStr;

@end
