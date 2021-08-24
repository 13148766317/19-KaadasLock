//
//  KDSHttpManager+User.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/22.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSHttpManager+User.h"
//#import "MJExtension.h"

@implementation KDSHttpManager (User)

- (NSURLSessionDataTask *)getUserNicknameWithUid:(NSString *)uid success:(void (^)(NSString * _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    uid = uid ?: @"";
    return [self POST:@"user/edit/getUsernickname" parameters:@{@"uid": uid} success:^(id  _Nullable responseObject) {
        if (![responseObject isKindOfClass:NSDictionary.class])
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        NSDictionary *obj = (NSDictionary *)responseObject;
        NSString *nickname = [obj[@"nickName"] isKindOfClass:NSString.class] ? obj[@"nickName"] : nil;
        !success ?: success(nickname);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)setUserNickname:(NSString *)nickname withUid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    nickname = nickname ?: @""; uid = uid ?: @"";
    return [self POST:@"user/edit/postUsernickname" parameters:@{@"uid":uid, @"nickname":nickname} success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)getUserAvatarImageWithUid:(NSString *)uid success:(void (^)(UIImage * _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //设置返回格式为AFHTTPResponseSerializer 此处必须使用二进制的形式 后台以二进制数据存储的图片
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html",@"text/json",@"text/javascript", @"text/plain",@"image/jpeg",@"image/png",@"image/jpg",@"image/*",nil];

    if (self.token)
    {
        [manager.requestSerializer setValue:self.token forHTTPHeaderField:@"token"];
    }
    [manager.requestSerializer setValue:[KDSTool getIphoneType] forHTTPHeaderField:@"phoneName"];
//    manager.securityPolicy = self.customSecurityPolicy;
    //是否允许无效证书
    manager.securityPolicy.allowInvalidCertificates = NO;
    //是否需要验证域名
    manager.securityPolicy.validatesDomainName = NO;
    //关闭缓存避免干扰测试
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;

    
    [manager.requestSerializer setTimeoutInterval:20.f];
    NSString *url = [[[KDSAppSettings sharedInstance] serverObjectForKey:KDSToolKitConfigHttpServer] stringByAppendingString:@"user/edit/showfileonline"];
    if (![NSURL URLWithString:url])
    {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    NSString *fullUrl = [NSString stringWithFormat:@"%@/%@",url,[KDSUserManager sharedManager].user.uid];
    return [manager GET:fullUrl parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (![responseObject isKindOfClass:NSData.class])
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        UIImage *img = [[UIImage alloc] initWithData:responseObject];
        !success ?: success(img);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if ([task.response isKindOfClass:[NSHTTPURLResponse class]])
        {
            NSHTTPURLResponse *r = (NSHTTPURLResponse *)task.response;
            NSDictionary *dict = r.allHeaderFields;
            NSString *contentType = dict[@"Content-Type"];
            if ([contentType isEqualToString:@"kaadas/json"])
            {
                !errorBlock ?: errorBlock([NSError errorWithDomain:@"用户没有上传头像" code:error.code userInfo:nil]);
                return;
            }
        }
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)setUserAvatarImage:(UIImage *)image withUid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    if (!image.size.width || !image.size.height ||  !uid.length)
    {
        !errorBlock ?: errorBlock([NSError errorWithDomain:@"上传的参数错误" code:(NSInteger)KDSHttpErrorParamIncorrect userInfo:nil]);
        return nil;
    }
    NSString *url = [[[KDSAppSettings sharedInstance] serverObjectForKey:KDSToolKitConfigHttpServer]  stringByAppendingString:@"user/edit/uploaduserhead"];
    if (![NSURL URLWithString:url])
    {
        url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    }
    return [self.afManager POST:url parameters:@{@"uid": uid} headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData *imageData = nil;
        NSString *mimeType = nil;
        CGImageAlphaInfo info = CGImageGetAlphaInfo(image.CGImage);
        if (info==kCGImageAlphaNone || info==kCGImageAlphaNoneSkipLast || info==kCGImageAlphaNoneSkipFirst)
        {
            imageData = UIImageJPEGRepresentation(image, 0.5);
            mimeType = @"image/jpg";
        }
        else
        {
            imageData = UIImagePNGRepresentation(image);
            mimeType = @"image/png";
        }
        //name：file是后台要求的格式
        [formData appendPartWithFileData:imageData name:@"file" fileName:@"img.png" mimeType:mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary *obj = responseObject;
        if (![obj isKindOfClass:NSDictionary.class])
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        if ([obj[@"code"] isEqualToString:@"200"])
        {
            !success ?: success();
        }
        else
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:[obj[@"msg"] isKindOfClass:NSString.class] ? obj[@"msg"] : @"服务器返回值错误" code:[obj[@"code"] isKindOfClass:NSString.class] ? [obj[@"code"] integerValue] : (int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)getSystemMessageWithUid:(NSString *)uid page:(int)page success:(void (^)(NSArray<KDSSysMessage *> * _Nonnull))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    return [self POST:@"systemMessage/list" parameters:@{@"uid":uid ?: @"", @"page":@(page)} success:^(id  _Nullable responseObject) {
        NSArray *obj = responseObject;
        if (![obj isKindOfClass:NSArray.class] || (obj.count && ![obj.firstObject isKindOfClass:NSDictionary.class]))
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        NSMutableArray *msgs = [KDSSysMessage mj_objectArrayWithKeyValuesArray:obj];
        !success ?: success(msgs.copy ?: @[]);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)deleteSystemMessage:(KDSSysMessage *)msg withUid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    return [self POST:@"systemMessage/delete" parameters:@{@"uid":uid ?: @"", @"mid":msg._id ?: @""} success:^(id  _Nullable responseObject) {
        !success ?: success();//NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)feedback:(NSString *)content withUid:(NSString *)uid success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    if (content.length<8 || content.length>300 || !uid.length)
    {
        !errorBlock ?: errorBlock([NSError errorWithDomain:@"上传的参数错误" code:(NSInteger)KDSHttpErrorParamIncorrect userInfo:nil]);
        return nil;
    }
    return [self POST:@"suggest/putmsg" parameters:@{@"suggest":content, @"uid":uid} success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)getUserAgreementVersion:(void (^)(KDSUserAgreement * _Nonnull))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    return [self GET:@"user/protocol/version/select" parameters:nil success:^(id  _Nullable responseObject) {
        NSDictionary *obj = responseObject;
        if (![obj isKindOfClass:NSDictionary.class])
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        KDSUserAgreement *agreement = [KDSUserAgreement new];
        obj = [self filteredDictionaryWithDictionary:obj];
        agreement.name = obj[@"name"];
        agreement._id = obj[@"_id"];
        agreement.version = obj[@"version"];
        agreement.tag = obj[@"tag"];
        !success ?: success(agreement);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)getUserAgreementContentWithAgreement:(KDSUserAgreement *)agreement success:(void (^)(KDSUserAgreement * _Nonnull))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    return [self POST:@"user/protocol/content" parameters:@{@"protocolId" : agreement._id ?: @""} success:^(id  _Nullable responseObject) {
        NSDictionary *obj = responseObject;
        if (![obj isKindOfClass:NSDictionary.class])
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        KDSUserAgreement *agr = [KDSUserAgreement new];
        obj = [self filteredDictionaryWithDictionary:obj];
        agr.name = agreement.name;
        agr.content = obj[@"content"];
        agr._id = obj[@"_id"];
        agr.version = obj[@"version"];
        agr.tag = obj[@"tag"];
        !success ?: success(agreement);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)getAuthorizedUsersWithUid:(NSString *)uid bleName:(NSString *)name success:(void (^)(NSArray<KDSAuthMember *> * _Nullable))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    uid = uid ?: @""; name = name ?: @"";
    return [self POST:@"normallock/ctl/getNormalDevlist" parameters:@{@"devname":name, @"user_id":uid} success:^(id  _Nullable responseObject) {
        NSArray *obj = responseObject;
        if (![obj isKindOfClass:NSArray.class] || (obj.count && ![obj.firstObject isKindOfClass:NSDictionary.class]))
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        !success ?: success([KDSAuthMember mj_objectArrayWithKeyValuesArray:obj].copy);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)addAuthorizedUser:(KDSAuthMember *)member withUid:(NSString *)uid device:(MyDevice *)device success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"admin_id"] = uid;
    params[@"device_username"] = member.uname;
    params[@"devicemac"] = device.devmac;
    params[@"devname"] = device.lockName;
    params[@"lockNickName"] = device.lockNickName;
    params[@"open_purview"] = member.jurisdiction;
    params[@"start_time"] = member.beginDate;
    params[@"end_time"] = member.endDate;
    params[@"items"] = member.items;
    return [self POST:@"normallock/reg/createNormalDev" parameters:params success:^(id  _Nullable responseObject) {
        !success ?: success();//返回值为NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)updateAuthorizedUserNickname:(KDSAuthMember *)member success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    return [self POST:@"normallock/reg/updateNormalDevUnickName" parameters:@{@"ndId":member._id ?: @"", @"userNickName":member.unickname ?: @""} success:^(id  _Nullable responseObject) {
        !success ?: success();//返回值为NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)setAuthorizedUser:(KDSAuthMember *)member withUid:(NSString *)uid device:(MyDevice *)device success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"admin_id"] = uid;
    params[@"dev_username"] = member.uname;
    //params[@"devicemac"] = device.devmac;
    params[@"devname"] = device.lockName;
    //params[@"lockNickName"] = device.device_nickname;
    params[@"open_purview"] = member.jurisdiction;
    params[@"datestart"] = member.beginDate;
    params[@"dateend"] = member.endDate;
    params[@"items"] = member.items;
    return [self POST:@"normallock/ctl/updateNormalDevlock" parameters:params success:^(id  _Nullable responseObject) {
        !success ?: success();//返回值为NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)deleteAuthorizedUser:(KDSAuthMember *)member withUid:(NSString *)uid device:(MyDevice *)device success:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    return [self POST:@"normallock/reg/deletenormaldev" parameters:@{@"adminid":uid ?: @"", @"dev_username":member.uname ?: @"", @"devname":device.lockName ?: @""} success:^(id  _Nullable responseObject) {
        !success ?: success();//返回值为NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)getFAQ:(int)language success:(void (^)(NSArray<KDSFAQ *> * _Nonnull))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    return [self GET:[@"FAQ/list/" stringByAppendingString:@(language).stringValue] parameters:nil success:^(id  _Nullable responseObject) {
        NSArray *obj = responseObject;
        if (![obj isKindOfClass:NSArray.class] || (obj.count && ![obj.firstObject isKindOfClass:NSDictionary.class]))
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        NSMutableArray *faqs = [KDSFAQ mj_objectArrayWithKeyValuesArray:obj];
        for (KDSFAQ *faq in faqs) { faq.language = language; }
        !success ?: success(faqs.copy ?: @[]);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)uploadPushToken:(NSString *)deviceToken remoteNotificationToken:(NSString *)voipToken withUid:(NSString *)uid mobileInfo:(nonnull NSDictionary *)mobileInfo success:(nullable void (^)(void))success error:(nullable void (^)(NSError * _Nonnull))errorBlock failure:(nullable void (^)(NSError * _Nonnull))failure
{
    uid = uid ?: @""; deviceToken = deviceToken ?: @""; voipToken = voipToken ?: @"";mobileInfo = mobileInfo ?: nil;
    NSNumber * iosVoipFlag;
    if (@available(iOS 13.0, *)) {
        iosVoipFlag = @0;
    }else{
        iosVoipFlag = @1;
    }
    return [self POST:@"user/upload/pushId" parameters:@{@"uid":uid, @"JPushId":deviceToken, @"VoIPId":voipToken, @"type":@1,@"iosVoIPFlag":iosVoipFlag ,@"mobileInfo":mobileInfo} success:^(id  _Nullable responseObject) {
        !success ?: success();//NSNull
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)getUserGWLockUnlockNotificationWithUid:(NSString *)uid completion:(void (^)(BOOL))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    uid = uid ?: @"";
    return [self POST:@"user/get/getPushSwitch" parameters:@{@"uid" : uid} success:^(id  _Nullable responseObject) {
        
        NSNumber *openlockPushSwitch = [responseObject objectForKey:@"openlockPushSwitch"];
        NSLog(@"--{Kaadas}--responseObject===%@",responseObject);
        if (![responseObject isKindOfClass:NSDictionary.class] || ![openlockPushSwitch isKindOfClass:NSNumber.class])
        {
            !errorBlock ?: errorBlock([NSError errorWithDomain:@"服务器返回值错误" code:(int)KDSHttpErrorReturnValueIncorrect userInfo:nil]);
            return;
        }
        !success ?: success(openlockPushSwitch.boolValue);
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

- (NSURLSessionDataTask *)setUserGWLockUnlockNotification:(BOOL)open withUid:(NSString *)uid completion:(void (^)(void))success error:(void (^)(NSError * _Nonnull))errorBlock failure:(void (^)(NSError * _Nonnull))failure
{
    uid = uid ?: @"";
    return [self POST:@"user/edit/postPushSwitch" parameters:@{@"uid":uid, @"openlockPushSwitch":@(open)} success:^(id  _Nullable responseObject) {
        !success ?: success();
    } error:errorBlock failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !failure ?: failure(error);
    }];
}

@end
