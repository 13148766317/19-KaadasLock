//
//  AlarmMessageModel.h
//  lock
//
//  Created by wzr on 2018/8/9.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlarmMessageModel : NSObject<NSCoding>

@property(nonatomic,copy)NSString * timeStr;
@property(nonatomic,copy)UIImage *photoImg;
@property(nonatomic,assign)NSString *h264Str;
@property(nonatomic,assign)NSString *audioStr;
@property(nonatomic,copy)NSString * isChecked;



@end
