//
//  KDSCatEyeLookbackVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/5/7.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCatEyeLookbackVC.h"
#import "KDSCatEyePlaybackCell.h"
#import "KdsKxMovieViewController.h"
#import "MBProgressHUD+MJ.h"
#import "AlarmMessageModel.h"
#import "KDSDBManager+CY.h"


@interface KDSCatEyeLookbackVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,readwrite,strong)UITableView * tableView;
@property(nonatomic,strong)NSMutableArray<AlarmMessageModel*> * dataArray;
@end

@implementation KDSCatEyeLookbackVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(0);
        make.width.mas_equalTo(KDSScreenWidth);
        make.height.mas_equalTo(KDSScreenHeight-200-kStatusBarHeight);
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(lookbackTimeSelected:) name:@"KDSLookbackTimeSelected" object:nil];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSArray *VArray = [[KDSDBManager sharedManager] getRecordArrayWithCateID:self.gatewayDeviceModel.deviceId recordDate:self.currentRecordDate];
    if (VArray.count != 0) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"timeStr" ascending:NO];
        NSMutableArray *resultArray = [[NSMutableArray alloc] initWithArray:[VArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
        self.dataArray = resultArray;
        [self.tableView reloadData];
    }
}
-(void)lookbackTimeSelected:(NSNotification*)notif {
    NSString * str = [notif.userInfo objectForKey: @"time"];
    self.currentRecordDate = str;
    self.dataArray = [self getPlayBackDataArray];
    if (self.dataArray.count == 0) {
        [MBProgressHUD showError:Localized(@"此日暂无录屏")];
    }
    [self.tableView reloadData];
    NSLog(@"录屏选择了时间%@",str);
}
-(NSMutableArray<AlarmMessageModel*> *)getPlayBackDataArray{
    //数据库中的缓存数据
    NSArray *DBArray = [[KDSDBManager sharedManager] getRecordArrayWithCateID:self.gatewayDeviceModel.deviceId recordDate:self.currentRecordDate];
    
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString * pathDir1 = [pathDocuments stringByAppendingPathComponent:self.gatewayDeviceModel.deviceId];
    NSString * pathDir2 = [NSString stringWithFormat:@"%@%@",pathDir1,@"RePlayerFilePath"];
    NSString * pathDir3 = [pathDir2 stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[NSString stringWithFormat:@"%@",[self.currentRecordDate stringByReplacingOccurrencesOfString:@"-" withString:@""]]]];
    ///var/mobile/Containers/Data/Application/xxxx/Documents/CH01183910014RePlayerFilePath/20190523
    NSFileManager * manager = [NSFileManager defaultManager];
    NSArray * array = [manager contentsOfDirectoryAtPath:pathDir3 error:nil];
    if (array.count == 0) {
        return nil;
    }
    //沙盒中的视频缓存
    NSMutableArray * videoArray = [[NSMutableArray alloc] init];
    for (int i=0; i<=array.count-1; i++) {//提取出mkv文件
        NSString *name=array[i];
        BOOL b = [name hasSuffix:@".mkv"];
        if (b) {
            [videoArray addObject:name];
        }
    }
    if (videoArray.count == 0) return nil;
    NSMutableArray * Varray = [[NSMutableArray alloc] init];//时间数组
    for (NSString * fileNameStr  in videoArray) {
        [Varray addObject:[fileNameStr substringWithRange:NSMakeRange(0, fileNameStr.length-4)]];
    }
    NSMutableArray *cacheTimeArray = [[NSMutableArray alloc] init];
    NSMutableArray *tempArray = [[NSMutableArray alloc] initWithArray:DBArray];
    for (AlarmMessageModel *amodel in DBArray) {
        [cacheTimeArray addObject:amodel.timeStr];
    }
    [Varray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop)
     {
         if (![cacheTimeArray containsObject:obj]) {
             AlarmMessageModel * aModel = [[AlarmMessageModel alloc] init];
             aModel.timeStr = obj;
             aModel.photoImg = [[UIImage alloc]initWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",pathDir3,[obj stringByAppendingString:@".jpg"]]];
             aModel.isChecked = @"false";
             [tempArray addObject:aModel];
         }
     }];
    [[KDSDBManager sharedManager] addRecordVideoArray:tempArray cateyeID:self.gatewayDeviceModel.deviceId recordDate:self.currentRecordDate];
    return tempArray;
    
}

#pragma mark UITableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KDSCatEyePlaybackCell *cell = [tableView dequeueReusableCellWithIdentifier:KDSCatEyePlaybackCell.ID];
    AlarmMessageModel *model = self.dataArray[indexPath.row];
    cell.alarmModel = model;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //设置未读标志隐藏
    AlarmMessageModel *amodel = _dataArray[indexPath.row];
    amodel.isChecked = @"true";
    [_dataArray replaceObjectAtIndex:indexPath.row withObject:amodel];
    [[KDSDBManager sharedManager] addRecordVideoArray:_dataArray cateyeID:self.gatewayDeviceModel.deviceId recordDate:self.currentRecordDate];
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
    NSString * pathDir1 = [pathDocuments stringByAppendingPathComponent:self.gatewayDeviceModel.deviceId];
    NSString * pathDir2 = [NSString stringWithFormat:@"%@%@",pathDir1,@"RePlayerFilePath"];
    NSString * pathDir3 = [pathDir2 stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[NSString stringWithFormat:@"%@",[self.currentRecordDate stringByReplacingOccurrencesOfString:@"-" withString:@""]]]];
    NSString *videoName = [NSString stringWithFormat:@"%@.mkv", _dataArray[indexPath.row].timeStr];
    NSString *path = [pathDir3 stringByAppendingPathComponent:videoName];
    KDSLog(@"--00--path===%@",path);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        parameters[KdsKxMovieParameterDisableDeinterlacing] = @(YES);
    KdsKxMovieViewController *vc = [KdsKxMovieViewController kdsmovieViewControllerWithContentPath:path
                                 
                                                                               parameters:parameters];
    if (vc) {
        [self presentViewController:vc animated:YES completion:nil];
        
    }
}
-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewRowAction *deleteRoWAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:Localized(@"确定删除？") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *actions = [UIAlertAction actionWithTitle:Localized(@"sure") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            NSString *pathDocuments = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0];
            NSString * pathDir1 = [pathDocuments stringByAppendingPathComponent:self.gatewayDeviceModel.deviceId];
            NSString * pathDir2 = [NSString stringWithFormat:@"%@%@",pathDir1,@"RePlayerFilePath"];
            NSString * pathDir3 = [pathDir2 stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",[NSString stringWithFormat:@"%@",[self.currentRecordDate stringByReplacingOccurrencesOfString:@"-" withString:@""]]]];
            NSString *videoName = [NSString stringWithFormat:@"%@.mkv", _dataArray[indexPath.row].timeStr];
            NSString *path = [pathDir3 stringByAppendingPathComponent:videoName];
            NSLog(@"--00--path====%@",path);
            NSFileManager* fileManager=[NSFileManager defaultManager];
            BOOL blDele= [fileManager removeItemAtPath:path error:nil];
            if (blDele) {
                NSLog(@"dele success");
                [_dataArray removeObjectAtIndex:indexPath.row];
                [tableView reloadData];
                [[KDSDBManager sharedManager] addRecordVideoArray:_dataArray cateyeID:self.gatewayDeviceModel.deviceId recordDate:self.currentRecordDate];
            }else {
                NSLog(@"dele fail");
            }
        }];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
        [alertVC addAction:actions];
        [alertVC addAction:cancel];
        if (alertVC) {
            [self presentViewController:alertVC animated:YES completion:nil];
            
        }
        // 删除操作
        NSLog(@"删除了哦哦哦哦哦");
    }];
    return @[deleteRoWAction];
}
//此方法不支持 mkv 格式的视频
//-(UIImage*) thumbnailImageForVideo:(NSString *)videoPath atTime:(NSTimeInterval)time {
//    //本地视频
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:videoPath] options:nil];
//    NSParameterAssert(asset);
//    AVAssetImageGenerator *assetImageGenerator =[[AVAssetImageGenerator alloc] initWithAsset:asset];
//    assetImageGenerator.appliesPreferredTrackTransform = YES;
//    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
//
//    CGImageRef thumbnailImageRef = NULL;
//    CFTimeInterval thumbnailImageTime = time;
//    NSError *thumbnailImageGenerationError = nil;
//    thumbnailImageRef = [assetImageGenerator copyCGImageAtTime:CMTimeMake(thumbnailImageTime, 60)actualTime:NULL error:&thumbnailImageGenerationError];
//    if(!thumbnailImageRef)
//        NSLog(@"thumbnailImageGenerationError %@",thumbnailImageGenerationError);
//    UIImage*thumbnailImage = thumbnailImageRef ? [[UIImage alloc]initWithCGImage: thumbnailImageRef] : nil;
//    return thumbnailImage;
//}

#pragma mark --Lazy load

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = ({
            UITableView *tv = [[UITableView alloc] initWithFrame:CGRectZero];
            tv.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            tv.tableFooterView = [UIView new];
            tv.delegate = self;
            tv.dataSource = self;
            tv.rowHeight = 100;
            [tv setSeparatorInset:UIEdgeInsetsMake(0, 137, 0, 0)];
            [tv setSeparatorColor:KDSRGBColor(221, 221, 221)];
            [tv registerClass:[KDSCatEyePlaybackCell class ] forCellReuseIdentifier:KDSCatEyePlaybackCell.ID];
            tv;
        });
    }
    return _tableView;
}

- (void)dealloc
{
    NSLog(@"执行了dealloc-----Lookback");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
