//
//  ESPAES.h
//  EspTouchDemo
//
//  Created by AE on 2018/4/5.
//

#import <Foundation/Foundation.h>

//-->数据加密解密类
@interface ESPAES : NSObject {
    @private NSString *key;
}

- (instancetype)initWithKey:(NSString *)secretKey;

- (NSData *)AES128EncryptData:(NSData *)data;
- (NSData *)AES128DecryptData:(NSData *)data;

@end
