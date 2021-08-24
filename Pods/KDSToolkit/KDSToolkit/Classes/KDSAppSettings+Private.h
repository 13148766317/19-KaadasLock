//
//  KDSAppSettings+Private.h
//  KDSToolkit
//
//  Created by Apple on 2021/4/22.
//

#import <KDSToolkit/KDSToolkit.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSAppSettings (Private)

//保存更改
-(void) save;

//返回设置UI单元格JSON数组
-(NSArray *) settingRows;

//批量更新键值
-(void) updateSettingValues:(NSDictionary
                             *) settingValues;


@end

NS_ASSUME_NONNULL_END
