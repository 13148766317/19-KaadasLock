//
//  KDSBleAlarmRecord.m
//  lock
//
//  Created by orange on 2019/1/18.
//  Copyright © 2019年 zhao. All rights reserved.
//

#import "KDSBleAlarmRecord.h"

@implementation KDSBleAlarmRecord

@synthesize total = _total;
@synthesize current = _current;
@synthesize hexString = _hexString;

- (instancetype)initWithData:(NSData *)data
{
    self = [super init];
    if (self)
    {
        const unsigned char *bytes = data.bytes;
        _total = bytes[4];
        _current = bytes[5];
        _type = bytes[8];
        NSMutableString *hex = [NSMutableString stringWithCapacity:data.length * 2];
        for (NSUInteger i = 0; i < data.length; ++i)
        {
            [hex appendFormat:@"%02x", bytes[i]];
        }
        _hexString = hex.copy;
    }
    return self;
}

- (instancetype)initWithHexString:(NSString *)string
{
    if (!string || strlen(string.UTF8String) != 40) return nil;
    char* buffer = (char*)calloc(1, 20);
    int i = 0;
    while (i < 20)
    {
        buffer[i] = strtoul([string substringWithRange:NSMakeRange(2 * i, 2)].UTF8String, 0, 16);
        i++;
    }
    return [[KDSBleAlarmRecord alloc] initWithData:[[NSData alloc] initWithBytesNoCopy:buffer length:20]];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    KDSBleAlarmRecord * record = (KDSBleAlarmRecord *)object;
    if (self.hexString.length<12 || record.hexString.length<12) return NO;
    return  [[self.hexString substringFromIndex:12] isEqualToString:[((KDSBleAlarmRecord *)object).hexString substringFromIndex:12]];
}

- (NSUInteger)hash
{
    return self.hexString.length>12 ? [self.hexString substringFromIndex:12].hash : self.hexString.hash;
}

@end
