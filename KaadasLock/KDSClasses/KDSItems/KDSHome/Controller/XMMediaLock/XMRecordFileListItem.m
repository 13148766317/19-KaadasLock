//
//  XMRecordFileListItem.m
//  XMDemo
//
//  Created by xunmei on 2020/9/2.
//  Copyright © 2020 TixXie. All rights reserved.
//

#import "XMRecordFileListItem.h"

@implementation XMRecordFileListItem

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forKey:(NSString *)key{
    if([key isEqualToString:@"recordfilelist"]){
        NSArray *list = value;
        NSMutableArray *newList = [NSMutableArray arrayWithCapacity:list.count];
        for (NSDictionary *dic in list) {
            XMRecordFileItem *item = [[XMRecordFileItem alloc] initWithDictionary:dic];
            [newList addObject:item];
        }
        value = newList;
    }
    [super setValue:value forKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"value:%@ undefineKey:%@",value,key);
}

@end

@implementation XMRecordFileItem

- (instancetype)initWithDictionary:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{
    NSLog(@"value:%@ undefineKey:%@",value,key);
}

@end
