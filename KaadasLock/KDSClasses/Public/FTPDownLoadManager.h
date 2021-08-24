//
//  FTPDownLoadManager.h
//  lock
//
//  Created by wzr on 2018/8/17.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTPDownLoadManager : NSObject
//单例方法
+(instancetype)sharedSingleton;
//处理pir触发返回数据
-(void)dealWithPIRData:(NSDictionary *)dict;

@end
