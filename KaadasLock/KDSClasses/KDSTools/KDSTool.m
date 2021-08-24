//
//  KDSTool.m
//  xiaokaizhineng
//
//  Created by orange on 2019/1/15.
//  Copyright © 2019年 shenzhen kaadas intelligent technology. All rights reserved.
//

#import "KDSTool.h"
#import <sys/utsname.h>
#include "libavcodec/avcodec.h"
#include "libavformat/avformat.h"
#include "libswscale/swscale.h"

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include <math.h>
#include <errno.h>
#include <limits.h>
#include <stdint.h>
#include <sys/stat.h>
#include <termios.h>
#include <fcntl.h>

#import <sys/utsname.h>
#import <Accelerate/Accelerate.h>
#import <CoreLocation/CLLocationManager.h>

NSString * const KDSLocaleLanguageDidChangeNotification = @"KDSLocaleLanguageDidChangeNotification";

@implementation KDSTool
#define FixedTime    946684800      //1970-2001年的时间 秒数
#define TAG "mkv"
#define FRAMERATE 25
#define BITRATE 334
#define SAMPLERATE 8000

@dynamic crc;
+ (void)setLanguage:(nullable NSString *)language
{
    NSString *lanExisted = [self getLanguage];
    NSString *lan_ = language;
    if (!language)
    {
        if (lanExisted) return;
        NSArray *preferredLanguages = [NSLocale preferredLanguages];
        language = preferredLanguages.firstObject;
        /*NSArray<NSString *> *comps = [language componentsSeparatedByString:@"-"];
        if ([[NSLocale ISOCountryCodes] containsObject:comps.lastObject])
        {
            language = [language substringToIndex:lan.length - 3];
        }*/
    }
    
    if ([language hasPrefix:JianTiZhongWen]) {//开头匹配简体中文
        language = JianTiZhongWen;
    }
    else if ([language hasPrefix:FanTiZhongWen]) {//开头匹配繁体中文
        language = FanTiZhongWen;
    }else if ([language hasPrefix:@"th"]){
        language = Thailand;
    }else{//其他一律设置为英文
        language = English;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:AppLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (![lanExisted isEqualToString:language] && lan_)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KDSLocaleLanguageDidChangeNotification object:nil];
    }
}

+ (NSString *)getLanguage
{
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:AppLanguage];
    return language;
}
+ (void)saveDeviceToken:(NSString *)deviceToken{
    NSString *Key = [NSString stringWithFormat:@"%@",@"deviceToken"];
    [KDSUserDefaults setObject:deviceToken forKey:Key];
    [KDSUserDefaults synchronize];
}
+ (void)saveVoIPDeviceToken:(NSString *)deviceToken{
    NSString *Key = [NSString stringWithFormat:@"%@",@"VoIPDeviceToken"];
    [KDSUserDefaults setObject:deviceToken forKey:Key];
    [KDSUserDefaults synchronize];
}
+ (NSString *)getDeviceToken{
    return  [KDSUserDefaults objectForKey:@"deviceToken"];
}
+ (NSString *)getVoIPDeviceToken{
    return  [KDSUserDefaults objectForKey:@"VoIPDeviceToken"];
}
+ (void)deleteDeviceToken{
    [KDSUserDefaults removeObjectForKey:@"deviceToken"];
    [KDSUserDefaults synchronize];
}

+ (void)setCrc:(NSString *)crc
{
    [[NSUserDefaults standardUserDefaults] setObject:crc forKey:@"countryOrRegionCode"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)crc
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"countryOrRegionCode"];
}

+ (void)setNotificationOn:(BOOL)on forDevice:(NSString *)deviceId
{
    deviceId = deviceId ?: @"";
    [[NSUserDefaults standardUserDefaults] setObject:on ? @"YES" : @"NO" forKey:[@"notificationOn-" stringByAppendingString:deviceId]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)getNotificationOnForDevice:(NSString *)deviceId
{
    deviceId = deviceId ?: @"";
   NSString *value = [[NSUserDefaults standardUserDefaults] objectForKey:[@"notificationOn-" stringByAppendingString:deviceId]];
    return value ? value.boolValue : YES;
}

+ (NSString *)appVersion
{
    return [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
}
+ (NSString*)getIphoneType{
    
    //需要导入头文件：#import <sys/utsname.h>
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    NSDictionary<NSString *, NSString *> *dict = @{
                                                   // iPhone
                                                   @"iPhone1,1" : @"iPhone 2G",
                                                   @"iPhone1,2" : @"iPhone 3G",
                                                   @"iPhone2,1" : @"iPhone 3GS",
                                                   @"iPhone3,1" : @"iPhone 4",
                                                   @"iPhone3,2" : @"iPhone 4",
                                                   @"iPhone3,3" : @"iPhone 4",
                                                   @"iPhone4,1" : @"iPhone 4S",
                                                   @"iPhone5,1" : @"iPhone 5",
                                                   @"iPhone5,2" : @"iPhone 5",
                                                   @"iPhone5,3" : @"iPhone 5c",
                                                   @"iPhone5,4" : @"iPhone 5c",
                                                   @"iPhone6,1" : @"iPhone 5s",
                                                   @"iPhone6,2" : @"iPhone 5s",
                                                   @"iPhone7,1" : @"iPhone 6 Plus",
                                                   @"iPhone7,2" : @"iPhone 6",
                                                   @"iPhone8,1" : @"iPhone 6s",
                                                   @"iPhone8,2" : @"iPhone 6s Plus",
                                                   @"iPhone8,4" : @"iPhone SE",
                                                   @"iPhone9,1" : @"iPhone 7",
                                                   @"iPhone9,2" : @"iPhone 7 Plus",
                                                   @"iPhone9,3" : @"iPhone 7",
                                                   @"iPhone9,4" : @"iPhone 7 Plus",
                                                   @"iPhone10,1" : @"iPhone 8",
                                                   @"iPhone10,4" : @"iPhone 8",
                                                   @"iPhone10,2" : @"iPhone 8 Plus",
                                                   @"iPhone10,5" : @"iPhone 8 Plus",
                                                   @"iPhone10,3" : @"iPhone X",
                                                   @"iPhone10,6" : @"iPhone X",
                                                   @"iPhone11,2" : @"iPhone XS",
                                                   @"iPhone11,4" : @"iPhone XS Max",
                                                   @"iPhone11,6" : @"iPhone XS Max",
                                                   @"iPhone11,8" : @"iPhone XR",
                                                   // iPad
                                                   @"iPad1,1" : @"iPad 1G",
                                                   @"iPad2,1" : @"iPad 2",
                                                   @"iPad2,2" : @"iPad 2",
                                                   @"iPad2,3" : @"iPad 2",
                                                   @"iPad2,4" : @"iPad 2",
                                                   @"iPad3,1" : @"iPad 3",
                                                   @"iPad3,2" : @"iPad 3",
                                                   @"iPad3,3" : @"iPad 3",
                                                   @"iPad3,4" : @"iPad 4",
                                                   @"iPad3,5" : @"iPad 4",
                                                   @"iPad3,6" : @"iPad 4",
                                                   @"iPad4,1" : @"iPad Air",
                                                   @"iPad4,2" : @"iPad Air",
                                                   @"iPad4,3" : @"iPad Air",
                                                   @"iPad5,3" : @"iPad Air 2",
                                                   @"iPad5,4" : @"iPad Air 2",
                                                   @"iPad6,7" : @"iPad Pro 12.9",
                                                   @"iPad6,8" : @"iPad Pro 12.9",
                                                   @"iPad6,3" : @"iPad Pro 9.7",
                                                   @"iPad6,4" : @"iPad Pro 9.7",
                                                   @"iPad6,11" : @"iPad 5",
                                                   @"iPad6,12" : @"iPad 5",
                                                   @"iPad7,1" : @"iPad Pro 12.9 inch 2nd gen",
                                                   @"iPad7,2" : @"iPad Pro 12.9 inch 2nd gen",
                                                   @"iPad7,3" : @"iPad Pro 10.5",
                                                   @"iPad7,4" : @"iPad Pro 10.5",
                                                   @"iPad7,5" : @"iPad 6",
                                                   @"iPad7,6" : @"iPad 6",
                                                   // iPad mini
                                                   @"iPad2,5" : @"iPad mini",
                                                   @"iPad2,6" : @"iPad mini",
                                                   @"iPad2,7" : @"iPad mini",
                                                   @"iPad4,4" : @"iPad mini 2",
                                                   @"iPad4,5" : @"iPad mini 2",
                                                   @"iPad4,6" : @"iPad mini 2",
                                                   @"iPad4,7" : @"iPad mini 3",
                                                   @"iPad4,8" : @"iPad mini 3",
                                                   @"iPad4,9" : @"iPad mini 3",
                                                   @"iPad5,1" : @"iPad mini 4",
                                                   @"iPad5,2" : @"iPad mini 4",
                                                   // Apple Watch
                                                   @"Watch1,1" : @"Apple Watch",
                                                   @"Watch1,2" : @"Apple Watch",
                                                   @"Watch2,6" : @"Apple Watch Series 1",
                                                   @"Watch2,7" : @"Apple Watch Series 1",
                                                   @"Watch2,3" : @"Apple Watch Series 2",
                                                   @"Watch2,4" : @"Apple Watch Series 2",
                                                   @"Watch3,1" : @"Apple Watch Series 3",
                                                   @"Watch3,2" : @"Apple Watch Series 3",
                                                   @"Watch3,3" : @"Apple Watch Series 3",
                                                   @"Watch3,4" : @"Apple Watch Series 3",
                                                   @"Watch4,1" : @"Apple Watch Series 4",
                                                   @"Watch4,2" : @"Apple Watch Series 4",
                                                   @"Watch4,3" : @"Apple Watch Series 4",
                                                   @"Watch4,4" : @"Apple Watch Series 4",
                                                   // iPod
                                                   @"iPod1,1" : @"iPod Touch 1G",
                                                   @"iPod2,1" : @"iPod Touch 2G",
                                                   @"iPod3,1" : @"iPod Touch 3G",
                                                   @"iPod4,1" : @"iPod Touch 4G",
                                                   @"iPod5,1" : @"iPod Touch 5G",
                                                   // 模拟器
                                                   @"i386" : @"iPhone Simulator",
                                                   @"x86_64" : @"iPhone Simulator",
                                                   };
    
    return dict[platform] ?: platform;
}

+ (BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"^[\\w-]+(\\.[\\w-]+)*@[\\w-]+(\\.[\\w-]+)+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

+ (BOOL)isValidatePhoneNumber:(NSString *)phone{
    NSString *phoneRegex = @"^(13|14|15|16|17|18|19)[0-9]{9}$";
//    NSString *phoneRegex = @"^1[3-9]{1}\\d{9}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", phoneRegex];
    return [phoneTest evaluateWithObject:phone];
}

+ (BOOL)isValidPassword:(NSString *)text
{
    NSString *expr = @"^(?=.*\\d)(?=.*[a-zA-Z])[0-9a-zA-Z]{6,12}$";
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", expr];
    return [p evaluateWithObject:text];
}

+ (void)setDefaultLoginAccount:(NSString *)account
{
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:@"KDSLoginAccount"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (void)setDefaultLoginPassWord:(NSString *)passWord
{
    [[NSUserDefaults standardUserDefaults] setObject:passWord forKey:@"KDSLoginPassWord"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
+ (NSString *)getDefaultLoginAccount
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"KDSLoginAccount"];
}
+(NSString *)getDefaultLoginPassWord
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"KDSLoginPassWord"];
}

+ (NSData *)getTranscodingStringDataWithString:(NSString *)string{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

+ (NSString *)limitedLengthStringWithString:(NSString *)string
{
    NSUInteger maxLength = 16;
    const char* utf8 = string.UTF8String;
    NSUInteger length = strlen(utf8);
    if (length <= maxLength) return string;
    NSUInteger i = 0;
    for (; i < length ;)
    {
        NSUInteger temp = i;
        for (int j = 7; j >= 0; --j)
        {
            if (((utf8[i] >> j) & 0x1) == 0)
            {
                i += (j==7 ? 1 : 7 - j);
                break;
            }
        }
        if (i >= maxLength)
        {
            i = i>maxLength ? temp : i;
            break;
        }
    }
    char dest[i + 1];
    strncpy(dest, utf8, i);
    dest[i] = 0;
    return @(dest);
}
+(NSString *)deleteSpecialCharacters:(NSString *)currentStr {
    NSString *newStr = currentStr;
    newStr = [newStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    newStr = [newStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    newStr = [newStr stringByReplacingOccurrencesOfString:@":" withString:@""];
    newStr = [newStr stringByReplacingOccurrencesOfString:@"*" withString:@""];
    return newStr;
}

+ (BOOL)isSimplePasswordInLock:(NSString *)password
{
    if (password.length < 6 || password.length > 12) return YES;
    
    NSPredicate *p = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", [NSString stringWithFormat:@"(^%d{%lu}$)", password.UTF8String[0] - '0', (unsigned long)password.length]];
    if ([p evaluateWithObject:password]) return YES;
    return [@"0123456789|9876543210" rangeOfString:password].length != 0;
}

//获取当前时间戳(精确到秒)
+(NSString *)getNowTimeTimestamp{
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970];
    NSString*timeString = [NSString stringWithFormat:@"%0.f", a];//转为字符型
    return timeString;
}

// 时间戳秒—>字符串时间
+ (NSString *)timeStringFromTimestamp:(NSString *)timestamp {
    //时间戳转时间的方法
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp longLongValue]];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}
// 时间戳—>字符串时间
+ (NSString *)timeStringYYMMDDFromTimestamp:(NSString *)timestamp {
    //时间戳转时间的方法
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[timestamp longLongValue]/1000];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}
//utc 时间戳—>字符串时间
+(NSString *)timestampSwitchTime:(NSInteger)timestamp andFormatter:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:format];
    NSTimeZone *timeZone1 = [NSTimeZone localTimeZone];//获取手机当前时区
    NSTimeZone *timeZone2 = [NSTimeZone systemTimeZone];
    NSTimeZone *timeZone3 = [NSTimeZone defaultTimeZone];
//    NSLog(@"timeZone1===%@ timeZone2===%@ timeZone3===%@",timeZone1.abbreviation,timeZone2.abbreviation,timeZone3.abbreviation);
    //    [formatter setTimeZone:timeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}
//utc时间戳—>utc字符串时间
+(NSString *)timestampSwitchUTCTime:(NSInteger)timestamp andFormatter:(NSString *)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    [formatter setDateFormat:format];
    [formatter setTimeZone:sourceTimeZone];
    NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSString *confromTimespStr = [formatter stringFromDate:confromTimesp];
    return confromTimespStr;
}
//获取Window当前显示的ViewController
+(UIViewController*)currentViewController{
    //获得当前活动窗口的根视图
    UIViewController* vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (1)
    {
        //根据不同的页面切换方式，逐步取得最上层的viewController
        if ([vc isKindOfClass:[UITabBarController class]]) {
            vc = ((UITabBarController*)vc).selectedViewController;
        }
        if ([vc isKindOfClass:[UINavigationController class]]) {
            vc = ((UINavigationController*)vc).visibleViewController;
        }
        if (vc.presentedViewController) {
            vc = vc.presentedViewController;
        }else{
            break;
        }
    }
    return vc;
}
/**
 得到当前时间之前N天的日期
 @param day N天
 @return return value description
 */
+(NSDate *)getTimeAfterNowWithDay:(NSInteger)day isAfter:(BOOL)isAfter{
    NSDate *nowDate = [NSDate date];
    NSDate *theDate;
    if(day!=0){
        NSTimeInterval  oneDay = 24*60*60*1;  //1天的长度
        if (isAfter) {//n天以后
            theDate = [nowDate initWithTimeIntervalSinceNow: +oneDay*day];
        }else{//n天以前
            theDate = [nowDate initWithTimeIntervalSinceNow: -oneDay*day];
        }
    }else{
        theDate = nowDate;
    }
    return theDate;
}

//将音频视频文件合成视频
+(int)mixmkvWithfileName:(const char *)in_filename in_filename2:(const char *)in_filename2 out_filename:(const char *)out_filename framerate:(int)framerate samplerate:(int)samplerate
{
    AVFormatContext *ic = NULL;
    AVFormatContext *auic = NULL;
    AVFormatContext *oc = NULL;
    //AVInputFormat *iformat;
    AVInputFormat *auiformat;
    AVOutputFormat *oformat = NULL;
    AVStream  *out_stream;
    AVCodecContext *c;
    AVCodec * pAVCodec = NULL;
    AVCodec * pAVCodec2 = NULL;
    AVPacket pkt1, *pkt = &pkt1;
    AVPacket pkt2, *pkta = &pkt2;
    struct AVRational time_base= {1,1000};//millisecond  time base;
    
    int64_t tmp,timestamp1;
    int st_index[AVMEDIA_TYPE_NB];
    int err, i, ret,ret2;
    int width, height;
    //avcodec_register_all();
    //avfilter_register_all();
    memset(st_index,-1,AVMEDIA_TYPE_NB);
    // av_log_set_level(AV_LOG_TRACE);
    //av_log_set_callback(log_callback_help);
    av_register_all();
    //avformat_network_init();
    
    ic = avformat_alloc_context();
    if (!ic) {
        KDSLog(@"Could not allocate context.");
        ret = AVERROR(ENOMEM);
    }
    auic = avformat_alloc_context();
    if (!ic) {
        KDSLog(@"Could not allocate contextauic.");
        ret = AVERROR(ENOMEM);
    }
    oc = avformat_alloc_context();
    if (!ic) {
        KDSLog(@"Could not allocate context.");
        ret = AVERROR(ENOMEM);
    }
    //strcmp(ic->iformat->name, "h264");
    err=avformat_alloc_output_context2(&oc, NULL,NULL, out_filename);
    if (!oc) {
        KDSLog(@"Could not create output context %s because %s",out_filename,av_err2str(err));
        ret = AVERROR_UNKNOWN;
        goto end;
    }
    
    oformat = oc->oformat;
    err = avformat_open_input(&ic, in_filename,NULL,NULL);//open http url;
    
    if (err < 0) {
        //__android_log_print(ANDROID_LOG_INFO,TAG, "avformat_open_input err=%s(%d)",av_err2str(err), err);
        return -1;
    }
    err = avformat_find_stream_info(ic, NULL);
    KDSLog(@"avformat_find_stream_info ret=%d ic->nb_streams=%d",err,ic->nb_streams);
    if (err < 0) {
        return -1;
    }
    auiformat=av_find_input_format("mulaw");
    // __android_log_print(ANDROID_LOG_INFO, "auformat==========%p\n",auiformat);
    
    err = avformat_open_input(&auic, in_filename2,auiformat,NULL);//open http url;
    if (err < 0) {
        KDSLog(@"avformat_open_input auiformat err=%s(%d)",av_err2str(err), err);
        return -1;
    }
    err = avformat_find_stream_info(auic, NULL);
    KDSLog(@"avformat_find_stream_info ret=%d auic->nb_streams=%d",err,auic->nb_streams);
    if (err < 0) {
        return -1;
    }
    //ret = av_read_frame(ic, pkt);
    //tmp=0;
    //while(ret>=0){
    //av_packet_unref(pkt);
    //ret = av_read_frame(ic, pkt);
    //printf"pkt->size =%d %lld\n",pkt->size,pkt->duration);
    //}
    //return;
    
    
    for (i = 0; i < (int)ic->nb_streams; i++) {
        if (ic->streams[i]->codec->codec_type == AVMEDIA_TYPE_VIDEO
            && st_index[AVMEDIA_TYPE_VIDEO]<0) {
            st_index[AVMEDIA_TYPE_VIDEO] = i;
            KDSLog(@"find a video stream. videoStream=%d",st_index[AVMEDIA_TYPE_VIDEO]);
        }
        
        if (ic->streams[i]->codec->codec_type == AVMEDIA_TYPE_AUDIO
            && st_index[AVMEDIA_TYPE_AUDIO]<0) {
            st_index[AVMEDIA_TYPE_AUDIO] = i;
            KDSLog(@"find a audio stream. audioStream=%d",st_index[AVMEDIA_TYPE_AUDIO]);
        }
    }
    
    if (st_index[AVMEDIA_TYPE_VIDEO] >= 0) {
        //printf"st_index[AVMEDIA_TYPE_VIDEO]=%d",st_index[AVMEDIA_TYPE_VIDEO]);//st_index[AVMEDIA_TYPE_VIDEO]=1127865328
        AVStream *st = ic->streams[st_index[AVMEDIA_TYPE_VIDEO]];
        AVCodecContext *codecpar = st->codec;
        //AVRational sar = av_guess_sample_aspect_ratio(ic, st, NULL);
        if (codecpar->width)
        {
            height=codecpar->height;
            width=codecpar->width;
        }
    }
    /*
     pAVCodec = avcodec_find_encoder(AV_CODEC_ID_H264);
     if (pAVCodec == NULL)
     {
     LOG_I("Can't find encoder %d!\n",AV_CODEC_ID_H264);
     //return NULL; if encode h.264 should open this
     }
     pAVCodec2 = avcodec_find_encoder(AV_CODEC_ID_PCM_MULAW);
     if (pAVCodec2 == NULL)
     {
     LOG_I("Can't find encoder %d!\n",AV_CODEC_ID_PCM_MULAW);
     //return NULL; if encode h.264 should open this
     }    */
    for (i = 0; i < 1; i++) {
        out_stream = avformat_new_stream(oc, pAVCodec);
        if (!out_stream) {
            KDSLog(@"Failed allocating output stream\n");
            ret = AVERROR_UNKNOWN;
            goto end;
        }
        c = out_stream->codec;
        c->codec_id = AV_CODEC_ID_H264;
        KDSLog(@"out_stream->codecpar.codec_id=%d %d codec_tag=%d",out_stream->codec->codec_id,AV_CODEC_ID_H264,out_stream->codec->codec_tag);
        c->codec_type = AVMEDIA_TYPE_VIDEO;
        c->width = width;
        c->height = height;
        out_stream->time_base.den = framerate;//STREAM_FRAME_RATE;
        out_stream->time_base.num = 1;//STREAM_FRAME_RATE/frame_rate;
        //c->time_base.den = FRAMERATE;//STREAM_FRAME_RATE;
        //c->time_base.num = 1;//STREAM_FRAME_RATE/frame_rate;
        //c->sample_aspect_ratio.num=1;
        //c->sample_aspect_ratio.den=FRAMERATE;
        c->pix_fmt = AV_PIX_FMT_YUV420P;
        c->bit_rate = BITRATE;
        //c->rc_lookahead = 40;
        c->thread_count = 0;
        
        
    }
    for (i = 0; i < 1; i++) {//insert audio
        out_stream = avformat_new_stream(oc, pAVCodec2);
        if (!out_stream) {
            KDSLog(@"Failed allocating output stream\n");
            ret = AVERROR_UNKNOWN;
            goto end;
        }
        c = out_stream->codec;
        out_stream->time_base.den = samplerate;//SAMPLERATE;
        out_stream->time_base.num = 1;//SAMPLERATE/sample_rate;
        c->codec_id = AV_CODEC_ID_PCM_MULAW;
        KDSLog(@"out_stream->codecpar.codec_id=%d %d codec_tag=%d",out_stream->codec->codec_id,AV_CODEC_ID_PCM_MULAW,out_stream->codec->codec_tag);
        c->codec_type = AVMEDIA_TYPE_AUDIO;
        c->sample_fmt = AV_SAMPLE_FMT_U8;
        //c->bit_rate = 5120 ;
        //c->bit_rate_tolerance = 5120 * 12/10;
        c->sample_rate = samplerate;
        c->channels = 1;
        //c->frame_size = 1024;
        
    }
    
    //av_dump_format(oc, 0, "1.mp4", 1);
    
    if (!(oformat->flags & AVFMT_NOFILE)) {
        ret = avio_open(&oc->pb, out_filename, AVIO_FLAG_WRITE);
        if (ret < 0) {
            KDSLog(@"Could not open output file '%s'", out_filename);
            goto end;
        }
    }
    ret = avformat_write_header(oc, NULL);
    if (ret < 0) {
        KDSLog(@"Error occurred when opening output file\n");
        goto end;
    }
    KDSLog(@"height=%d,width=%d\n",height,width);
    ret = av_read_frame(ic, pkt);
    ret2 = av_read_frame(auic, pkta);
    timestamp1=tmp=0;
    while(ret>=0 || ret2>=0){
        if(ret>=0){
            pkt->stream_index=0;//video index
            out_stream = oc->streams[pkt->stream_index];//new_pkt.pts = new_pkt.dts = av_rescale_q(pMediaPkt->pts, time_base, pMuxWriter->oc->streams[pMediaPkt->iStreamIdx]->time_base);//pMediaPkt->pts * pMuxWriter->iAudioTimeScale /1000;
            pkt->pts = av_rescale_q(tmp, time_base, out_stream->time_base);
            pkt->dts = av_rescale_q(tmp, time_base, out_stream->time_base);
            tmp+=1000/framerate;pkt->duration = 1000/framerate;
            pkt->pos = -1;
            ret = av_interleaved_write_frame(oc, pkt);
            if (ret < 0) {
                KDSLog(@"Error muxing packet\n");
                break;
            }
            av_packet_unref(pkt);
        }
        
        if(ret2>=0){
            pkta->stream_index=1;//audio index
            out_stream = oc->streams[pkta->stream_index];
            pkta->dts=pkta->pts = av_rescale_q(timestamp1, time_base, out_stream->time_base);pkta->duration = (pkta->size*1000)/SAMPLERATE;
            pkta->pos = -1;
            timestamp1+=(pkta->size*1000)/samplerate;
            ret2 = av_interleaved_write_frame(oc, pkta);
            if (ret < 0) {
                KDSLog(@"Error muxing packet\n");
                break;
            }
            av_packet_unref(pkta);
        }
        ret = av_read_frame(ic, pkt);
        ret2 = av_read_frame(auic, pkta);
    }
    
    av_write_trailer(oc);
end:
    /* close output */
    if (oc && !(oformat->flags & AVFMT_NOFILE))
        avio_closep(&oc->pb);
    if(ic)avformat_close_input(&ic);
    if(auic)avformat_close_input(&auic);
    if(oc)avformat_close_input(&oc);
    return 0;
}

+(BOOL)isValidateWiFi:(NSString *)value
{
    NSString *WiFiRegex = @"^[\\w-]+$";
    NSPredicate *WiFiTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",WiFiRegex];
    return [WiFiTest evaluateWithObject:value];
}

+(BOOL)isValidateIP:(NSString *)value
{
    NSArray *array = [value componentsSeparatedByString:@"."]; //从字符.中分隔成4个元素的数组
    //    NSLog(@"array:%@",array); //
    if (array.count == 4) {
        for (int i = 0; i < array.count; i++) {
            //判断是否为数字
            if (![self isNumber:array[i]]) {
                return NO;
            }
            
        }
        return YES;
    } else {
        return NO;
    }
}

+(BOOL)determineWhetherTheAPPOpensTheLocation{

    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] ==kCLAuthorizationStatusAuthorizedAlways)) {
        return YES;
    }else if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied){
        return NO;
    }else{
        return NO;
    }
}

+(void)openSettingsURLString
{
    
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

    if (@available(iOS 10.0, *)) {
        
        if ([[UIApplication sharedApplication] canOpenURL:url]) {

        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"Opened url");
            }
            else{
                NSLog(@"Opened url error");

            }
        }];
        
        }
       
    } else {
        // Fallback on earlier versions
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];

        if ([[UIApplication sharedApplication] canOpenURL:url]) {

            NSLog(@"API_AVAILABLE(ios(8.0) Opened url");

            [[UIApplication sharedApplication] openURL:url];

        }
    }
}

+(BOOL)isNumber:(NSString *)strValue
{
    if (strValue == nil || [strValue length] <= 0)
    {
        return NO;
    }
    
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:@"0123456789."] invertedSet];
    NSString *filtered = [[strValue componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    
    if (![strValue isEqualToString:filtered])
    {
        return NO;
    }
    //1-254
    else if (0<[strValue intValue] && [strValue intValue]<255){
        return NO;
    }
    return YES;
}
///判断是否为全面屏
+(BOOL)isNotchScreen{
    dispatch_async(dispatch_get_main_queue(), ^{

    });
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad) {
        return NO;
    }
    CGSize size = [UIScreen mainScreen].bounds.size;
    NSInteger notchValue = size.width / size.height * 100;
    if (216 == notchValue || 46 == notchValue) {
        return YES;
    } return NO;
}


+ (NSDate *)getNowDateFromatAnDate:(NSDate *)anyDate
{
    //设置源日期时区
    NSTimeZone* sourceTimeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT"];//或GMT
    //设置转换后的目标日期时区
    NSTimeZone* destinationTimeZone = [NSTimeZone localTimeZone];
    //得到源日期与世界标准时间的偏移量
    NSInteger sourceGMTOffset = [sourceTimeZone secondsFromGMTForDate:anyDate];
    //目标日期与本地时区的偏移量
    NSInteger destinationGMTOffset = [destinationTimeZone secondsFromGMTForDate:anyDate];
    //得到时间偏移量的差值
    NSTimeInterval interval = destinationGMTOffset - sourceGMTOffset;
    //转为现在时间
    NSDate * destinationDateNow =[[NSDate alloc] initWithTimeInterval:interval sinceDate:anyDate];
    
    return destinationDateNow;
}

+ (NSDate *)getDateTimeFromMilliSeconds:(long long) miliSeconds
{

NSTimeInterval tempMilli = miliSeconds;

NSTimeInterval seconds = tempMilli/1000.0;//这里的.0一定要加上，不然除下来的数据会被截断导致时间不一致

NSLog(@"传入的时间戳=%f",seconds);

return [NSDate dateWithTimeIntervalSince1970:seconds];

}

+ (NSString *)getTimeToShowWithTimestamp:(NSString *)timestamp
{
    int start = 0;//“（”的位置
    int end = 0;//“）”的位置
    for (int i = 0; i < timestamp.length; i++) {
        if ([timestamp characterAtIndex:i] == '(') {
            start = i;
        }
        if ([timestamp characterAtIndex:i] == ')') {
            end = i;
        }
    }
    NSString *publishString = [timestamp substringToIndex:end];
    publishString = [publishString substringFromIndex:start + 1];
    
    double publishLong = [publishString doubleValue];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [formatter setDateFormat:@"yyyy.MM.dd HH:mm:ss"];
    
    NSDate *publishDate = [NSDate dateWithTimeIntervalSince1970:publishLong/1000];
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:date];
    publishDate = [publishDate  dateByAddingTimeInterval: interval];
    
    publishString = [formatter stringFromDate:publishDate];
    
    return publishString;
}

#pragma mark ---- 将时间戳转换成时间

+ (NSString *)getTimeFromTimestamp:(long long)time{

    //将对象类型的时间转换为NSDate类型
    NSDate * myDate=[NSDate dateWithTimeIntervalSince1970:time];
    //设置时间格式
    NSDateFormatter * formatter=[[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    //将时间转换为字符串

    NSString *timeStr=[formatter stringFromDate:myDate];

    return timeStr;

}

#pragma mark ---- 保存ssid与密码

#define  kUserDefaultInputWifiSSID @"kUserDefaultInputWifiSSID"
/**
 * 获取ssid保存过的密码
 */
+(NSString *) getPwdWithSSID:(NSString *) ssid {
    NSString *passwd = nil;
    NSDictionary *dict = [[ NSUserDefaults standardUserDefaults] objectForKey:kUserDefaultInputWifiSSID];
    if (dict && [dict isKindOfClass:[NSDictionary class]] && ssid) {
        passwd = dict[ssid];
    }
    return passwd;
}

/**
 * 保存ssid与密码
 */
+(void) saveSSID:(NSString *) ssid pwd:(NSString *) pwd {
    if (ssid) {
        NSDictionary *dict = [KDSUserDefaults  objectForKey:kUserDefaultInputWifiSSID];
        NSMutableDictionary *saveDict = nil;
        if (dict && [dict isKindOfClass:[NSDictionary class]] && ssid) {
            saveDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
        }else {
            saveDict = [[NSMutableDictionary alloc] init];
        }
        saveDict[ssid] = pwd ? pwd : @"";
        [KDSUserDefaults setObject:saveDict forKey:kUserDefaultInputWifiSSID];
        [KDSUserDefaults synchronize];
        
    }
    
}


@end
