//
//  KDSHttpManager.m
//  xiaokaizhineng
//  Created by orange on 2019/1/21.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
#import "KDSHttpManager.h"
#import "KDSHttpManager+User.h"
NSString *const KDSHttpTokenExpiredNotification = @"KDSHttpTokenExpiredNotification";
@interface KDSHttpManager ()
@property (nonatomic, strong) NSDictionary *headerDic;
@end

@implementation KDSHttpManager

+ (instancetype)sharedManager
{
    static KDSHttpManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[KDSHttpManager alloc] init];
    });
    return _manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if (_afManager == nil) {
            _afManager = [AFHTTPSessionManager manager];
            _afManager.requestSerializer = [AFJSONRequestSerializer serializer];
            //设置返回格式
            _afManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"text/plain", @"image/jpeg", @"image/png", @"image/jpg", nil];
            [_afManager.requestSerializer setValue:[KDSTool getIphoneType] forHTTPHeaderField:@"phoneName"];
//            _afManager.securityPolicy = [self customSecurityPolicy];
            //是否允许无效证书
            _afManager.securityPolicy.allowInvalidCertificates = NO;
            //是否需要验证域名
            _afManager.securityPolicy.validatesDomainName = NO;
            //关闭缓存避免干扰测试
            _afManager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
            //超时时间
            [_afManager.requestSerializer setTimeoutInterval:20.f];

            // 初始化头部的信息
            _headerDic = @{ @"version": @"1", @"timestamp": [self getNowTimeTimestamp] };
        }
    }
    return self;
}

- (void)createResErrorWithCode:(NSInteger)code {
    NSString *domain = @"请求返回错误";
    NSString *desc = [KDSHttpResOption httpResponseLocalizeWithCode:code];
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: desc };
    self.resError = [NSError errorWithDomain:domain
                                        code:code
                                    userInfo:userInfo];
    NSLog(@"--{Kaadas}--error333=%@", self.resError);
}

- (void)setToken:(NSString *)token
{
    _token = token;
    if (token) {
        [self.afManager.requestSerializer setValue:token forHTTPHeaderField:@"token"];
    }
}

- (AFSecurityPolicy *)customSecurityPolicy {
    //先导入证书
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"server" ofType:@"p12"];
    //证书的路径
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    // AFSSLPinningModeNone 使用证书验证模式
    //这个模式表示不做SSL pinning，
    //只跟浏览器一样在系统的信任机构列表里验证服务端返回的证书。若证书是信任机构签发的就会通过，若是自己服务器生成的证书就不会通过。
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    NSSet *certificateSet = [[NSSet alloc] initWithObjects:certData, nil];
    [securityPolicy setPinnedCertificates:certificateSet];
    //validatesDomainName 是否需要验证域名，默认为YES；
    securityPolicy.validatesDomainName = YES;     // 关键语句1
    //假如证书的域名与你请求的域名不一致，需把该项设置为NO；如设成NO的话，即服务器使用其他可信任机构颁发的证书，也可以建立连接，这个非常危险，建议打开。
    //置为NO，主要用于这种情况：客户端请求的是子域名，而证书上的是另外一个域名。因为SSL证书上的域名是独立的，假如证书上注册的域名是www.google.com，那么mail.google.com是无法验证通过的；当然，有钱可以注册通配符的域名*.google.com，但这个还是比较贵的。
    //如置为NO，建议自己添加对应域名的校验逻辑。
//    securityPolicy.validatesDomainName = NO; // 关键语句1
    // allowInvalidCertificates 是否允许无效证书（也就是自建的证书），默认为NO
    securityPolicy.allowInvalidCertificates = NO;     // 关键语句2
    // 如果是需要验证自建证书，需要设置为YES
//    securityPolicy.allowInvalidCertificates = YES; // 关键语句2
    return securityPolicy;
}

- (NSMutableDictionary *)filteredDictionaryWithDictionary:(NSDictionary *)dictionary
{
    if (![dictionary isKindOfClass:NSDictionary.class]) return [NSMutableDictionary dictionary];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:dictionary];
    for (NSString *key in dict.allKeys) {
        if ([dict[key] isKindOfClass:NSNull.class]) dict[key] = nil;
    }
    return dict;
}

- (NSURLSessionDataTask *)GET:(NSString *)URLString parameters:(id)parameters success:(void (^)(id _Nullable))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSURLSessionDataTask *_Nullable, NSError *_Nonnull))failure
{
    
#pragma mark  新增加密方案
    /*无token的加密接口 */
    BOOL    ISDataAES = YES;  // 默认值是加密的
    NSString *completeAES;
    NSString *StrJson;
    if ([URLString isEqualToString:@"user/reg/putuserbytel"] ||
        [URLString isEqualToString:@"user/reg/putuserbyemail"]  ||
        [URLString isEqualToString:@"user/login/getuserbytel"]  ||
        [URLString isEqualToString:@"user/login/getuserbymail"]  ||
        [URLString isEqualToString:@"user/edit/forgetPwd"]  ||
        [URLString isEqualToString:@"sms/sendSmsTokenByTX"] ||
        [URLString isEqualToString:@"mail/sendemailtoken"] ||
        [URLString containsString:@"api/deviceDevupRecord/bt/add"]
        ) {  //无 token的接口
        _headerDic = @{ @"version": @"1", @"timestamp": [self getNowTimeTimestamp] };
        // json 字符串
        StrJson = [[KDSUserManager sharedManager] convertToJsonData:parameters];
        NSLog(@"zhu 字典转化成字符串==%@", StrJson);
        NSString *key =     [self  jiamijosnStr];
        completeAES = [NSData AES128Encrypt99:StrJson key:key];
    }  else if ( //  无header 和 无加密的接口  get  
                 [URLString  containsString:@"FAQ/list/"]  ||
                 [URLString  containsString:@"user/protocol/version/select"]  ||
                 [URLString  containsString:@"user/edit/showfileonline"] ||
                 [URLString  containsString:@"cfg/SoftMgr/app.json"]
                ){
         _headerDic  = nil;
         ISDataAES  = NO;
    }else { // 有token的加密接口
        _headerDic = @{ @"version": @"1", @"timestamp": [self getNowTimeTimestamp] };
        StrJson = [[KDSUserManager sharedManager] convertToJsonData:parameters];
        NSLog(@"zhu 字典转化成字符串==%@", StrJson);
        if (self.token) {
            NSString *key =     [self  callBackKey];
            completeAES = [NSData AES128Encrypt99:StrJson key:key];
        }
    }
    if (![NSURL URLWithString:URLString].scheme) {
        URLString = [[[KDSAppSettings sharedInstance] serverObjectForKey:KDSToolKitConfigHttpServer]   stringByAppendingString:URLString];
    }
    if (![NSURL URLWithString:URLString]) {
        URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    //获取当前的时间戳
    NSLog(@"zhu 输出get请求 请求参数中字典的数据==%@", parameters);
    return [self.afManager GET:URLString parameters: ISDataAES ? completeAES: parameters headers:_headerDic progress:nil success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        [self parseObject:responseObject success:^(id _Nullable data) {
            !success ? : success(data);
        } error:^(NSError *error) {
            !errorBlock ? : errorBlock(error);
        }];
    } failure:failure];
}
- (NSURLSessionDataTask *)POST:(NSString *)URLString parameters:(id)parameters success:(void (^)(id _Nullable))success error:(void (^)(NSError *_Nonnull))errorBlock failure:(void (^)(NSURLSessionDataTask *_Nullable, NSError *_Nonnull))failure
{
    KDSLog(@"--{Kaadas}--%@ parameters=%@", URLString, parameters);
#pragma  mark    
    BOOL    ISDataAES = YES;  // 默认值是加密的
    // 对接口进行判断
    NSString *completeAES;
    NSString *StrJson;
    if ([URLString isEqualToString:@"user/reg/putuserbytel"] ||
        [URLString isEqualToString:@"user/reg/putuserbyemail"]  ||
        [URLString isEqualToString:@"user/login/getuserbytel"]  ||
        [URLString isEqualToString:@"user/login/getuserbymail"]  ||
        [URLString isEqualToString:@"user/edit/forgetPwd"]  ||
        [URLString isEqualToString:@"sms/sendSmsTokenByTX"] ||
        [URLString isEqualToString:@"mail/sendemailtoken"] ||
        [URLString containsString:@"api/deviceDevupRecord/bt/add"]
        ) {  // 无token的接口
        _headerDic = @{ @"version": @"1", @"timestamp": [self getNowTimeTimestamp] };
        // json 字符串
        StrJson = [[KDSUserManager sharedManager] convertToJsonData:parameters];
        NSLog(@"zhu 字典转化成字符串==%@", StrJson);
        NSString *key =     [self  jiamijosnStr];
        completeAES = [NSData AES128Encrypt99:StrJson key:key];
    } else if ([URLString  isEqualToString:@"/user/logout"] ||
               [URLString  isEqualToString:@"user/protocol/version/select"] ||
               [URLString  isEqualToString:@"user/edit/uploaduserhead"] ||
               [URLString  isEqualToString:@"user/edit/showfileonline"] ||
               [URLString  isEqualToString:@"FAQ/list/"]
                 ){
        _headerDic = nil;
        ISDataAES = NO;
    }else { // 有token
        _headerDic = @{ @"version": @"1", @"timestamp": [self getNowTimeTimestamp] };
        StrJson = [[KDSUserManager sharedManager] convertToJsonData:parameters];
        NSLog(@"zhu 字典转化成字符串==%@", StrJson);
        if (self.token) {
            NSString *key =     [self  callBackKey];
            completeAES = [NSData AES128Encrypt99:StrJson key:key];
        }
    }
    if (![NSURL URLWithString:URLString].scheme) {
        URLString = [[[KDSAppSettings sharedInstance] serverObjectForKey:KDSToolKitConfigHttpServer] stringByAppendingString:URLString];
    }
    if (![NSURL URLWithString:URLString]) {
        URLString = [URLString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    // 添加一个变量 是否加密的变量
    return [self.afManager POST:URLString parameters: ISDataAES ? completeAES : parameters headers:_headerDic progress:nil success:^(NSURLSessionDataTask *_Nonnull task, id _Nullable responseObject) {
        [self parseObject:responseObject success:^(id _Nullable data) {
            NSLog(@"--{Kaadas}--URLString=%@ result=%@", URLString, data);
            !success ? : success(data);
        } error:^(NSError *error) {
            NSLog(@"--{Kaadas}--error111=%@", error);
            if (error) {
                NSLog(@"--{Kaadas}--error222=%ld", (long)error.code);
                [self createResErrorWithCode:error.code];
                NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:self.resError.userInfo];
                for (NSString *key in error.userInfo.allKeys) {
                    info[key] = error.userInfo[key];
                }
                error = [NSError errorWithDomain:self.resError.domain code:self.resError.code userInfo:info];
                !errorBlock ? : errorBlock(error);
            }
        }];
    } failure:failure];
}
/**
 *@abstract 从服务器返回的解析完毕的字典中提取code、data和msg字段。
 *@param obj 解析对象。
 *@param success 成功回调，参数是data字段，如果没有也可能为空。
 *@param error 失败回调。
 */
- (void)parseObject:(NSDictionary *)obj success:(nullable void (^)(id _Nullable data))success error:(void (^)(NSError *error))error
{
    NSLog(@"--{Kaadas}--解析对象obj=%@", obj);

    if (![obj isKindOfClass:[NSDictionary class]]) {
        error([NSError errorWithDomain:@"返回值不正确" code:(NSInteger)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
        return;
    }
    NSInteger code = [obj[@"code"] isKindOfClass:NSString.class] ? [obj[@"code"] intValue] : (NSInteger)KDSHttpErrorReturnValueIncorrect;
    ![obj[@"nowTime"] isKindOfClass:NSNumber.class] ? : (void)(_serverTime = [obj[@"nowTime"] doubleValue]);
    if (code == 200) { // 只有code为200的时候才会返回数据
        success(obj[@"data"]);

//      ",_serverTime);
    }else if (code == 444) {//failure的状态码401也表示token过期。
//        error([NSError errorWithDomain:[obj[@"msg"] isKindOfClass:NSString.class] ? obj[@"msg"] : @"token过期" code:code userInfo:nil]);
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSHttpTokenExpiredNotification object:nil];
    } else {
        error([NSError errorWithDomain:[obj[@"msg"] isKindOfClass:NSString.class] ? obj[@"msg"] : @"未知错误" code:code userInfo:obj]);
    }
}



//获取当前时间戳有两种方法(以秒为单位)
- (NSString *)getNowTimeTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    [formatter setDateStyle:NSDateFormatterMediumStyle];

    [formatter setTimeStyle:NSDateFormatterShortStyle];

    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制

//设置时区,这个对于时间的处理有时很重要

    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];

    [formatter setTimeZone:timeZone];

    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式

    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];

    return timeSp;
}
// 带有token的数据格式
- (NSString *)callBackKey {
    NSLog(@"调用了有token加密的方式");
    //  NSString  * token  =  @"fdfwt34toio242242grew";
    //特定的字符串
    NSString *ASDstr = @"3a79fee83a79fbc3";
    NSString *subTimeTemp = [[KDSUserManager sharedManager] getNowTimeTimestamp];
    // 密码的形成 密码规则为(特定字符串1-4位) + (token倒数3-4位) + (时间戳倒数3-4位) + (特定字符串5-8位) + (token倒数1-2位) + (时间戳倒数1-2位)。
    //特定字符串的1-4位
    NSString *specificStronetofour = [ASDstr substringToIndex:4];
    NSLog(@"zhu 特定字符串的1-4位=%@", specificStronetofour);
    // token 倒数3-4位
    NSLog(@"zhu当前类的token为 ==%@", self.token);
    NSString *tokentheretofour = [self.token substringWithRange:NSMakeRange(self.token.length - 4, 2)];
    NSLog(@"zhu token 倒数3-4位=%@", tokentheretofour);
    //时间戳3-4 位
    NSString *timetemptheretofour = [subTimeTemp substringWithRange:NSMakeRange(subTimeTemp.length - 4, 2)];
    NSLog(@"zhu 时间戳3-4 位=%@", timetemptheretofour);
    // 特定的字符串5-8
    NSString *specificStrfivetoeight = [ASDstr substringWithRange:NSMakeRange(4, 4)];
    NSLog(@"zhu 特定的字符串5-8=%@", specificStrfivetoeight);
    // token 倒数1-2位
    NSString *tokenonetotwo = [self.token substringWithRange:NSMakeRange(self.token.length - 2, 2)];
    NSLog(@"zhu token 倒数1-2位=%@", tokenonetotwo);
    //时间戳的倒数1-2位
    NSString *timetemponetotwo = [subTimeTemp substringWithRange:NSMakeRange(subTimeTemp.length - 2, 2)];
    NSLog(@"zhu 时间戳的倒数1-2位=%@", timetemponetotwo);
    NSString *constStr = [NSString stringWithFormat:@"%@%@%@%@%@%@", specificStronetofour, tokentheretofour, timetemptheretofour, specificStrfivetoeight, tokenonetotwo, timetemponetotwo];
    NSLog(@"zhu ==组成的加密数据 ==%@", constStr);
    return constStr;
}

// 加密字符串  没有token 的加密方式
- (NSString *)jiamijosnStr {
    NSLog(@"zhu调用了没有token加密的方式");
    NSString *ASDstr = @"3a79fee83a79fbc3";
    //时间戳后四位
    NSString *subTimeTemp = [[KDSUserManager sharedManager] getNowTimeTimestamp];
    NSLog(@"zhu 时间戳==%@", subTimeTemp);
    // 密码的形成 密码规则为(特定字符串1-5位) + (时间戳倒数4-6位) + (特定字符串6-10位) + (时间戳倒数1-3位)。
    //特定字符串的1-5位
    NSString *specificStronetofive = [ASDstr substringToIndex:5];
    NSLog(@"zhu 特定字符串的1-5位=%@", specificStronetofive);
    // 时间戳倒数4-6位
    NSString *timetemp4to6 = [subTimeTemp substringWithRange:NSMakeRange(subTimeTemp.length - 6, 3)];
    NSLog(@"zhu 时间戳倒数4-6位=%@", timetemp4to6);

    // 特定的字符串6-10
    NSString *specificStrsixtoten = [ASDstr substringWithRange:NSMakeRange(5, 5)];
    NSLog(@"zhu 特定的字符串6-10=%@", specificStrsixtoten);
    //  时间倒数1-3位
    NSString *timetemp1to3 = [subTimeTemp substringWithRange:NSMakeRange(subTimeTemp.length - 3, 3)];
    NSLog(@"zhu 倒数1-3位=%@", timetemp1to3);
    NSString *constStr = [NSString stringWithFormat:@"%@%@%@%@", specificStronetofive, timetemp4to6, specificStrsixtoten, timetemp1to3];
    NSLog(@"zhu ==组成的加密数据 ==%@", constStr);
    return constStr;
}

@end
