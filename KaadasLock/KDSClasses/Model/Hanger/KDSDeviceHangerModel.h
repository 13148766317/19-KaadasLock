#import <UIKit/UIKit.h>
#import "KDSDeviceHangerSwitch.h"
#import "KDSDeviceHangerMotor.h"

@interface KDSDeviceHangerModel : NSObject

@property (nonatomic, strong) KDSDeviceHangerSwitch * uV;
@property (nonatomic, strong) NSString * idField;
@property (nonatomic, strong) NSString * adminName;
@property (nonatomic, strong) NSString * adminUid;
@property (nonatomic, strong) KDSDeviceHangerSwitch * airDry;
@property (nonatomic, strong) KDSDeviceHangerSwitch * baking;
@property (nonatomic, assign) NSInteger childLock;
@property (nonatomic, strong) NSString * hangerNickName;
@property (nonatomic, strong) NSString * hangerSN;
@property (nonatomic, strong) NSString * hangerVersion;
@property (nonatomic, assign) NSInteger isAdmin;
@property (nonatomic, strong) KDSDeviceHangerSwitch * light;
@property (nonatomic, assign) NSInteger loudspeaker;
@property (nonatomic, strong) NSString * moduleSN;
@property (nonatomic, strong) NSString * moduleVersion;
@property (nonatomic, strong) KDSDeviceHangerMotor * motor;
@property (nonatomic, assign) NSInteger onlineState;
@property (nonatomic, assign) NSInteger overload;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString * uid;
@property (nonatomic, strong) NSString * uname;
@property (nonatomic, assign) NSInteger updateTime;
@property (nonatomic, strong) NSString * wifiSN;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;

+(NSArray *) hangersFromDictArray:(NSArray <NSDictionary *>*) array;
@end
