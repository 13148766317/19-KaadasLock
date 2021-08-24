//
//  KDSFormController.h
//  KDSToolkit
//
//  Created by Apple on 2021/5/14.
//

#import <Foundation/Foundation.h>
#import <XLForm/XLForm.h>
NS_ASSUME_NONNULL_BEGIN

@interface KDSFormController : NSObject <UITableViewDataSource, UITableViewDelegate, XLFormDescriptorDelegate, UITextFieldDelegate, UITextViewDelegate, XLFormViewControllerDelegate>

@property (nonatomic, strong) XLFormDescriptor * form;

@property (nonatomic, weak)  UITableView * tableView;
@property(nonatomic, weak) UIViewController *presentingVC;

-(instancetype)initWithForm:(XLFormDescriptor *)form;
-(instancetype)initWithForm:(XLFormDescriptor *)form style:(UITableViewStyle)style;

+(NSMutableDictionary *)cellClassesForRowDescriptorTypes;
+(NSMutableDictionary *)inlineRowDescriptorTypesForRowDescriptorTypes;


-(void)viewDidLoad;
-(void)viewWillAppear;
-(void)viewDidAppear;
-(void)viewDidDisappear;


-(void)performFormSelector:(SEL)selector withObject:(id)sender;

@end

NS_ASSUME_NONNULL_END
