//
//  LoginViewController.m
//  lock
//
//  Created by zhaowz on 2017/5/25.
//  Copyright © 2017年 zhao. All rights reserved.
//

#import "XWCountryCodeController.h"

@interface XWCountryCodeController() <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
{
    //国际代码主tableview
    UITableView *countryCodeTableView;
    //搜索
    UISearchController *searchController;
//    UISearchBar *searchBar;
    //代码字典
    NSDictionary *sortedNameDict; //代码字典
    NSArray *indexArray;
    NSMutableArray *searchResultValuesArray;
}

@end

@interface XWCountryCodeController ()

@end

@implementation XWCountryCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //背景
    [self.view setBackgroundColor:[UIColor whiteColor]];
    //顶部标题
    [self setCustomNavigationView];
    //创建子视图
    [self creatSubviews];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    countryCodeTableView.frame = self.view.bounds;
}

- (void)setCustomNavigationView{
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.navigationController.navigationBar.barTintColor = KDSRGBColor(54, 54, 58);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn.widthAnchor constraintEqualToConstant:30].active = YES;
    [closeBtn.heightAnchor constraintEqualToConstant:30].active = YES;
    [closeBtn setImage:[UIImage imageNamed:@"loginClose"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeBtn];
    self.title = Localized(@"selectCountryOrRegion");
}
- (void)closeBtnAction:(UIButton *)sender
{
    //UISearchController崩溃的问题
    searchController.active = NO;
    [self dismissViewControllerAnimated:YES completion:nil];

}
//创建子视图
-(void)creatSubviews{
    searchResultValuesArray = [[NSMutableArray alloc] init];
    
    countryCodeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    [self.view addSubview:countryCodeTableView];
    //自动调整自己的宽度，保证与superView左边和右边的距离不变。
    [countryCodeTableView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [countryCodeTableView setDataSource:self];
    [countryCodeTableView setDelegate:self];
    [countryCodeTableView setSectionIndexBackgroundColor:[UIColor clearColor]];
    
    [self initMysearchBarcontroller];
    
    NSString *plistPathCH = [[NSBundle mainBundle] pathForResource:@"sortedChnames" ofType:@"plist"];
    NSString *plistPathCHFanti = [[NSBundle mainBundle] pathForResource:@"sortedChFantinames" ofType:@"plist"];
    NSString *plistPathEN = [[NSBundle mainBundle] pathForResource:@"sortedEnames" ofType:@"plist"];
    
    //根据语言 设置不同的数据源
    NSString *valueLangeuage = [[NSUserDefaults standardUserDefaults] objectForKey:AppLanguage];
    if (valueLangeuage) {
        if ([valueLangeuage isEqualToString:JianTiZhongWen]) {
            sortedNameDict = [NSDictionary dictionaryWithContentsOfFile:plistPathCH];
        }else if ([valueLangeuage isEqualToString:FanTiZhongWen]){
            sortedNameDict = [NSDictionary dictionaryWithContentsOfFile:plistPathCHFanti];
        }
        else{
            sortedNameDict = [NSDictionary dictionaryWithContentsOfFile:plistPathEN];
        }
    }else{
        
        // 获取当前系统语言。判断首次应该使用哪个语言文件
        NSArray *languages = [NSLocale preferredLanguages];
        NSString *language = [languages objectAtIndex:0];
        if ([language hasPrefix:JianTiZhongWen]) {//开头匹配简体中文
           sortedNameDict = [NSDictionary dictionaryWithContentsOfFile:plistPathCH];
        }
        else if ([language hasPrefix:FanTiZhongWen]) {//开头匹配繁体中文
            sortedNameDict = [NSDictionary dictionaryWithContentsOfFile:plistPathCHFanti];
        }
        else{//其他一律设置为英文
            sortedNameDict = [NSDictionary dictionaryWithContentsOfFile:plistPathEN];
        }
    }
    
    indexArray = [sortedNameDict allKeys];
    indexArray = [indexArray sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
}
-(void)initMysearchBarcontroller
{
    searchController=[[UISearchController  alloc]initWithSearchResultsController:nil];
    //设置背景不透明
    searchController.searchBar.translucent=NO;
    searchController.searchBar.barTintColor=[UIColor grayColor];

    //用textfiled代替搜索框
    UITextField *searchField=[searchController.searchBar valueForKey:@"searchField"];
    searchField.backgroundColor = [UIColor whiteColor];
    
    //设置searchbar的边框颜色和背景颜色一致
    searchController.searchBar.layer.borderWidth=1;
    searchController.searchBar.layer.borderColor=[[UIColor grayColor] CGColor];
    searchController.searchResultsUpdater = self;
    //默认为YES,控制搜索控制器的灰色半透明效果
    searchController.dimsBackgroundDuringPresentation = NO;
    //默认为YES,控制搜索时，是否隐藏导航栏
    searchController.hidesNavigationBarDuringPresentation = NO;
    searchController.searchBar.frame = CGRectMake(searchController.searchBar.frame.origin.x, searchController.searchBar.frame.origin.y, searchController.searchBar.frame.size.width, 44);
    searchController.searchBar.delegate=self;
    searchController.searchBar.placeholder = @"search";
   countryCodeTableView.tableHeaderView = searchController.searchBar;
    //清空tableview多余的空格线
    [countryCodeTableView setTableFooterView:[[UIView alloc]initWithFrame:CGRectZero]];

}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{

    if (searchController.active) {
       
        [searchResultValuesArray removeAllObjects];

        for (NSArray *array in [sortedNameDict allValues]) {
            for (NSString *value in array) {
                if ([value containsString:searchController.searchBar.text]) {
                    [searchResultValuesArray addObject:value];
                }
            }
        }

        //刷新表格
        [countryCodeTableView reloadData];
        
    }
    else{
        [countryCodeTableView reloadData];
    }
    
}
#pragma mark - UITableView
//section
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (searchController.active) {
        return 1;
    }
    else{
        return [sortedNameDict allKeys].count;
    }

}
//row
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

        if (searchController.active) {
            return searchResultValuesArray.count;
        }else{
            NSArray *array = [sortedNameDict objectForKey:[indexArray objectAtIndex:section]];
            return array.count;
        }

}
//height
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
//初始化cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (searchController.active) {
        static NSString *ID2 = @"cellIdentifier2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID2];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID2];
        }
        if ([searchResultValuesArray count] > 0) {
            cell.textLabel.text = [searchResultValuesArray objectAtIndex:indexPath.row];
        }
        return cell;
    }
    else{
        static NSString *ID1 = @"cellIdentifier1";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID1];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID1];
        }
        //初始化cell数据!
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        
        cell.textLabel.text = [[sortedNameDict objectForKey:[indexArray objectAtIndex:section]] objectAtIndex:row];
        [cell.textLabel setFont:[UIFont systemFontOfSize:16]];
        return cell;
    }

}
//indexTitle
-(NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (searchController.active) {
        return nil;
    }
    else{
        return indexArray;
    }

}
//
-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    
    if (searchController.active) {
        return 0;
    }
    else{
        return index;
    }

}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (searchController.active) {
           return 0;
       }
    else{
        if (section == 0) {
            return 0;
        }
        return 30;
    }

    
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [indexArray objectAtIndex:section];
}

#pragma mark - 选择国际获取代码
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    //    //1.代理传值
    //    if (self.deleagete && [self.deleagete respondsToSelector:@selector(returnCountryCode:)]) {
    //        [self.deleagete returnCountryCode:cell.textLabel.text];
    //    }
    //    [self dismissViewControllerAnimated:YES completion:nil];
    
    //2.block传值
    if (self.returnCountryCodeBlock != nil) {
        NSLog(@"--{Kaadas}--cell.textLabel.text==%@",cell.textLabel.text);
        self.returnCountryCodeBlock(cell.textLabel.text);
    }
    //    [self.navigationController popViewControllerAnimated:YES];
    //UISearchController崩溃的问题
    searchController.active = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 代理传值
-(void)toReturnCountryCode:(returnCountryCodeBlock)block{
    self.returnCountryCodeBlock = block;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
