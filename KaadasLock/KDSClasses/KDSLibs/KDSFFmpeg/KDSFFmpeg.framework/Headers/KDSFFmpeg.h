//
//  KDSFFmpeg.h
//  KDSFFmpeg
//
//  Created by Frank Hu on 2020/9/16.
//  Copyright © 2020 Kaadas. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for KDSFFmpeg.
FOUNDATION_EXPORT double KDSFFmpegVersionNumber;

//! Project version string for KDSFFmpeg.
FOUNDATION_EXPORT const unsigned char KDSFFmpegVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <KDSFFmpeg/PublicHeader.h>
#import "libavformat/avformat.h"
#import "libswscale/swscale.h"
#import "libavcodec/avcodec.h"
#import "libavutil/avutil.h"
#import "libswresample/swresample.h"
#import "libavfilter/avfilter.h"
#import "libavdevice/avdevice.h"

