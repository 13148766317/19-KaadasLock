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

#import "TIOADToadImageReader.h"

@implementation TIOADToadSection {
    
}

-(TIOADToadBoundaryInformation_t) getDataAsBoundaryInformation {
    TIOADToadBoundaryInformation_t boundaryInfo;
    boundaryInfo.segmentInfo = self.segmentInfo;
    [self.data getBytes:&boundaryInfo.TOADBoundaryStackEntryAddress length:sizeof(TIOADToadBoundaryInformation_t) - sizeof(TIOADToadSegmentInformation_t)
     ];
    return boundaryInfo;
}
-(TIOADToadContiguousImageInformation_t) getDataAsContiguousImageInformation {
    TIOADToadContiguousImageInformation_t contInfo;
    contInfo.segmentInfo = self.segmentInfo;
    [self.data getBytes:&contInfo length:sizeof(TIOADToadContiguousImageInformation_t) - sizeof(TIOADToadSegmentInformation_t)];
    return contInfo;
}
-(TIOADToadSecureFWInformation_t) getDataAsSecurityImageInformation {
    TIOADToadSecureFWInformation_t secInfo;
    secInfo.segmentInfo = self.segmentInfo;
    [self.data getBytes:&secInfo.TOADVersion length:sizeof(TIOADToadSecureFWInformation_t) - sizeof(TIOADToadSegmentInformation_t)];
    return secInfo;
}

-(NSString *) description {
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendFormat:@"Segment info:\n"];
    [str appendFormat:@"Segment type: %@ (0x%02hhx)\n",
     (self.segmentInfo.TOADSegmentType == SEGMENT_TYPE_BOUNDARY_INFO) ? @"Boundary information" :
     (self.segmentInfo.TOADSegmentType == SEGMENT_TYPE_CONTIGUOUS_INFO) ? @"Contiguous information" : @"Unknown",self.segmentInfo.TOADSegmentType];
    [str appendFormat:@"Wireless Standard: %@ (0x%04hx)\n",[TIOADToadImageReader wirelessTechnologyToString:self.segmentInfo.TOADWirelessTechnology],self.segmentInfo.TOADWirelessTechnology];
    [str appendFormat:@"Payload Length: %d (0x%08x)\n",self.segmentInfo.TOADPayloadLength,self.segmentInfo.TOADPayloadLength];
    if (self.segmentInfo.TOADSegmentType == SEGMENT_TYPE_BOUNDARY_INFO) {
        TIOADToadBoundaryInformation_t boundaryInfo = [self getDataAsBoundaryInformation];
        [str appendFormat:@"Stack Entry Address: 0x%08x\n",boundaryInfo.TOADBoundaryStackEntryAddress];
        [str appendFormat:@"ICALL_STACK0_ADDR: 0x%08x\n",boundaryInfo.TOADBoundaryICALL_STACK0_ADDR];
        [str appendFormat:@"RAM_START_ADDR: 0x%08x\n",boundaryInfo.TOADBoundaryRAM_START_ADDR];
        [str appendFormat:@"RAM_END_ADDR: 0x%08x\n",boundaryInfo.TOADBoundaryRAM_END_ADDR];
    }
    else if (self.segmentInfo.TOADSegmentType == SEGMENT_TYPE_CONTIGUOUS_INFO) {
        TIOADToadContiguousImageInformation_t contInfo = [self getDataAsContiguousImageInformation];
        [str appendFormat:@"Entry Address: 0x%08x\n",contInfo.TOADStackEntryAddress];
    }
    else if (self.segmentInfo.TOADSegmentType == SEGMENT_TYPE_SECURITY_INFO) {
        TIOADToadSecureFWInformation_t secInfo = [self getDataAsSecurityImageInformation];
        [str appendFormat:@"Security Version: %d (%@)\n",secInfo.TOADVersion, (secInfo.TOADVersion == 0x01) ? @"ECDSA P-256 Signature" :
         (secInfo.TOADVersion == 0x02) ? @"AES 128-CBC Signature" : @"Reserved"];
        [str appendFormat:@"Time-stamp: %d (0x%08x)\n",secInfo.TOADTimeStamp,secInfo.TOADTimeStamp];
        [str appendFormat:@"Sign Payload: \n"];
        [str appendFormat:@"             Signer Information : 0x%02hhx,0x%02hhx,0x%02hhx,0x%02hhx,0x%02hhx,0x%02hhx,0x%02hhx,0x%02hhx\n",
                                                                secInfo.TOADSignPayload.TOADSignerInformation[0],
                                                                secInfo.TOADSignPayload.TOADSignerInformation[1],
                                                                secInfo.TOADSignPayload.TOADSignerInformation[2],
                                                                secInfo.TOADSignPayload.TOADSignerInformation[3],
                                                                secInfo.TOADSignPayload.TOADSignerInformation[4],
                                                                secInfo.TOADSignPayload.TOADSignerInformation[5],
                                                                secInfo.TOADSignPayload.TOADSignerInformation[6],
                                                                secInfo.TOADSignPayload.TOADSignerInformation[7]];
        [str appendFormat:@"             Signature : "];
        for (int ii = 0; ii < sizeof(secInfo.TOADSignPayload.TOADSignature); ii++) {
            [str appendFormat:@"0x%02hhx,",secInfo.TOADSignPayload.TOADSignature[ii]];
            if ((ii != 0) && ((ii % 16) == 0)) {
                [str appendFormat:@"\n"];
            }
        }
    }
    
    
    return str;
}

@end

@implementation TIOADToadImageReader {
    NSData *imgData;
    TIOADToadImageHeader_t fileHeader;
    NSMutableArray *sections;
}


-(instancetype) initWithImageData:(NSData *)imageData fileName:(NSString *)fileName {
    self = [super init];
    if (self) {
        self.fileName = fileName;
        imgData = imageData;
        sections = [[NSMutableArray alloc] init];
        if (![self validateImage]) return nil;
    }
    return self;
}

-(TIOADToadImageHeader_t) getHeader {
    return fileHeader;
}
-(NSArray *) getSections {
    return sections;
}

-(TIOADToadSection *) getSection:(int) section {
    if (section > sections.count - 1) return nil;
    else return [sections objectAtIndex:section];
}

-(NSData *) getRAWData {
    return imgData;
}

-(NSString *) getCircuitString {
    return [NSString stringWithFormat:@"%c%c%c%c%c%c%c%c",
            self.getHeader.TOADImageIdentificationValue[0],
            self.getHeader.TOADImageIdentificationValue[1],
            self.getHeader.TOADImageIdentificationValue[2],
            self.getHeader.TOADImageIdentificationValue[3],
            self.getHeader.TOADImageIdentificationValue[4],
            self.getHeader.TOADImageIdentificationValue[5],
            self.getHeader.TOADImageIdentificationValue[6],
            self.getHeader.TOADImageIdentificationValue[7]];
}

-(BOOL) validateImage {
    NSRange range = NSMakeRange(0, sizeof(TIOADToadImageHeader_t) + sizeof(TIOADToadSegmentInformation_t));
    if ((imgData.length < range.length) || (imgData == nil)) {
        return NO;
    }
    range.length = sizeof(TIOADToadImageHeader_t);
    [imgData getBytes:&fileHeader range:range];
    
    while ((range.location + range.length) < imgData.length) {
        TIOADToadSection *section = [[TIOADToadSection alloc] init];
        section.header = fileHeader;
        
        //Start to parse the rest of the header !
        range.location += range.length;
        range.length = sizeof(TIOADToadSegmentInformation_t);
        
        TIOADToadSegmentInformation_t tmpSegment;
        [imgData getBytes:&tmpSegment range:range];
        
        switch (tmpSegment.TOADSegmentType) {
            case SEGMENT_TYPE_BOUNDARY_INFO: {
                if (tmpSegment.TOADPayloadLength != sizeof(TIOADToadBoundaryInformation_t)) {
                    NSLog(@"Boundary info segment not of right size");
                }
                section.segmentInfo = tmpSegment;
                range.location += range.length;
                range.length = tmpSegment.TOADPayloadLength - sizeof(TIOADToadSegmentInformation_t);
                if ((range.location + range.length) > imgData.length) {
                    NSLog(@"The segment length field was longer than the actual data !");
                    return NO;
                }
                NSData *data = [imgData subdataWithRange:range];
                section.data = data;
                [sections addObject:section];
                break;
            }
            case SEGMENT_TYPE_CONTIGUOUS_INFO: {
                if (tmpSegment.TOADPayloadLength < sizeof(TIOADToadContiguousImageInformation_t)) {
                    NSLog(@"Contiguous info segment not of right size");
                }
                section.segmentInfo = tmpSegment;
                range.location += range.length;
                range.length = tmpSegment.TOADPayloadLength - sizeof(TIOADToadSegmentInformation_t);
                if (range.length > imgData.length - range.location) {
                    NSLog(@"Not contiguos image info, length to long !");
                    return NO;
                }
                NSData *data = [imgData subdataWithRange:range];
                section.data = data;
                [sections addObject:section];
                break;
            }
            case SEGMENT_TYPE_SECURITY_INFO: {
                section.segmentInfo = tmpSegment;
                range.location +=range.length;
                section.segmentInfo = tmpSegment;
                range.length = tmpSegment.TOADPayloadLength - sizeof(TIOADToadSegmentInformation_t);
                if (range.length > imgData.length - range.location) {
                    
                    return NO;
                }
                NSData *data = [imgData subdataWithRange:range];
                section.data = data;
                [sections addObject:section];
                break;
            }
            default:
                break;
        }
    }
    NSLog(@"validateImage:\n%@",self);
    NSLog(@"Total Sections in file : %lu",(unsigned long)sections.count);
    int ii = 0;
    for (TIOADToadSection *s in sections) {
        NSLog(@"\nSection %d : \n%@)",ii,s);
        ii++;
    }
    return YES;
}

-(NSString *) description {
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendFormat:@"Image info:\n"];
    [str appendFormat:@"Image identification: %c%c%c%c%c%c%c%c\n",
     fileHeader.TOADImageIdentificationValue[0],
     fileHeader.TOADImageIdentificationValue[1],
     fileHeader.TOADImageIdentificationValue[2],
     fileHeader.TOADImageIdentificationValue[3],
     fileHeader.TOADImageIdentificationValue[4],
     fileHeader.TOADImageIdentificationValue[5],
     fileHeader.TOADImageIdentificationValue[6],
     fileHeader.TOADImageIdentificationValue[7]];
    [str appendFormat:@"Image CRC32: 0x%08x\n",fileHeader.TOADImageCRC32];
    [str appendFormat:@"Image BIM Version: %hhd\n",fileHeader.TOADImageBIMVersion];
    [str appendFormat:@"Image Header Version: %hhd\n",fileHeader.TOADImageImageHeaderVersion];
    [str appendFormat:@"Image Wireless Standard: %@\n",[TIOADToadImageReader wirelessTechnologyToString:fileHeader.TOADImageWirelessTechnology]];
    [str appendFormat:@"Image Information:\n%@\n",[TIOADToadImageReader imageInfoToString:fileHeader.TOADImageInformation]];
    [str appendFormat:@"Image Validation: 0x%08x\n",fileHeader.TOADImageValidation];
    [str appendFormat:@"Image Length: %d(0x%08x) Bytes\n",fileHeader.TOADImageLength,fileHeader.TOADImageLength];
    [str appendFormat:@"Image Program Entry Address: 0x%08x\n",fileHeader.TOADImageProgramEntryAddress];
    [str appendFormat:@"Image Software Version: App:%d%d.%d%d Stack: %d%d.%d%d\n",(fileHeader.TOADImageSoftwareVersion[3] & 0x0F),
     (fileHeader.TOADImageSoftwareVersion[3] & 0xF0) >> 4,
     (fileHeader.TOADImageSoftwareVersion[2] & 0x0F),
     (fileHeader.TOADImageSoftwareVersion[2] & 0xF0) >> 4,
     (fileHeader.TOADImageSoftwareVersion[1] & 0x0F),
     (fileHeader.TOADImageSoftwareVersion[1] & 0xF0) >> 4,
     (fileHeader.TOADImageSoftwareVersion[0] & 0x0F),
     (fileHeader.TOADImageSoftwareVersion[0] & 0xF0) >> 4];
    [str appendFormat:@"Image End Address: 0x%08x\n",fileHeader.TOADImageEndAddress];
    [str appendFormat:@"Image Header Length: %d(0x%08x)\n",fileHeader.TOADImageHeaderLength,fileHeader.TOADImageHeaderLength];
    
    return str;
}


+(NSString *) imageInfoToString:(uint8_t *)imgInfo {
    NSMutableString *str = [[NSMutableString alloc] init];
    [str appendFormat:@"  - Image Copy Status: %@",
     (imgInfo[0] == TOAD_IMAGE_COPY_STATUS_NO_ACTION_NEEDED) ? @"Default status, no action needed" :
     (imgInfo[0] == TOAD_IMAGE_COPY_STATUS_IMAGE_TO_BE_COPIED) ? @"Image to be copied to on-chip flash at location indicated in the image header" :
     (imgInfo[0] == TOAD_IMAGE_COPY_STATUS_IMAGE_COPIED) ? @"Image copied" : @"Unknown"];
    [str appendFormat:@"\n"];
    [str appendFormat:@"  - Image CRC Status: %@",
     (imgInfo[1] == TOAD_IMAGE_CRC_STATUS_INVALID) ? @"CRC Invalid (0x00)" :
     (imgInfo[1] == TOAD_IMAGE_CRC_STATUS_VALID) ? @"CRC Valid (0x01)" :
     (imgInfo[1] == TOAD_IMAGE_CRC_STATUS_NOT_CALCULATED_YET) ? @"CRC Not Calculated Yet (0x03)" : @"Unknown"];
    [str appendFormat:@"\n"];
    [str appendFormat:@"  - Image Type: %@",
     (imgInfo[2] == TOAD_IMAGE_TYPE_PERSISTENT_APP) ? @"Persistent Application (0x00)" :
     (imgInfo[2] == TOAD_IMAGE_TYPE_APP) ? @"Application (0x01)" :
     (imgInfo[2] == TOAD_IMAGE_TYPE_STACK) ? @"Stack (0x02)" :
     (imgInfo[2] == TOAD_IMAGE_TYPE_APP_STACK_MERGED) ? @"App + Stack Merged  (0x03)" :
     (imgInfo[2] == TOAD_IMAGE_TYPE_NETWORK_PROC) ? @"Network Processor  (0x04)" :
     (imgInfo[2] == TOAD_IMAGE_TYPE_BLE_FACTORY_IMAGE) ? @"Bluetooth Low Energy Factory Image  (0x05)" :
     (imgInfo[2] == TOAD_IMAGE_TYPE_BIM) ? @"Boot Loader Image" : @"Unknown ()"];
    [str appendFormat:@"\n"];
    [str appendFormat:@"  - Image Number: 0x%02hhx",imgInfo[3]];
    [str appendFormat:@"\n"];
    return str;
}

+(NSString *) wirelessTechnologyToString:(uint16_t)wirelesstech {
    NSMutableString *str = [[NSMutableString alloc] init];
    if ((wirelesstech & TOAD_WIRELESS_STD_BLE) == 0x00) {
        [str appendFormat:@" [Bluetooth Low Energy]"];
    }
    else if ((wirelesstech & TOAD_WIRELESS_STD_802_15_4_SUB_ONE) == 0x00) {
        [str appendFormat:@" [802.15.4 Sub-One]"];
    }
    else if ((wirelesstech & TOAD_WIRELESS_STD_802_15_4_2_POINT_4) == 0x00) {
        [str appendFormat:@" [802.15.4 2.4GHz]"];
    }
    else if ((wirelesstech & TOAD_WIRELESS_STD_ZIGBEE) == 0x00) {
        [str appendFormat:@" [ZigBee]"];
    }
    else if ((wirelesstech & TOAD_WIRELESS_STD_RF4CE) == 0x00) {
        [str appendFormat:@" [RF4CE]"];
    }
    else if ((wirelesstech & TOAD_WIRELESS_STD_THREAD) == 0x00) {
        [str appendFormat:@" [Thread]"];
    }
    else if ((wirelesstech & TOAD_WIRELESS_STD_EASY_LINK) == 0x00) {
        [str appendFormat:@" [Easy Link]"];
    }
    return str;
}

+(NSString *) verificationStatusToString:(uint8_t)verificationStatus {
    switch (verificationStatus) {
        case TOAD_IMAGE_VERIFICATION_STATUS_STD:
            return @"Default";
            break;
        case TOAD_IMAGE_VERIFICATION_STATUS_FAILED:
            return @"Failed";
        case TOAD_IMAGE_VERIFICATION_STATUS_SUCCESS:
            return @"Success";
        default:
            return @"Unknown";
            break;
    }
}

@end
