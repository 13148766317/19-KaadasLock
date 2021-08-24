//
//  PirUpdateTipView.h
//  lock
//
//  Created by wzr on 2019/4/18.
//  Copyright © 2019 zhao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol PirUpdateTipViewDelegate <NSObject>
- (void)clickCloseBtn;
@end
@interface PirUpdateTipView : UIView
@property (weak, nonatomic) IBOutlet UILabel *tipLab;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (nonatomic, weak) id <PirUpdateTipViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
