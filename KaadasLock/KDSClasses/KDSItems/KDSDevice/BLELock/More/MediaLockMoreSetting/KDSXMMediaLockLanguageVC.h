//
//  KDSXMMediaLockLanguageVC.h
//  KaadasLock
//
//  Created by zhaoxueping on 2020/10/27.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSAutoConnectViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSXMMediaLockLanguageVC : KDSAutoConnectViewController

///锁当前语言。可以是Localized(@"languageChinese")或"zh"，Localized(@"languageEnglish")或"en"。
@property (nonatomic, strong) NSString *language;
///锁当前语言修改成功后执行的回调，回调参数为已本地化的语言。
@property (nonatomic, copy) void(^lockLanguageDidAlterBlock) (NSString *newLanguage);

@end

NS_ASSUME_NONNULL_END
