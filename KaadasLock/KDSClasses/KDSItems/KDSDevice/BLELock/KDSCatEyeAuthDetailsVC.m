//
//  KDSCatEyeAuthDetailsVC.m
//  KaadasLock
//
//  Created by zhaona on 2019/7/1.
//  Copyright © 2019 com.Kaadas. All rights reserved.
//

#import "KDSCatEyeAuthDetailsVC.h"
#import "UIView+Extension.h"
#import "MBProgressHUD+MJ.h"


@interface KDSCatEyeAuthDetailsVC ()
@property (weak, nonatomic) IBOutlet UIImageView *memBerImg;
///名称标签
@property (weak, nonatomic) IBOutlet UILabel *userNameLb;
@property (weak, nonatomic) IBOutlet UIButton *deleBtn;
///授权时间标签
@property (weak, nonatomic) IBOutlet UILabel *authMemberTipLb;
///显示被授权用户昵称
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
///显示被授权设备时间
@property (weak, nonatomic) IBOutlet UILabel *authmemberLabel;
@property (weak, nonatomic) IBOutlet UIView *supview;
@property (weak, nonatomic) IBOutlet UILabel *nameLb;

@end

@implementation KDSCatEyeAuthDetailsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.supview.layer.cornerRadius = 4;
    self.navigationTitleLabel.text = Localized(@"userDetails");
    self.deleBtn.layer.cornerRadius = 22;
    self.nameLb.text = ((KDSAuthCatEyeMember *)self.model).username;
    NSString *timeS = ((KDSAuthCatEyeMember * )self.model).time;
    if (timeS.length >19) {
        self.authmemberLabel.text = [timeS substringWithRange:NSMakeRange(0, 16)];
    }
    self.userNameLabel.text = ((KDSAuthCatEyeMember *)self.model).userNickname ?: ((KDSAuthCatEyeMember *)self.model).username;
}

///删除被授权用户按钮
- (IBAction)deleBtn:(id)sender {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"Are you sure delete user's rights") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    [cancel setValue:KDSRGBColor(0x33, 0x33, 0x33) forKey:@"titleTextColor"];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"delete") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self deleteCateyeAuthMember];
    }];
    [ac addAction:cancel];
    [ac addAction:ok];
    [self presentViewController:ac animated:YES completion:nil];
    
}
///编辑昵称时输入框文字改变。
- (void)textFieldTextChanged:(UITextField *)sender
{
    [sender trimTextToLength:-1];
}
///编辑昵称按钮
- (IBAction)editBtn:(id)sender {
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:Localized(@"pleaseInputUserName") message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    NSString *placeholder = self.nameLb.text;
    [ac addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textAlignment = NSTextAlignmentCenter;
        textField.font = [UIFont systemFontOfSize:12];
        textField.placeholder = placeholder;
        [textField addTarget:weakSelf action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:Localized(@"cancel") style:UIAlertActionStyleDefault handler:nil];
    [cancel setValue:KDSRGBColor(0x33, 0x33, 0x33) forKey:@"titleTextColor"];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:Localized(@"ok") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [weakSelf updateNickname:ac.textFields.firstObject.text];
    }];
    [ac addAction:cancel];
    [ac addAction:ok];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)updateNickname:(NSString *)nickname
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"pleaseWait") toView:self.view];
    [[KDSMQTTManager sharedManager] shareGatewayBindingWithGW:self.cateye.gw.model device:self.cateye.gatewayDeviceModel userAccount:self.nameLb.text userNickName:nickname shareFlag:1 type:2 completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:YES];
        if (success) {
            self.userNameLabel.text = nickname;
            [MBProgressHUD showSuccess:Localized(@"setSuccess")];
        }else{
            [MBProgressHUD showError:Localized(@"setFailed")];
        }
    }];
}

-(void)deleteCateyeAuthMember
{
    MBProgressHUD *hud = [MBProgressHUD showMessage:Localized(@"deleting") toView:self.view];
    [[KDSMQTTManager sharedManager] shareGatewayBindingWithGW:self.cateye.gw.model device:self.cateye.gatewayDeviceModel userAccount:self.nameLb.text userNickName:@"" shareFlag:0 type:2 completion:^(NSError * _Nullable error, BOOL success) {
        [hud hideAnimated:YES];
        if (success) {
            [MBProgressHUD showSuccess:Localized(@"deleteSuccess")];
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showError:Localized(@"deleteFailed")];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

@end
