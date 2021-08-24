//
//  KDSGWLockKeyInfo.m
//  KaadasLock
//
//  Created by orange on 2019/4/16.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSGWLockKeyInfo.h"

@implementation KDSGWLockKeyInfo

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"maxpwdusernum:%ld, maxrfidusernum:%ld, maxusernum:%ld, maxpwdsize:%ld, minpwdsize:%ld, maxrfidsize:%ld, minrfidsize:%ld", self.maxpwdusernum, self.maxrfidusernum, self.maxusernum, self.maxpwdsize, self.minpwdsize, self.maxrfidsize, self.minrfidsize];
}

@end
