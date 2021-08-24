//
//  TTQVideoListItemModel.h
//  KaadasLock
//
//  Created by kaadas on 2021/1/27.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 视频状态

 - TTQVideoItemStatusNormal: 0正常(审核通过)
 - TTQVideoItemStatusDeleted:  1已删除
 - TTQVideoItemStatusWaitingForReview: 2待审核
 - TTQVideoItemStatusReviewReject: 3审核不通过
 - TTQVideoItemStatusReviewRecommend: 4首推
 - TTQVideoItemStatusDeletedWithJunk: 5反垃圾删除
 - TTQVideoItemStatusDeletedByUser: 6用户自己删除
 */
typedef NS_ENUM(NSUInteger, TTQVideoItemStatus) {
    TTQVideoItemStatusNormal = 0,
    TTQVideoItemStatusDeleted = 1,
    TTQVideoItemStatusWaitingForReview = 2,
    TTQVideoItemStatusReviewReject = 3,
    TTQVideoItemStatusReviewRecommend = 4,
    TTQVideoItemStatusDeletedWithJunk = 5,
    TTQVideoItemStatusDeletedByUser = 6,
};
NS_ASSUME_NONNULL_BEGIN

@interface TTQVideoListItemModel : NSObject
@property(nonatomic, assign) NSInteger videoID;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, assign) NSInteger play_count;///<播放次数
@property(nonatomic, assign) NSInteger praise_count;///<点赞数
@property(nonatomic, assign) NSInteger view_times;///<浏览量
@property(nonatomic, copy) NSString *redirect_url;///<跳转地址
@property(nonatomic, assign) TTQVideoItemStatus status;
@property(nonatomic, copy) NSString *status_desc;///<状态说明
@property(nonatomic, copy) NSString *published_date;///<发布时间
@property(nonatomic, copy) NSString *images;///<图片

@end

NS_ASSUME_NONNULL_END
