//
//  KDSMineViewController.m
//  KaadasLock
//
//  Created by wzr on 2019/1/15.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSMineViewController.h"
#import "MineCell.h"
#import "KDSMyMessageVC.h"
#import "KDSMyMessageCell.h"
#import "KDSUserCenterVC.h"
#import "KDSSecuritySettingVC.h"
#import "KDSFAQViewController.h"

#import "KDSFAQ2ViewController.h"

#import "KDSAboutVC.h"
#import "KDSUserFeedbackVC.h"
#import "KDSSystemSettingVC.h"
#import "KDSDBManager.h"
#import <AVFoundation/AVFoundation.h>
#import "RHScanViewController.h"
#import "KDSHttpManager+User.h"

@interface KDSMineViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)KDSMyMessageCell * heardView;


@end

@implementation KDSMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = KDSRGBColor(242, 242, 242);
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.separatorInset=UIEdgeInsetsMake(0,60, 0, 20);
    self.tableView.separatorColor = KDSRGBColor(206, 206, 206);
    self.heardView.frame = CGRectMake(0, 0, 0, 215);
    self.tableView.rowHeight = KDSScreenHeight < 667 ? 45:65;
    self.tableView.tableHeaderView = self.heardView;
    self.tableView.tableFooterView = [UIView new];
    [_tableView registerNib:[UINib nibWithNibName:@"MineCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MineCell"];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localeLanguageDidChange:) name:KDSLocaleLanguageDidChangeNotification object:nil];
    [self getUserNickname];
    [self getUserAvatar];
    [self getUserNickname];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ///设置头像--昵称
    KDSUserManager *userMgr = [KDSUserManager sharedManager];
    userMgr.userNickname = [[KDSDBManager sharedManager] queryUserNickname];
    self.heardView.nickNameLabel.text = userMgr.userNickname ?: userMgr.user.name;
    KDSDBManager *dbMgr = [KDSDBManager sharedManager];
    NSData *imgData = [dbMgr queryUserAvatarData];
    if (!imgData) [self getUserAvatar];
    UIImage *img = imgData ? [[UIImage alloc] initWithData:imgData] : [UIImage imageNamed:@"头像-默认"];
    self.heardView.heardImageView.image = img;
}

#pragma mark - 网络请求方法。
///获取用户昵称，刷新界面和更新数据库。
- (void)getUserNickname
{
    KDSUserManager *userMgr = [KDSUserManager sharedManager];
    KDSDBManager *dbMgr = [KDSDBManager sharedManager];
    [[KDSHttpManager sharedManager] getUserNicknameWithUid:userMgr.user.uid success:^(NSString * _Nullable nickname) {
        !nickname ?: (void)((void)(self.heardView.nickNameLabel.text = nickname), [dbMgr updateUserNickname:nickname]);
    } error:nil failure:nil];
}

///获取用户头像，刷新界面和更新数据库。
- (void)getUserAvatar
{
    KDSUserManager *userMgr = [KDSUserManager sharedManager];
    KDSDBManager *dbMgr = [KDSDBManager sharedManager];
    [[KDSHttpManager sharedManager] getUserAvatarImageWithUid:userMgr.user.uid success:^(UIImage * _Nullable image) {
        if (image)
        {
            self.heardView.heardImageView.image = image;
            CGImageAlphaInfo info = CGImageGetAlphaInfo(image.CGImage);
            if (info==kCGImageAlphaNone || info==kCGImageAlphaNoneSkipLast || info==kCGImageAlphaNoneSkipFirst)
            {
                [dbMgr updateUserAvatarData:UIImageJPEGRepresentation(image, 1.0)];
            }
            else
            {
                [dbMgr updateUserAvatarData:UIImagePNGRepresentation(image)];
            }
        }
    } error:nil failure:nil];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return indexPath.row==0 ? 0.001 : 60;//产品激活此版本隐藏
    }
    return 60;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }if (section == 1) {
        return 4;
    }if (section == 2) {
        return 2;
    }
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    return view;
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    MineCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MineCell"];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
   
    if (indexPath.section == 0)
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.iconeImageView.image = [UIImage imageNamed:@"message"];
        cell.titleNameLabel.text = Localized(@"message");
      
    }
    if (indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSArray *imgNames = @[@"ProductActivation",@"securitySetting",@"UserFeedback",@"CommonProblem"];
        NSArray *titles = @[Localized(@"ProductActivation"), Localized(@"securitySetting"), Localized(@"UserFeedback"), Localized(@"CommonProblem")];
        cell.iconeImageView.image =[UIImage imageNamed:imgNames[indexPath.row]];
        cell.titleNameLabel.text = titles[indexPath.row];
        if (indexPath.row==0) {
            cell.hidden = YES;//产品激活此版本隐藏
        }
    }
    if (indexPath.section == 2) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        NSArray *imgNames = @[@"MySettings", @"AboutUs"];
        NSArray *titles = @[Localized(@"MySettings"), Localized(@"AboutUs")];
        cell.iconeImageView.image = [UIImage imageNamed:imgNames[indexPath.row]];
        cell.titleNameLabel.text = titles[indexPath.row];
    }
 
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {///我的消息
        
        KDSMyMessageVC * messageVC = [KDSMyMessageVC new];
        messageVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:messageVC animated:YES];
        
    }else if (indexPath.section == 1){
        switch (indexPath.row) {
            case 0:///产品激活
            {
                ///鉴权相机权限
//                RHScanViewController *vc = [RHScanViewController new];
//                vc.isOpenInterestRect = YES;
//                vc.isVideoZoom = YES;
//                vc.hidesBottomBarWhenPushed = YES;
//                vc.fromWhereVC = @"MineVC";//产品激活
//                [self.navigationController pushViewController:vc animated:YES];
            }
                break;
            case 1:///安全设置
            {
                KDSSecuritySettingVC * securitySettingVC = [KDSSecuritySettingVC new];
                securitySettingVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:securitySettingVC animated:YES];
            }
                break;
            case 2:///用户反馈
            {
                KDSUserFeedbackVC * userFeedbackVC = [KDSUserFeedbackVC new];
                userFeedbackVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:userFeedbackVC animated:YES];
                
            }
                break;
            case 3:///常见问题
            {
                KDSFAQ2ViewController * faqVC = [KDSFAQ2ViewController new];
                faqVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:faqVC animated:YES];
            }
                break;
                
            default:
                break;
        }
    }else if (indexPath.section == 2){
        switch (indexPath.row) {
            case 0:///我的设置
                {
                    KDSSystemSettingVC * settingVC = [KDSSystemSettingVC new];
                    settingVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:settingVC animated:YES];
                    
                }
                break;
            case 1:///关于我们
            {
                KDSAboutVC * aboutVC = [KDSAboutVC new];
                aboutVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:aboutVC animated:YES];
               
            }
                break;
                
            default:
                break;
        }
    }

    
}

#pragma mark Lazy load

-(KDSMyMessageCell *)heardView
{
    if (!_heardView) {
        
        _heardView = ({
             __weak typeof(self) weakSelf = self;
            KDSMyMessageCell * h = [KDSMyMessageCell new];
            h.backgroundColor = [UIColor clearColor];
            h.block = ^(id _Nonnull param) {
                NSLog(@"点击了头像");
                
                KDSUserCenterVC * userCenterVC = [KDSUserCenterVC new];
                userCenterVC.hidesBottomBarWhenPushed = YES;
                [weakSelf.navigationController pushViewController:userCenterVC animated:YES];
            };
            h;
        });
    }
    
    return _heardView;
}

#pragma mark - 通知
///收到更改了本地语言的通知，刷新表视图。
- (void)localeLanguageDidChange:(NSNotification *)noti
{
    [self.tableView reloadData];
}

@end
