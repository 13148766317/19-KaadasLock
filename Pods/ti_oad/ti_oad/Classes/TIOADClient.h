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
#import <CoreBluetooth/CoreBluetooth.h>
#import "TIOADToadImageReader.h"
#import "TIOADDefines.h"

typedef struct TIOADClientProgressValues {
    uint32_t currentBlockSize;
    uint32_t currentBlock;
    uint32_t currentByte;
    uint32_t totalBlocks;
    uint32_t totalBytes;
    float percentProgress;
    float currentBytesPerSecond;
    double startDownloadTime;
    double totalDownloadTime;
}TIOADClientProgressValues_t;

typedef enum TIOADClientState {
    tiOADClientInitializing,
    tiOADClientPeripheralNotConnected,
    tiOADClientOADServiceMissingOnPeripheral,
    tiOADClientReady,
    tiOADClientGetDeviceTypeCommandSent,
    tiOADClientGetDeviceTypeResponseRecieved,
    tiOADClientBlockSizeRequestSent,
    tiOADClientGotBlockSizeResponse,
    tiOADClientHeaderSent,
    tiOADClientHeaderOK,
    tiOADClientHeaderFailed,
    tiOADClientOADProcessStartCommandSent,
    tiOADClientImageTransfer,
    tiOADClientImageTransferFailed,
    tiOADClientImageTransferOK,
    tiOADClientEnableOADImageCommandSent,
    tiOADClientCompleteFeedbackOK,
    tiOADClientCompleteFeedbackFailed,
    tiOADClientDisconnectedDuringDownload,
    tiOADClientOADCompleteIncludingDisconnect,
    tiOADClientRSSIGettingLow,
}TIOADClientState_t;

@protocol TIOADClientProgressDelegate;



@interface TIOADClient : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property id<TIOADClientProgressDelegate> delegate;
@property uint32_t deviceID;

-(instancetype) initWithPeripheral:(CBPeripheral *) peripheral
                      andImageData:(TIOADToadImageReader *)data
                       andDelegate:(id<TIOADClientProgressDelegate>) delegate;
-(instancetype) initWithPeripheral:(CBPeripheral *)peripheral
                      andImageData:(TIOADToadImageReader *)data
                       andDelegate:(id<TIOADClientProgressDelegate>)delegate
                        andManager:(CBCentralManager *)manager;
-(void) startOAD;
-(void) stopOAD;
-(void) sendOADControlGetOADBlockSizeCmd;
-(ChipType_t) getChipTypeOfOAD;
-(NSString *) getChipId;


+(NSString *) getStatusStringFromStatusByte:(uint8_t) statusByte;
+(NSString *) getStateStringFromState:(TIOADClientState_t)state;

@end




@protocol TIOADClientProgressDelegate <NSObject>

-(void) client:(TIOADClient *)client oadProgressUpdated:(TIOADClientProgressValues_t) progress;
-(void) client:(TIOADClient *)client oadProcessStateChanged:(TIOADClientState_t)state error:(NSError *)error;


@end
