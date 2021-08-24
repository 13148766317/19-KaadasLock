//
//	KDSDeviceHangerState.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "KDSDeviceHangerState.h"

NSString *const kKDSDeviceHangerStateDevtype = @"devtype";
NSString *const kKDSDeviceHangerStateEventparams = @"eventparams";
NSString *const kKDSDeviceHangerStateEventtype = @"eventtype";
NSString *const kKDSDeviceHangerStateFunc = @"func";
NSString *const kKDSDeviceHangerStateMsgId = @"msgId";
NSString *const kKDSDeviceHangerStateMsgtype = @"msgtype";
NSString *const kKDSDeviceHangerStateTimestamp = @"timestamp";
NSString *const kKDSDeviceHangerStateWfId = @"wfId";

@interface KDSDeviceHangerState ()
@end
@implementation KDSDeviceHangerState




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kKDSDeviceHangerStateDevtype] isKindOfClass:[NSNull class]]){
		self.devtype = dictionary[kKDSDeviceHangerStateDevtype];
	}	
	if(![dictionary[kKDSDeviceHangerStateEventparams] isKindOfClass:[NSNull class]]){
		self.eventparams = [[KDSDeviceHangerEventparam alloc] initWithDictionary:dictionary[kKDSDeviceHangerStateEventparams]];
	}

	if(![dictionary[kKDSDeviceHangerStateEventtype] isKindOfClass:[NSNull class]]){
		self.eventtype = dictionary[kKDSDeviceHangerStateEventtype];
	}	
	if(![dictionary[kKDSDeviceHangerStateFunc] isKindOfClass:[NSNull class]]){
		self.func = dictionary[kKDSDeviceHangerStateFunc];
	}	
	if(![dictionary[kKDSDeviceHangerStateMsgId] isKindOfClass:[NSNull class]]){
		self.msgId = [dictionary[kKDSDeviceHangerStateMsgId] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerStateMsgtype] isKindOfClass:[NSNull class]]){
		self.msgtype = dictionary[kKDSDeviceHangerStateMsgtype];
	}	
	if(![dictionary[kKDSDeviceHangerStateTimestamp] isKindOfClass:[NSNull class]]){
		self.timestamp = dictionary[kKDSDeviceHangerStateTimestamp];
	}	
	if(![dictionary[kKDSDeviceHangerStateWfId] isKindOfClass:[NSNull class]]){
		self.wfId = dictionary[kKDSDeviceHangerStateWfId];
	}	
	return self;
}


/**
 * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
 */
-(NSDictionary *)toDictionary
{
	NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
	if(self.devtype != nil){
		dictionary[kKDSDeviceHangerStateDevtype] = self.devtype;
	}
	if(self.eventparams != nil){
		dictionary[kKDSDeviceHangerStateEventparams] = [self.eventparams toDictionary];
	}
	if(self.eventtype != nil){
		dictionary[kKDSDeviceHangerStateEventtype] = self.eventtype;
	}
	if(self.func != nil){
		dictionary[kKDSDeviceHangerStateFunc] = self.func;
	}
	dictionary[kKDSDeviceHangerStateMsgId] = @(self.msgId);
	if(self.msgtype != nil){
		dictionary[kKDSDeviceHangerStateMsgtype] = self.msgtype;
	}
	if(self.timestamp != nil){
		dictionary[kKDSDeviceHangerStateTimestamp] = self.timestamp;
	}
	if(self.wfId != nil){
		dictionary[kKDSDeviceHangerStateWfId] = self.wfId;
	}
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
	if(self.devtype != nil){
		[aCoder encodeObject:self.devtype forKey:kKDSDeviceHangerStateDevtype];
	}
	if(self.eventparams != nil){
		[aCoder encodeObject:self.eventparams forKey:kKDSDeviceHangerStateEventparams];
	}
	if(self.eventtype != nil){
		[aCoder encodeObject:self.eventtype forKey:kKDSDeviceHangerStateEventtype];
	}
	if(self.func != nil){
		[aCoder encodeObject:self.func forKey:kKDSDeviceHangerStateFunc];
	}
	[aCoder encodeObject:@(self.msgId) forKey:kKDSDeviceHangerStateMsgId];	if(self.msgtype != nil){
		[aCoder encodeObject:self.msgtype forKey:kKDSDeviceHangerStateMsgtype];
	}
	if(self.timestamp != nil){
		[aCoder encodeObject:self.timestamp forKey:kKDSDeviceHangerStateTimestamp];
	}
	if(self.wfId != nil){
		[aCoder encodeObject:self.wfId forKey:kKDSDeviceHangerStateWfId];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.devtype = [aDecoder decodeObjectForKey:kKDSDeviceHangerStateDevtype];
	self.eventparams = [aDecoder decodeObjectForKey:kKDSDeviceHangerStateEventparams];
	self.eventtype = [aDecoder decodeObjectForKey:kKDSDeviceHangerStateEventtype];
	self.func = [aDecoder decodeObjectForKey:kKDSDeviceHangerStateFunc];
	self.msgId = [[aDecoder decodeObjectForKey:kKDSDeviceHangerStateMsgId] integerValue];
	self.msgtype = [aDecoder decodeObjectForKey:kKDSDeviceHangerStateMsgtype];
	self.timestamp = [aDecoder decodeObjectForKey:kKDSDeviceHangerStateTimestamp];
	self.wfId = [aDecoder decodeObjectForKey:kKDSDeviceHangerStateWfId];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	KDSDeviceHangerState *copy = [KDSDeviceHangerState new];

	copy.devtype = [self.devtype copy];
	copy.eventparams = [self.eventparams copy];
	copy.eventtype = [self.eventtype copy];
	copy.func = [self.func copy];
	copy.msgId = self.msgId;
	copy.msgtype = [self.msgtype copy];
	copy.timestamp = [self.timestamp copy];
	copy.wfId = [self.wfId copy];

	return copy;
}
@end