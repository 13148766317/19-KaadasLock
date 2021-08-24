//
//  KDSLockFAQViewController.m
//  KaadasLock
//
//  Created by kaadas on 2021/1/25.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSLockFAQViewController.h"
#import "KDSHttpManager+User.h"
#import "KDSDBManager.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"


@interface KDSFAQ2View : UIView

@property (nonatomic, strong) KDSFAQ *faq;

@end
@implementation KDSFAQ2View

@end

@interface KDSLockFAQViewController ()<UIScrollViewDelegate>
///滚动视图。
@property (nonatomic, strong) UIScrollView *scrollView;
///线
@property (nonatomic, strong) UIView *separator;
@end

@implementation KDSLockFAQViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kStatusBarHeight - kNavBarHeight)];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = self.view.backgroundColor;

    [self.view addSubview:self.scrollView];
    __weak typeof(self) weakSelf = self;
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getFAQ];
    }];
    NSArray<KDSFAQ *> *faqs = [[KDSDBManager sharedManager] queryFAQOrMessage:1];
    [self createAndUpdateFAQSubviews:faqs];
    [self getFAQ];
}
///根据FAQ数组创建并调整滚动视图的子视图。
- (void)createAndUpdateFAQSubviews:(NSArray<KDSFAQ *> *)faqs
{
    NSMutableArray *deduplication = [NSMutableArray array];
    for (KDSFAQ *faq in faqs)
    {
        if (![deduplication containsObject:faq]) [deduplication addObject:faq];
    }
    faqs = deduplication;
    CGFloat height = self.scrollView.contentSize.height;
    CGFloat del = 0;
    UIView *createdView = nil;
    for (KDSFAQ *faq in faqs)
    {
        NSArray<KDSFAQ *> *subarr = [faqs subarrayWithRange:NSMakeRange(0, [faqs indexOfObject:faq])];
        if ([subarr containsObject:faq]) continue;
        KDSFAQ2View *existedView = nil;
        for (UIView *sub in self.scrollView.subviews)
        {
            if ([sub isKindOfClass:KDSFAQ2View.class] && [((KDSFAQ2View *)sub).faq isEqual:faq])
            {
                existedView = (KDSFAQ2View *)sub;
                break;
            }
        }
        if (existedView)
        {
            if (!([existedView.faq.question isEqualToString:faq.question] || [existedView.faq.answer isEqualToString:faq.answer]))
            {//内容不同重新创建一个。
                NSString *answer = [[faq.answer stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"] stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];
                KDSFAQ2View *view = [self createQAndAView:@{faq.question : answer}];
                view.faq = faq;
                view.frame = (CGRect){0, CGRectGetMaxY(createdView.frame), kScreenWidth, existedView.frame.size.height==60 ? 60 : view.tag};
                NSUInteger index = [self.scrollView.subviews indexOfObject:existedView];
                [existedView removeFromSuperview];
                [self.scrollView insertSubview:view atIndex:index];
                createdView = view;
                del += view.bounds.size.height - existedView.bounds.size.height;
            }
            else
            {
                CGRect frame = existedView.frame;
                frame.origin.y = CGRectGetMaxY(createdView.frame);
                existedView.frame = frame;
                createdView = existedView;
            }
            continue;
        }
        NSString *answer = [[faq.answer stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"] stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];
        KDSFAQ2View *view = [self createQAndAView:@{faq.question : answer}];
        view.faq = faq;
        view.frame = (CGRect){0, CGRectGetMaxY(createdView.frame), kScreenWidth, 60};
        [self.scrollView addSubview:view];
        createdView = view;
        del += 60;
    }
    self.scrollView.contentSize = CGSizeMake(kScreenWidth, height==0 ? del+createdView.tag : height+del);
}





/**
 *@abstract 根据问题和答案以及原点y创建一个视图添加到滚动视图上，已添加一个点击手势展开、闭合视图，tag设置为视图展开时的高度。
 *@param qAndA 问题和答案字典，key是问题，value是答案。
 *@return 添加点击手势的视图。
 */
- (KDSFAQ2View *)createQAndAView:(NSDictionary<NSString *, NSString *> *)qAndA
{
    KDSFAQ2View *view = [[KDSFAQ2View alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    view.clipsToBounds = YES;
    
    UIImage *arrowImg = [UIImage imageNamed:@"rightArrow"];
    NSString *question = [qAndA.allKeys.firstObject stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSRange range = [question rangeOfString:@"."];
    if (range.length) question = [question substringFromIndex:range.location + range.length];
    ///问题
    UIFont *font = [UIFont systemFontOfSize:13];
    //CGRect bounds = [question boundingRectWithSize:CGSizeMake(kScreenWidth - 34 - arrowImg.size.width - 17, 200) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil];
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(17, 0, kScreenWidth - 34 - arrowImg.size.width - 7, 60)];
    questionLabel.textColor = KDSRGBColor(0x2b, 0x2f, 0x50);
    questionLabel.font = font;
    questionLabel.text = question;
    questionLabel.numberOfLines = 0;
    [view addSubview:questionLabel];
    ///右箭头
    UIImageView *arrowIV = [[UIImageView alloc] initWithImage:arrowImg];
    arrowIV.bounds = (CGRect){0, 0, arrowImg.size};
    arrowIV.center = CGPointMake(kScreenWidth - 17 - arrowImg.size.width / 2, 30);
//    arrowIV.transform = CGAffineTransformRotate(arrowIV.transform, -M_PI_2);
    [view addSubview:arrowIV];
    
    ////分割线
    self.separator= [[UIView alloc] initWithFrame:CGRectMake(17, 59, kScreenWidth - 17, 1)];
    self.separator.backgroundColor = KDSRGBColor(234, 233, 233);
    self.separator.tag = 1234;//其实这个不用提取
    [view addSubview:self.separator];
    
    NSArray<NSString *> *comps = [qAndA.allValues.firstObject componentsSeparatedByString:@"\n"];
    UIView *existedView = nil;
    UIColor *color = KDSRGBColor(51, 51, 51);
    ///灰色背景图
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(17, CGRectGetMaxY(self.separator.frame), kScreenWidth - 34, 100)];
    [view addSubview:v];
    v.backgroundColor = KDSRGBColor(242, 242, 242);
    v.layer.masksToBounds = YES;
    v.layer.cornerRadius = 5;
    CGFloat th = 0; int count = 0;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    NSDictionary *attr = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:style};
    for (NSString *str in comps)
    {
        NSString *clippedStr = [str stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        if (comps.count > 1)
        {
            range = [clippedStr rangeOfString:@"."];
            if (range.length)
            {
                style.headIndent = ceil([[clippedStr substringToIndex:range.location + range.length] sizeWithAttributes:attr].width + 1.8);
            }
        }
        UILabel *label = [[UILabel alloc] init];
        label.font = font;
        label.attributedText = [[NSAttributedString alloc] initWithString:clippedStr attributes:attr];
        label.textColor = color;
        label.numberOfLines = 0;
        CGFloat height = ceil([label.attributedText boundingRectWithSize:CGSizeMake(kScreenWidth - 64, kScreenHeight) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.height);
        if (height <= 21) height = 16;//系统的排版可能有些问题
        label.frame = (CGRect){15, existedView ? (CGRectGetMaxY(existedView.frame) + 5) : 17, kScreenWidth - 64, height};
        [v addSubview:label];
        existedView = label;
        th += height;
        count++;
    }
    CGRect frame = v.frame;
    frame.size.height = th+count+34;
    v.frame = frame;
    view.tag = CGRectGetMaxY(v.frame) + 24;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapToShowOrHideAnswers:)];
    [view addGestureRecognizer:tap];
    
    return view;
}

///点击展开/收缩答案。
- (void)tapToShowOrHideAnswers:(UITapGestureRecognizer *)sender
{
    sender.view.userInteractionEnabled = NO;
    UIImageView *arrowIV = nil;
    for (UIView *sub in sender.view.subviews)
    {
        if ([sub isKindOfClass:UIImageView.class])
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
            arrowIV = sub;
#pragma clang diagnostic pop
            break;
        }
    }
    CGFloat height = sender.view.bounds.size.height;
    CGRect frame = sender.view.frame;
    frame.size.height += height==60 ? sender.view.tag-60 : 60-sender.view.tag;
    CGSize size = self.scrollView.contentSize;
    size.height += height==60 ? sender.view.tag-60 : 60-sender.view.tag;
    self.scrollView.contentSize = size;
    UIView *separator = [sender.view viewWithTag:1234];
    CGRect sFrame = separator.frame;
    sFrame.origin.y = height==60 ? sender.view.tag - 1 : 59;
    if (sFrame.origin.y == 59) {
        [UIView animateWithDuration:0.2 animations:^{
            arrowIV.transform = CGAffineTransformRotate(arrowIV.transform, -M_PI_2);
            sender.view.frame = frame;
            separator.frame = sFrame;
            BOOL after = NO;
            for (UIView *sub in self.scrollView.subviews)
            {
                if (sub == sender.view)
                {
                    after = YES;
                    continue;
                }
                if (after && ![sub isKindOfClass:UIImageView.class])
                {
                    CGRect frame = sub.frame;
                    frame.origin.y += height==60 ? sender.view.tag-60 : 60-sender.view.tag;
                    sub.frame = frame;
                }
            }
        } completion:^(BOOL finished) {
             sender.view.userInteractionEnabled = YES;
        }];
    }else{
        [UIView animateWithDuration:0.2 animations:^{
            arrowIV.transform = CGAffineTransformRotate(arrowIV.transform, M_PI_2);
            sender.view.frame = frame;
            separator.frame = sFrame;
            BOOL after = NO;
            for (UIView *sub in self.scrollView.subviews)
            {
                if (sub == sender.view)
                {
                    after = YES;
                    continue;
                }
                if (after && ![sub isKindOfClass:UIImageView.class])
                {
                    CGRect frame = sub.frame;
                    frame.origin.y += height==60 ? sender.view.tag-60 : 60-sender.view.tag;
                    sub.frame = frame;
                }
            }
        } completion:^(BOOL finished) {
            sender.view.userInteractionEnabled = YES;
        }];
    }
   
}

#pragma mark - 网络请求方法。
- (void)getFAQ
{
    NSString *language = [KDSTool getLanguage];
    int lan = 3;
    if ([language hasPrefix:JianTiZhongWen]) {//开头匹配简体中文
        lan = 1;
    }
    else if ([language hasPrefix:FanTiZhongWen]) {//开头匹配繁体中文
        lan = 2;
    }else if ([language hasPrefix:@"th"]){
        lan = 4;
    }else{//其他一律设置为英文
        lan = 3;
    }
    lan = 1;
    
    [[KDSHttpManager sharedManager] getFAQ:lan success:^(NSArray<KDSFAQ *> * _Nonnull faqs) {
        NSArray<KDSFAQ *> *dbFaqs = [[KDSDBManager sharedManager] queryFAQOrMessage:1];
        [[KDSDBManager sharedManager] deleteFAQOrMessage:nil type:1];
        [[KDSDBManager sharedManager] insertFAQOrMessage:faqs];
        if (dbFaqs.firstObject.language != lan)
        {
            for (UIView *sub in self.scrollView.subviews)
            {
                if ([sub isKindOfClass:KDSFAQ2View.class])
                {
                    [sub removeFromSuperview];
                }
            }
            self.scrollView.contentSize = CGSizeZero;
        }
        [self createAndUpdateFAQSubviews:faqs];
        self.scrollView.mj_header.state = MJRefreshStateIdle;
        
    } error:^(NSError * _Nonnull error) {
        self.scrollView.mj_header.state = MJRefreshStateIdle;
        NSArray<KDSFAQ *> *faqs = [[KDSDBManager sharedManager] queryFAQOrMessage:1];
        if (!faqs.count)
        {
            [MBProgressHUD showError:[NSString stringWithFormat:@"error: %ld", (long)error.localizedDescription]];
        }
    } failure:^(NSError * _Nonnull error) {
        self.scrollView.mj_header.state = MJRefreshStateIdle;
        NSArray<KDSFAQ *> *faqs = [[KDSDBManager sharedManager] queryFAQOrMessage:1];
        if (!faqs.count)
        {
            [MBProgressHUD showError:error.localizedDescription];
        }
    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

#pragma mark - FAQ内容
///简体中文FAQ，字典key是标题，value是内容。
- (NSArray<NSDictionary<NSString *, NSString *> *> *)zhsFAQ
{
    NSDictionary *pushNoti = @{@"收不到推送通知" : @"1、请确保小凯智能App的通知权限是开启状态。\n2、请确小凯智能App对应的设备消息开关是否关闭：\n      具体查看：设备--更多-消息免打扰 是关闭状态。"};
    NSDictionary *reset = @{@"按了门锁的“重置”按钮，恢复出厂设置后无法使用" : @"门锁被重置、恢复出厂设置后，就无法继续使用了。请先到“更多”里进行“删除设备”操作，然后再重新进行设备添加，添加成功后即可继续使用。"};
    NSDictionary *hwUpdate = @{@"如何进行固件升级" : @"固件升级需要您打开手机蓝牙将手机贴近门锁，同时保持手机网络良好。"};
    NSDictionary *distance = @{@"门锁和手机蓝牙的有效距离多远" : @"无障碍物10米"};
    NSDictionary *authQues = @{@"无法管理授权（添加或删除指纹、密码等）" : @"请检查手机联网状态和蓝牙连接状态，管理操作需要在门锁旁边并且手机联网时才可以进行"};
    NSDictionary *fpSecurity = @{@"指纹开锁安全吗" : @"安全。我们所使用的活体指纹，会自动排除一些假指纹或者指纹膜，另外我们的指纹信息（包括密码信息）仅保留在锁里面，不用担心会泄露"};
    NSDictionary *powerless = @{@"门锁没电怎么办" : @"电量低于10%时，门锁及APP都会进行提示。如果没有及时更换电池造成电量用尽，可以用USB外接电源接在门锁外面板底部的应急电源接口进行应急供电，或者使用机械方式开锁。"};
    NSDictionary *fpUsers = @{@"老人和小孩能否用指纹开锁" : @"指纹锁支持7岁到70岁年龄范围的人群，但具体需要看指纹的磨损情况，磨损严重或者指纹浅的人会不太好用，这是指纹锁甚至智能手机上都有的问题。"};
    NSDictionary *fpReconize = @{@"遇到指纹开锁识别率不高怎么办" : @"指纹的识别率和人本身的指纹深浅有关系，也跟干湿手指、空气湿度等有关系。针对识别率不高的家人，建议对同一手指重复多添加几个指纹，同时要注意在添加指纹时采用正确的手握把手姿势，手指的多个角度均匀录入。"};
    NSDictionary *fpCantOpen = @{@"有效指纹无法开启" : @"1. 按用户手册及提示音重新再录入指纹。\n2. 按录入位置和力度放置手指。\n3. 用细木棒插入前执手的复位键5s左右，听到叮咛声，表示重启成功。\n4. 拔开连接线接头重新插到位。\n"};
    NSDictionary *pwdCantOpen = @{@"密码无法开启" : @"1. 如一直提示密码错误，用其它方式开启后，按用户手册重新设置密码试验。\n2. 用细木棒插入前执手的复位键5s左右，听到叮咛声，表示重启成功。\n3. 按用户手册试验。\n4. 拔开连接线接头重新插到位。\n5 .等待5 分钟后密码键盘恢复正常。"};
    NSDictionary *rfidCantOpen = @{@"卡片无法开启" : @"1. 重新再录入一次或用其它有效卡片试开验证。\n2. 卡片不合格，与当地代理商或售后服务中心联系。\n3. 用细木棒插入前执手的复位键 5s 左右，听到叮咛声，表示重启成功。\n4. 拔开连接线接头重新插到位"};
    NSDictionary *numFlash = @{@"数字键自动闪动" : @"1. 线被压断时与当地代理商或售后服务中心联系。\n2. 拔开连接线接头重新插到位。\n3. 重新安装好电池。\n4. 扳正或固紧排针后重新连接。"};
    NSDictionary *phoneLoss = @{@"手机丢失怎么办" : @"为防止丢失手机后他人直接进入APP开锁，可以在米家APP中设置进入锁设备界面的独立密码。这样即使拿到手机没有密码也无法控制开锁。"};
    NSDictionary *notiTooMore = @{@"推送提醒太频繁，怎么设置勿扰模式" : @"请到小凯智能APP“设备”-“选择设备”-“更多”-“消息免打扰”中设置免打扰时段。"};
    NSDictionary *hwUpdateFailed = @{@"固件升级不成功怎么办" : @"如果进度卡主可能是因为手机网络不好或手机与门锁的蓝牙连接已断开，请退出更新检查后重试一次。"};
    NSDictionary *deviceShare = @{@"“设备共享”是什么？怎么用" : @"通过门锁首页的“设备共享”，您可以将蓝牙钥匙发放给家人，而且除了用蓝牙钥匙开门，家人还可以查看设备动态等，与您一起守护家的安全。"};
    NSDictionary *bleCantConnect = @{@"使用过程中蓝牙连接不上怎么办" : @"可以尝试将手机蓝牙重新开关，并杀死App进程再重新打开，然后摸亮门锁密码键盘重新尝试连接。"};
    return @[pushNoti, reset, hwUpdate, distance, authQues, fpSecurity, powerless, fpUsers, fpReconize, fpCantOpen, pwdCantOpen, rfidCantOpen, numFlash, phoneLoss, notiTooMore, hwUpdateFailed, deviceShare, bleCantConnect];
}

///繁体中文FAQ，字典key是标题，value是内容。
- (NSArray<NSDictionary<NSString *, NSString *> *> *)zhtFAQ
{
    return nil;
}

///泰语FAQ，字典key是标题，value是内容。
- (NSArray<NSDictionary<NSString *, NSString *> *> *)thFAQ
{
    return nil;
}

///英语FAQ，字典key是标题，value是内容。
- (NSArray<NSDictionary<NSString *, NSString *> *> *)enFAQ
{
    return nil;
}


@end
