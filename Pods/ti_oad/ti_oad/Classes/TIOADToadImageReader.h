/*
 Copyright 2018 Texas Instruments
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import <Foundation/Foundation.h>

#define SEGMENT_TYPE_BOUNDARY_INFO                  0x00
#define SEGMENT_TYPE_CONTIGUOUS_INFO                0x01
#define SEGMENT_TYPE_SECURITY_INFO                  0x03

#define SEGMENT_TYPE_OFF_WIRELESS_STD               1
#define SEGMENT_TYPE_OFF_PAYLOAD_LEN                4

#define TOAD_WIRELESS_STD_BLE                       0x01
#define TOAD_WIRELESS_STD_802_15_4_SUB_ONE          0x02
#define TOAD_WIRELESS_STD_802_15_4_2_POINT_4        0x04
#define TOAD_WIRELESS_STD_ZIGBEE                    0x08
#define TOAD_WIRELESS_STD_RF4CE                     0x10
#define TOAD_WIRELESS_STD_THREAD                    0x20
#define TOAD_WIRELESS_STD_EASY_LINK                 0x40

#define TOAD_IMAGE_COPY_STATUS_NO_ACTION_NEEDED     0xFF
#define TOAD_IMAGE_COPY_STATUS_IMAGE_TO_BE_COPIED   0xFE
#define TOAD_IMAGE_COPY_STATUS_IMAGE_COPIED         0xFC

#define TOAD_IMAGE_VERIFICATION_STATUS_STD          0xFF
#define TOAD_IMAGE_VERIFICATION_STATUS_FAILED       0xFC
#define TOAD_IMAGE_VERIFICATION_STATUS_SUCCESS      0xFE

#define TOAD_IMAGE_CRC_STATUS_INVALID               0x00
#define TOAD_IMAGE_CRC_STATUS_VALID                 0x02
#define TOAD_IMAGE_CRC_STATUS_NOT_CALCULATED_YET    0x03

#define TOAD_IMAGE_TYPE_PERSISTENT_APP              0x00
#define TOAD_IMAGE_TYPE_APP                         0x01
#define TOAD_IMAGE_TYPE_STACK                       0x02
#define TOAD_IMAGE_TYPE_APP_STACK_MERGED            0x03
#define TOAD_IMAGE_TYPE_NETWORK_PROC                0x04
#define TOAD_IMAGE_TYPE_BLE_FACTORY_IMAGE           0x05
#define TOAD_IMAGE_TYPE_BIM                         0x06





typedef struct __attribute__((packed)) TIOADToadSegmentInformation {
    uint8_t     TOADSegmentType;                    //1
    uint16_t    TOADWirelessTechnology;             //3
    uint8_t     TOADReserved;                       //4
    uint32_t    TOADPayloadLength;                  //8
}TIOADToadSegmentInformation_t;

typedef struct __attribute__((packed)) TIOADToadSignPayload {
    uint8_t     TOADSignerInformation[8];           //8
    uint8_t     TOADSignature[64];                  //72
}TIOADToadSignPayload_t;

typedef struct __attribute__((packed)) TIOADToadSecureFWInformation {
    TIOADToadSegmentInformation_t   segmentInfo;    //8
    uint8_t     TOADVersion;                        //9
    uint32_t    TOADTimeStamp;                      //13
    TIOADToadSignPayload_t  TOADSignPayload;        //85
}TIOADToadSecureFWInformation_t;

typedef struct __attribute__((packed)) TIOADToadContiguousImageInformation {
    TIOADToadSegmentInformation_t   segmentInfo;    //8
    uint32_t    TOADStackEntryAddress;              //12
}TIOADToadContiguousImageInformation_t;

typedef struct __attribute__((packed)) TIOADToadBoundaryInformation {
    TIOADToadSegmentInformation_t   segmentInfo;    //8
    uint32_t    TOADBoundaryStackEntryAddress;      //12
    uint32_t    TOADBoundaryICALL_STACK0_ADDR;      //16
    uint32_t    TOADBoundaryRAM_START_ADDR;         //20
    uint32_t    TOADBoundaryRAM_END_ADDR;           //24
}TIOADToadBoundaryInformation_t;

typedef struct __attribute__((packed)) TIOADToadImageHeader {
    uint8_t     TOADImageIdentificationValue[8];    //8
    uint32_t    TOADImageCRC32;                     //12
    uint8_t     TOADImageBIMVersion;                //13
    uint8_t     TOADImageImageHeaderVersion;        //14
    uint16_t    TOADImageWirelessTechnology;        //16
    uint8_t     TOADImageInformation[4];            //20
    uint32_t    TOADImageValidation;                //24
    uint32_t    TOADImageLength;                    //28
    uint32_t    TOADImageProgramEntryAddress;       //32
    uint8_t     TOADImageSoftwareVersion[4];        //36
    uint32_t    TOADImageEndAddress;                //40
    uint16_t    TOADImageHeaderLength;              //42
    uint16_t    TOADImageReservedLongField;         //44 Not in documentation
}TIOADToadImageHeader_t;

//Secure FW

typedef struct __attribute__((packed)) TIOADSignPayload {
    uint8_t     TIOADSignerInformation[8];          //8
    uint8_t     TIOADSignature[64];                 //72
}TIOADSignPayload_t;

@interface TIOADToadSection : NSObject

@property TIOADToadImageHeader_t header;
@property TIOADToadSegmentInformation_t segmentInfo;
@property NSData *data;

-(TIOADToadBoundaryInformation_t) getDataAsBoundaryInformation;
-(TIOADToadContiguousImageInformation_t) getDataAsContiguousImageInformation;
-(TIOADToadSecureFWInformation_t) getDataAsSecurityImageInformation;

@end


@interface TIOADToadImageReader : NSObject

@property NSString *fileName;

-(instancetype) initWithImageData:(NSData *)imageData fileName:(NSString *)fileName;
-(BOOL) validateImage;

-(TIOADToadImageHeader_t) getHeader;
-(NSArray *) getSections;
-(TIOADToadSection *) getSection:(int) section;
-(NSData *) getRAWData;
-(NSString *) getCircuitString;

+(NSString *) imageInfoToString:(uint8_t *)imgInfo;
+(NSString *) wirelessTechnologyToString:(uint16_t)wirelesstech;
+(NSString *) verificationStatusToString:(uint8_t)verificationStatus;
@end
