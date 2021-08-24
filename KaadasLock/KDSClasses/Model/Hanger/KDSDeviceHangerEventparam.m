//
//	KDSDeviceHangerEventparam.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "KDSDeviceHangerEventparam.h"

NSString *const kKDSDeviceHangerEventparamUV = @"UV";
NSString *const kKDSDeviceHangerEventparamAirDry = @"airDry";
NSString *const kKDSDeviceHangerEventparamBaking = @"baking";
NSString *const kKDSDeviceHangerEventparamChildLock = @"childLock";
NSString *const kKDSDeviceHangerEventparamLight = @"light";
NSString *const kKDSDeviceHangerEventparamLoudspeaker = @"loudspeaker";
NSString *const kKDSDeviceHangerEventparamMotor = @"motor";
NSString *const kKDSDeviceHangerEventparamOverload = @"overload";
NSString *const kKDSDeviceHangerEventparamStatus = @"status";

@interface KDSDeviceHangerEventparam ()
@end
@implementation KDSDeviceHangerEventparam




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kKDSDeviceHangerEventparamUV] isKindOfClass:[NSNull class]]){
		self.uV = [[KDSDeviceHangerSwitch alloc] initWithDictionary:dictionary[kKDSDeviceHangerEventparamUV]];
	}

	if(![dictionary[kKDSDeviceHangerEventparamAirDry] isKindOfClass:[NSNull class]]){
		self.airDry = [[KDSDeviceHangerSwitch alloc] initWithDictionary:dictionary[kKDSDeviceHangerEventparamAirDry]];
	}

	if(![dictionary[kKDSDeviceHangerEventparamBaking] isKindOfClass:[NSNull class]]){
		self.baking = [[KDSDeviceHangerSwitch alloc] initWithDictionary:dictionary[kKDSDeviceHangerEventparamBaking]];
	}

	if(![dictionary[kKDSDeviceHangerEventparamChildLock] isKindOfClass:[NSNull class]]){
		self.childLock = [dictionary[kKDSDeviceHangerEventparamChildLock] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerEventparamLight] isKindOfClass:[NSNull class]]){
		self.light = [[KDSDeviceHangerSwitch alloc] initWithDictionary:dictionary[kKDSDeviceHangerEventparamLight]];
	}

	if(![dictionary[kKDSDeviceHangerEventparamLoudspeaker] isKindOfClass:[NSNull class]]){
		self.loudspeaker = [dictionary[kKDSDeviceHangerEventparamLoudspeaker] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerEventparamMotor] isKindOfClass:[NSNull class]]){
		self.motor = [[KDSDeviceHangerMotor alloc] initWithDictionary:dictionary[kKDSDeviceHangerEventparamMotor]];
	}

	if(![dictionary[kKDSDeviceHangerEventparamOverload] isKindOfClass:[NSNull class]]){
		self.overload = [dictionary[kKDSDeviceHangerEventparamOverload] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerEventparamStatus] isKindOfClass:[NSNull class]]){
		self.status = [dictionary[kKDSDeviceHangerEventparamStatus] integerValue];
	}

	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.uV != nil){
		dictionary[kKDSDeviceHangerEventparamUV] = [self.uV toDictionary];
	}
	if(self.airDry != nil){
		dictionary[kKDSDeviceHangerEventparamAirDry] = [self.airDry toDictionary];
	}
	if(self.baking != nil){
		dictionary[kKDSDeviceHangerEventparamBaking] = [self.baking toDictionary];
	}
	dictionary[kKDSDeviceHangerEventparamChildLock] = @(self.childLock);
	if(self.light != nil){
		dictionary[kKDSDeviceHangerEventparamLight] = [self.light toDictionary];
	}
	dictionary[kKDSDeviceHangerEventparamLoudspeaker] = @(self.loudspeaker);
	if(self.motor != nil){
		dictionary[kKDSDeviceHangerEventparamMotor] = [self.motor toDictionary];
	}
	dictionary[kKDSDeviceHangerEventparamOverload] = @(self.overload);
	dictionary[kKDSDeviceHangerEventparamStatus] = @(self.status);
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
	if(self.uV != nil){
		[aCoder encodeObject:self.uV forKey:kKDSDeviceHangerEventparamUV];
	}
	if(self.airDry != nil){
		[aCoder encodeObject:self.airDry forKey:kKDSDeviceHangerEventparamAirDry];
	}
	if(self.baking != nil){
		[aCoder encodeObject:self.baking forKey:kKDSDeviceHangerEventparamBaking];
	}
	[aCoder encodeObject:@(self.childLock) forKey:kKDSDeviceHangerEventparamChildLock];	if(self.light != nil){
		[aCoder encodeObject:self.light forKey:kKDSDeviceHangerEventparamLight];
	}
	[aCoder encodeObject:@(self.loudspeaker) forKey:kKDSDeviceHangerEventparamLoudspeaker];	if(self.motor != nil){
		[aCoder encodeObject:self.motor forKey:kKDSDeviceHangerEventparamMotor];
	}
	[aCoder encodeObject:@(self.overload) forKey:kKDSDeviceHangerEventparamOverload];	[aCoder encodeObject:@(self.status) forKey:kKDSDeviceHangerEventparamStatus];
}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.uV = [aDecoder decodeObjectForKey:kKDSDeviceHangerEventparamUV];
	self.airDry = [aDecoder decodeObjectForKey:kKDSDeviceHangerEventparamAirDry];
	self.baking = [aDecoder decodeObjectForKey:kKDSDeviceHangerEventparamBaking];
	self.childLock = [[aDecoder decodeObjectForKey:kKDSDeviceHangerEventparamChildLock] integerValue];
	self.light = [aDecoder decodeObjectForKey:kKDSDeviceHangerEventparamLight];
	self.loudspeaker = [[aDecoder decodeObjectForKey:kKDSDeviceHangerEventparamLoudspeaker] integerValue];
	self.motor = [aDecoder decodeObjectForKey:kKDSDeviceHangerEventparamMotor];
	self.overload = [[aDecoder decodeObjectForKey:kKDSDeviceHangerEventparamOverload] integerValue];
	self.status = [[aDecoder decodeObjectForKey:kKDSDeviceHangerEventparamStatus] integerValue];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	KDSDeviceHangerEventparam *copy = [KDSDeviceHangerEventparam new];

	copy.uV = [self.uV copy];
	copy.airDry = [self.airDry copy];
	copy.baking = [self.baking copy];
	copy.childLock = self.childLock;
	copy.light = [self.light copy];
	copy.loudspeaker = self.loudspeaker;
	copy.motor = [self.motor copy];
	copy.overload = self.overload;
	copy.status = self.status;

	return copy;
}
@end
