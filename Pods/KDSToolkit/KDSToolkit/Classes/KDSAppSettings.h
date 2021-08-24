//
//  KDSAppSettings.h
//  KDSToolkit
//
//  Created by Apple on 2021/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KDSAppSettings : NSObject

#pragma mark - 初始化配置文件与解密数据密码
//初始化配置文件与解密数据密码，密码需为16个字符
+ (void) setConfigFilePath:(NSString *) filePath passwd:(NSString *) passwd;
+ (instancetype)sharedInstance;
//使用指定配置名称
-(void) applySettingValuesWithName:(NSString *) name;

#pragma mark - 获取设置配置键值
//获取Server配置中的键值
-(id) serverObjectForKey:(NSString *) key;

//获取settingValues中的键值
-(id) settingObjectForKey:(NSString *) key;

//设置值到settingValues中
-(void) setSettingObject:(id) object forKey:(NSString *) key;

//删除settingValues的键值
-(void) removeSettingObjectForKey:(NSString *) key;

#pragma mark - 加解密文件
//加密文件，密码需为16个字符
+(NSString *) genEncryptConfigFilePath:(NSString *) filePath passwd:(NSString *) passwd;
//解密base64字符串为json 数组或字典
+(id) decryptJSONObjectWithBase64:(NSString *) base64Str  passwd:(NSString *) passwd;
//加密数组或字典为base64字符串
+(NSString *) base64EncryptJSONObject:(id) object  passwd:(NSString *) passwd;
@end

NS_ASSUME_NONNULL_END
