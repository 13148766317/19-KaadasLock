//
//  KDSCodingObject.h
//  KaadasLock
//
//  Created by orange on 2019/4/30.
//  Copyright © 2019年 com.Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///这个类实现了NSCoding协议，子类继承时可以直接使用编解码，但需要注意C基本类型属性不要设置为结构体和指针等，没有兼容这些类型。
@interface KDSCodingObject : NSObject <NSCoding>

/**************************************************************
 *          新增变量时不要添加结构体和C指针，没有做编码兼容            *
 **************************************************************/

@end

NS_ASSUME_NONNULL_END
