//
//  KDSBindingGatewayCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/8.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSBindingGatewayCell : UITableViewCell

//@property (nonatomic,strong) id model;
///图标
@property (nonatomic,strong)UIImageView * gateWayIconImg;
///Interface
@property (nonatomic,strong)UILabel * titleLabel;
///管理员
@property (nonatomic,strong)UILabel * AdministratorsLabel;
///ID
@property (nonatomic,strong)UILabel * gateWayID;
///右侧的小图标对号
@property (nonatomic,strong)UIButton * rightIconBtn;
///显示：授权网关
@property (nonatomic,strong)UILabel * authMemGwLb;
///表示网关状态的图标
@property(nonatomic,strong)UIImageView * gateWayStatusImg;
///表示网关状态的文字说明
@property(nonatomic,strong)UILabel * gateWayStatusLb;


@end

NS_ASSUME_NONNULL_END
