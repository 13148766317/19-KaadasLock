//
//  CBPeripheral+Extension.m
//  BLETest
//
//  Created by zhaowz on 2017/9/13.
//  Copyright © 2017年 zhaowz. All rights reserved.
//

#import "CBPeripheral+Extension.h"
#import <objc/runtime.h>

static char *kCBAdvDataLocalNameKey = "kCBAdvDataLocalNameKey";
static char *newDeviceKey = "newDeviceKey";
static char lockModelTypeKey;
static char lockModelNumberKey;
static char serialNumberKey;
static char hardwareVerKey;
static char softwareVerKey;
static char powerKey;
static char isAutoModeKey;
static char volumeKey;
static char languageKey;
static char bleVersionKey;
static char functionSetKey;
static char connectableKey;
static char menuBindableKey;
static char directBindableKey;
static char isAwayModelKey;
static char isBleAndWifiKey;
static char *isMeibiaoLockKey = "isMeibiaoLock";

@implementation CBPeripheral (Extension)



- (void)setAdvDataLocalName:(NSString *)advDataLocalName{
    objc_setAssociatedObject(self, kCBAdvDataLocalNameKey, advDataLocalName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
- (NSString *)advDataLocalName{
    return objc_getAssociatedObject(self, kCBAdvDataLocalNameKey);
}

- (NSString *)mac
{
    if (self.advDataLocalName.length < 12) return nil;
    NSString *macAddress = [self.advDataLocalName substringFromIndex:self.advDataLocalName.length - 12];
    NSMutableArray *mutableStrArr = [NSMutableArray array];
    //通过循环，将：添加到字符串中
    for (int i = 0; i < macAddress.length; i += 2)
    {
        NSString *str = [macAddress substringWithRange:NSMakeRange(i, 2)];
        [mutableStrArr addObject:str];
    }
    return [mutableStrArr componentsJoinedByString:@":"];
}

- (void)setIsNewDevice:(BOOL)newDevice{
    objc_setAssociatedObject(self, newDeviceKey, [NSNumber numberWithBool:newDevice], OBJC_ASSOCIATION_COPY_NONATOMIC );
}
- (BOOL)isNewDevice{
    return [objc_getAssociatedObject(self, newDeviceKey) boolValue];
}

- (void)setLockModelType:(NSString *)lockModelType
{
    objc_setAssociatedObject(self, &lockModelTypeKey, lockModelType, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)lockModelType
{
    return objc_getAssociatedObject(self, &lockModelTypeKey);
}

- (NSUInteger)maxUsers
{
    return [[self.lockModelType uppercaseString] containsString:@"DB2"] ? 20 : 10;
}

- (void)setLockModelNumber:(NSString *)lockModelNumber
{
    objc_setAssociatedObject(self, &lockModelNumberKey, lockModelNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)lockModelNumber
{
    return objc_getAssociatedObject(self, &lockModelNumberKey);
}

- (BOOL)unlockPIN
{
    return !([self.lockModelNumber isEqualToString:@"RGBT1761"] || [self.lockModelNumber isEqualToString:@"RGBT1761D"]);
}

- (void)setSerialNumber:(NSString *)serialNumber
{
    objc_setAssociatedObject(self, &serialNumberKey, serialNumber, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)serialNumber
{
    return objc_getAssociatedObject(self, &serialNumberKey);
}

- (void)setHardwareVer:(NSString *)hardwareVer
{
    objc_setAssociatedObject(self, &hardwareVerKey, hardwareVer, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)hardwareVer
{
    return objc_getAssociatedObject(self, &hardwareVerKey);
}

- (void)setSoftwareVer:(NSString *)softwareVer
{
    objc_setAssociatedObject(self, &softwareVerKey, softwareVer, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)softwareVer
{
    return objc_getAssociatedObject(self, &softwareVerKey);
}

- (void)setPower:(int)power
{
    objc_setAssociatedObject(self, &powerKey, @(power), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (int)power
{
    NSNumber *value = objc_getAssociatedObject(self, &powerKey);
    return value ? value.intValue : -1;
}

- (void)setIsAutoMode:(BOOL)isAutoMode
{
    objc_setAssociatedObject(self, &isAutoModeKey, [NSNumber numberWithBool:isAutoMode], OBJC_ASSOCIATION_COPY_NONATOMIC );
}

- (BOOL)isAutoMode
{
    return [objc_getAssociatedObject(self, &isAutoModeKey) boolValue];
}

- (void)setVolume:(int)volume
{
    objc_setAssociatedObject(self, &volumeKey, @(volume), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (int)volume
{
    NSNumber *value = objc_getAssociatedObject(self, &volumeKey);
    return value ? value.intValue : -1;
}

- (void)setLanguage:(NSString *)language
{
    objc_setAssociatedObject(self, &languageKey, language, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)language
{
    return objc_getAssociatedObject(self, &languageKey);
}

- (void)setBleVersion:(int)bleVersion
{
    objc_setAssociatedObject(self, &bleVersionKey, @(bleVersion), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (int)bleVersion
{
    NSNumber *value = objc_getAssociatedObject(self, &bleVersionKey);
    return value ? value.intValue : 1;
}

- (void)setFunctionSet:(NSString *)functionSet
{
    objc_setAssociatedObject(self, &functionSetKey, functionSet, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)functionSet
{
    return objc_getAssociatedObject(self, &functionSetKey);
}

-(void)setConnectable:(BOOL)connectable{
    objc_setAssociatedObject(self, &connectableKey, [NSNumber numberWithBool:connectable], OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BOOL)connectable{
    return [objc_getAssociatedObject(self, &connectableKey) boolValue];
    
}
-(void)setMenuBindable:(BOOL)menuBindable{
    objc_setAssociatedObject(self, &menuBindableKey, [NSNumber numberWithBool:menuBindable], OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BOOL)menuBindable{
    return [objc_getAssociatedObject(self, &menuBindableKey) boolValue];
    
}
-(void)setDirectBindable:(BOOL)directBindable{
    objc_setAssociatedObject(self, &directBindableKey,[NSNumber numberWithBool:directBindable],OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BOOL)directBindable{
    return [objc_getAssociatedObject(self, &directBindableKey) boolValue];
    
}
-(void)setIsMeibiaoLock:(BOOL)isMeibiaoLock{
    objc_setAssociatedObject(self, &isMeibiaoLockKey,[NSNumber numberWithBool:isMeibiaoLock],OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BOOL)isMeibiaoLock{
    return [objc_getAssociatedObject(self, &isMeibiaoLockKey) boolValue];
}
-(void)setIsBleAndWifi:(BOOL)isBleAndWifi{
    objc_setAssociatedObject(self, &isBleAndWifiKey,[NSNumber numberWithBool:isBleAndWifi],OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BOOL)isBleAndWifi{
    return [objc_getAssociatedObject(self, &isBleAndWifiKey) boolValue];
}
-(void)setIsAwayModel:(BOOL)isAwayModel{
    objc_setAssociatedObject(self, &isAwayModelKey,[NSNumber numberWithBool:isAwayModel],OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(BOOL)isAwayModel{
    return [objc_getAssociatedObject(self, &isAwayModelKey) boolValue];
}

@end
