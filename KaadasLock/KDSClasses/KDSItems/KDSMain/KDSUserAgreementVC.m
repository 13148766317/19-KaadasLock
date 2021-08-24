//
//  KDSUserAgreementVC.m
//  xiaokaizhineng
//
//  Created by orange on 2019/2/25.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSUserAgreementVC.h"

@interface KDSUserAgreementVC ()

@end

@implementation KDSUserAgreementVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationTitleLabel.text = Localized(@"userAgreement");
    self.view.backgroundColor = KDSRGBColor(242, 242, 242);
    [self setRightButton];
    UITextView *textView = [[UITextView alloc] init];
    textView.editable = NO;
    textView.selectable = NO;
    textView.dataDetectorTypes = UIDataDetectorTypeNone;
    textView.textAlignment = NSTextAlignmentLeft;
    textView.attributedText = [self zhSimple];
    textView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:textView];
    [textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self.view);
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}

- (NSAttributedString *)zhSimple
{
    NSString *content = @"\n\n本协议系深圳市凯迪仕智能科技有限公司（以下简称“kaadas”）与所有使用凯迪仕智能科技客户端（以下简称“凯迪仕”）的主体（包含但不限于个人、团队等）（以下简称用户）所订立的有效合约。使用凯迪仕的任何服务即表示接受本协议的全部条款。\n\n一、总则\n\n1.1 凯迪仕智能的所有权和运营权归深圳市凯迪仕智能科技有限公司所有。\n\n1.2 用户在注册之前，应当仔细阅读本协议，并同意遵守本协议后方可成为注册用户。一旦注册成功，则用户与凯迪仕之间自动形成协议关系，用户应当受本协议的约束。用户在使用特殊的服务或产品时，应当同意接受相关协议后方能使用。\n\n1.3 本协议可由凯迪仕智能随时更新，更新后的协议条款一旦公布即代替原来的协议条款，恕不再另行通知，用户可在本平台查阅最新版协议条款。在凯迪仕智能修改协议条款后，如果用户不接受修改后的条款，请立即停止使用凯迪仕提供的服务，用户继续使用凯迪仕提供的服务将被视为接受修改后的协议。\n\n二、服务内容及使用须知\n\n2.1 凯迪仕智能APP需配合凯迪仕品牌相关产品使用。\n\n2.2 凯迪仕智能仅提供相关的网络服务，除此之外与相关网络服务有关的设备(如个人电脑、手机、及其他与接入互联网或移动网有关的装置)及所需的费用(如为接入互联网而支付的电话费及上网费、为使用移动网而支付的手机费)均应由用户自行负担。\n\n三、用户账号\n\n3.1 经凯迪仕智能注册系统完成注册程序并通过身份认证的用户即成为正式用户，可以获得凯迪仕规定用户所应享有的一切权限。\n\n3.2 用户通过该账号所进行的一切活动引起的任何损失或损害，由用户自行承担全部责任，凯迪仕智能不承担任何责任。因黑客行为或用户的保管疏忽导致账号非法使用，凯迪仕不承担任何责任。\n\n四、使用规则\n\n4.1 用户需遵守中华人民共和国相关法律法规，包括但不限于《中华人民共和国计算机信息系统安全保护条例》、《计算机软件保护条例》、《最高人民法院关于审理涉及计算机网络著作权纠纷案件适用法律若干问题的解释(法释[2004]1号)》、《全国人大常委会关于维护互联网安全的决定》、《互联网电子公告服务管理规定》、《互联网新闻信息服务管理规定》、《互联网著作权行政保护办法》和《信息网络传播权保护条例》等有关计算机互联网规定和知识产权的法律和法规、实施办法。\n\n4.2 用户对其自行发表、上传或传送的内容负全部责任，所有用户不得在凯迪仕智能任何页面发布、转载、传送含有下列内容之一的信息，否则凯迪仕有权自行处理并不通知用户，且由此引起的任何损失或损害，由用户自行承担全部责任，凯迪仕不承担任何责任：\n(1)违反宪法确定的基本原则的；\n(2)危害国家安全，泄漏国家机密，颠覆国家政权，破坏国家统一的；\n(3)损害国家荣誉和利益的；\n(4)煽动民族仇恨、民族歧视，破坏民族团结的；\n(5)破坏国家宗教政策，宣扬邪教和封建迷信的；\n(6)散布谣言，扰乱社会秩序，破坏社会稳定的；\n(7)散布淫秽、色情、赌博、暴力、恐怖或者教唆犯罪的；\n(8)侮辱或者诽谤他人，侵害他人合法权益的；\n(9)煽动非法集会、结社、游行、示威、聚众扰乱社会秩序的；\n(10)以非法民间组织名义活动的；\n(11)含有法律、行政法规禁止的其他内容的。\n\n4.3 用户承诺对其发表或者上传于凯迪仕智能的所有信息(即属于《中华人民共和国著作权法》规定的作品，包括但不限于文字、图片、音乐、电影、表演和录音录像制品和电脑程序等)均享有完整的知识产权，或者已经得到相关权利人的合法授权；如用户违反本条规定造成优点智能被第三人索赔的，用户应全额补偿凯迪仕一切费用(包括但不限于各种赔偿费、诉讼代理费及为此支出的其它合理费用)，由此引起的任何损失或损害，由用户自行承担全部责任，凯迪仕不承担任何责任；\n\n4.4 当第三方认为用户发表或者上传于凯迪仕的信息侵犯其权利，并根据《信息网络传播权保护条例》或者相关法律规定向凯迪仕发送权利通知书时，用户同意凯迪仕可以自行判断决定删除涉嫌侵权信息，除非用户提交书面证据材料排除侵权的可能性，凯迪仕智能将不会自动恢复上述删除的信息；\n\n4.5 用户保证，其向凯迪仕智能上传的内容不得直接或间接的：\n(1)为任何非法目的而使用网络服务系统；\n(2)以任何方式干扰或企图干扰凯迪仕智能客户端或深圳市凯迪仕智能科技有限公司网站的任何部分及功能的正常运行；\n(3)避开、尝试避开或声称能够避开任何内容保护机制或者凯迪仕智能数据度量工具；\n(4)未获得凯迪仕事先书面同意以书面格式或图形方式使用源自凯迪仕智能科技的任何注册或未注册的作品、服务标志、公司徽标（LOGO）、URL或其他标志；\n(5)请求、收集、索取或以其他方式从任何用户那里获取对凯迪仕智能科技账号、密码或其他身份验证凭据的访问权；\n(6)为任何用户自动登录到凯迪仕智能账号代理身份验证凭据；\n(7)提供跟踪功能，包括但不限于识别其他用户在个人主页上查看或操作；\n(8)未经授权冒充他人获取对凯迪仕智能科技的访问权。\n\n4.6 用户违反上述任何一款的保证，凯迪仕均有权就其情节对其做出警告、屏蔽直至取消登录资格的处罚；如因用户违反上述保证而给凯迪仕、凯迪仕智能用户或凯迪仕智能科技的任何合作伙伴造成损失，用户自行负责承担一切法律责任并赔偿损失。\n\n五、隐私保护\n\n5.1 凯迪仕智能不对外公开或向第三方提供单个用户的注册资料及用户在使用网络服务时存储在凯迪仕智能的非公开内容，但下列情况除外：\n(1)事先获得用户的明确授权；\n(2)根据有关的法律法规要求；\n(3)按照相关政府主管部门的要求；\n(4)为维护社会公众的利益。\n\n5.2 凯迪仕智能可能会与第三方合作向用户提供相关的网络服务，在此情况下，如该第三方同意承担与优点智能同等的保护用户隐私的责任，则凯迪仕智能有权将用户的注册资料等提供给该第三方。\n\n5.3 在不透露单个用户隐私资料的前提下，凯迪仕智能有权对整个用户数据库进行分析并对用户数据库进行商业上的利用。\n\n六、版权声明\n\n6.1 凯迪仕智能的文字、图片、音频、视频等版权均归深圳凯迪仕智能科技有限公司享有或与作者共同享有，未经优点智能许可，不得任意转载，否则将承担相关法律责任。\n\n6.2 凯迪仕智能特有的标识、版面设计、编排方式等版权均属深圳凯迪仕智能科技有限公司享有，未经凯迪仕智能许可，不得任意复制或转载。\n\n6.3 使用凯迪仕智能的任何内容均应注明“来源于凯迪仕智能”及署上作者姓名，按法律规定需要支付稿酬的，应当通知凯迪仕及作者并支付稿酬，并独立承担一切法律责任。\n\n6.4 凯迪仕智能享有所有作品用于其它用途的优先权，包括但不限于网站、电子杂志、平面出版等，但在使用前会通知作者，并按同行业的标准支付稿酬。\n\n6.5 凯迪仕智能所有内容仅代表作者自己的立场和观点，与凯迪仕无关，由作者本人承担一切法律责任。\n\n6.6 恶意转载凯迪仕智能内容的，凯迪仕保留将其诉诸法律的权利。\n\n七、责任声明\n\n7.1 用户明确同意其使用凯迪仕智能网络服务所存在的风险及一切后果将完全由用户本人承担，凯迪仕对此不承担任何责任。\n\n7.2 凯迪仕智能无法保证网络服务一定能满足用户的要求，也不保证网络服务的及时性、安全性、准确性。\n\n7.3 凯迪仕智能不保证为方便用户而设置的外部链接的准确性和完整性，同时，对于该等外部链接指向的不由凯迪仕智能实际控制的任何网页上的内容，凯迪仕智能不承担任何责任。\n\n7.4对于凯迪仕智能向用户提供的下列产品或者服务的质量缺陷本身及其引发的任何损失，凯迪仕智能无需承担任何责任：\n(1)凯迪仕智能向用户免费提供的各项网络服务；\n(2)凯迪仕智能向用户赠送的任何产品或者服务。\n\n7.5 凯迪仕智能有权于任何时间暂时或永久修改或终止本服务(或其任何部分)，而无论其通知与否，凯迪仕智能对用户和任何第三人均无需承担任何责任。\n\n八、附则\n\n8.1 本协议的订立、执行和解释及争议的解决均应适用中华人民共和国法律。如用户和优点科技就本协议内容或其执行发生任何争议，双方应尽量友好协商解决；协商不成时，任何一方均可向凯迪仕所在地的人民法院提起诉讼。\n\n8.2本协议一经公布即生效，凯迪仕有权随时对协议内容进行修改，修改后的结果公布于凯迪仕智能科技网站上。如果不同意凯迪仕对本协议相关条款所做的修改，用户有权停止使用网络服务。如果用户继续使用网络服务，则视为用户接受凯迪仕智能科技对本协议相关条款所做的修改。\n\n8.3 如本协议中的任何条款无论因何种原因完全或部分无效或不具有执行力，本协议的其余条款仍应有效并且有约束力。\n\n8.4不可抗力条款：如果不能履行本协议是由于一方所不能预见和控制的原因造成的，如战争、罢工、自然灾害、恶劣天气、航空运输中断等，则不能履行本协议的一方可相应免责。\n\n8.5 本协议解释权及修订权归深圳市凯迪仕智能科技有限公司所有。\n\n\n";

    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    style.firstLineHeadIndent = style.headIndent = 10;
    style.tailIndent = -10;
    NSDictionary *attrs = @{NSFontAttributeName:[UIFont systemFontOfSize:17], NSForegroundColorAttributeName:UIColor.blackColor, NSParagraphStyleAttributeName:style};
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:content attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSParagraphStyleAttributeName:style}];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"一、总则"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"二、服务内容及使用须知"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"三、用户账号"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"四、使用规则"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"五、隐私保护"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"六、版权声明"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"七、责任声明"]];
    [attrStr addAttributes:attrs range:[content rangeOfString:@"八、附则"]];
    
    return attrStr;
}

@end
