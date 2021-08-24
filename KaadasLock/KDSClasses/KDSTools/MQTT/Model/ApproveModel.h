//
//  ApproveModel.h
//  lock
//
//  Created by zhaowz on 2018/5/17.
//  Copyright © 2018年 zhao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApproveModel : NSObject
/*     "_id" = 5afbf0e6380df656adc83073;
 deviceNickName = UI01181910002;
 deviceSN = UI01181910002;
 requestTime = "2018-05-16 16:50:46";
 uid = 5a9ce65bf4dc324b1eca54ad;
 userNickname = 8613590300672;
 username = 8613590300672;*/
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *deviceNickName;
@property (nonatomic, copy) NSString *deviceSN;
@property (nonatomic, copy) NSString *requestTime;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *userNickname;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, strong) NSIndexPath *indexPath;


@end
