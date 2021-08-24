
//
//  CatSetModel.m
//  lock
//
//  Created by zhaowz on 2017/6/19.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import "CateyeSetModel.h"

@implementation CateyeSetModel

- (instancetype)initWithName:(NSString *)titleName andValue:(NSString *)value{
    if (self = [super init]) {
        _titleName = titleName;
        _value = value;
    }
    return self;
}
+ (instancetype)setWithName:(NSString *)titleName andValue:(NSString *)value{
    return [[self alloc]initWithName:titleName andValue:value];
}
@end
