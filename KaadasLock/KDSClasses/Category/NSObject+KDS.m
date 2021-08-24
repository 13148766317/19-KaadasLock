//
//  NSObject+KDS.m
//  lock
//
//  Created by zhaowz on 2018/8/3.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "NSObject+KDS.h"
#import <objc/runtime.h>
@implementation NSObject (KDS)
-(NSString*)getDescribeStringOfSelf{
    unsigned int count;
    NSMutableString*str=[[NSMutableString alloc]init];
   NSString *str1=[NSString stringWithFormat:@"%@:[",NSStringFromClass([self class])];
    [str appendString:str1];
    objc_property_t*Propertys =  class_copyPropertyList([self class], &count);
    for (int i =0; i<count; i++) {
        objc_property_t Property =Propertys[i];
        NSString*name=[NSString stringWithUTF8String:property_getName(Property)];
        id value =   [self valueForKey:name];
        [str appendString:[NSString stringWithFormat:@"%@:%@,",name,value]];
        if (i==count-1) {
            [str appendString:@"]\n"];
        }
    }
    NSLog(@"DescribeString:%@",str);
    return str;
}
@end
