//
//  KDSSysMsgDetailsCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/2.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSSysMsgDetailsCell : UITableViewCell

///日期，yyyy/MM/dd HH:mm。
@property (nonatomic, strong) NSString *date;
///标题。
@property (nonatomic, strong) NSString *title;
///内容。
@property (nonatomic, strong) NSString *content;

@end

NS_ASSUME_NONNULL_END
