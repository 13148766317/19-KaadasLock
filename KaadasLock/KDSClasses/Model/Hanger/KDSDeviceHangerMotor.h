#import <UIKit/UIKit.h>

@interface KDSDeviceHangerMotor : NSObject

@property (nonatomic, assign) NSInteger action;
@property (nonatomic, assign) NSInteger status;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end