
//
//  RecordModel.m
//  lock
//
//  Created by zhaowz on 2017/5/12.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import "RecordModel.h"
#import "NSObject+KDS.h"
@implementation RecordModel
-(NSString*)description{
    /*@property (nonatomic, copy) NSString *user_num;  //用户编号
     @property (nonatomic, copy) NSString *type;      //开门类型
     @property (nonatomic, assign) NSTimeInterval timeInterval;      //时间戳
     @property (nonatomic, copy) NSString *time;*/
    return [NSString stringWithFormat:@"[1.timeInterval:%f  2.user_num:%@  2.type:%@  4.  4.time:%@]",self.timeInterval,self.user_num,self.type,self.time];
}
@end
