//
//  KDSSystemMsgDetailsVC.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/2.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSTableViewController.h"
#import "KDSSysMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSSystemMsgDetailsVC : KDSTableViewController


///要展示的消息。@property (nonatomic, copy) NSArray<KDSSysMsgDetailsModel *> *messages;
///要展示的消息。
@property (nonatomic, copy) KDSSysMessage *messages;

@end

NS_ASSUME_NONNULL_END
