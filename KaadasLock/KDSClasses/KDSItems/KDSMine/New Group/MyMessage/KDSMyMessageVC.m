//
//  KDSMyMessageVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/3/30.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSMyMessageVC.h"
#import "KDSMyMessageContentView.h"
#import "KDSMyMessageinfoStyleOneCell.h"
#import "KDSMyMessageinfoStyleTwoCell.h"
#import "KDSSystemMsgDetailsVC.h"
#import "KDSHttpManager+User.h"
#import "KDSDBManager.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"


@interface KDSMyMessageVC ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,readwrite,strong) KDSMyMessageContentView * noDataView;
///数据源数组。
@property (nonatomic,readwrite,strong) NSMutableArray<KDSSysMessage *> *messages;
///时间格式器，yyyy/MM/dd
@property (nonatomic,readwrite,strong) NSDateFormatter *dateFmt;
///左滑删除事件。
@property (nonatomic, strong) UITableViewRowAction *deleteAction;
///圆角视图。
@property (nonatomic, strong) UIView *cornerView;
@property (nonatomic, assign) int pageCount;

@end

@implementation KDSMyMessageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = Localized(@"message");
    self.dateFmt = [[NSDateFormatter alloc] init];
    self.dateFmt.dateFormat = @"yyyy/MM/dd";
    _pageCount = 1;
    [self setUI];
    [self loadNewData];
    self.messages = [NSMutableArray array];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessage)];
    [self.tableView registerClass:[KDSMyMessageinfoStyleTwoCell class] forCellReuseIdentifier:@"KDSMyMessageinfoStyleTwoCell"];
    [self.tableView registerClass:[KDSMyMessageinfoStyleOneCell class] forCellReuseIdentifier:@"KDSMyMessageinfoStyleOneCell"];
}

-(void)setUI
{
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
}
///刷新表视图。调用此方法前请确保已经对数据源进行了更新。
- (void)reloadData
{
    if (!self.messages.count)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tableView.tableFooterView = self.noDataView;
        });
    }
    else
    {
        self.tableView.tableFooterView = [UIView new];
    }
    [self.tableView reloadData];
}

- (UITableViewRowAction *)deleteAction
{
    if (!_deleteAction)
    {
        __weak typeof(self) weakSelf = self;
        _deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:Localized(@"delete") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            KDSSysMessage *message = weakSelf.messages[indexPath.row];
            [weakSelf.messages removeObject:message];
            [weakSelf.tableView beginUpdates];
            [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
            [weakSelf.tableView endUpdates];
            [weakSelf scrollViewDidScroll:weakSelf.tableView];
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                message.deleted = YES;
                [[KDSDBManager sharedManager] deleteFAQOrMessage:message type:2];
                [weakSelf deleteSystemMessage:message];
            });
        }];
    }
    return _deleteAction;
}

#pragma mark - 网络请求方法

///获取第几页的消息，从1起。
- (void)loadNewData
{
    [[KDSHttpManager sharedManager] getSystemMessageWithUid:[KDSUserManager sharedManager].user.uid page:1 success:^(NSArray<KDSSysMessage *> * _Nonnull messages) {
        [self.messages removeAllObjects];
        [self.messages addObjectsFromArray:messages];
        [self reloadData];
        _pageCount = 1;
        [self.tableView.mj_footer resetNoMoreData];
        self.tableView.mj_header.state = MJRefreshStateIdle;
    } error:^(NSError * _Nonnull error) {
        self.tableView.mj_header.state = MJRefreshStateIdle;

    } failure:^(NSError * _Nonnull error) {
        self.tableView.mj_header.state = MJRefreshStateIdle;

    }];
}

-(void)loadMoreMessage{
    
    [[KDSHttpManager sharedManager] getSystemMessageWithUid:[KDSUserManager sharedManager].user.uid page:_pageCount +1 success:^(NSArray<KDSSysMessage *> * _Nonnull messages) {
        if (messages.count == 0)
        {
            self.tableView.mj_footer.state = MJRefreshStateNoMoreData;
            return;
        }
        _pageCount ++;
        for (KDSSysMessage * message in messages) {
            if (![self.messages containsObject:message]) {
                [self.messages addObjectsFromArray:messages];
            }
        }

        [self reloadData];
       
        self.tableView.mj_footer.state = MJRefreshStateIdle;
        
    } error:^(NSError * _Nonnull error) {

    self.tableView.mj_footer.state = MJRefreshStateIdle;

    } failure:^(NSError * _Nonnull error) {
        self.tableView.mj_footer.state = MJRefreshStateIdle;

    }];
}

///删除本地的系统消息。该方法内会查询本地有没有已标记删除的消息，如果有会请求服务器将其删除，请在子线程执行。
- (void)deleteSystemMessage:(KDSSysMessage * __nullable )message
{
    [[KDSHttpManager sharedManager] deleteSystemMessage:message withUid:[KDSUserManager sharedManager].user.uid success:^{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
           [[KDSDBManager sharedManager] deleteFAQOrMessage:message type:2];
        });
               
    } error:nil failure:nil];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat maxHeight = kScreenHeight - kStatusBarHeight - kNavBarHeight;
    CGFloat rowHeight = self.tableView.rowHeight;
    CGFloat height = self.messages.count * rowHeight;
    if (offsetY < 0)
    {
        //不能超过上限
        CGFloat originY = 10 - offsetY;
        height = height + originY > maxHeight ? maxHeight + 10 - originY : height;
        height = height < 0 ? 0 : height;
        self.cornerView.frame = CGRectMake(0, originY, kScreenWidth, height);
    }
    else
    {
        //不能超过上下限
        height -= offsetY;
        height = height > maxHeight ? maxHeight : height;
        height = height < 0 ? 0 : height;
        self.cornerView.frame = CGRectMake(0, 0, kScreenWidth, height);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self scrollViewDidScroll:scrollView];
}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messages.count;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @[self.deleteAction];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSSysMessage * message = self.messages[indexPath.row];

    if (message.type == 1) {//系统消息
        KDSMyMessageinfoStyleOneCell *oneCell = [tableView dequeueReusableCellWithIdentifier:@"KDSMyMessageinfoStyleOneCell" forIndexPath:indexPath];
        oneCell.clipsToBounds = YES;
        oneCell.titleLabel.text = message.title;
        oneCell.detailLabel.text = message.content;

        oneCell.timeLabel.text = [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.createTime]];
        return oneCell;
    }
    KDSMyMessageinfoStyleTwoCell *twoCell = [tableView dequeueReusableCellWithIdentifier:@"KDSMyMessageinfoStyleTwoCell" forIndexPath:indexPath];
    twoCell.clipsToBounds = YES;
    twoCell.titleLabel.text = message.title;
    twoCell.timeLabel.text = [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.createTime]];
    return twoCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSSystemMsgDetailsVC *sysy = [[KDSSystemMsgDetailsVC alloc] init];
    sysy.messages = self.messages[indexPath.row];
    sysy.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:sysy animated:YES];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    KDSSysMessage * message = self.messages[indexPath.row];
    if (message.type == 1) {
        return 100;
    }
    return 70;
}

#pragma make --lazy load

- (KDSMyMessageContentView *)noDataView
{
    if (!_noDataView) {
        _noDataView = ({
            KDSMyMessageContentView * v = [[KDSMyMessageContentView alloc] initWithFrame:CGRectMake(0, 0, KDSScreenWidth, KDSScreenHeight)];
            v;
        });
    }
    return _noDataView;
}

@end
