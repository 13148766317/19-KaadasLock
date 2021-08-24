//
//  KDSGW.m
//  KaadasLock
//
//  Created by orange on 2019/7/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSGW.h"
#import "KDSHttpManager.h"

@implementation KDSGW

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:GatewayModel.class])
    {
        return [self.model isEqual:object];
    }
    else if ([object isKindOfClass:KDSGW.class])
    {
        return self.model && [((KDSGW *)object).model isEqual:self.model];
    }
    return NO;
}

- (NSUInteger)hash
{
    return self.model.hash;
}

- (BOOL)networkAvailable
{
    if (_networkAvailable) return _networkAvailable;
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    return status==AFNetworkReachabilityStatusReachableViaWiFi || status==AFNetworkReachabilityStatusReachableViaWWAN;
}

- (BOOL)online
{
    return self.networkAvailable && [self.state isEqualToString:@"online"];
}

@end
