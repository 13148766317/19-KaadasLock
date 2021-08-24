//
//  KDSCodingObject.m
//  KaadasLock
//
//  Created by orange on 2019/4/30.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSCodingObject.h"
#import <objc/runtime.h>

@implementation KDSCodingObject

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    unsigned count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; ++i)
    {
        const char* type = ivar_getTypeEncoding(ivars[i]);
        const char* name = ivar_getName(ivars[i]);
        if (!type || strlen(type) == 0) continue;
        id value = nil;
        switch (type[0])
        {
            case 'c':
            case 'i':
            case 's':
            case 'l':
            case 'C':
            case 'I':
            case 'S':
            case 'L':
                //int
                value = @([aDecoder decodeIntForKey:@(name)]);
                break;
                
            case 'q':
            case 'Q':
                //long long
                value = @([aDecoder decodeIntegerForKey:@(name)]);
                break;
                
            case 'f':
                //float
                value = @([aDecoder decodeFloatForKey:@(name)]);
                break;
                
            case 'd':
                //double
                value = @([aDecoder decodeDoubleForKey:@(name)]);
                break;
                
            case 'B':
                //bool
                value = @([aDecoder decodeBoolForKey:@(name)]);
                break;
                
            case '@':
                value = [aDecoder decodeObjectForKey:@(name)];
                break;
                
            default:
                break;
        }
        [self setValue:value forKey:@(name)];
    }
    free(ivars);
    ivars = NULL;
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    unsigned count = 0;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; ++i)
    {
        const char* type = ivar_getTypeEncoding(ivars[i]);
        const char* name = ivar_getName(ivars[i]);
        if (!type || strlen(type) == 0) continue;
        id value = [self valueForKey:@(name)];
        if (!value) continue;
        switch (type[0])
        {
            case 'c':
            case 'i':
            case 's':
            case 'l':
            case 'C':
            case 'I':
            case 'S':
            case 'L':
                //int
                [aCoder encodeInt:[value intValue] forKey:@(name)];
                break;
                
            case 'q':
            case 'Q':
                //long long
                [aCoder encodeInteger:[value integerValue] forKey:@(name)];
                break;
                
            case 'f':
                //float
                [aCoder encodeFloat:[value floatValue] forKey:@(name)];
                break;
                
            case 'd':
                //double
                [aCoder encodeDouble:[value doubleValue] forKey:@(name)];
                break;
                
            case 'B':
                //bool
                [aCoder encodeBool:[value boolValue] forKey:@(name)];
                break;
                
            case '@':
                [aCoder encodeObject:value forKey:@(name)];
                
            default:
                break;
        }
    }
    free(ivars);
    ivars = NULL;
}

@end
