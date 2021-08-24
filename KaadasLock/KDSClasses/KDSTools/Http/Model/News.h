//
//  News.h
//  kaadas
//
//  Created by ise on 16/10/8.
//  Copyright © 2016年 ise. All rights reserved.
//
/*************************************************************************
 * 公       司： 深圳市高金科技有限公司
 * 作       者： 深圳市高金科技有限公司	king
 * 文件名称：News
 * 内容摘要：门锁记录消息模型
 * 日        期： 2016/11/30
 ************************************************************************/
#import <Foundation/Foundation.h>

@interface News : NSObject

@property (nonatomic, strong) NSString *open_type;      //开门类型
@property (nonatomic, strong) NSString *lockNickName;
@property (nonatomic, strong) NSString *lockName;
@property (nonatomic, strong) NSString *uname;          //用户姓名(APP开门使用）
@property (nonatomic, strong) NSString *open_purview;
///服务器返回的格式yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSString *open_time;
///昵称。
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *cid;
@property (nonatomic, strong) NSString *user_num;       


@end
