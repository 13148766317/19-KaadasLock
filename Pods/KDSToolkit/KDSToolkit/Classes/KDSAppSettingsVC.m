//
//  KDSAppSettingsVC.m
//  KDSToolkit
//
//  Created by Apple on 2021/4/22.
//

#import "KDSAppSettingsVC.h"
#import "KDSAppSettings+Private.h"
#import "KDSAppLog.h"
#import <GBDeviceInfo/GBDeviceInfo.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface KDSAppSettingsVC ()
@property (nonatomic,strong) NSArray *settingRows;


@end

@implementation KDSAppSettingsVC



-(instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}

#pragma mark - Helper

-(void)initializeForm
{
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    
    
    form = [XLFormDescriptor formDescriptor];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"配置应用选项", nil)];
    [form addFormSection:section];
    
    
    
    
    
    self.settingRows = [[KDSAppSettings sharedInstance] settingRows];
    
    
    
    
    
    for (NSUInteger i=0; i<self.settingRows.count; i++) {
        XLFormRowDescriptor *row = [self genRowFromDict:self.settingRows[i]];
        if (row) {
            [section addFormRow:row];
        }
    }
    
    
    XLFormSectionDescriptor *tempSection = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"临时开启", nil)];
    [form addFormSection:tempSection];
    
    
    XLFormRowDescriptor *showLogRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"showLogRow" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"显示控制台日志", nil)];
    showLogRow.action = [[XLFormAction alloc] init];
    showLogRow.action.formBlock = ^(XLFormRowDescriptor * _Nonnull sender) {
        [KDSAppLog showConsole];
    };
    XLFormRowDescriptor *hideLogRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"hideLogRow" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"隐藏控制台日志", nil)];
    hideLogRow.action = [[XLFormAction alloc] init];
    hideLogRow.action.formBlock = ^(XLFormRowDescriptor * _Nonnull sender) {
        [KDSAppLog hideConsole];
    };
    
    [tempSection addFormRow:showLogRow];
    [tempSection addFormRow:hideLogRow];
    
    
    XLFormSectionDescriptor *otherSection = [XLFormSectionDescriptor formSectionWithTitle:NSLocalizedString(@"其它", nil)];
    __weak __typeof(self)weakSelf = self;
    XLFormRowDescriptor *shareLogRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"shareLogRow" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"发送日志", nil)];
    shareLogRow.action = [[XLFormAction alloc] init];
    shareLogRow.action.formBlock = ^(XLFormRowDescriptor * _Nonnull sender) {
        //[KDSAppLog hideConsole]
        [weakSelf shareLog];
    };
    [otherSection addFormRow:shareLogRow];
    
    XLFormRowDescriptor *restartRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"restart" rowType:XLFormRowDescriptorTypeButton title:NSLocalizedString(@"重启应用", nil)];
    restartRow.action = [[XLFormAction alloc] init];
    restartRow.action.formBlock = ^(XLFormRowDescriptor * _Nonnull sender) {
        //[KDSAppLog hideConsole]
        [[KDSAppSettings
          sharedInstance] updateSettingValues:self.formValues];
        exit(0);
    };
    [otherSection addFormRow:restartRow];
    
    [form addFormSection:otherSection];
    self.form = form;
}


#define kTag @"tag"
#define kTitle @"title"
#define kRowType @"rowType"
#define kSelectorTitle @"selectorTitle"
#define kSelectorOptions @"selectorOptions"
#define kMetaData @"metaData"
#define kValue @"value"
#define kDisplayText @"displayText"
-(XLFormRowDescriptor *) genRowFromDict:(NSDictionary *) dict {
    XLFormRowDescriptor *result;
    
    
        NSDictionary *metaData = dict;
        if (metaData[kTag] && metaData[kRowType] && metaData[kTitle]) {
            if ([metaData[kRowType] isEqualToString:XLFormRowDescriptorTypeBooleanSwitch] ) {
                result = [XLFormRowDescriptor formRowDescriptorWithTag:metaData[kTag] rowType:metaData[kRowType] title:metaData[kTitle]];
                result.value = [[KDSAppSettings sharedInstance] settingObjectForKey:metaData[kTag]];
            }else if ([metaData[kRowType] isEqualToString:XLFormRowDescriptorTypeSelectorPush] ) {
                result = [XLFormRowDescriptor formRowDescriptorWithTag:metaData[kTag] rowType:metaData[kRowType] title:metaData[kTitle]];
                result.value = [[KDSAppSettings sharedInstance] settingObjectForKey:metaData[kTag]];
                result.selectorTitle = metaData[kSelectorTitle
                                                ];
                result.selectorOptions = [self genSelectorOptions:metaData[kSelectorOptions]];
                
            }
        }
    
    
    
    
    return result;
}
- (NSArray<XLFormOptionsObject *> *) genSelectorOptions:(NSArray *) options {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    for (NSUInteger i=0;i<options.count;i++) {
        NSDictionary *option = options[i];
        XLFormOptionsObject *optionObject = [XLFormOptionsObject formOptionsObjectWithValue:option[kValue]  displayText:option[kDisplayText]];
        [result addObject:optionObject];
    }
    return result.count ? result: nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.navigationItem) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cacnelPressed:)];
    }
}
-(IBAction)savePressed:(id)sender {
   
    [[KDSAppSettings sharedInstance] updateSettingValues:self.formValues];
    
    if (self.backBlock) {
        self.backBlock();
    }
    
}
-(IBAction)cacnelPressed:(id)sender {
    if (self.backBlock) {
        self.backBlock();
    }
    
}

-(void) shareLog {
    //1. 压缩日志 -> 2. 分享
    //打印设备信息&APP信息
    __weak __typeof(self)weakSelf = self;
    NSLog(@"shareLog");

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
   
        NSString *zipDst = [NSTemporaryDirectory()   stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.log.zip",[NSBundle mainBundle].bundleIdentifier]];
        NSString *srcFile = [KDSAppLog logDirectory];
        BOOL result = [KDSAppLog  zipSrcFile:srcFile dstFile:zipDst passwd:@"kds123456"];
        
        if (result) {
            NSLog(@"压缩日志完成");

            dispatch_block_t block = ^() {
                [KDSAppLog shareFilePath:zipDst viewController:weakSelf];
            };
            
            dispatch_async(dispatch_get_main_queue(), block);
            
        }else {
            NSLog(@"压缩日志文件失败");
        }
        
    });
}
@end
