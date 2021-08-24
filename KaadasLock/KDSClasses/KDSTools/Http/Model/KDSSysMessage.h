//
//  KDSSysMessage.h
//  xiaokaizhineng
//
//  Created by orange on 2019/3/7.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///系统消息。
@interface KDSSysMessage : NSObject <NSCoding>

///id
@property (nonatomic, strong) NSString *_id;
///消息类型。1系统消息，2用户授权消息，3网关授权消息。
@property (nonatomic, assign) int type;
///消息标签。
@property (nonatomic, strong) NSString *title;
///消息内容。
@property (nonatomic, strong) NSString *content;
///创建时间，距70年的本地时间秒数。
@property (nonatomic, assign) NSTimeInterval createTime;
///本地添加的属性，标记该消息是否已被用户删除。用于用户删除操作但网络请求失败时存储在本地，判断是否要显示该消息的依据。
@property (nonatomic, assign) BOOL deleted;

@end

NS_ASSUME_NONNULL_END
