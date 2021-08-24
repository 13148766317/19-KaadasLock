//
//	KDSDeviceHangerUV.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "KDSDeviceHangerSwitch.h"

NSString *const kKDSDeviceHangerUVCountdown = @"countdown";
NSString *const kKDSDeviceHangerUVSwitchField = @"switch";

@interface KDSDeviceHangerSwitch ()
@end
@implementation KDSDeviceHangerSwitch




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kKDSDeviceHangerUVCountdown] isKindOfClass:[NSNull class]]){
		self.countdown = [dictionary[kKDSDeviceHangerUVCountdown] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerUVSwitchField] isKindOfClass:[NSNull class]]){
		self.switchField = [dictionary[kKDSDeviceHangerUVSwitchField] integerValue];
	}

	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	dictionary[kKDSDeviceHangerUVCountdown] = @(self.countdown);
	dictionary[kKDSDeviceHangerUVSwitchField] = @(self.switchField);
	return dictionary;

}

/**
 * Implementation of NSCoding encoding method
 */
/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
- (void)encodeWithCoder:(NSCoder *)aCoder
{
	[aCoder encodeObject:@(self.countdown) forKey:kKDSDeviceHangerUVCountdown];	[aCoder encodeObject:@(self.switchField) forKey:kKDSDeviceHangerUVSwitchField];
}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.countdown = [[aDecoder decodeObjectForKey:kKDSDeviceHangerUVCountdown] integerValue];
	self.switchField = [[aDecoder decodeObjectForKey:kKDSDeviceHangerUVSwitchField] integerValue];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	KDSDeviceHangerSwitch *copy = [KDSDeviceHangerSwitch new];

	copy.countdown = self.countdown;
	copy.switchField = self.switchField;

	return copy;
}
@end
