//
//  AlarmFileShowViewController.m
//  lock
//
//  Created by wzr on 2019/4/11.
//  Copyright © 2019 zhao. All rights reserved.
//

#import "AlarmFileShowViewController.h"
#import "LxFTPRequest.h"
#import "MBProgressHUD+MJ.h"
#import "KdsKxMovieViewController.h"
#import "KDSDBManager+CY.h"
#import "KDSMQTTManager.h"
#import "KDSFTIndicator.h"
static NSString * const USERNAME = nil;
static NSString * const PASSWORD = nil;

#define PATHDOCUMNT  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]

@interface AlarmFileShowViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *picImgView;
@property(nonatomic,copy)NSURL * serverURL;
@property(nonatomic,copy)NSURL * localURL;
@property(nonatomic,copy)NSString * currentPath;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *playVideoBtn;
@property(nonatomic,assign)uint16_t ftpPort;//此次ftp打开的端口
@property(nonatomic,copy)NSString * ftpIPAddress;//此次ftp的
@property(nonatomic,copy)NSString * currentPicDatePath;//此次ftp的
@property (weak, nonatomic) IBOutlet UIButton *reLoadBtn;
@property(strong,nonatomic)LxFTPRequest * request;
@end

@implementation AlarmFileShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationTitleLabel.text = @"快照";
    self.navigationItem.title = [KDSTool timestampSwitchTime:self.currentFileName.integerValue andFormatter:@"yyyy-MM-dd HH:mm"];;
    self.view.backgroundColor = KDSPublicBackgroundColor;
    _picImgView.backgroundColor =  [UIColor lightGrayColor];
    self.imgViewHeightConstraint.constant = KDSScreenWidth/1.78;
    [self.playVideoBtn setTitle:Localized(@"点击查看视频") forState:UIControlStateNormal];
    [self getCacheFile];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:YES];
    if (_request) {
        [_request stop];
    }
    [KDSFTIndicator dismissProgress];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];

    
    KDSWeakSelf(self);
    dispatch_queue_t dispatchQueue  = dispatch_queue_create("AlarmFileShow", DISPATCH_QUEUE_SERIAL);
    dispatch_async(dispatchQueue, ^{
        NSArray *pirPicArray = [[KDSDBManager sharedManager] getPirArrayWithCateID:weakself.gatewayDeviceModel.deviceId picDate:weakself.currentPicDate];
        NSMutableArray<AlarmMessageModel*> *temArray = [NSMutableArray arrayWithArray:pirPicArray];
        [pirPicArray enumerateObjectsUsingBlock:^(AlarmMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
//             if ([obj.timeStr isEqualToString:weakself.currentFileName] && !obj.photoImg){
             if ([obj.timeStr isEqualToString:weakself.currentFileName]){
                 if (![obj.isChecked isEqualToString:@"true"]) {
                     obj.isChecked = @"true";
                     [temArray replaceObjectAtIndex:idx withObject:obj];
                     [[KDSDBManager sharedManager] addPirArray:temArray cateyeID:weakself.gatewayDeviceModel.deviceId picDate:weakself.currentPicDate];
                     *stop = YES;
                 }
             }
         }];
    });
}
-(void)getCacheFile{
    KDSWeakSelf(self);
    weakself.currentPicDatePath = [NSString stringWithFormat:@"orangecat-%@",[weakself.currentPicDate stringByReplacingOccurrencesOfString:@"-" withString:@""]];
    weakself.currentPath = [PATHDOCUMNT stringByAppendingString:[NSString stringWithFormat:@"/%@",weakself.currentPicDatePath]];
    //判断当前文件夹是否存在文件
    if ([weakself fileSizeAtPath:[NSString stringWithFormat:@"%@/%@",weakself.currentPath,[weakself.currentFileName stringByAppendingString:@"_picture.jpg"]]] != 0) {
        weakself.picImgView.image = [[UIImage alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",weakself.currentPath,[weakself.currentFileName stringByAppendingString:@"_picture.jpg"]]];
        NSArray *pirPicArray = [[KDSDBManager sharedManager] getPirArrayWithCateID:weakself.gatewayDeviceModel.deviceId picDate:weakself.currentPicDate];
        NSMutableArray<AlarmMessageModel*> *temArray = [NSMutableArray arrayWithArray:pirPicArray];
        [pirPicArray enumerateObjectsUsingBlock:^(AlarmMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
         {
             if ([obj.timeStr isEqualToString:weakself.currentFileName]){
                 if (!obj.photoImg || ![obj.isChecked isEqualToString:@"true"]) {
                     obj.photoImg = weakself.picImgView.image;
                     obj.isChecked = @"true";
                     [temArray replaceObjectAtIndex:idx withObject:obj];
                     [[KDSDBManager sharedManager] addPirArray:temArray cateyeID:weakself.gatewayDeviceModel.deviceId picDate:weakself.currentPicDate];
                     *stop = YES;
                 }
             }
         }];
    }else{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakself setFTPEnableWithFileName:[weakself.currentFileName stringByAppendingString:@"_picture.jpg"] isHFile:NO];
        });

    }
}
-(void)setFTPEnableWithFileName:(NSString *)fileName isHFile:(BOOL)isH{
    KDSWeakSelf(self);
//    [KDSFTIndicator showProgressWithMessage:Localized(@"正在连接") userInteractionEnable:YES];
    [MBProgressHUD showMessage:@"正在连接" toView:self.view.window];
    KDSLog(@"ftp--------------正在连接！！");
    [[KDSMQTTManager sharedManager] cy:weakself.gatewayDeviceModel openFtpRelay:YES withAddress:kFTPRelayHost completion:^(NSError * _Nullable error, NSString * _Nullable ip, NSInteger port) {
        if (!error) {
            [MBProgressHUD hideHUDForView:self.view.window];
//            [KDSFTIndicator dismissProgress];
            KDSLog(@"ftp--------------正在下载！！");
            [KDSFTIndicator showProgressWithMessage:Localized(@"正在下载") userInteractionEnable:YES];
            weakself.ftpIPAddress = ip?:ip;
            weakself.ftpPort = port;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [weakself ftpDownLoadRequestWithName:fileName isHFile:NO];
            });
        }else{
            [KDSFTIndicator dismissProgress];
            KDSLog(@"ftp--------------猫眼连接失败---隐藏hud！！");
            [MBProgressHUD showError:Localized(@"猫眼连接失败")];
        }
    } ];
}
//根据文件名下载，isH用来判断是否为h264文件
- (void)ftpDownLoadRequestWithName:(NSString *)fileName isHFile:(BOOL)isH{
    KDSWeakSelf(self);
    NSArray *pirPicArray = [[KDSDBManager sharedManager] getPirArrayWithCateID:weakself.gatewayDeviceModel.deviceId picDate:weakself.currentPicDate];
    NSMutableArray<AlarmMessageModel*> *temArray = [NSMutableArray arrayWithArray:pirPicArray];
    _request = [LxFTPRequest downloadRequest];
    NSString *FTPAddress = [NSString stringWithFormat:@"ftp://%@:",weakself.ftpIPAddress];
    uint16_t ftpPort = weakself.ftpPort;
    NSString * urlStr = [FTPAddress stringByAppendingString:[NSString stringWithFormat:@"%hu/",ftpPort]];
    NSString *URL;
    if (![fileName containsString:@".h264"] || isH) {
        NSString *fileDate = [KDSTool timestampSwitchUTCTime:[[fileName substringWithRange:NSMakeRange(0, 10)] integerValue] andFormatter:@"yyyy-MM-dd"];
        NSString *fileDir = [NSString stringWithFormat:@"orangecat-%@",[fileDate stringByReplacingOccurrencesOfString:@"-" withString:@""]];
        URL = [urlStr stringByAppendingString:[NSString stringWithFormat:@"%@%@",[NSString stringWithFormat:@"sdap0/storage/%@/",fileDir],fileName]];
    }else{
        URL = [urlStr stringByAppendingString:[NSString stringWithFormat:@"%@",fileName]];
    }
    _request.serverURL = [NSURL URLWithString:URL];
    NSString *localFileStr = [NSString stringWithFormat:@"Documents/%@/%@/",weakself.currentPicDatePath,fileName];
    _request.localFileURL = [[NSURL fileURLWithPath:NSHomeDirectory()] URLByAppendingPathComponent:localFileStr];
    NSLog(@"serverURL====%@",_request.serverURL);
    NSLog(@"localFileURL====%@",_request.localFileURL);
    _request.username = [NSString stringWithFormat:@"%@,%@,%@",[KDSUserManager sharedManager].user.uid,weakself.gatewayDeviceModel.gatewayId,weakself.gatewayDeviceModel.deviceId ];
    _request.password = PASSWORD;
    _request.progressAction = ^(NSInteger totalSize, NSInteger finishedSize, CGFloat finishedPercent) {
        NSLog(@"---===---totalSize = %ld, finishedSize = %ld, finishedPercent = %f", (long)totalSize, (long)finishedSize, finishedPercent); //
    };
    _request.successAction = ^(Class resultClass, id result) {
        if ([fileName containsString:@".jpg"]) {
            if (weakself.reLoadBtn.hidden == NO) {
                [weakself.reLoadBtn setHidden:YES];
            }
            KDSLog(@"ftp--------------图片下载成功！！--隐藏hud");
            [KDSFTIndicator dismissProgress];
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",Localized(@"下载成功")]];
            weakself.picImgView.image = [[UIImage alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",weakself.currentPath,fileName]];

            [pirPicArray enumerateObjectsUsingBlock:^(AlarmMessageModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
             {
                 if ([obj.timeStr isEqualToString:weakself.currentFileName]){
                     obj.photoImg = weakself.picImgView.image;
                 }
                 [temArray replaceObjectAtIndex:idx withObject:obj];
             }];

            [[KDSDBManager sharedManager] addPirArray:temArray cateyeID:weakself.gatewayDeviceModel.deviceId picDate:weakself.currentPicDate];
        }else if ([fileName containsString:@"raw"]){
            NSLog(@"---===---下载raw成功");
            NSString *currentH264Str = [NSString stringWithFormat:@"%@video.h264",[fileName substringWithRange:NSMakeRange(0, 11)]];
            [weakself ftpDownLoadRequestWithName:currentH264Str isHFile:(BOOL)isH];
        }else if ([fileName containsString:@".h264"]){
            KDSLog(@"ftp--------------下载h264成功---隐藏hud！！");
            [KDSFTIndicator dismissProgress];
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",Localized(@"下载成功")]];
            NSString *currentRawStr = [NSString stringWithFormat:@"%@audio.raw",[fileName substringWithRange:NSMakeRange(0, 11)]];
            NSString *rawPath = [NSString stringWithFormat:@"%@/%@",weakself.currentPath,currentRawStr];
            NSString *h264Path = [NSString stringWithFormat:@"%@/%@",weakself.currentPath,fileName];
            NSString *currentMkvStr = [NSString stringWithFormat:@"%@.mkv",[fileName substringWithRange:NSMakeRange(0, 10)]];
            NSString *mkvStr = [NSString stringWithFormat:@"%@/%@",weakself.currentPath,currentMkvStr];
            NSLog(@"---===---mkv文件路径%@",mkvStr);
            int success;
            success = [KDSTool mixmkvWithfileName:h264Path.UTF8String in_filename2:rawPath.UTF8String out_filename:mkvStr.UTF8String framerate:20 samplerate:8000];
            if (success == 0) {
                NSLog(@"---===---下载h264成功");
                [weakself playMkvVideoWithmkvStr:mkvStr];
                [[NSFileManager defaultManager] removeItemAtPath:rawPath error:nil];
                [[NSFileManager defaultManager] removeItemAtPath:h264Path error:nil];
            }
        }
    };
    _request.failAction = ^(CFStreamErrorDomain domain, NSInteger error, NSString *errorMessage) {
        if ([fileName containsString:@".jpg"]) {
            [weakself.reLoadBtn setHidden:NO];
        }
        [KDSFTIndicator dismissProgress];
        KDSLog(@"ftp--------------下载失败---隐藏hud！！");
        [MBProgressHUD showError:[NSString stringWithFormat:@"%@",Localized(@"下载失败")]];
        NSLog(@"---===---domain = %ld, error = %ld, errorMessage = %@", domain, (long)error, errorMessage); //
    };
    [_request start];
}

#pragma mark 按钮点击事件

- (IBAction)reloadBtnClick:(id)sender {
    [self setFTPEnableWithFileName:[self.currentFileName stringByAppendingString:@"_picture.jpg"] isHFile:NO];
}
- (IBAction)clickPlayVideo:(id)sender {
    NSLog(@"点击了查看视频");
    NSString *currentMkvStr = [NSString stringWithFormat:@"%@.mkv",self.currentFileName];
    NSString *currentRawStr = [NSString stringWithFormat:@"%@_audio.raw",self.currentFileName];
    NSString *currentH264Str = [NSString stringWithFormat:@"%@_video.h264",self.currentFileName];
    //    BOOL blHaveRaw = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",self.currentPath,currentRawStr]];
    //    BOOL blHaveH264 = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",self.currentPath,currentH264Str]];
    BOOL blHaveMkv = [[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithFormat:@"%@/%@",self.currentPath,currentMkvStr]];
    if (blHaveMkv) {
        [self playMkvVideoWithmkvStr:[NSString stringWithFormat:@"%@/%@",self.currentPath,currentMkvStr]];
    }else{
//        if ([self currentTimeCompareWithSevDayAgo ]) {
            //当raw文件大小等于0时，先下raw文件，再下载h264e文件
            if ([self fileSizeAtPath:[NSString stringWithFormat:@"%@/%@",self.currentPath,currentRawStr]] == 0) {
                [self setFTPEnableWithFileName:currentRawStr isHFile:NO];
            }else{
                //当raw文件存在时，直接下载h264文件
                [self setFTPEnableWithFileName:currentH264Str isHFile:YES];
            }
//        }else{
//            [MBProgressHUD showError:@"暂不支持下载七天前视频"];
//        }
        
    }
}
-(void)playMkvVideoWithmkvStr:(NSString*)mkvStr{
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KdsKxMovieParameterDisableDeinterlacing] = @(YES);
    KdsKxMovieViewController *vc = [KdsKxMovieViewController kdsmovieViewControllerWithContentPath:mkvStr parameters:parameters];
    if (vc) {
        [self presentViewController:vc animated:YES completion:nil];
    }
}
-(BOOL)currentTimeCompareWithSevDayAgo{
    NSDate * date = [KDSTool getTimeAfterNowWithDay:7 isAfter:NO];
    NSString * fileDateStr = [KDSTool timestampSwitchTime:[self.currentFileName integerValue] andFormatter:@"yyyy-MM-dd"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
    NSDate *fileDate = [dateFormatter dateFromString:fileDateStr];
    if([fileDate compare:date] == NSOrderedDescending){//七天内
        return YES;
    }else{//七天前
        return NO;
    }
}

//单个文件的大小
-(long long)fileSizeAtPath:(NSString*)filePath
{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
