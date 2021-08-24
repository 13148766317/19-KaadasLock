//
//  CateyePIRSilenceCell.h
//  lock
//
//  Created by zhaona on 2019/4/23.
//  Copyright © 2019 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CateyeSetModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CateyePIRSilenceCell : UITableViewCell

@property (nonatomic,class,readonly,copy)NSString * ID;
///
@property(nonatomic,readwrite,strong)UITextField * contentTf;
@property (nonatomic, strong) CateyeSetModel *model;

@end

NS_ASSUME_NONNULL_END
