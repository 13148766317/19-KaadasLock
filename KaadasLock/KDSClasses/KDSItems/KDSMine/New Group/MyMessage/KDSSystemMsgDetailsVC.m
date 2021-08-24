//
//  KDSSystemMsgDetailsVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/4/2.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import "KDSSystemMsgDetailsVC.h"
#import "KDSSysMsgDetailsCell.h"

@interface KDSSystemMsgDetailsVC ()<UITableViewDataSource, UITableViewDelegate>


///行高。
@property (nonatomic, strong) NSArray<NSNumber *> *rowHeights;
///时间格式器，yyyy/MM/dd
@property (nonatomic, strong) NSDateFormatter *dateFmt;

@end

@implementation KDSSystemMsgDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = KDSRGBColor(242, 242, 242);
    self.navigationTitleLabel.text = Localized(@"msgDetails");
    
    self.dateFmt = [[NSDateFormatter alloc] init];
    self.dateFmt.dateFormat = @"yyyy/MM/dd HH:mm";
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).offset(10);
        make.bottom.right.equalTo(self.view).offset(-10);
    }];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundColor = self.view.backgroundColor;
}

- (void)setMessages:(KDSSysMessage *)messages
{
    _messages = messages;
    NSMutableArray *heights = [NSMutableArray array];
    CGFloat tHeight = ceil([messages.title boundingRectWithSize:CGSizeMake(kScreenWidth - 50, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]} context:nil].size.height);
    CGFloat cHeight = ceil([messages.content boundingRectWithSize:CGSizeMake(kScreenWidth - 50, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12]} context:nil].size.height);
    [heights addObject:@(20 + 8 + 12 + 15 + tHeight + 17.5 + cHeight + 17.5)];
    
    self.rowHeights = heights;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    return self.messages.count;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.rowHeights[indexPath.row].doubleValue;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseId = NSStringFromClass([self class]);
    KDSSysMsgDetailsCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (!cell)
    {
        cell = [[KDSSysMsgDetailsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseId];
    }
    KDSSysMessage *message = self.messages;
    cell.title = message.title;
    cell.content = message.content;
    cell.date = [self.dateFmt stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.createTime]];
    
    return cell;
}

@end
