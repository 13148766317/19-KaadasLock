//
//  KDSBleOpRec.m
//  KaadasLock
//
//  Created by orange on 2019/6/21.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSBleOpRec.h"

@implementation KDSBleOpRec

@synthesize niketotal = _niketotal;
@synthesize nikecurrent = _nikecurrent;
@synthesize hexString = _hexString;

- (instancetype)initWithData:(NSData *)data
{
    if (data.length != 20) return nil;
    self = [super init];
    if (self)
    {
        const unsigned char *bytes = data.bytes;
        _niketotal = bytes[4] + bytes[5] * 256;///Total
        _nikecurrent = bytes[6] + bytes[7] * 256;///Index
        _cmdType = bytes[8];///Cmd Type
        _eventType = bytes[9];///Event Type
        _eventSource = bytes[10];///Event Source1
        _eventCode = bytes[11];///Event Code
        _userID = bytes[12];///UserID
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
    return [[KDSBleOpRec alloc] initWithData:[[NSData alloc] initWithBytesNoCopy:buffer length:20]];
}

- (BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[self class]]) return NO;
    KDSBleAlarmRecord * record = (KDSBleAlarmRecord *)object;
    if (self.hexString.length<16 || record.hexString.length<16) return NO;
    return  [[self.hexString substringFromIndex:16] isEqualToString:[((KDSBleAlarmRecord *)object).hexString substringFromIndex:16]];
}

- (NSUInteger)hash
{
    return self.hexString.length>16 ? [self.hexString substringFromIndex:16].hash : self.hexString.hash;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder
{
    [aCoder encodeInt:self.niketotal forKey:@"niketotal"];
    [aCoder encodeInt:self.nikecurrent forKey:@"nikecurrent"];
    [aCoder encodeInt:self.eventType forKey:@"eventType"];
    [aCoder encodeInt:self.eventSource forKey:@"eventSource"];
    [aCoder encodeInt:self.eventCode forKey:@"eventCode"];
    [aCoder encodeInt:self.userID forKey:@"userID"];
    [aCoder encodeObject:self.date forKey:@"data"];
    [aCoder encodeObject:self.hexString forKey:@"hexString"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        _niketotal = [aDecoder decodeIntForKey:@"niketotal"];
        _nikecurrent =[aDecoder decodeIntForKey:@"nikecurrent"];
        _eventType = [aDecoder decodeIntForKey:@"eventType"];
        _eventSource = [aDecoder decodeIntForKey:@"eventSource"];
        _eventCode = [aDecoder decodeIntForKey:@"eventCode"];
        _userID = [aDecoder decodeIntForKey:@"userID"];
        self.date = [aDecoder decodeObjectForKey:@"data"];
        _hexString = [aDecoder decodeObjectForKey:@"hexString"];
    }
    return self;
}

@end
