//
//  KDSAppLogFormatter.m
//  KDSToolkit
//
//  Created by Apple on 2021/4/23.
//

#import "KDSAppLogFormatter.h"

@implementation KDSAppLogFormatter
- (NSString *)formatLogMessage:(DDLogMessage *)logMessage {
    return [NSString stringWithFormat:@"%@ %@  %@",logMessage.timestamp, logMessage.function,logMessage.message];
    
}
@end
