//
//  KDSAppSettingsVC.h
//  KDSToolkit
//
//  Created by Apple on 2021/4/22.
//

#import <UIKit/UIKit.h>
#import <XLForm/XLForm.h>
NS_ASSUME_NONNULL_BEGIN

@interface KDSAppSettingsVC : XLFormViewController

@property (nonatomic,copy) dispatch_block_t backBlock;


@end

NS_ASSUME_NONNULL_END
