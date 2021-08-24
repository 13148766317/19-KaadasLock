//
//  CatSetModel.h
//  lock
//
//  Created by zhaowz on 2017/6/19.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CateyeSetModel : NSObject
@property (nonatomic, copy) NSString *titleName;    //标题
@property (nonatomic, copy) NSString *value;        //对应的值

- (instancetype)initWithName:(NSString *)titleName andValue:(NSString *)value;
+ (instancetype)setWithName:(NSString *)titleName andValue:(NSString *)value;
@end
