//
//  KDSMyAlbumVC.m
//  KaadasLock
//
//  Created by zhaoxueping on 2020/9/16.
//  Copyright © 2020 com.Kaadas. All rights reserved.
//

#import "KDSMyAlbumVC.h"
#import "KDSMyAlbumListCell.h"
#import "XMUtil.h"
#import "KDSDBManager+XMMediaLock.h"
#import "KDSXMMediaLockModel.h"
#import "XMUtil.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "KDSMyAlbumDetailsVC.h"

static NSString * const deviceListCellId = @"MyAlbumCell";

@interface KDSMyAlbumVC ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

///用来展示相册内容的视图
@property (nonatomic,readwrite,strong)UICollectionView * collectionView;
///从数据库中取出的缓存的截图、录屏的数据。
@property (nonatomic, strong) NSMutableArray<KDSXMMediaLockModel *> *mediaRecordArr;
///缓存的截图、录屏的数据按日期(天)提取的记录分组数组。
@property (nonatomic, strong) NSArray<NSArray<KDSXMMediaLockModel *> *> *mediaRecordSectionArr;
///A date formatter with format yyyy-MM-dd HH:mm:ss
@property (nonatomic, strong) NSDateFormatter *dateFmt;
///是否有录屏
@property (nonatomic, assign) BOOL isHaveVideo;

@end

@implementation KDSMyAlbumVC

- (NSMutableArray<KDSXMMediaLockModel *> *)mediaRecordArr
{
    if (!_mediaRecordArr) {
        _mediaRecordArr = [NSMutableArray array];
    }
    return _mediaRecordArr;
}
- (NSDateFormatter *)dateFmt
{
    if (!_dateFmt)
    {
        _dateFmt = [[NSDateFormatter alloc] init];
        _dateFmt.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFmt;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationTitleLabel.text = @"我的相册";
    [self.view addSubview:self.collectionView];
    self.isHaveVideo = NO;
    // 注册
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSMyAlbumListCell class]) bundle:nil] forCellWithReuseIdentifier:deviceListCellId];
    [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KDSMyAlbumListCell class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"myAlbumCollectionViewHeader"];
    ////添加猫眼、网关父视图
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.bottom.equalTo(self.view);
    }];
    [self getOriginalImages];
    
}

#pragma mark UICollecionViewDelegate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.mediaRecordSectionArr[section].count;
}
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.mediaRecordSectionArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    KDSMyAlbumListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:deviceListCellId forIndexPath:indexPath];
    cell.playBtn.hidden = YES;
    cell.iconImg.contentMode = UIViewContentModeScaleAspectFill;
    KDSXMMediaLockModel * model = self.mediaRecordSectionArr[indexPath.section][indexPath.row];
    if (model.mp4Address.length >0) {
        cell.iconImg.image = [self getScreenShotImageFromVideoPath:model.mp4Address];
        cell.playBtn.hidden = NO;
        cell.playBtnClickBlock = ^{
            
            KDSXMMediaLockModel * model = self.mediaRecordSectionArr[indexPath.section][indexPath.row];
            KDSMyAlbumDetailsVC * vc = [KDSMyAlbumDetailsVC new];
            vc.model = model;
            [self.navigationController pushViewController:vc animated:YES];
        };
    }else{
        NSData * imageData = [NSData dataWithData:model.lockCutData];
        cell.iconImg.image = [UIImage imageWithData:imageData];
        cell.maskView.hidden = YES;
    }
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    KDSXMMediaLockModel * model = self.mediaRecordSectionArr[indexPath.section][indexPath.row];
    KDSMyAlbumDetailsVC * vc = [KDSMyAlbumDetailsVC new];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
    
}
/**
 *  获取视频的缩略图方法
 *  @param filePath 视频的本地路径
 *  @return 视频截图
 */
- (UIImage *)getScreenShotImageFromVideoPath:(NSString *)filePath{
    
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    gen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    shotImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return shotImage;
    
}


#pragma mark - 视图内容
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    // 视图添加到 UICollectionReusableView 创建的对象中
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"myAlbumCollectionViewHeader" forIndexPath:indexPath];
        headerView.backgroundColor = UIColor.clearColor;
        UIView * supview = [UIView new];
        supview.backgroundColor = UIColor.whiteColor;
        [headerView addSubview:supview];
        [supview mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.top.right.equalTo(headerView);
        }];
        UILabel * timeLb = [UILabel new];
//        timeLb.text = @"2020/08/23";
        timeLb.font = [UIFont systemFontOfSize:15];
        timeLb.textColor = UIColor.blackColor;
        timeLb.textAlignment = NSTextAlignmentLeft;
        timeLb.backgroundColor = UIColor.whiteColor;
        [supview addSubview:timeLb];
        [timeLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(headerView.mas_left).offset(15);
            make.right.equalTo(headerView.mas_right).offset(-15);
            make.bottom.equalTo(headerView.mas_bottom).offset(0);
            make.height.equalTo(@30);
        }];
        
        NSString *todayStr = [[self.dateFmt stringFromDate:[NSDate date]] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        NSInteger today = [todayStr substringToIndex:8].integerValue;
        NSString *dateStr = dateStr = self.mediaRecordSectionArr[indexPath.section].firstObject.imageName;
        NSInteger date = [[dateStr stringByReplacingOccurrencesOfString:@"-" withString:@""] substringToIndex:8].integerValue;
        if (today == date)
        {
            timeLb.text = Localized(@"today");
        }
        else if (today - date == 1)
        {
            timeLb.text = Localized(@"yesterday");
        }
        else
        {
            timeLb.text = [[dateStr componentsSeparatedByString:@" "].firstObject stringByReplacingOccurrencesOfString:@"-" withString:@"/"];
        }
        return headerView;
    }
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGSize size = CGSizeMake((kScreenWidth - 10) / 3.0, (kScreenWidth - 10) / 3.0);
    return size;
}

// 两个cell之间的最小间距，是由API自动计算的，只有当间距小于该值时，cell会进行换行
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}
// 两行之间的最小间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 5;
}

- (void)getOriginalImages
{
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:YES];
    }

    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    // 遍历相机胶卷,获取大图
    [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
}

/**
 *  遍历相簿中的所有图片
 *  @param assetCollection 相簿
 *  @param original        是否要原图
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    NSLog(@"相簿名:%@", assetCollection.localizedTitle);
    // 获得某个相簿中的所有PHAsset对象
    NSString *title =[NSString stringWithFormat:@"KDS:%@",self.lock.wifiDevice.wifiSN];
    if ([assetCollection.localizedTitle isEqualToString:title]) {
        //遍历获取相册
        //获取当前相册里所有的PHAsset，也就是图片或者视频
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        for (NSInteger j = 0; j < fetchResult.count; j++) {
            //从相册中取出照片
            PHAsset* asset = fetchResult[j];
            if (asset.mediaType == PHAssetMediaTypeImage) {
               //得到一个图片类型资源
                NSLog(@"当前图片PHAsset的值%ld",(long)j);
                PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                // 同步获得图片, 只会返回1张图片
                options.synchronous = YES;
                // 是否要原图
                CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;

                // 从asset中获得图片
                [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                    ///删除相册选择图片直接删除PHAsset即可
                    NSLog(@"凯迪仕智能相册里面的图片%@", result);
                    KDSXMMediaLockModel * mode = [KDSXMMediaLockModel new];
                    UIImage * image = result;
                    NSString * imageCreationDate = [NSString stringWithFormat:@"%@",[self getNowDateFromatAnDate:asset.creationDate]];
                    mode.lockCutData = UIImagePNGRepresentation(image);
                    mode.imageName = [imageCreationDate stringByReplacingOccurrencesOfString:@".png" withString:@""];
                    if (mode.lockCutData) [self.mediaRecordArr addObject:mode];
                    if (self.mediaRecordArr.count == fetchResult.count) {
                        [self refreshData];
                    }
                    
                }];
            }else if (asset.mediaType == PHAssetMediaTypeVideo) {
                //得到一个视频类型资源
                NSLog(@"当前视频PHAsset的值%ld",(long)j);
                KDSXMMediaLockModel * mode = [KDSXMMediaLockModel new];
                NSString * imageCreationDate = [NSString stringWithFormat:@"%@",[self getNowDateFromatAnDate:asset.creationDate]];
                mode.imageName = [imageCreationDate stringByReplacingOccurrencesOfString:@".mp4" withString:@""];
                PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                options.version = PHImageRequestOptionsVersionCurrent;
                options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    AVURLAsset *urlAsset = (AVURLAsset *)asset;
                    NSURL *url = urlAsset.URL;
                    NSData *data = [NSData dataWithContentsOfURL:url];
                    NSLog(@"%@",data);
                    mode.mp4Address = [NSString stringWithFormat:@"%@",url];
                    if (mode.mp4Address) [self.mediaRecordArr addObject:mode];
                    if (self.mediaRecordArr.count == fetchResult.count) {
                        self.isHaveVideo = YES;
                        [self refreshData];
                    }

                }];

            }else if (asset.mediaType == PHAssetMediaTypeAudio) {
                  //音频，PHAsset的mediaType属性有三个枚举值，笔者对PHAssetMediaTypeAudio暂时没有进行处理
           }
        }
    }
}

- (void)refreshData
{
    NSMutableArray *sections = [NSMutableArray array];
    NSMutableArray<KDSXMMediaLockModel *> *section = [NSMutableArray array];
    __block NSString *date = nil;
    [self.mediaRecordArr sortUsingComparator:^NSComparisonResult(KDSXMMediaLockModel *  _Nonnull obj1, KDSXMMediaLockModel *  _Nonnull obj2) {
        return [obj2.imageName compare:obj1.imageName];
    }];
    [self.mediaRecordArr enumerateObjectsUsingBlock:^(KDSXMMediaLockModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!date)
        {
            if (obj.imageName) {
                date = [obj.imageName componentsSeparatedByString:@" "].firstObject;
                [section addObject:obj];
            }else{
                [self.mediaRecordArr removeObject:obj];
            }

        }
        else if ([date isEqualToString:[obj.imageName componentsSeparatedByString:@" "].firstObject])
        {

            [section addObject:obj];
        }
        else
        {
            if (section.count >0) {
                [sections addObject:[NSArray arrayWithArray:section]];
            }
            [section removeAllObjects];
            if (obj.imageName) {
                date = [obj.imageName componentsSeparatedByString:@" "].firstObject;
                [section addObject:obj];
            }else{
                [self.mediaRecordArr removeObject:obj];
            }
        }
    }];
    if (section.count >0) {
        [sections addObject:[NSArray arrayWithArray:section]];
    }
    self.mediaRecordSectionArr = [NSArray arrayWithArray:sections];
    if (self.isHaveVideo) {
        ///有视频录屏的时候需要异步刷新UI，只有图片的时候不用
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
        });
    }else{
        [self.collectionView reloadData];
    }
    
}
- (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate * destinationDateNow = [[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];

    return destinationDateNow;
}

#pragma mark --Lazy Load

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = UIColor.whiteColor;
        _collectionView.layer.masksToBounds = YES;
        _collectionView.layer.shadowColor = [UIColor colorWithRed:121/255.0 green:146/255.0 blue:167/255.0 alpha:0.1].CGColor;
        _collectionView.layer.shadowOffset = CGSizeMake(0,-4);
        _collectionView.layer.shadowOpacity = 1;
        _collectionView.layer.shadowRadius = 12;
        _collectionView.layer.cornerRadius = 5;
         layout.headerReferenceSize = CGSizeMake(KDSScreenWidth, 40);
        [_collectionView flashScrollIndicators];
    }
    return _collectionView;
}

@end
