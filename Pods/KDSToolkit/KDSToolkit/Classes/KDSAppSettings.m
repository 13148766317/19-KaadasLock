//
//  KDSAppSettings.m
//  KDSToolkit
//
//  Created by Apple on 2021/4/22.
//

#import "KDSAppSettings.h"
#import "KDSAppSettings+Private.h"
#import "NSData+KDSEncrypt.h"
#define kProtocolVer  @"protocolVer"
#define kDataVer @"dataVer"
#define kEncrypted @"encrypted"
#define kEncryptedData @"encryptedData"
#define kData @"data"
#define kDataServer @"server"
#define kDataSettingValues @"settingValues"
#define kDataSettingRows   @"settingRows"


static NSString *KDSAppSettings_configFilePath;
static NSString *KDSAppSettings_configFilePathPasswd;


@interface KDSAppSettings ()

@property (nonatomic,strong) NSMutableDictionary *settings;
//@property (nonatomic,strong) NSMutableDictionary *settingValues;
@property(nonatomic, strong) NSString  *settingValuesName;
@end
@implementation KDSAppSettings


+ (void) setConfigFilePath:(NSString *) filePath passwd:(NSString *) passwd {
    
    KDSAppSettings_configFilePath = filePath;
    KDSAppSettings_configFilePathPasswd = passwd;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static KDSAppSettings *appSettingsInstance = nil;
    dispatch_once(&onceToken, ^{
        appSettingsInstance = [[KDSAppSettings alloc] init];
    });
    return appSettingsInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self loadSetting];
    }
    return self;
}

//加载设置
-(void) loadSetting {
    //首先检查用户目录下有否有最新配置，没有获取应用打包的配置
    NSMutableDictionary *dict;
    if ([[NSFileManager
          defaultManager] fileExistsAtPath:[KDSAppSettings userFilePath]]) {
        dict = [KDSAppSettings loadConfigFile:[KDSAppSettings
                                               userFilePath]];
        
        //检查版本
        NSMutableDictionary *appDict = [KDSAppSettings loadConfigFile:[KDSAppSettings
                                                  bundleFilePath]];
        NSString *appVer = appDict[kDataVer];
        NSString *userVer = dict[kDataVer];
        //todo 检查协议版本，是否需要清理当前数据，重新生成
        if ([appVer integerValue] > [userVer integerValue]) {
            dict = appDict;
        }
        //todo 解码加密数据
        
    }else {
        dict = [KDSAppSettings loadConfigFile:[KDSAppSettings
                                               bundleFilePath]];
    }
    
    if([dict[kEncrypted] boolValue]) {
        //进行解密，重新赋值
        dict[kData] = [KDSAppSettings decryptJSONObjectWithBase64:dict[kEncryptedData] passwd:KDSAppSettings_configFilePathPasswd];
        [dict removeObjectForKey:kEncryptedData];
    }
    
    self.settings = dict;

}


//使用指定配置名称
-(void) applySettingValuesWithName:(NSString *) name {
    self.settingValuesName = name;
}

//返回设置UI单元格JSON数组
-(NSArray *) settingRows{
    return self.settings[kData][kDataSettingRows];
}

-(NSMutableDictionary *) settingValues{
   
    NSMutableDictionary *settingValuesObject = [[self.settings objectForKey:kData] objectForKey:kDataSettingValues];
    
    if (self.settingValuesName) {
        return [settingValuesObject objectForKey:self.settingValuesName];
    }else {
        return nil;
    }
}



//-(NSMutableDictionary *) currentSettingValues {
//
//    return self.settings[kData][kDataSettingValues][self.settingValuesName];
//}

#pragma mark - server

//获取Server配置中的键值
-(id) serverObjectForKey:(NSString *) key {
    //获取server设置
    //获取server.xxx字典
    //获取server.xxx字典key键值
    if (!key) {
        return nil;
    }

    NSString *serverName = [self settingObjectForKey:KDSToolKitSettingServer];
    if (!serverName) {
        return nil;
    }
    
    
    NSMutableDictionary *serverDict = [self.settings[kData][kDataServer]  objectForKey:serverName];
    

    if (!serverDict) {
        return nil;
    }
    
    return [serverDict objectForKey:key];
}

#pragma mark - settingValues

//获取settingValues中的键值
-(id) settingObjectForKey:(NSString *) key {
    if (!key) {
        return nil;
    }else {
        return [[self settingValues] objectForKey:key];
    }
}
-(void) setSettingObject:(id) object forKey:(NSString *) key {
    [[self settingValues] setObject:object forKey:key];
    [self save];
}
-(void) removeSettingObjectForKey:(NSString *) key {
    [[self settingValues] removeObjectForKey:key];
    [self save];
}

#pragma mark - private method
-(void) save {
    
    //todo save settingValues
    NSError *error;
    
    NSMutableDictionary *saveDict = [[NSMutableDictionary alloc] initWithDictionary:self.settings];
    if ([saveDict[kEncrypted] boolValue]) {
        saveDict[kEncryptedData] = [KDSAppSettings base64EncryptJSONObject:saveDict[kData] passwd:KDSAppSettings_configFilePathPasswd];
        [saveDict removeObjectForKey:kData];
    }

    NSData *data =[NSJSONSerialization dataWithJSONObject:saveDict options:0 error:&error
                   ];
    if (!error) {
        [data writeToFile:[KDSAppSettings userFilePath] atomically:YES];
    }else {
        NSLog(@"%@", [error description]);
    }
}

//批量更新键值
-(void) updateSettingValues:(NSMutableDictionary
                             *) settingValues {
    if (settingValues) {
        __weak __typeof(self)weakSelf = self;
        [settingValues enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [[weakSelf settingValues] setObject:obj forKey:key];
        }];
        //[self.settingValues addEntriesFromDictionary:settingValues];
        [self save];
    }
    
}

#pragma mark - file load
//加载bundle file
+(NSMutableDictionary *) loadConfigFile:(NSString *) filePath {
    
    NSError *error;
    
    NSMutableDictionary *result;
    if (filePath && [[NSFileManager defaultManager] fileExistsAtPath:filePath] ) {
        
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        
        id jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
        
        if (!error) {
            
            result = jsonDict;
        }else {
            NSLog(@"%@", [error description]);
        }
    }
    return result;
}

+(NSString *) userFilePath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"AppConfig.dat"];
}
+(NSString *) bundleFilePath {
    return KDSAppSettings_configFilePath ? : nil;
    //return  [[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"json"];
}

#pragma mark - 加解密文件与JSON对象
//加密配置文件
+(NSString *) genEncryptConfigFilePath:(NSString *) filePath passwd:(NSString *) passwd {
    NSMutableDictionary *srcDict = [KDSAppSettings
                                    loadConfigFile:filePath];
    
    //1. a = dict[data] -> json string -> aes baseb4
    //获取
    NSError *error;
    NSMutableDictionary *dataDict = [srcDict objectForKey:kData];
    
    //加密
    NSString *base64Data = [KDSAppSettings base64EncryptJSONObject:dataDict passwd:passwd];
    
    
    //set
    if(base64Data) {
        srcDict[kEncrypted] = @(1);
        
        srcDict[kEncryptedData] = base64Data;
        //[srcDict removeObjectForKey:kData];
    }
    
    
    NSData *lastData = [NSJSONSerialization dataWithJSONObject:srcDict options:NSJSONWritingPrettyPrinted error:&error];
    
    if (error) {
        NSLog(@"%@", [error description]);
    }
    
    return [lastData kds_UTF8String];
    
}

//解密base64字符串为json 数组或字典
+(id) decryptJSONObjectWithBase64:(NSString *) ciphertext  passwd:(NSString *) passwd {
    id result = nil;
    if (passwd && ciphertext) {
        NSData *cipherData = [[NSData alloc] initWithBase64EncodedData:[ciphertext dataUsingEncoding:NSUTF8StringEncoding] options:NSDataBase64DecodingIgnoreUnknownCharacters];
        if (cipherData) {
            NSData *resultData = [cipherData kds_decryptedWithAESUsingKey:passwd andIV:nil];
            NSError *error;
            if (resultData) {
                
                result = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableContainers error:&error];
                if (error) {
                    NSLog(@"%@",[error
                                 description]);
                }
                
            }else {
                
            }
        }

    }
    NSLog(@"decryptJSONObjectWithBase64");
    NSLog(@"ciphertext:%@",ciphertext);
    NSLog(@"object:%@",result);

    return result;
}


//加密数组或字典为base64字符串
+(NSString *) base64EncryptJSONObject:(id) object  passwd:(NSString *) passwd {
    NSString *result;
    if (object && passwd) {
        NSError *error;
        NSData *srcData = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
        NSData *encryptData;
        if (!error) {
            encryptData = [srcData kds_encryptedWithAESUsingKey:passwd andIV:nil];
            NSData *base64Data = [encryptData base64EncodedDataWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
            result = [base64Data kds_UTF8String];
        }
    }
    NSLog(@"base64EncryptJSONObject");
    NSLog(@"object:%@",object);
    NSLog(@"base64:%@",result);
    return result;
}
@end
