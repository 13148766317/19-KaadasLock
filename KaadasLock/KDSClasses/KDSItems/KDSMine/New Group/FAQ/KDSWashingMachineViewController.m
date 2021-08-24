//
//  KDSWashingMachineViewController.m
//  KaadasLock
//
//  Created by kaadas on 2021/1/25.
//  Copyright © 2021 com.Kaadas. All rights reserved.
//

#import "KDSWashingMachineViewController.h"
#import "KDSHttpManager+User.h"
#import "KDSDBManager.h"
#import "MJRefresh.h"
#import "MBProgressHUD+MJ.h"


@interface KDSFAQ3View : UIView
@property (nonatomic, strong) KDSFAQ *faq;
@end

@implementation KDSFAQ3View

@end

@interface KDSWashingMachineViewController ()<UIScrollViewDelegate>
///滚动视图。
@property (nonatomic, strong) UIScrollView *scrollView;
///线
@property (nonatomic, strong) UIView *separator;

@end

@implementation KDSWashingMachineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kStatusBarHeight - kNavBarHeight)];
    self.scrollView.delegate = self;
    self.scrollView.backgroundColor = self.view.backgroundColor;

    [self.view addSubview:self.scrollView];
    //本地生成faq,用不着刷新与获取
    /*
     __weak typeof(self) weakSelf = self;
    self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf getFAQ];
    }];
    NSArray<KDSFAQ *> *faqs = [[KDSDBManager sharedManager] queryFAQOrMessage:1];
    [self createAndUpdateFAQSubviews:faqs];
    [self getFAQ];
     */
    [self localFAQ];
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
        KDSFAQ3View *existedView = nil;
        for (UIView *sub in self.scrollView.subviews)
        {
            if ([sub isKindOfClass:KDSFAQ3View.class] && [((KDSFAQ3View *)sub).faq isEqual:faq])
            {
                existedView = (KDSFAQ3View *)sub;
                break;
            }
        }
        if (existedView)
        {
            if (!([existedView.faq.question isEqualToString:faq.question] || [existedView.faq.answer isEqualToString:faq.answer]))
            {//内容不同重新创建一个。
                NSString *answer = [[faq.answer stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\n"] stringByReplacingOccurrencesOfString:@"\n\r" withString:@"\n"];
                KDSFAQ3View *view = [self createQAndAView:@{faq.question : answer}];
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
        KDSFAQ3View *view = [self createQAndAView:@{faq.question : answer}];
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
- (KDSFAQ3View *)createQAndAView:(NSDictionary<NSString *, NSString *> *)qAndA
{
    KDSFAQ3View *view = [[KDSFAQ3View alloc] init];
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
+ (KDSFAQ
   *) createFAQ:(NSString
                 *) idField question:(NSString *) question answer:(NSString
                                                                   *) answer {
    KDSFAQ *faq = [[KDSFAQ alloc] init];
    faq._id = idField;
    faq.question = question;
    faq.answer = answer;
    return faq;
}

-(void) localFAQ {

    NSMutableArray *faqs = [[NSMutableArray alloc] init];
    
    [faqs addObject:[KDSWashingMachineViewController createFAQ:@"1" question:NSLocalizedString(@"按了遥控器灯亮，但是机器没有反应怎么办？",nil) answer:NSLocalizedString(@"同时按住“停止键”和“童锁键”3秒，听到晾衣机短响一声后即可恢复。", nil)]];
    [faqs addObject:[KDSWashingMachineViewController createFAQ:@"2" question:NSLocalizedString(@"衣杆不上不下怎么办？",nil) answer:NSLocalizedString(@"① 确认衣杆是否安装完整，安装完整即可正常使用；\n② 衣杆下降或上升过程中是否遇到障碍物，移开障碍物即可恢复使用。", nil)]];
    [faqs addObject:[KDSWashingMachineViewController createFAQ:@"3" question:NSLocalizedString(@"晾衣机指示常亮红灯是怎么回事？",nil) answer:NSLocalizedString(@"配网失败或超时未配网，正常配网成功后会变为绿色常亮3分钟，如不操作，红灯也会在3分钟后熄灭。", nil)]];

    
    [self createAndUpdateFAQSubviews:faqs];
    
}
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
                if ([sub isKindOfClass:KDSFAQ3View.class])
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
    NSDictionary *pushNoti = @{@"按了遥控器灯亮，但是机器没有反应怎么办？" : @"同时按住“停止键”和“童锁键”3秒，听到晾衣机短响一声后即可恢复。"};
    NSDictionary *hwUpdate = @{@"衣杆不上不下怎么办？" : @"① 确认衣杆是否安装完整，安装完整即可正常使用；② 衣杆下降或上升过程中是否遇到障碍物，移开障碍物即可恢复使用。"};
    NSDictionary *distance = @{@"晾衣机指示常亮红灯是怎么回事？" : @"① 确认衣杆是否安装完整，安装完整即可正常使用；② 衣杆下降或上升过程中是否遇到障碍物，移开障碍物即可恢复使用。"};
    return @[pushNoti, hwUpdate, distance];
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
