//
//  KDSTableViewController.h
//  xiaokaizhineng
//
//  Created by orange on 2019/1/15.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSBaseViewController.h"
#import "MJRefresh.h"
#import "Masonry.h"

NS_ASSUME_NONNULL_BEGIN

@interface KDSTableViewController : KDSBaseViewController

///table view的样式，默认UITableViewStylePlain。
@property (nonatomic, assign) UITableViewStyle style;
///本类创建的table view，默认约束上下左右和俯视图边缘一样。
@property (nonatomic, weak, readonly) UITableView *tableView;
///是否添加下拉刷新，默认否。
@property (nonatomic, assign) BOOL enablePulldown;
///是否添加上拉，默认否。
@property (nonatomic, assign) BOOL enablePullup;

///如果已添加下拉刷新，当下拉刷新时会执行此方法，默认什么都没做，子类重载添加具体的实现。
- (void)loadNewData;
///如果已添加上拉，当上拉时会执行此方法，默认什么都没做，子类重载添加具体的实现。
- (void)loadMoreData;

@end

NS_ASSUME_NONNULL_END
