#import <UIKit/UIKit.h>

@interface KDSDeviceHangerSwitch : NSObject

@property (nonatomic, assign) NSInteger countdown;
@property (nonatomic, assign) NSInteger switchField;

-(instancetype)initWithDictionary:(NSDictionary *)dictionary;

-(NSDictionary *)toDictionary;
@end
