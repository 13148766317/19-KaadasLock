//
//  KDSBleAssistant.m
//  KaadasLock
//
//  Created by orange on 2019/6/27.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBleAssistant.h"

@implementation KDSBleAssistant

+ (NSData *)extractSystemIDFromAdvName:(NSString *)advName
{
    NSInteger allLenth = advName.length;
    if (allLenth < 12) return NSData.data;
    NSString *orgStr = [advName substringFromIndex:allLenth-12];
    const Byte* bytes = [KDSBleAssistant convertHexStrToData:orgStr].bytes;
    char c[8] = {bytes[5], bytes[4], bytes[3], 0, 0, bytes[2], bytes[1], bytes[0]};
    return [[NSData alloc] initWithBytes:c length:8];
}

+ (NSString*)convertDataToHexStr:(NSData *)data{
    
    if ([data isKindOfClass:NSString.class]) return (NSString *)data;
    if (![data isKindOfClass:NSData.class]) return @"";
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    return [NSString stringWithString:hexString];
}

+ (NSData *)convertHexStrToData:(NSString *)str{
    if (![str isKindOfClass:NSString.class] || [str length] == 0) {
        return [NSData data];
    }
    str = (str.length % 2 == 0) ? str : [@"0" stringByAppendingString:str];
    unsigned char bytes[str.length / 2];
    for (int i = 0; i < str.length; i += 2)
    {
        bytes[i / 2] = strtol([str substringWithRange:NSMakeRange(i, 2)].UTF8String, NULL, 16);
    }
    
    return [[NSData alloc] initWithBytes:bytes length:str.length / 2];
}

+ (NSString *)hexStringFromString:(NSString *)string
{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}

+ (NSString *)extractDateString:(NSString *)date
{
    if (!date || date.length != strlen(date.UTF8String) || date.length != 14)
    {
        char dateC[15] = {48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48, 48};
        int i = 0;
        NSString *sub = nil;
        for (NSUInteger j = 0; j < date.length; ++j)
        {
            sub = [date substringWithRange:NSMakeRange(j, 1)];
            if (strlen(sub.UTF8String) != 1 || sub.UTF8String[0] < 48 || sub.UTF8String[0] > 57) continue;
            dateC[i++] = sub.UTF8String[0];
        }
        dateC[14] = 0;
        date = @(dateC);
    }
    return date;
}

+ (int)sumOfDataThroughoutBytes:(NSData *)data
{
    if (![data isKindOfClass:NSData.class] || data.length == 0) return 0;
    const unsigned char* bytes = data.bytes;
    NSInteger length = 0; int sum = 0;
    while (length < data.length)
    {
        sum += bytes[length];
        length++;
    }
    return sum;
}

+(NSString *)convertToNSString:(NSData *)data
{
    const unsigned char * szBuffer = [data bytes];
    if (!szBuffer) {
        return nil;
    }
    NSMutableString * strTemp = [NSMutableString stringWithCapacity:[data length]* 2];
    NSUInteger dataLength = [data length];
    for (NSInteger i =0 ; i <dataLength; i ++) {
        [strTemp appendFormat:@"%02lx",(unsigned long)szBuffer[i]];
    }
    NSString* result = [NSString stringWithString:strTemp];
    return result;
    
}

+ (NSString *) NSDataToIP:(NSData *)ip
{
    NSData *ip1=[ip subdataWithRange:NSMakeRange(0, 1)];
    NSData *ip2=[ip subdataWithRange:NSMakeRange(1, 1)];
    NSData *ip3=[ip subdataWithRange:NSMakeRange(2, 1)];
    NSData *ip4=[ip subdataWithRange:NSMakeRange(3, 1)];
    
    return [NSString stringWithFormat:@"%hu.%hu.%hu.%hu",[self dataToUInt16:ip1],[self dataToUInt16:ip2],[self dataToUInt16:ip3],[self dataToUInt16:ip4]];
}

+ (uint16_t) dataToUInt16:(NSData *)data
{
    //    NSString *result = [NSString stringWithFormat:@"0x%@",[[data description] substringWithRange:NSMakeRange(1, [[data description] length]-2)]];
    NSString * result = [self convertToNSString:data];
    unsigned long ret = strtoul([result UTF8String],0,16);
    return ret;
}


@end
