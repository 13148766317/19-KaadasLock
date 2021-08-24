#import <UIKit/UIKit.h>
#import "KDSDeviceHangerEventparam.h"

@interface KDSDeviceHangerState : NSObject

@property (nonatomic, strong) NSString * devtype;
@property (nonatomic, strong) KDSDeviceHangerEventparam * eventparams;
@property (nonatomic, strong) NSString * eventtype;
@property (nonatomic, strong) NSString * func;
@property (nonatomic, assign) NSInteger msgId;
@property (nonatomic, strong) NSString * msgtype;
@property (nonatomic, strong) NSString * timestamp;
@property (nonatomic, strong) NSString * wfId;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end