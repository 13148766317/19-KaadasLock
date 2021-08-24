//
//  KDSDuressAlarmHub.h
//  2021-Philips
//
//  Created by dangwanzhen on 2021/5/20.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KDSDuressAlarmHubDelegate <NSObject>

-(void) removeDuressAlarmHub;

@end

@interface KDSDuressAlarmHub : UIView

@property (nonatomic, strong) id<KDSDuressAlarmHubDelegate>duressAlarmHubDelegate;

@end

NS_ASSUME_NONNULL_END
