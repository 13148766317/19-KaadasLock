//
//  KDSGWNetSetting.m
//  KaadasLock
//
//  Created by orange on 2019/4/15.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWNetSetting.h"

@implementation KDSGWNetSetting

/*///固件版本号。
 @property (nonatomic, strong) NSString *SW;
 ///局域网IP。
 @property (nonatomic, strong) NSString *lanIp;
 ///局域网子网掩码。
 @property (nonatomic, strong) NSString *lanNetmask;
 ///广域网IP。
 @property (nonatomic, strong) NSString *wanIp;
 ///广域网子网掩码。
 @property (nonatomic, strong) NSString *wanNetmask;
 ///广域网接入方式。
 @property (nonatomic, strong) NSString *wanType;
*/
- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"gateway settings, software ver:%@, lan ip:%@, lan net mask:%@, wan ip:%@, wan net mask:%@, wan type:%@", self.SW, self.lanIp, self.lanNetmask, self.wanIp, self.wanNetmask, self.wanType];
}

@end
