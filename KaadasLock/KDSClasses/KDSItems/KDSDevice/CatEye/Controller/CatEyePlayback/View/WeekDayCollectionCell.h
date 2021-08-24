//
//  WeekDayCollectionCell.h
//  KaadasLock
//
//  Created by zhaona on 2019/4/16.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface WeekDayCollectionCell : UICollectionViewCell
@property (nonatomic,strong)UILabel *weekDayLbl;
@property (nonatomic,strong)UILabel *dayLbl;

@property (nonatomic,copy,class,readonly)NSString *ID;
@end


