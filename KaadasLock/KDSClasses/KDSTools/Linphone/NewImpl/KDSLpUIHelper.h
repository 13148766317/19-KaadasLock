//
//  KDSLpUIHelper.h
//  KaadasLock
//
//  Created by orange on 2019/7/22.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SIPUACTU;

NS_ASSUME_NONNULL_BEGIN
///处理多个通话事件。
@interface KDSLpUIHelper : NSObject

///tus
@property (nonatomic, copy) NSArray<SIPUACTU *> *tus;

@end

NS_ASSUME_NONNULL_END
