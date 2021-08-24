//
//  NSData+JKEncrypt.h
//  JKCategories (https://github.com/shaojiankui/JKCategories)
//
//  Created by Jakey on 14/12/15.
//  Copyright (c) 2014年 www.skyfox.org. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (JKEncrypt)

/**
 *  利用AES加密数据
 *
 *  @param key key
 *  @param iv  iv description
 *
 *  @return data
 */
- (NSData *)jk_encryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv;
/**
 *  @brief  利用AES解密据
 *
 *  @param key key
 *  @param iv  iv
 *
 *  @return 解密后数据
 */
- (NSData *)jk_decryptedWithAESUsingKey:(NSString*)key andIV:(NSData*)iv;

/**
 *  利用3DES加密数据
 *
 *  @param key key
 *  @param iv  iv description
 *
 *  @return data
 */
- (NSData *)jk_encryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv;
/**
 *  @brief   利用3DES解密数据
 *
 *  @param key key
 *  @param iv  iv
 *
 *  @return 解密后数据
 */
- (NSData *)jk_decryptedWith3DESUsingKey:(NSString*)key andIV:(NSData*)iv;

/**
 *  @brief  NSData 转成UTF8 字符串
 *
 *  @return 转成UTF8 字符串
 */
- (NSString *)jk_UTF8String;


/**
 aes加密 key为字符串
 */
- (NSData *)aes256_encrypt:(NSString *)key;

/**
 aes解密 key为字符串
 */
- (NSData *)aes256_decrypt:(NSString *)key;

/**
 aes加密 key为Data
 */
- (NSData *)aes256_encryptData:(NSData *)keyData;

/**
 aes解密 key(128)为Data
 */
- (NSData *)aes256_decryptData:(NSData *)keyData;
/**
 aes解密 key(256)为Data
 */
- (NSData *)aesWifiLock256_decryptData:(NSData *)keyData;

/**
CRC32算法进行数据校验
*/
-(int32_t) crc32;
// 加密解密
- (NSData *)AES128ParmEncryptWithKey:(NSString *)key iv:(NSString *)iv;
+(NSData *)AES128Encrypt:(NSString *)plainText key:(NSString *)key;
//AES + 128 + ECB 加密
+ (NSData *)encryptAES:(NSString *)content key:(NSString *)key;
// AES + 128 + ECB 解密
+ (NSData *)decryptAESWithData:(NSData *)data key:(NSString *)key;
// 解密方式
+(NSString *)encryptAESLast:(NSString *)content key:(NSString *)key;
// base64
+(NSString *)AES128Encrypt99:(NSString *)plainText key:(NSString *)key;

@end
