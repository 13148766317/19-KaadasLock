# KDSToolkit

## 主要功能

配置应用服务器与相关设置，调试测试隐含功能，可UI界面更改；日志文件保存、显示日志控制台，发送APP日志文件；加密配置文件

### 问题
1. 同事经常测试APP与设备，非预期行为，后发现APP版本与服务器环境不一致，目前公司APP，如要连接不同服务器进行测试，需重新下载对应APP，而iOS APP的下载，又分应用商城与内部分发版，一个简单的下载，往往会花费不少时间
2. APP操作设备，有时无预期响应，除了现象外，非开发人员无法知道APP/服务器/设备更多运行信息

### 解决
1. APP提供服务器配置文件，可UI界面选择更改，如切换测试服务器/正式服务器/海外服务器
2. APP显示日志控制台，有问题可随时了解运行情况
3. 日志文件保存，提供发送APP日志文件功能，便于开发人员诊断
3. 提供功能基础库，方便应用快速集成与后继升级完善，提供更多功能



## 配置原理

根据应用发行版本类别，生成各种类别配置值；应用运行前指定版本类别，再从指定的版本类别下，存取配置

```javascript
let settings = {
  debug: { httpServer: 'http://test.www.api.com', sipServer: 'test.sip.api.com' },
  release: { httpServer: 'http://www.api.com', sipServer: 'sip.api.com' },
};

//指定配置为debug
let config = 'debug';
//获取配置键值
console.log('debug httpServer ' + settings[config].httpServer); 
//输出 http://test.www.api.com

//指定配置为release
config = 'release';
console.log('release httpServer ' + settings[config].httpServer); 
//输出http://www.api.com
```

![KDSToolkit.png](./KDSToolkit.png)

## 使用示例

要运行示例项目，请克隆 repo，并先从 Example 目录中运行 pod install。



## 要求

为应用添加配置文件：AppConfig.json，初始化指定文件与密码

## 安装

KDSToolkit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LumberjackConsole', :git => 'git@192.168.2.250:fujinqian/LumberjackConsole.git'

pod 'KDSToolkit', :git => 'git@192.168.2.250:fujinqian/KDSToolkit.git'

```
## 使用
通过json配置文件，支持应用获取与修改相关配置常量与设置
- 一种是用于常用应用各种服务器DEBUG/RELEASE下常量值的读取，可适配应用不同版本，取对应的常量值
- 另一种是全局设置：关联指定应用服务器版本，可通过界面来修改；其它设置值，实现隐含，动态修改功能
- 为应用添加配置文件AppConfig.json，后续可改为服务器获取

### json 文件介绍

| 名称  | 值   | 说明 |
| --- | --- | --- |
| protocolVer | 1   | 配置文件支持版本，保留字段，用于后继功能兼容 |
| dataVer | 2020042603 | 数据版本，值要比之前的大，用于比对替换最新配置文件 |
| data | json对象 | 定义各种配置、UI配置、指定设置 |
| data.server | json对象 | 定义各种服务器常量值 |
| data.settingValues | json对象 | 定义各种模式下全局设置 |
| data.settingRows | json数组 | UI配置 |
| encrypted | 0或1 | 标识data数据是否加密，如果是，使用encryptedData保存加密后的data数据 |
| encryptedData | HNGEyJJA== | data数据加密后的base64字符串 |

```json
{
  "dataVer" : "2022042603",
  "data" : {
    "server" : {
      "Debug" : {
        "httpServer" : "https:\/\/test.juziwulian.com:8090\/",
        "sipServer" : "test.juziwulian.com",
        "mqttServer" : "test.juziwulian.com"
      },
      "Release" : {
        "httpServer" : "https:\/\/app.kaadas.com:34000\/",
        "sipServer" : "sip-kaadas.juziwulian.com",
        "mqttServer" : "mqtt-kaadas.juziwulian.com"
      }
    },
    "settingValues" : {
      "Debug" : {
        "server" : "Debug",
        "enableDebug" : 0
      },
      "AdHot" : {
        "server" : "Debug",
        "enableDebug" : 0
      },
      "AppStore" : {
        "server" : "Release",
        "enableDebug" : 0
      }
    },
    "settingRows" : [
      {
        "title" : "配置模式",
        "rowType" : "selectorPush",
        "selectorTitle" : "配置模式",
        "tag" : "server",
        "selectorOptions" : [
          {
            "value" : "Debug",
            "displayText" : "Debug"
          },
          {
            "value" : "Release",
            "displayText" : "Release"
          }
        ]
      },
      {
        "tag" : "enableDebug",
        "title" : "开启调试",
        "rowType" : "booleanSwitch"
      }
    ]
  },
  "encrypted" : 1,
  "protocolVer" : "1",
  "encryptedData" : "dPYGX7S0hZlKvhOC0f4aFcPFnwLt5TWPbfincvrJKyi6iNVACf686+Bnhv\/VSgRejcLtm5HCHat7i4xDZhCzKLZCZdavUsw1WP\/8ImjBgXQulXlhsBQMJTBGLXfA4Z64nkfXEDmzxJC7gMx8K+7ebpCIj02K3Q06Wamc+U02SHaP24ZA6Y6hJGZ5TnhVH6HwTvWAqi4wM2BxjSt\/fVksYtQksBBbf4ijb5IY7PJG7O0QUKoUpJ0MaSUubot+g3pbf8Ztebc199Zic9gVgjezUtw0Xwj2lMuWCQb1b8kGEOVLWQES+j1sd21isjvZe7JW\/4i3tcFYTH3srgw0Ldod8VFTtUJPBst0tneGDBPuKHMKS9bCk+htrvZCqKf3y7r5EIG5aornFAgUWu\/6a8VZiG8hL2k9tzkgNe6BhkZhLA3FiLud203dfE6vIcUwEJ6h78DrhaM3v627WFAPb4awgdd6kX3BthApc2bRt8gC3Ib0ohbuRQpgW+ddFP1joquLBsj1DwJjsEcxlspKcOsslEUNnJJKtSegK+BTyvD20Y4meCMQPGHxEfiWVbym9EnTz9G725hNcuO\/rWaI3sqADHW8OEb5tddzi7op8kzOjSD7EMsp9U4OYBSxVYCN2bArrJldT\/x3WHol5y5IiQ80wmlXy8C1Uo3hPRM8lPrGO+NhLOShAyXS5ZvIpAMsxfT+Dg2SYA8AKEbwgDqUrEGqXuqUNDpSYor5OKrckRR6a43wWnLwpAgANB03+WMGgQxy9MLsLFY87+H5u08Iynnpu26Vhh92YqqWTTgxqrqOXlk1go6gagaxzlnDdW76gqzDtJrnNMsWFIXbmf67brm\/4tTirEGkT48vKR4hcEvLUy6PQr2OrXQ2rGkfQQhRRIKligHLrTF+XhgQunt+p4qRfWXqrsdkEdvpCrEE8pvY07H4LUbvgaMyXT+N0NkHdjf7f\/04lvw2nYbD0WHNGEyJJA=="
}


```


### AppDelegate文件初始化

1. 指定使用初始化配置文件与解密数据密码
2. 指定使用 data.settingValues下某一个配置

```ObjC


[KDSAppSettings setConfigFilePath:[[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"json"] passwd:[@[@"kds",@"3456789abc",@"ios"] componentsJoinedByString:@""]];


#ifdef DEBUG
[[KDSAppSettings sharedInstance] applySettingValuesWithName:@"Debug"];

#else
[[KDSAppSettings sharedInstance] applySettingValuesWithName:@"AppStore"];

#endif

```


### 读取server DEBUG/RELEASE下常量值的读取
key为data.server.xxxx.yyyy，其中xxxx对应data.settingValues.***.server设置

```objectivec
KDSAppSettings *appSettings = [KDSAppSettings sharedInstance];
//获取当前config中的键值
NSLog(@"%@",[appSettings serverObjectForKey:KDSToolKitConfigHttpServer]);
```

### 调用界面更改全局设置

设置
```objectivec
KDSAppSettingsVC *vc = [[KDSAppSettingsVC alloc] init];
UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

[self presentViewController:nav animated:YES completion:nil];


vc.backBlock = ^() {
    [self dismissViewControllerAnimated:YES completion:nil];
};
```
### 读取全局设置，进行隐含功能操作
key为：data.settingValues.xxxx字典下的键名，xxxx由[KDSAppSettings applySettingValuesWithName:] 配置
```objectivec
KDSAppSettings *appSettings = [KDSAppSettings sharedInstance];
if ([appSettings settingObjectForKey:KDSToolKitSettingEnableDebug]) {

}else {

}
```
### 配置文件数据加密
读取配置文件中的data，生成加密配置文件的encryptedData，复制输出结果到配置文件里即可；为安全起见，正式应用集成配置文件，要求删除data字段
```objectivec
NSLog(@"encrypt:\n%@",[KDSAppSettings
                      genEncryptConfigFilePath:[[NSBundle mainBundle] pathForResource:@"AppConfig" ofType:@"json"]  passwd:[@[@"kds",@"3456789abc",@"ios"] componentsJoinedByString:@""]]);
```
### 使用日志

1. 工程 pch 文件中引入头文件，ddLogLevel定义日志显示级别（为0时不输出日志）

    ```objectivec

    #import <CocoaLumberjack/CocoaLumberjack.h>
    #ifdef DEBUG
    #define ddLogLevel DDLogLevelVerbose
    #else
    #define ddLogLevel 0
    #endif

    ```
2. AppDelegate 文件初始化日志保存

    ```objectivec

    #import <KDSToolkit/KDSAppLog.h>
    @implementation KDSAppDelegate

    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        // Override point for customization after application launch.
        [KDSAppLog defaultConfig];
        
        return YES;
    }

    ```

3. 代码中打印日志

    ```objectivec

    DDLogInfo(@"%@",@"log");
    DDLogDebug(@"%@",@"log");

    ```
4. 原先日志替换与NSLog禁用

    ```objectivec

    #define KDSLog(FORMAT, ...) DDLogInfo(FORMAT, ##__VA_ARGS__);
    #define NSLog(...)

    ```
5. MQTT库中有定义相关日志宏，需为工程添加宏定义LUMBERJACK，不使用MQTT库中自定义的


## Author

alf, fujinqian@kaadas.com

