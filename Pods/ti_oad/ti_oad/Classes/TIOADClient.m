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

#import "TIOADClient.h"
#import "TIOADDefines.h"

@implementation TIOADClient {
    /* All OAD versions */
    CBCharacteristic *TIOADImageIdentifyChar;
    CBCharacteristic *TIOADImageBlockChar;
    /* Intermediate Characteristics not used on Turbo */
    CBCharacteristic *TIOADCountChar;
    CBCharacteristic *TIOADStatusChar;
    /* Turbo Characteristics */
    CBCharacteristic *TIOADControlChar;
    
    TIOADClientProgressValues_t progress;
    TIOADClientState_t state;
    TIOADToadImageReader *imgData;
    CBPeripheral *oadPeripheral;
    CBCentralManager *oadManager;
    BOOL rssiWarningSent;
    NSTimer *rssiTimer;
    uint8_t lastErrorCode;
}

-(instancetype) initWithPeripheral:(CBPeripheral *)peripheral
                      andImageData:(TIOADToadImageReader *)data
                       andDelegate:(id<TIOADClientProgressDelegate>)delegate
                        andManager:(CBCentralManager *)manager {
    self = [self initWithPeripheral:peripheral andImageData:data andDelegate:delegate];
    if (self) {
        oadManager = manager;
        oadManager.delegate = self;
    }
    return self;
}

-(instancetype) initWithPeripheral:(CBPeripheral *) peripheral
                      andImageData:(TIOADToadImageReader *)data
                       andDelegate:(id<TIOADClientProgressDelegate>) delegate {
    self = [super init];
    if (self) {
        state = tiOADClientInitializing;
        self.delegate = delegate;
        
        TIOADImageIdentifyChar = nil;
        TIOADImageBlockChar = nil;
        TIOADCountChar = nil;
        TIOADStatusChar = nil;
        TIOADControlChar = nil;
        
        oadPeripheral = peripheral;
        rssiWarningSent = NO;
        imgData = data;
        progress.totalBytes = (uint32_t)[data getRAWData].length;
        //We have set delegate, we can deliver errors from this point on.
        if (peripheral.state != CBPeripheralStateConnected) {
            state = tiOADClientPeripheralNotConnected;
            [self sendStateChangedWithErrorBasedOnState:0];
        }
        peripheral.delegate = self;
        for (CBService *s in peripheral.services) {
            for (CBCharacteristic *c in s.characteristics) {
                if ([c.UUID.UUIDString isEqualToString:TI_OAD_IMAGE_NOTIFY]) {
                    TIOADImageIdentifyChar = c;
                    if (!c.isNotifying) {
                        [peripheral setNotifyValue:YES forCharacteristic:c];
                    }
                }
                else if ([c.UUID.UUIDString isEqualToString:TI_OAD_IMAGE_BLOCK_REQUEST]) {
                    TIOADImageBlockChar = c;
                    if (!c.isNotifying) {
                        [peripheral setNotifyValue:YES forCharacteristic:c];
                    }
                }
                else if ([c.UUID.UUIDString isEqualToString:TI_OAD_CONTROL]) {
                    TIOADControlChar = c;
                    if (!c.isNotifying) {
                        [peripheral setNotifyValue:YES forCharacteristic:c];
                    }
                }
                else {
                    //Not a characteristic we need, disable notifications for this if it is enabled
                    if (c.isNotifying) {
                        [peripheral setNotifyValue:NO forCharacteristic:c];
                    }
                }
            }
        }
        if ((TIOADImageIdentifyChar == nil) || (TIOADImageBlockChar == nil) || (TIOADControlChar == nil)) {
            //We don't have the characteristics we need to continue safely, we need to notify the delegate
            state = tiOADClientOADServiceMissingOnPeripheral;
            [self sendStateChangedWithErrorBasedOnState:0];
        }
        else {
            //We can continue !
            state = tiOADClientReady;
            //[self sendStateChangedWithoutErrorBasedOnState];
            [self sendGetDeviceTypeCommand];
        }
    }
    return self;
}

-(void) startOAD {
    if ((state != tiOADClientReady) && (state != tiOADClientGetDeviceTypeResponseRecieved)) {
        [self sendStateChangedWithErrorBasedOnState:0];
    }
    progress.startDownloadTime = CACurrentMediaTime();
    //Init says we are ready, then start by sending header to image identify
    [self sendOADControlGetOADBlockSizeCmd];
    dispatch_async(dispatch_get_main_queue(), ^{
        self->rssiTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f target:self selector:@selector(readRSSI) userInfo:nil repeats:YES];
    });
}

-(ChipType_t) getChipTypeOfOAD {
    return (self.deviceID >> 24) & 0xFF;
}

-(void) readRSSI {
    [oadPeripheral readRSSI];
}
-(void) stopOAD {
    if (rssiTimer != nil) [rssiTimer invalidate];
}

-(void) sendStateChangedWithoutErrorBasedOnState {
    if ([self.delegate respondsToSelector:@selector(client:oadProcessStateChanged:error:)]) {
        [self.delegate client:self oadProcessStateChanged:state error:nil];
    }
}

-(void) sendStateChangedWithErrorBasedOnState:(uint8_t)statusByte {
    if (rssiTimer != nil) [rssiTimer invalidate];
    if ([self.delegate respondsToSelector:@selector(client:oadProcessStateChanged:error:)]) {
        switch (state) {
            case tiOADClientPeripheralNotConnected:{
                NSError *err = [[NSError alloc] initWithDomain:@"com.ti.ti-oad" code:(int)tiOADClientPeripheralNotConnected userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Peripheral is not connected, TIOADClient cannot continue. Please connect and discover services and characteristics before calling TIOADClient init !",NSLocalizedDescriptionKey, nil]];
                [self.delegate client:self oadProcessStateChanged:tiOADClientPeripheralNotConnected error:err];
                break;
            }
            case tiOADClientOADServiceMissingOnPeripheral: {
                NSError *err = [[NSError alloc] initWithDomain:@"com.ti.ti-oad" code:(int)tiOADClientOADServiceMissingOnPeripheral userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Peripheral is missing the correct characteristics, TIOADClient cannot continue. Please connect and discover services and characteristics before calling TIOADClient init !",NSLocalizedDescriptionKey, nil]];
                [self.delegate client:self oadProcessStateChanged:tiOADClientOADServiceMissingOnPeripheral error:err];
                break;
            }
            case tiOADClientCompleteFeedbackFailed: {
                NSError *err = [[NSError alloc] initWithDomain:@"com.ti.ti-oad" code:(int)tiOADClientCompleteFeedbackFailed userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Download to peripheral went OK, but peripheral would not start, please initialize a new TIOADClient and run the process again !",NSLocalizedDescriptionKey, nil]];
                [self.delegate client:self oadProcessStateChanged:tiOADClientCompleteFeedbackFailed error:err];
                break;
            }
            case tiOADClientHeaderFailed: {
                NSError *err = [[NSError alloc] initWithDomain:@"com.ti.ti-oad" code:(int)lastErrorCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"Peripheral received header but would not accept, try another image and initialize again ... Peripheral status : %@(%d)",[TIOADClient getStatusStringFromStatusByte:statusByte],statusByte],NSLocalizedDescriptionKey, nil]];
                [self.delegate client:self oadProcessStateChanged:tiOADClientHeaderFailed error:err];
                break;
            }
            case tiOADClientImageTransferFailed: {
                NSError *err = [[NSError alloc] initWithDomain:@"com.ti.ti-oad" code:(int)lastErrorCode userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Image transfer failed during programming ...",NSLocalizedDescriptionKey, nil]];
                [self.delegate client:self oadProcessStateChanged:tiOADClientImageTransferFailed error:err];
                break;
            }
            default: {
                NSError *err = [[NSError alloc] initWithDomain:@"com.ti.ti-oad" code:(int)state userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Unknown error code during programming ...",NSLocalizedDescriptionKey, nil]];
                [self.delegate client:self oadProcessStateChanged:state error:err];
                break;
            }
        }
    }
}

#pragma mark -- OAD Control command senders below (Private functions)
-(void) sendGetDeviceTypeCommand {
    uint8_t data = TI_TOAD_CONTROL_CMD_GET_DEVICE_TYPE_CMD;
    [oadPeripheral writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:TIOADControlChar type:CBCharacteristicWriteWithoutResponse];
    state = tiOADClientGetDeviceTypeCommandSent;
    NSLog(@"TIOADClient: OAD Control TX: %@",[NSData dataWithBytes:&data length:1]);
}

-(void) sendOADControlGetOADBlockSizeCmd {
    uint8_t data = TI_TOAD_CONTROL_CMD_GET_BLOCK_SIZE;
    [oadPeripheral writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:TIOADControlChar type:CBCharacteristicWriteWithoutResponse];
    state = tiOADClientBlockSizeRequestSent;
    NSLog(@"TIOADClient: OAD Control TX: %@",[NSData dataWithBytes:&data length:1]);
}

-(void) sendOADImageHeader {
    NSMutableData *headerReq = [[NSMutableData alloc] init];
    TIOADToadImageHeader_t header = [imgData getHeader];
    [headerReq appendBytes:&header.TOADImageIdentificationValue length:sizeof(header.TOADImageIdentificationValue)];
    [headerReq appendBytes:&header.TOADImageBIMVersion length:sizeof(header.TOADImageBIMVersion)];
    [headerReq appendBytes:&header.TOADImageImageHeaderVersion length:sizeof(header.TOADImageImageHeaderVersion)];
    [headerReq appendBytes:&header.TOADImageInformation length:sizeof(header.TOADImageInformation)];
    [headerReq appendBytes:&header.TOADImageLength length:sizeof(header.TOADImageLength)];
    [headerReq appendBytes:&header.TOADImageSoftwareVersion length:sizeof(header.TOADImageSoftwareVersion)];
    [oadPeripheral writeValue:headerReq forCharacteristic:TIOADImageIdentifyChar type:CBCharacteristicWriteWithResponse];
    state = tiOADClientHeaderSent;
    NSLog(@"TIOADClient: OAD Image Identify TX: %@",headerReq);
    
}

-(void) sendOADControlStartOADProcessCmd {
    uint8_t data = TI_TOAD_CONTROL_CMD_START_OAD_PROCESS;
    [oadPeripheral writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:TIOADControlChar type:CBCharacteristicWriteWithoutResponse];
    state = tiOADClientOADProcessStartCommandSent;
    NSLog(@"TIOADClient: OAD Control TX: %@",[NSData dataWithBytes:&data length:1]);
}

-(void) sendOADNextImageBlock {
    progress.currentByte = (progress.currentBlock) * progress.currentBlockSize;
    progress.percentProgress = (((float)progress.currentByte * 100.0f) / ((float)progress.totalBytes));
    NSRange rng = NSMakeRange(progress.currentByte, progress.currentBlockSize);
    NSData *imgRAWData = [imgData getRAWData];
    if ((progress.currentByte + (progress.currentBlockSize)) > imgRAWData.length) {
        rng.length = (imgRAWData.length - (progress.currentByte));
        NSLog(@"TIOADClient: Last Block !!");
        
    }
        
    NSMutableData *imgBlock = [[NSMutableData alloc] init];
    [imgBlock appendBytes:&progress.currentBlock length:sizeof(uint32_t)];
    [imgBlock appendData:[imgRAWData subdataWithRange:rng]];
    [oadPeripheral writeValue:imgBlock forCharacteristic:TIOADImageBlockChar type:CBCharacteristicWriteWithoutResponse];
    NSLog(@"TIOADClient: OAD Block TX: %@, length %ld",imgBlock,(long)imgBlock.length);
    if (@available(iOS 9.0, *)) {
        NSLog(@"TIOADClient: OAD Block WR: %ld, WOR: %ld",
              (long)[oadPeripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithResponse],
              (long)[oadPeripheral maximumWriteValueLengthForType:CBCharacteristicWriteWithoutResponse]);
    } else {
        // Fallback on earlier versions
    }
}

-(void) sendOADControlEnableOADImageCmd {
    uint8_t data = TI_TOAD_CONTROL_CMD_ENABLE_OAD_IMAGE_CMD;
    [oadPeripheral writeValue:[NSData dataWithBytes:&data length:1] forCharacteristic:TIOADControlChar type:CBCharacteristicWriteWithoutResponse];
    state = tiOADClientEnableOADImageCommandSent;
    NSLog(@"TIOADClient: OAD Control TX: %@",[NSData dataWithBytes:&data length:1]);
    if (rssiTimer != nil) {
        [rssiTimer invalidate];
    }
}

#pragma mark -- OAD State machine (Private)
-(void) oadStatMachineIterate {
    switch (state) {
        case tiOADClientGotBlockSizeResponse:
            //We have block size, send header
            [self sendOADImageHeader];
            [self sendStateChangedWithoutErrorBasedOnState];
            break;
        case tiOADClientHeaderOK:
            //Header sent OK, we send start of OAD process command...
            [self sendOADControlStartOADProcessCmd];
            [self sendStateChangedWithoutErrorBasedOnState];
            break;
        case tiOADClientImageTransfer:
            //Image block transfer
            [self sendOADNextImageBlock];
            if ([self.delegate respondsToSelector:@selector(client:oadProgressUpdated:)]) {
                [self.delegate client:self oadProgressUpdated:progress];
            }
            break;
        case tiOADClientImageTransferOK:
            //Image transferred OK !
            progress.currentBlock = progress.totalBlocks;
            progress.currentByte = progress.totalBytes;
            if ([self.delegate respondsToSelector:@selector(client:oadProgressUpdated:)]) {
                [self.delegate client:self oadProgressUpdated:progress];
            }
            [self sendStateChangedWithoutErrorBasedOnState];
            [self sendOADControlEnableOADImageCmd];
            break;
        default:
            break;
    }
    
    
}

-(NSString *) getChipId {
    switch ([self getChipTypeOfOAD]) {
        case CHIP_TYPE_CC1310:
        case CHIP_TYPE_CC1312:
        case CHIP_TYPE_CC2620:
        case CHIP_TYPE_CC2630:
            return @"Non BLE chip !";
        case CHIP_TYPE_CC1350:
            return @"CC1350";
        case CHIP_TYPE_CC1352:
            return @"CC1352";
        case CHIP_TYPE_CC2640:
            return @"CC2640";
        case CHIP_TYPE_CC2642:
            return @"CC2642";
        case CHIP_TYPE_CC2644:
            return @"CC2644";
        case CHIP_TYPE_CC2650:
            return @"CC2650";
        case CHIP_TYPE_CC2652:
            return @"CC2652";
        case CHIP_TYPE_Unknown:
            return @"Unknown";
        case CHIP_TYPE_CC2640R2:
            return @"CC2640R2F";
        case CHIP_TYPE_CUSTOM_0:
            return @"Custom";
        case CHIP_TYPE_CUSTOM_1:
            return @"Custom";
        default:
            return @"Unknown";
    }
}


+(NSString *) getStatusStringFromStatusByte:(uint8_t) statusByte {
    NSArray *stringAr = [NSArray arrayWithObjects:TI_EOAD_STATUS_STRINGS];
    return stringAr[statusByte];
}
+(NSString *) getStateStringFromState:(TIOADClientState_t)state {
    NSArray *stringAr = [NSArray arrayWithObjects:TI_EOAD_STATE_STRINGS];
    if (state <= tiOADClientRSSIGettingLow) {
        return stringAr[state];
    }
    return [NSString stringWithFormat:@"Unknown state %d",state];
}


#pragma mark -- CBCentralManagerDelegate methods below
//TODO: We need to get a manager in here, if we get disconnects or other problems during the download
-(void) centralManagerDidUpdateState:(CBCentralManager *)central {
    //TODO: React to state changes
}

-(void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    if (state != tiOADClientCompleteFeedbackOK) {
        state = tiOADClientDisconnectedDuringDownload;
        [self sendStateChangedWithErrorBasedOnState:0];
    }
    else {
        state = tiOADClientOADCompleteIncludingDisconnect;
        [self sendStateChangedWithoutErrorBasedOnState];
    }
    if (rssiTimer != nil) [rssiTimer invalidate];
    //Cannot continue from here, device disconnected ....
}


#pragma mark -- CBPeripheralDelegate methods below
-(void) peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"TIOADClient: Notification for %@ set to :%d",characteristic.UUID.UUIDString,(int)characteristic.isNotifying);
    if ([characteristic.UUID.UUIDString isEqualToString:TI_OAD_CONTROL]) {
        //We can start sending commands here
        [self sendStateChangedWithoutErrorBasedOnState];
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic isEqual:TIOADControlChar]) {
        NSLog(@"TIOADClient: OAD Control TX OK");
    }
}

-(void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
    if ([characteristic isEqual:TIOADControlChar]) {
        uint8_t data[characteristic.value.length];
        [characteristic.value getBytes:data length:characteristic.value.length];
        NSLog(@"TIOADClient: OAD Control RX: %@",characteristic.value);
        if (characteristic.value.length < 1) return;
        
        switch (data[0]) {
            case TI_TOAD_CONTROL_CMD_GET_BLOCK_SIZE:
                progress.currentBlockSize = (((uint32_t)data[2] << 8) | ((uint32_t)data[1])) - 4;
                progress.totalBlocks = progress.totalBytes / progress.currentBlockSize;
                NSLog(@"TIOADClient: OAD block size response: %d",progress.currentBlockSize);
                state = tiOADClientGotBlockSizeResponse;
                [self oadStatMachineIterate];
                break;
            case TI_TOAD_CONTROL_CMD_IMAGE_BLOCK_WRITE_CHAR_RESPONSE:
                progress.currentBlock = ((uint32_t)data[5] << 24) | ((uint32_t)data[4] << 16) | ((uint32_t)data[3] << 8) | ((uint32_t)data[2]);
                NSLog(@"TIOADClient: OAD Image Block write char response: %u , last status: %02hhx",
                      progress.currentBlock, data[1]);
                switch (data[1]) {
                    case 0x00:
                        if (state != tiOADClientImageTransfer) {
                            state = tiOADClientImageTransfer;
                            [self sendStateChangedWithoutErrorBasedOnState];
                        }
                        state = tiOADClientImageTransfer;
                        [self oadStatMachineIterate];
                        break;
                    case 0x0e:
                        state = tiOADClientImageTransferOK;
                        [self oadStatMachineIterate];
                        break;
                    default:
                        state = tiOADClientImageTransferFailed;
                        lastErrorCode = data[1];
                        [self sendStateChangedWithErrorBasedOnState:data[1]];
                        break;
                }
                break;
            case TI_TOAD_CONTROL_CMD_ENABLE_OAD_IMAGE_CMD:
                progress.totalDownloadTime = CACurrentMediaTime() - progress.startDownloadTime;
                switch (data[1]) {
                    case 0x00:
                        state = tiOADClientCompleteFeedbackOK;
                        [self sendStateChangedWithoutErrorBasedOnState];
                        if (rssiTimer != nil) [rssiTimer invalidate];
                        break;
                    default:
                        state = tiOADClientCompleteFeedbackFailed;
                        [self sendStateChangedWithErrorBasedOnState:data[1]];
                        break;
                }
                break;
            case TI_TOAD_CONTROL_CMD_GET_DEVICE_TYPE_CMD:
                self.deviceID = (uint32_t)data[1] << 24 | (uint32_t)data[2] << 16 | (uint32_t)data[3] | data[4];
                state = tiOADClientGetDeviceTypeResponseRecieved;
                [self sendStateChangedWithoutErrorBasedOnState];
                break;
            default:
                break;
        }
    }
    
    if ([characteristic isEqual:TIOADImageBlockChar]) {
        uint8_t data[characteristic.value.length];
        [characteristic.value getBytes:data length:characteristic.value.length];
        NSLog(@"TIOADClient: OAD Block RX: %@",characteristic.value);
    }
    
    if ([characteristic isEqual:TIOADImageIdentifyChar]) {
        uint8_t data[characteristic.value.length];
        [characteristic.value getBytes:data length:characteristic.value.length];
        NSLog(@"TIOADClient: OAD Image Identify RX: %@",characteristic.value);
        
        switch (data[0]) {
            case 0x00:
                NSLog(@"Success, we can start the OAD process !");
                state = tiOADClientHeaderOK;
                [self oadStatMachineIterate];
                break;
                
            default:
                NSLog(@"Failed, we have to stop");
                state = tiOADClientHeaderFailed;
                lastErrorCode = data[0];
                [self sendStateChangedWithErrorBasedOnState:data[0]];
                break;
        }
        
    }
}


-(void) peripheral:(CBPeripheral *)peripheral didReadRSSI:(NSNumber *)RSSI error:(NSError *)error {
    //TODO: add warnings to keep user in proximity of the peripheral during OAD upgrade...
    if (!rssiWarningSent) {
        if ([RSSI integerValue] < -85) {
            state = tiOADClientRSSIGettingLow;
            [self sendStateChangedWithErrorBasedOnState:0];
            rssiWarningSent = TRUE;
        }
    }
}








@end
