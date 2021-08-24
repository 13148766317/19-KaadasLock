//
//	KDSDeviceHangerMotor.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "KDSDeviceHangerMotor.h"

NSString *const kKDSDeviceHangerMotorAction = @"action";
NSString *const kKDSDeviceHangerMotorStatus = @"status";

@interface KDSDeviceHangerMotor ()
@end
@implementation KDSDeviceHangerMotor




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kKDSDeviceHangerMotorAction] isKindOfClass:[NSNull class]]){
		self.action = [dictionary[kKDSDeviceHangerMotorAction] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerMotorStatus] isKindOfClass:[NSNull class]]){
		self.status = [dictionary[kKDSDeviceHangerMotorStatus] integerValue];
	}

	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	dictionary[kKDSDeviceHangerMotorAction] = @(self.action);
	dictionary[kKDSDeviceHangerMotorStatus] = @(self.status);
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
	[aCoder encodeObject:@(self.action) forKey:kKDSDeviceHangerMotorAction];	[aCoder encodeObject:@(self.status) forKey:kKDSDeviceHangerMotorStatus];
}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.action = [[aDecoder decodeObjectForKey:kKDSDeviceHangerMotorAction] integerValue];
	self.status = [[aDecoder decodeObjectForKey:kKDSDeviceHangerMotorStatus] integerValue];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	KDSDeviceHangerMotor *copy = [KDSDeviceHangerMotor new];

	copy.action = self.action;
	copy.status = self.status;

	return copy;
}
@end