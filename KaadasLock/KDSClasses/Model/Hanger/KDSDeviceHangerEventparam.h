#import <UIKit/UIKit.h>
#import "KDSDeviceHangerSwitch.h"
#import "KDSDeviceHangerMotor.h"

@interface KDSDeviceHangerEventparam : NSObject

@property (nonatomic, strong) KDSDeviceHangerSwitch * uV;
@property (nonatomic, strong) KDSDeviceHangerSwitch * airDry;
@property (nonatomic, strong) KDSDeviceHangerSwitch * baking;
@property (nonatomic, assign) NSInteger childLock;
@property (nonatomic, strong) KDSDeviceHangerSwitch * light;
@property (nonatomic, assign) NSInteger loudspeaker;
@property (nonatomic, strong) KDSDeviceHangerMotor * motor;
@property (nonatomic, assign) NSInteger overload;
@property (nonatomic, assign) NSInteger status;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
