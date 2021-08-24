//
//	KDSDeviceHangerModel.m
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport



#import "KDSDeviceHangerModel.h"

NSString *const kKDSDeviceHangerModelUV = @"UV";
NSString *const kKDSDeviceHangerModelIdField = @"_id";
NSString *const kKDSDeviceHangerModelAdminName = @"adminName";
NSString *const kKDSDeviceHangerModelAdminUid = @"adminUid";
NSString *const kKDSDeviceHangerModelAirDry = @"airDry";
NSString *const kKDSDeviceHangerModelBaking = @"baking";
NSString *const kKDSDeviceHangerModelChildLock = @"childLock";
NSString *const kKDSDeviceHangerModelHangerNickName = @"hangerNickName";
NSString *const kKDSDeviceHangerModelHangerSN = @"hangerSN";
NSString *const kKDSDeviceHangerModelHangerVersion = @"hangerVersion";
NSString *const kKDSDeviceHangerModelIsAdmin = @"isAdmin";
NSString *const kKDSDeviceHangerModelLight = @"light";
NSString *const kKDSDeviceHangerModelLoudspeaker = @"loudspeaker";
NSString *const kKDSDeviceHangerModelModuleSN = @"moduleSN";
NSString *const kKDSDeviceHangerModelModuleVersion = @"moduleVersion";
NSString *const kKDSDeviceHangerModelMotor = @"motor";
NSString *const kKDSDeviceHangerModelOnlineState = @"onlineState";
NSString *const kKDSDeviceHangerModelOverload = @"overload";
NSString *const kKDSDeviceHangerModelStatus = @"status";
NSString *const kKDSDeviceHangerModelUid = @"uid";
NSString *const kKDSDeviceHangerModelUname = @"uname";
NSString *const kKDSDeviceHangerModelUpdateTime = @"updateTime";
NSString *const kKDSDeviceHangerModelWifiSN = @"wifiSN";

@interface KDSDeviceHangerModel ()
@end
@implementation KDSDeviceHangerModel




/**
 * Instantiate the instance using the passed dictionary values to set the properties values
 */

-(instancetype)initWithDictionary:(NSDictionary *)dictionary
{
	self = [super init];
	if(![dictionary[kKDSDeviceHangerModelUV] isKindOfClass:[NSNull class]]){
		self.uV = [[KDSDeviceHangerSwitch alloc] initWithDictionary:dictionary[kKDSDeviceHangerModelUV]];
	}

	if(![dictionary[kKDSDeviceHangerModelIdField] isKindOfClass:[NSNull class]]){
		self.idField = dictionary[kKDSDeviceHangerModelIdField];
	}	
	if(![dictionary[kKDSDeviceHangerModelAdminName] isKindOfClass:[NSNull class]]){
		self.adminName = dictionary[kKDSDeviceHangerModelAdminName];
	}	
	if(![dictionary[kKDSDeviceHangerModelAdminUid] isKindOfClass:[NSNull class]]){
		self.adminUid = dictionary[kKDSDeviceHangerModelAdminUid];
	}	
	if(![dictionary[kKDSDeviceHangerModelAirDry] isKindOfClass:[NSNull class]]){
		self.airDry = [[KDSDeviceHangerSwitch alloc] initWithDictionary:dictionary[kKDSDeviceHangerModelAirDry]];
	}

	if(![dictionary[kKDSDeviceHangerModelBaking] isKindOfClass:[NSNull class]]){
		self.baking = [[KDSDeviceHangerSwitch alloc] initWithDictionary:dictionary[kKDSDeviceHangerModelBaking]];
	}

	if(![dictionary[kKDSDeviceHangerModelChildLock] isKindOfClass:[NSNull class]]){
		self.childLock = [dictionary[kKDSDeviceHangerModelChildLock] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerModelHangerNickName] isKindOfClass:[NSNull class]]){
		self.hangerNickName = dictionary[kKDSDeviceHangerModelHangerNickName];
	}	
	if(![dictionary[kKDSDeviceHangerModelHangerSN] isKindOfClass:[NSNull class]]){
		self.hangerSN = dictionary[kKDSDeviceHangerModelHangerSN];
	}	
	if(![dictionary[kKDSDeviceHangerModelHangerVersion] isKindOfClass:[NSNull class]]){
		self.hangerVersion = dictionary[kKDSDeviceHangerModelHangerVersion];
	}	
	if(![dictionary[kKDSDeviceHangerModelIsAdmin] isKindOfClass:[NSNull class]]){
		self.isAdmin = [dictionary[kKDSDeviceHangerModelIsAdmin] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerModelLight] isKindOfClass:[NSNull class]]){
		self.light = [[KDSDeviceHangerSwitch alloc] initWithDictionary:dictionary[kKDSDeviceHangerModelLight]];
	}

	if(![dictionary[kKDSDeviceHangerModelLoudspeaker] isKindOfClass:[NSNull class]]){
		self.loudspeaker = [dictionary[kKDSDeviceHangerModelLoudspeaker] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerModelModuleSN] isKindOfClass:[NSNull class]]){
		self.moduleSN = dictionary[kKDSDeviceHangerModelModuleSN];
	}	
	if(![dictionary[kKDSDeviceHangerModelModuleVersion] isKindOfClass:[NSNull class]]){
		self.moduleVersion = dictionary[kKDSDeviceHangerModelModuleVersion];
	}	
	if(![dictionary[kKDSDeviceHangerModelMotor] isKindOfClass:[NSNull class]]){
		self.motor = [[KDSDeviceHangerMotor alloc] initWithDictionary:dictionary[kKDSDeviceHangerModelMotor]];
	}

	if(![dictionary[kKDSDeviceHangerModelOnlineState] isKindOfClass:[NSNull class]]){
		self.onlineState = [dictionary[kKDSDeviceHangerModelOnlineState] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerModelOverload] isKindOfClass:[NSNull class]]){
		self.overload = [dictionary[kKDSDeviceHangerModelOverload] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerModelStatus] isKindOfClass:[NSNull class]]){
		self.status = [dictionary[kKDSDeviceHangerModelStatus] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerModelUid] isKindOfClass:[NSNull class]]){
		self.uid = dictionary[kKDSDeviceHangerModelUid];
	}	
	if(![dictionary[kKDSDeviceHangerModelUname] isKindOfClass:[NSNull class]]){
		self.uname = dictionary[kKDSDeviceHangerModelUname];
	}	
	if(![dictionary[kKDSDeviceHangerModelUpdateTime] isKindOfClass:[NSNull class]]){
		self.updateTime = [dictionary[kKDSDeviceHangerModelUpdateTime] integerValue];
	}

	if(![dictionary[kKDSDeviceHangerModelWifiSN] isKindOfClass:[NSNull class]]){
		self.wifiSN = dictionary[kKDSDeviceHangerModelWifiSN];
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
		dictionary[kKDSDeviceHangerModelUV] = [self.uV toDictionary];
	}
	if(self.idField != nil){
		dictionary[kKDSDeviceHangerModelIdField] = self.idField;
	}
	if(self.adminName != nil){
		dictionary[kKDSDeviceHangerModelAdminName] = self.adminName;
	}
	if(self.adminUid != nil){
		dictionary[kKDSDeviceHangerModelAdminUid] = self.adminUid;
	}
	if(self.airDry != nil){
		dictionary[kKDSDeviceHangerModelAirDry] = [self.airDry toDictionary];
	}
	if(self.baking != nil){
		dictionary[kKDSDeviceHangerModelBaking] = [self.baking toDictionary];
	}
	dictionary[kKDSDeviceHangerModelChildLock] = @(self.childLock);
	if(self.hangerNickName != nil){
		dictionary[kKDSDeviceHangerModelHangerNickName] = self.hangerNickName;
	}
	if(self.hangerSN != nil){
		dictionary[kKDSDeviceHangerModelHangerSN] = self.hangerSN;
	}
	if(self.hangerVersion != nil){
		dictionary[kKDSDeviceHangerModelHangerVersion] = self.hangerVersion;
	}
	dictionary[kKDSDeviceHangerModelIsAdmin] = @(self.isAdmin);
	if(self.light != nil){
		dictionary[kKDSDeviceHangerModelLight] = [self.light toDictionary];
	}
	dictionary[kKDSDeviceHangerModelLoudspeaker] = @(self.loudspeaker);
	if(self.moduleSN != nil){
		dictionary[kKDSDeviceHangerModelModuleSN] = self.moduleSN;
	}
	if(self.moduleVersion != nil){
		dictionary[kKDSDeviceHangerModelModuleVersion] = self.moduleVersion;
	}
	if(self.motor != nil){
		dictionary[kKDSDeviceHangerModelMotor] = [self.motor toDictionary];
	}
	dictionary[kKDSDeviceHangerModelOnlineState] = @(self.onlineState);
	dictionary[kKDSDeviceHangerModelOverload] = @(self.overload);
	dictionary[kKDSDeviceHangerModelStatus] = @(self.status);
	if(self.uid != nil){
		dictionary[kKDSDeviceHangerModelUid] = self.uid;
	}
	if(self.uname != nil){
		dictionary[kKDSDeviceHangerModelUname] = self.uname;
	}
	dictionary[kKDSDeviceHangerModelUpdateTime] = @(self.updateTime);
	if(self.wifiSN != nil){
		dictionary[kKDSDeviceHangerModelWifiSN] = self.wifiSN;
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
	if(self.uV != nil){
		[aCoder encodeObject:self.uV forKey:kKDSDeviceHangerModelUV];
	}
	if(self.idField != nil){
		[aCoder encodeObject:self.idField forKey:kKDSDeviceHangerModelIdField];
	}
	if(self.adminName != nil){
		[aCoder encodeObject:self.adminName forKey:kKDSDeviceHangerModelAdminName];
	}
	if(self.adminUid != nil){
		[aCoder encodeObject:self.adminUid forKey:kKDSDeviceHangerModelAdminUid];
	}
	if(self.airDry != nil){
		[aCoder encodeObject:self.airDry forKey:kKDSDeviceHangerModelAirDry];
	}
	if(self.baking != nil){
		[aCoder encodeObject:self.baking forKey:kKDSDeviceHangerModelBaking];
	}
	[aCoder encodeObject:@(self.childLock) forKey:kKDSDeviceHangerModelChildLock];	if(self.hangerNickName != nil){
		[aCoder encodeObject:self.hangerNickName forKey:kKDSDeviceHangerModelHangerNickName];
	}
	if(self.hangerSN != nil){
		[aCoder encodeObject:self.hangerSN forKey:kKDSDeviceHangerModelHangerSN];
	}
	if(self.hangerVersion != nil){
		[aCoder encodeObject:self.hangerVersion forKey:kKDSDeviceHangerModelHangerVersion];
	}
	[aCoder encodeObject:@(self.isAdmin) forKey:kKDSDeviceHangerModelIsAdmin];	if(self.light != nil){
		[aCoder encodeObject:self.light forKey:kKDSDeviceHangerModelLight];
	}
	[aCoder encodeObject:@(self.loudspeaker) forKey:kKDSDeviceHangerModelLoudspeaker];	if(self.moduleSN != nil){
		[aCoder encodeObject:self.moduleSN forKey:kKDSDeviceHangerModelModuleSN];
	}
	if(self.moduleVersion != nil){
		[aCoder encodeObject:self.moduleVersion forKey:kKDSDeviceHangerModelModuleVersion];
	}
	if(self.motor != nil){
		[aCoder encodeObject:self.motor forKey:kKDSDeviceHangerModelMotor];
	}
	[aCoder encodeObject:@(self.onlineState) forKey:kKDSDeviceHangerModelOnlineState];	[aCoder encodeObject:@(self.overload) forKey:kKDSDeviceHangerModelOverload];	[aCoder encodeObject:@(self.status) forKey:kKDSDeviceHangerModelStatus];	if(self.uid != nil){
		[aCoder encodeObject:self.uid forKey:kKDSDeviceHangerModelUid];
	}
	if(self.uname != nil){
		[aCoder encodeObject:self.uname forKey:kKDSDeviceHangerModelUname];
	}
	[aCoder encodeObject:@(self.updateTime) forKey:kKDSDeviceHangerModelUpdateTime];	if(self.wifiSN != nil){
		[aCoder encodeObject:self.wifiSN forKey:kKDSDeviceHangerModelWifiSN];
	}

}

/**
 * Implementation of NSCoding initWithCoder: method
 */
- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super init];
	self.uV = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelUV];
	self.idField = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelIdField];
	self.adminName = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelAdminName];
	self.adminUid = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelAdminUid];
	self.airDry = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelAirDry];
	self.baking = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelBaking];
	self.childLock = [[aDecoder decodeObjectForKey:kKDSDeviceHangerModelChildLock] integerValue];
	self.hangerNickName = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelHangerNickName];
	self.hangerSN = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelHangerSN];
	self.hangerVersion = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelHangerVersion];
	self.isAdmin = [[aDecoder decodeObjectForKey:kKDSDeviceHangerModelIsAdmin] integerValue];
	self.light = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelLight];
	self.loudspeaker = [[aDecoder decodeObjectForKey:kKDSDeviceHangerModelLoudspeaker] integerValue];
	self.moduleSN = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelModuleSN];
	self.moduleVersion = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelModuleVersion];
	self.motor = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelMotor];
	self.onlineState = [[aDecoder decodeObjectForKey:kKDSDeviceHangerModelOnlineState] integerValue];
	self.overload = [[aDecoder decodeObjectForKey:kKDSDeviceHangerModelOverload] integerValue];
	self.status = [[aDecoder decodeObjectForKey:kKDSDeviceHangerModelStatus] integerValue];
	self.uid = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelUid];
	self.uname = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelUname];
	self.updateTime = [[aDecoder decodeObjectForKey:kKDSDeviceHangerModelUpdateTime] integerValue];
	self.wifiSN = [aDecoder decodeObjectForKey:kKDSDeviceHangerModelWifiSN];
	return self;

}

/**
 * Implementation of NSCopying copyWithZone: method
 */
- (instancetype)copyWithZone:(NSZone *)zone
{
	KDSDeviceHangerModel *copy = [KDSDeviceHangerModel new];

	copy.uV = [self.uV copy];
	copy.idField = [self.idField copy];
	copy.adminName = [self.adminName copy];
	copy.adminUid = [self.adminUid copy];
	copy.airDry = [self.airDry copy];
	copy.baking = [self.baking copy];
	copy.childLock = self.childLock;
	copy.hangerNickName = [self.hangerNickName copy];
	copy.hangerSN = [self.hangerSN copy];
	copy.hangerVersion = [self.hangerVersion copy];
	copy.isAdmin = self.isAdmin;
	copy.light = [self.light copy];
	copy.loudspeaker = self.loudspeaker;
	copy.moduleSN = [self.moduleSN copy];
	copy.moduleVersion = [self.moduleVersion copy];
	copy.motor = [self.motor copy];
	copy.onlineState = self.onlineState;
	copy.overload = self.overload;
	copy.status = self.status;
	copy.uid = [self.uid copy];
	copy.uname = [self.uname copy];
	copy.updateTime = self.updateTime;
	copy.wifiSN = [self.wifiSN copy];

	return copy;
}

+(NSArray *) hangersFromDictArray:(NSArray <NSDictionary *>*) array {
    NSMutableArray *lArray = nil;
    if (array) {
        lArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            KDSDeviceHangerModel *hanger = [[KDSDeviceHangerModel alloc] initWithDictionary:dict];
            [lArray addObject:hanger];
        }
    }
    return lArray;
     
}
@end
