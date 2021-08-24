//
//  FTPDownLoadManager.m
//  lock
//
//  Created by wzr on 2018/8/17.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import "FTPDownLoadManager.h"
#import "KDSFTIndicator.h"


#define PATHDOCUMNT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]


@implementation FTPDownLoadManager

//全局变量
static id _instance = nil;
//单例方法
+(instancetype)sharedSingleton{
    return [[self alloc] init];
    
}
////alloc会调用allocWithZone:
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    //只进行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
        
    });
    return _instance;
    
}
//初始化方法
- (instancetype)init{
    // 只进行一次
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super init];
    });
    return _instance;
    
}

-(void)dealWithPIRData:(NSDictionary *)dict{
    [KDSFTIndicator showNotificationWithTitle:Localized(@"注意") message:Localized(@"快照报警了") tapHandler:^{
    }];
    NSArray * AlarmArray = [[NSArray alloc] initWithArray:[KDSUserDefaults objectForKey:@"PhotoAlarmArray"]];
    NSMutableArray * array = [[NSMutableArray alloc] initWithArray:AlarmArray];
    NSString * str = [[[[dict objectForKey:@"eventparams"] objectForKey:@"devinfo"] objectForKey:@"params"] objectForKey:@"url"];
    NSString *pictureStr = [str substringWithRange:NSMakeRange(15,str.length-15)];
    [array addObject:pictureStr];
    [KDSUserDefaults setObject:array forKey:@"PhotoAlarmArray"];
}


//copy在底层 会调用copyWithZone:
- (id)copyWithZone:(NSZone *)zone{
    return _instance;
    
}
+ (id)copyWithZone:(struct _NSZone *)zone{
    return _instance;
    
}
+ (id)mutableCopyWithZone:(struct _NSZone *)zone{
    return _instance;
    
}
- (id)mutableCopyWithZone:(NSZone *)zone{
    return _instance;
    
}

@end
