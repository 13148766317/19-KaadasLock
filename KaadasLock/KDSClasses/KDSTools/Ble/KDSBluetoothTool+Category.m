//
//  KDSBluetoothTool+Category.m
//  BLETest
//
//  Created by zhaowz on 2018/4/25.
//  Copyright © 2018年 zhaowz. All rights reserved.
//

#import "KDSBluetoothTool+Category.h"
#import <objc/runtime.h>
#import "KDSBleAssistant.h"

static char *keyArrayKey = "keyArrayKey";
@interface KDSBluetoothTool ()
@property (nonatomic, strong) NSMutableArray *keyArr;     //密钥数组(开锁的时候使用)
@end

@implementation KDSBluetoothTool (Category)
- (void)dealWithReceiveOldBleModelData:(NSData *)data{
    NSLog(@"--{Kaadas}--老模块data=%@",data);
    if (!data) return;
    //获取收到的数据包头来判断有效性
    NSData *dat = [data subdataWithRange:NSMakeRange(0, 1)];
    u_int8_t tt;
    [dat getBytes:&tt length:sizeof(tt)];
    
    if (self.dataM.length == 0 && tt == 0x00) {
        //前面没剩余，来的又是0开头 所以直接去掉  不处理
        return;
    }
    if (self.dataM.length > 0 && tt == 0x5f ) {
        self.dataM = [[NSMutableData alloc]init];
    }
    if (self.dataM.length + data.length  < 32) {
        [self.dataM appendData:data];
        return;
    }
    if (self.dataM.length + data.length  > 32){
        ////------------------------这里的代码不能注释否则透传或者老板蓝牙无法开锁------------------------------
        NSInteger num = 32 - self.dataM.length ;
        NSRange rangeQian = NSMakeRange(0, num);
        NSRange rangeHou  = NSMakeRange(num, data.length - num);
        NSData *dataQian = [data subdataWithRange:rangeQian];
        NSData *dataHou = [data subdataWithRange:rangeHou];
        [self.dataM appendData:dataQian];
        //处理数据
        [self dealDataAboutEnterNetOrOutNet];
        self.dataM = [[NSMutableData alloc]init];
        [self.dataM appendData:dataHou];
        
    } else {
        //存的数据和接收到的加起来刚好32
        [self.dataM appendData:data];
        //处理数据
        [self dealDataAboutEnterNetOrOutNet];
    }

}

#pragma mark - 处理开锁的逻辑
- (void)doOpenLockWithEncryptData:(NSData *)dataM{
    NSMutableData *dataFina = [[NSMutableData alloc]init];
    self.keyArr = [self getKeyArray];
    for (int i = 0; i < self.keyArr.count; i++) {
        //第一次解密
        NSData *dataJiemi1 = [dataM aes256_decrypt:self.keyArr[i]];
        //        NSData *data16 = [dataJiemi1 subdataWithRange:NSMakeRange(0, 16)];
        //        NSData *jiami16 = [data16 aes256_encrypt:self.keyArr[i]];
        //        NSData *jiemi16 = [jiami16 aes256_decrypt:self.keyArr[i]];
        //        KDSLog(@"data:%@ jiami16:%@ jiemi16:%@",data16,jiami16,jiemi16);
        //获取帧头判断
        NSData *dataJiemiZhenTou = [dataJiemi1 subdataWithRange:NSMakeRange(0, 1)];
        u_int8_t JMZT;
        [dataJiemiZhenTou getBytes:&JMZT length:sizeof(JMZT)];
        
        if (JMZT == 0x5f) {
            //帧头对  再判断校验和
            NSData *xiaoyanData = [dataJiemi1 subdataWithRange:NSMakeRange(4, 28)];
            int xiaoyanhe2 = [self checksum:xiaoyanData];
            const unsigned char *bytes = (const unsigned char*)dataJiemi1.bytes;//小端1、2字节
            int xiaoyanhe1 = bytes[1] + bytes[2] * 256;
            if (xiaoyanhe1 == xiaoyanhe2) {
                //说明数据和秘钥都是对的 获取16位随机数再进行解密  跳出循环 不用再用下一组秘钥去解了
                KDSLog(@"=====第一次解密密码组数：%d",i);
                NSData *suijishuData = [dataJiemi1 subdataWithRange:NSMakeRange(6, 16)];
                
                //根据秘钥组对随机数进行解密，根据前两位判断解密是否正确
                for (int j = 0; j < self.keyArr.count; j++) {
                    NSData *dataJiemi2 = [suijishuData aes256_decrypt:self.keyArr[j]];
                    bytes = dataJiemi2.bytes;
                    //获取前两位 判断校验和
                    int xiaoyanhe3 = bytes[0] + bytes[1] * 256;
                    int xiaoyanhe4 = [self checksum:[dataJiemi2 subdataWithRange:NSMakeRange(2, 14)]];
                    if (xiaoyanhe3 == xiaoyanhe4) {
                        //说明解对了  可以跳出循环
                        KDSLog(@"=====第二次解密密码组数：%d",j);
                        NSData *datafina1 = [dataJiemi1 subdataWithRange:NSMakeRange(0, 6)];
                        NSData *datafina3 = [dataJiemi1 subdataWithRange:NSMakeRange(22, 10)];
                        [dataFina appendData:datafina1];
                        [dataFina appendData:dataJiemi2];
                        [dataFina appendData:datafina3];
                        //到此解密结束   已经拿到正确的回传  下面进行加密
                        
                        //更换帧头  换成f5
                        NSData *data1 = [KDSBleAssistant convertHexStrToData:@"f5"];
                        NSData *data2 = [dataFina subdataWithRange:NSMakeRange(1, 31)];
                        NSMutableData *dataNew = [[NSMutableData alloc]init];
                        [dataNew appendData:data1];
                        [dataNew appendData:data2];
                        
                        if (self.keyArr.count > 0) {
                            NSInteger num = self.keyArr.count;
                            int num1 = arc4random()%num;
                            KDSLog(@"=====收到数据后第一次加密密码组数：%d",num1);
                            NSData *jiamisuijishu = [[dataNew subdataWithRange:NSMakeRange(6, 16)] aes256_encrypt:self.keyArr[num1]];
                            //将加密完成的随机数塞进去
                            NSMutableData *dataNewSend = [[NSMutableData alloc]init];
                            NSData *jiamidata1 = [dataNew subdataWithRange:NSMakeRange(0, 6)];
                            NSData *jiamidata3 = [dataNew subdataWithRange:NSMakeRange(22, 10)];
                            [dataNewSend appendData:jiamidata1];
                            [dataNewSend appendData:jiamisuijishu];
                            [dataNewSend appendData:jiamidata3];
                            
                            //十六位随机数加密之后 校验和需要更改
                            
                            NSData *xiaoyanData2 = [dataNewSend subdataWithRange:NSMakeRange(4, 28)];
                            uint16_t xiaoyanhe5 = [self checksum:xiaoyanData2];
                            uint8_t data [2];
                            data[0] = xiaoyanhe5 & 0x00ff;//lower
                            data[1] = (xiaoyanhe5 >> 8) & 0xff;//upper
                            
                            //将新校验和塞进去
                            NSMutableData *dataNewSend5 = [[NSMutableData alloc]init];
                            NSData *dataNewSend1 = [dataNewSend subdataWithRange:NSMakeRange(0, 1)];
                            NSData *dataNewSend2 = [dataNewSend subdataWithRange:NSMakeRange(3, 29)];
                            [dataNewSend5 appendData:dataNewSend1];
                            [dataNewSend5 appendData:[[NSData alloc] initWithBytes:data length:2]];
                            [dataNewSend5 appendData:dataNewSend2];
                            
                            int num2 = arc4random()%num;
                            KDSLog(@"=====收到数据后第二次加密密码组数：%d",num2);
                            //获取到最终加密完成要发送的数据
                            NSData *finaSendData = [dataNewSend5 aes256_encrypt:self.keyArr[num2]];
                            //拆成两包发送
                            [self sendWithData:[finaSendData subdataWithRange:NSMakeRange(0, 20)]];
                            sleep(0.015);
                            [self sendWithData:[finaSendData subdataWithRange:NSMakeRange(20, 12)]];
                            
                        }
                        break;//跳出第二次解密的循环
                    }
                }
                //跳出第一次解密的循环
                break;
                
            }
        }
    }
}
#pragma mark - 旧的模块处理(入网退网锁成功)
- (void)dealDataAboutEnterNetOrOutNet{
    KDSLog(@"旧蓝牙设备数据的处理--(入网退网锁成功)");
    //获取self.dataM帧头
    NSData *dataZhenTou = [self.dataM subdataWithRange:NSMakeRange(0, 1)];
    u_int8_t ZT;
    [dataZhenTou getBytes:&ZT length:sizeof(ZT)];
    //获取第四位 命令帧
    NSData *dataMingLing = [self.dataM subdataWithRange:NSMakeRange(4, 1)];
    u_int8_t ML;
    [dataMingLing getBytes:&ML length:sizeof(ML)];
    //获取第五位
    NSData *dataWu = [self.dataM subdataWithRange:NSMakeRange(5, 1)];
    u_int8_t Wu;
    [dataWu getBytes:&Wu length:sizeof(Wu)];
    //数据没加密，直接处理
    if (ZT == 0xf5 ) {
        if (ML == 0xb1) { //获取第四位 命令帧 b1表示门锁状态信息通知
            [self sendConfirmDataToOldBleDevice];
            NSString *receipt = @(ML).stringValue;
            void (^block)(NSData *data) = self.tasksMDict[receipt].bleReplyBlock;
            self.tasksMDict[receipt] = nil;
            !block ?: block(self.dataM.copy);
        }else if (ML == 0xb0){   //获取第四位 命令帧 b0表示入网退网
            if (Wu == 0x01) {//表示发过来退网命令
                [self sendResponseInOrOutNet:0];
                if ([self.delegate respondsToSelector:@selector(didReceiveInNetOrOutNetCommand:)]) {
                    [self.delegate didReceiveInNetOrOutNetCommand:NO];
                }
            }else if (Wu ==0x00){//表示发过来入网命令
                [self sendResponseInOrOutNet:0];
                if ([self.delegate respondsToSelector:@selector(didReceiveInNetOrOutNetCommand:)]) {
                    [self.delegate didReceiveInNetOrOutNetCommand:YES];
                }
            }
        }
        
    }else if (ZT == 0x5f ) {
        KDSLog(@"~~~command: %d", ML);
        if (ML == 0xc1){ //表示c1读取门锁信息
            //0x80表示正确的门锁信息返回,将数据解出来放进数据源
            if (Wu == 0x80) {
                NSData *dataQi = [self.dataM subdataWithRange:NSMakeRange(7, 1)];
                u_int8_t Qi;
                [dataQi getBytes:&Qi length:sizeof(Qi)];
                //去高位处理
                u_int8_t QiFinal = (Qi&0x7f);
                int elct = [[NSString stringWithFormat:@"%d",QiFinal] intValue];
                if ([self.delegate respondsToSelector:@selector(didReceiveDeviceElctInfo:)]) {
                    [self.delegate didReceiveDeviceElctInfo:elct];
                }
                KDSLog(@"电量 = = %d",elct);
                //收到电量信息 发送确认帧
                [self sendConfirmDataToOldBleDevice];
            }
        }
        else if (ML == 0xc3){
            //表示c3读取开锁记录
            KDSLog(@"旧蓝牙设备数据的处理--c3读取开锁记录");
            if (Wu == 0x80) {//(单条开门记录数据传输成功)
                KDSLog(@"旧蓝牙设备数据的处理--0x80拼接数据");
                NSMutableArray *container = self.tasksMDict[@(ML).stringValue].attrs[@"container"];
                KDSBleUnlockRecord *record = [[KDSBleUnlockRecord alloc] initWithData:self.dataM];
                [container containsObject:record] ?: [container addObject:record];
                if ([self.delegate respondsToSelector:@selector(didReceivedOpenLockRecord:)]) {
                    [self.delegate didReceivedOpenLockRecord:container];
                }
            }else if(Wu== 0x82){//(开门记录数据传输成功)
                KDSLog(@"旧蓝牙设备数据的处理--0x82数据拼接结束,开始上传数据");
                NSString *receipt = @(ML).stringValue;
                NSMutableArray *container = self.tasksMDict[receipt].attrs[@"container"];
                void (^block)(NSData *data) = self.tasksMDict[receipt].bleReplyBlock;
                self.tasksMDict[receipt] = nil;
                //发送命令时特殊约定
                !block ?: block((NSData *)container);
            }
            else
            {
                void (^block)(NSData *data) = self.tasksMDict[@(ML).stringValue].bleReplyBlock;
                self.tasksMDict[@(ML).stringValue] = nil;
                !block ?: block(nil);
            }
        }
    }
    else {
        //帧头不对数据加密或者出错
        [self doOpenLockWithEncryptData:self.dataM];
    }
}
- (void)sendConfirmDataToOldBleDevice{
    [self.connectedPeripheral writeValue:[KDSBleAssistant convertHexStrToData:@"5f80001c80000000000000000000000000000000"] forCharacteristic:self.writeCharacteristic type:0];
    [NSThread sleepForTimeInterval:0.01];
    [self.connectedPeripheral writeValue:[KDSBleAssistant convertHexStrToData:@"000000000000000000000000"] forCharacteristic:self.writeCharacteristic type:0];
}
- (void)sendWithData:(NSData *)data{
    if (self.writeCharacteristic == nil) return;
    if (data.length > 15) {
        [self.connectedPeripheral writeValue:[KDSBleAssistant convertHexStrToData:@"00000000000000000000000000000000000d0a00"] forCharacteristic:self.writeCharacteristic type:0];
        KDSLog(@"发送的唤醒命令:%@",[KDSBleAssistant convertHexStrToData:@"00000000000000000000000000000000000d0a00"]);
        sleep(0.01);
    }
    [self.connectedPeripheral writeValue:data forCharacteristic:self.writeCharacteristic type:0];
    KDSLog(@"发送的数据data%@",data);
}
- (void)oldBleModelbeginGetElectric{
    KDSLog(@"旧设备获取电量")
    [self sendWithData:[KDSBleAssistant convertHexStrToData:@"f5c1001cc1000000000000000000000000000000"]];
    [NSThread sleepForTimeInterval:0.01];
    [self sendWithData:[KDSBleAssistant convertHexStrToData:@"000000000000000000000000"]];
}
- (void)oldBleModelbeginOpenLock{
    //对命令加密
    NSData *data = [KDSBleAssistant convertHexStrToData:@"f5cb001cc2010800000000000000000000000000000000000000000000000000"];
    self.keyArr = [self getKeyArray];
    NSInteger num = self.keyArr.count;
    NSInteger num2 = arc4random()%num;
    KDSLog(@"=====点击开锁命令加密密码组数：%ld",(long)num2);
    NSData *datajiami = [data aes256_encrypt:self.keyArr[num2]];
    [self sendWithData:[datajiami subdataWithRange:NSMakeRange(0, 20)]];
    [NSThread sleepForTimeInterval:0.01];
    [self sendWithData:[datajiami subdataWithRange:NSMakeRange(20, 12)]];
}
- (void)sendReveiveInNetOrOutNetDatToOldBleDevice{
    //发送收到 入网/退网 确认帧 不需要唤醒设备 1111 1010
    [self.connectedPeripheral writeValue:[KDSBleAssistant convertHexStrToData:@"5f80001c80000000000000000000000000000000"] forCharacteristic:self.writeCharacteristic type:0];
    [NSThread sleepForTimeInterval:0.01];
    [self.connectedPeripheral writeValue:[KDSBleAssistant convertHexStrToData:@"000000000000000000000000"] forCharacteristic:self.writeCharacteristic type:0];
    
    sleep(0.3);
    [self oldBleModelSendInNetSuccessDada];
}
- (void)oldBleModelSendInNetSuccessDada{
    NSData *data = [KDSBleAssistant convertHexStrToData:@"5f30011cb0800000000000000000000000000000000000000000000000000000"];
    NSData *data1 = [data subdataWithRange:NSMakeRange(0,20)];
    NSData *data2 = [data subdataWithRange:NSMakeRange(20, 12)];
    [self sendWithData:data1];
    [NSThread sleepForTimeInterval:0.01];
    [self sendWithData:data2];
}
- (void)oldBleModelSendGetHistoryRecoryOrder{
    KDSLog(@"旧蓝牙设备数据的处理--发送命令获取历史记录");
    [self sendWithData:[KDSBleAssistant convertHexStrToData:@"f5c2011cc3ff0000000000000000000000000000"]];
    [NSThread sleepForTimeInterval:0.01];
    [self sendWithData:[KDSBleAssistant convertHexStrToData:@"000000000000000000000000"]];
}

/**
 *@abstract 获取二进制数据流每个字节的无符号值的和。
 *@param data 二进制数据。
 *@return 如果参数为空或者不是NSData类型，会返回0xffff。
 */
- (uint16_t)checksum:(NSData *)data
{
    if (![data isKindOfClass:NSData.class]) return 0xffff;
    const uint8_t *bytes = data.bytes;
    uint16_t checksum = 0;
    for (int i = 0; i < data.length; ++i)
    {
        checksum += bytes[i];
    }
    return checksum;
}
#pragma mark - runtime获取属性
- (NSMutableArray *)keyArr{
    return objc_getAssociatedObject(self, keyArrayKey);
}
- (void)setKeyArr:(NSMutableArray *)keyArr{
    objc_setAssociatedObject(self, keyArrayKey, keyArr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)getKeyArray{
    if (self.keyArr == nil) {
        NSMutableArray *arrM = [[NSMutableArray alloc]init];
        //1
        Byte byte1[16] = {0x56,0x6d,0x59,0x5a,0x57,0x59,0x65,0x32,0x78,0x47,0x70,0x79,0x31,0x49,0x66,0x6b};
        NSData *data1 = [NSData dataWithBytes:byte1 length:sizeof(byte1)];
        NSString *str1 = [[NSString alloc]initWithData:data1 encoding:NSUTF8StringEncoding];
        [arrM addObject:str1];
        //2
        Byte byte2[16] = {0x6d,0x35,0x35,0x47,0x52,0x79,0x57,0x7a,0x37,0x6a,0x6b,0x36,0x55,0x4c,0x39,0x4f};
        NSData *data2 = [NSData dataWithBytes:byte2 length:sizeof(byte2)];
        NSString *str2 = [[NSString alloc]initWithData:data2 encoding:NSUTF8StringEncoding];
        [arrM addObject:str2];
        //3
        Byte byte3[16] = {0x37,0x44,0x7a,0x32,0x55,0x79,0x61,0x50,0x54,0x59,0x61,0x49,0x4e,0x4f,0x68,0x54};
        NSData *data3 = [NSData dataWithBytes:byte3 length:sizeof(byte3)];
        NSString *str3 = [[NSString alloc]initWithData:data3 encoding:NSUTF8StringEncoding];
        [arrM addObject:str3];
        //4
        Byte byte4[16] = {0x37,0x44,0x55,0x34,0x78,0x70,0x77,0x4f,0x61,0x42,0x45,0x39,0x64,0x56,0x6e,0x75};
        NSData *data4 = [NSData dataWithBytes:byte4 length:sizeof(byte4)];
        NSString *str4 = [[NSString alloc]initWithData:data4 encoding:NSUTF8StringEncoding];
        [arrM addObject:str4];
        //5
        Byte byte5[16] = {0x35,0x76,0x71,0x75,0x4e,0x58,0x31,0x50,0x5a,0x75,0x61,0x74,0x47,0x44,0x34,0x58};
        NSData *data5 = [NSData dataWithBytes:byte5 length:sizeof(byte5)];
        NSString *str5 = [[NSString alloc]initWithData:data5 encoding:NSUTF8StringEncoding];
        [arrM addObject:str5];
        //6
        Byte byte6[16] = {0x56,0x36,0x54,0x4e,0x53,0x45,0x72,0x68,0x58,0x50,0x67,0x64,0x4a,0x53,0x5a,0x55};
        
        NSData *data6 = [NSData dataWithBytes:byte6 length:sizeof(byte6)];
        NSString *str6 = [[NSString alloc]initWithData:data6 encoding:NSUTF8StringEncoding];
        [arrM addObject:str6];
        //7
        Byte byte7[16] = {0x38,0x72,0x72,0x6b,0x63,0x42,0x53,0x77,0x39,0x39,0x32,0x38,0x70,0x78,0x6d,0x6a};
        
        NSData *data7 = [NSData dataWithBytes:byte7 length:sizeof(byte7)];
        NSString *str7 = [[NSString alloc]initWithData:data7 encoding:NSUTF8StringEncoding];
        [arrM addObject:str7];
        //8
        Byte byte8[16] = {0x72,0x59,0x41,0x36,0x78,0x6d,0x39,0x6d,0x50,0x31,0x67,0x71,0x64,0x49,0x74,0x5a};
        NSData *data8 = [NSData dataWithBytes:byte8 length:sizeof(byte8)];
        NSString *str8 = [[NSString alloc]initWithData:data8 encoding:NSUTF8StringEncoding];
        [arrM addObject:str8];
        Byte byte9[16] = {0x64,0x78,0x6a,0x34,0x69,0x77,0x58,0x50,0x42,0x52,0x50,0x4d,0x32,0x75,0x6b,0x34};
        NSData *data9 = [NSData dataWithBytes:byte9 length:sizeof(byte9)];
        NSString *str9 = [[NSString alloc]initWithData:data9 encoding:NSUTF8StringEncoding];
        [arrM addObject:str9];
        //10
        Byte byte10[16] = {0x6c,0x72,0x79,0x30,0x43,0x72,0x50,0x35,0x48,0x44,0x47,0x4c,0x35,0x56,0x71,0x59};
        NSData *data10 = [NSData dataWithBytes:byte10 length:sizeof(byte10)];
        NSString *str10 = [[NSString alloc]initWithData:data10 encoding:NSUTF8StringEncoding];
        [arrM addObject:str10];
        //        NSLog(@"秘钥组:%@",arrM);
        self.keyArr = [arrM mutableCopy];
    }
    return self.keyArr;
}


@end
