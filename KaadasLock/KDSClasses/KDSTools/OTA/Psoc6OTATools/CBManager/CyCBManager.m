/*
 * Copyright Cypress Semiconductor Corporation, 2014-2018 All rights reserved.
 *
 * This software, associated documentation and materials ("Software") is
 * owned by Cypress Semiconductor Corporation ("Cypress") and is
 * protected by and subject to worldwide patent protection (UnitedStates and foreign), United States copyright laws and international
 * treaty provisions. Therefore, unless otherwise specified in a separate license agreement between you and Cypress, this Software
 * must be treated like any other copyrighted material. Reproduction,
 * modification, translation, compilation, or representation of this
 * Software in any other form (e.g., paper, magnetic, optical, silicon)
 * is prohibited without Cypress's express written permission.
 *
 * Disclaimer: THIS SOFTWARE IS PROVIDED AS-IS, WITH NO WARRANTY OF ANY
 * KIND, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
 * NONINFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE. Cypress reserves the right to make changes
 * to the Software without notice. Cypress does not assume any liability
 * arising out of the application or use of Software or any product or
 * circuit described in the Software. Cypress does not authorize its
 * products for use as critical components in any products where a
 * malfunction or failure may reasonably be expected to result in
 * significant injury or death ("High Risk Product"). By including
 * Cypress's product in a High Risk Product, the manufacturer of such
 * system or application assumes all risk of such use and in doing so
 * indemnifies Cypress against all liability.
 *
 * Use of this Software may be limited by and subject to the applicable
 * Cypress software license agreement.
 *
 *
 */

#import <UIKit/UIKit.h>
#import "CyCBManager.h"
#import "CBPeripheralExt.h"
#import "ResourceHandler.h"
#import "Utilities.h"

#define MY_DOMAIN       @"myDomain"

/*!
 *  @class CyCBManager
 *
 *  @discussion Singleton, coordinates all the peripheral related operations.
 *
 */
@interface CyCBManager () <CBCentralManagerDelegate, CBPeripheralDelegate>
{
    CBCentralManager *centralManager;
    NSMutableArray *peripheralArray;
    
    void (^cbCommunicationHandler)(BOOL success, NSError *error);
    BOOL isTimeOutAlert;
}
@end

@implementation CyCBManager

@synthesize cbCharacteristicDelegate;
@synthesize myPeripheral;
@synthesize myService;
@synthesize myCharacteristic;
@synthesize serviceUUIDDict;
@synthesize cbDiscoveryDelegate;
@synthesize foundPeripherals;
@synthesize foundServices;
@synthesize characteristicDescriptors;
@synthesize characteristicProperties;
@synthesize bootloaderFileArray;
@synthesize bootloaderSecurityKey;
@synthesize bootloaderActiveApp;

#define k_SERVICE_UUID_PLIST_NAME @"ServiceUUIDPList"

#pragma mark - Singleton Methods
static CyCBManager *sharedMgr = nil;
static dispatch_once_t onceToken;

/*!
 *  @method sharedManager
 *
 *  @discussion Returns single instance of CyCBManager.
 *
 */
+ (id)sharedManager {
    dispatch_once(&onceToken, ^{
        sharedMgr = [[self alloc] init];
    });
    return sharedMgr;
}

- (id)init {
    if (self = [super init])
    {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        foundPeripherals = [[NSMutableArray alloc] init];
        foundServices = [[NSMutableArray alloc] init];
        peripheralArray = [[NSMutableArray alloc] init];
        serviceUUIDDict = [NSMutableDictionary dictionaryWithDictionary:[ResourceHandler getItemsFromPropertyList:k_SERVICE_UUID_PLIST_NAME]];
        bootloaderFileArray = nil;
        bootloaderSecurityKey = nil;
        bootloaderActiveApp = NoChange;
        
    }
    return self;
}
+ (id)sharedManagerWithPeripheral:(CBPeripheral *) peripheral {
    if (sharedMgr) {
        [[CyCBManager sharedManager] copyPeripheral:peripheral];

    }else{
        dispatch_once(&onceToken, ^{
            sharedMgr = [[self alloc] initWithPeripheral:peripheral];
        });
    }
    return sharedMgr;
}

- (id)initWithPeripheral:(CBPeripheral *) peripheral{
    if (self = [super init])
    {
        centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        foundPeripherals = [[NSMutableArray alloc] init];
        foundServices = [[NSMutableArray alloc] init];
        peripheralArray = [[NSMutableArray alloc] init];
        serviceUUIDDict = [NSMutableDictionary dictionaryWithDictionary:[ResourceHandler getItemsFromPropertyList:k_SERVICE_UUID_PLIST_NAME]];
        bootloaderFileArray = nil;
        bootloaderSecurityKey = nil;
        bootloaderActiveApp = NoChange;
        
        myPeripheral =  nil;
        myPeripheral = [peripheral copy];
        myPeripheral.delegate = self ;
        [myPeripheral discoverServices:nil];
        NSLog(@"--{Kaadas}--myPeripheral11==%@",myPeripheral);

    }
    return self;
}
- (void)copyPeripheral:(CBPeripheral *) peripheral{
   
        myPeripheral =  nil;
        myPeripheral = [peripheral copy];
        myPeripheral.delegate = self ;
        [myPeripheral discoverServices:nil];
        NSLog(@"--{Kaadas}--myPeripheral22==%@",myPeripheral);
    
}
#pragma mark - Discovery

/*!
 *  @method startScanning
 *
 *  @discussion Scan for advertising peripherals.
 *
 */
- (void) startScanning
{
    if((NSInteger)[centralManager state] == CBCentralManagerStatePoweredOn)
    {
        [cbDiscoveryDelegate bluetoothStateUpdatedToState:YES];
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
        [centralManager scanForPeripheralsWithServices:nil options:options];
    }
    else if ([centralManager state] == CBCentralManagerStateUnsupported)
    {
        [Utilities alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"BLENotSupportedAlert")];
    }
}


/*!
 *  @method stopScanning
 *
 *  @discussion  Stop scanning for peripherals.
 *
 */
- (void) stopScanning
{
    [centralManager stopScan];
}

/*!
 *  @method centralManager:didDiscoverPeripheral:advertisementData:RSSI
 *
 *  @discussion Central manager discovered some advertising peripheral.
 *
 */
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Add the peripheral to the list of discovered peripherals
    if (![peripheralArray containsObject:peripheral] && peripheral.state != CBPeripheralStateConnected)
    {
        CBPeripheralExt *peripheralExt = [[CBPeripheralExt alloc] init];
        peripheralExt.mPeripheral = [peripheral copy];
        peripheralExt.mAdvertisementData = [advertisementData copy];
        peripheralExt.mRSSI = [RSSI copy];
        [peripheralArray addObject:peripheral];
        [foundPeripherals addObject:peripheralExt];
        [cbDiscoveryDelegate discoveryDidRefresh];
    }
}

#pragma mark - Connection/Disconnection

/*!
 *  @method cancelTimeOutAlert
 *
 *  @discussion Cancel timeout alert.
 *
 */
-(void)cancelTimeOutAlert
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeOutMethodForConnect) object:nil];
}

/*!
 *  @method timeOutMethodForConnect
 *
 *  @discussion Handler for the timed out connection attempt.
 *
 */
-(void)timeOutMethodForConnect
{
    isTimeOutAlert = YES;
    [self cancelTimeOutAlert];
    [self disconnectPeripheral:myPeripheral];
    NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
    [errorDetail setValue:LOCALIZEDSTRING(@"connectionTimeOutAlert") forKey:NSLocalizedDescriptionKey];
    NSError *error = [NSError errorWithDomain:MY_DOMAIN code:100 userInfo:errorDetail];
    [self refreshPeripherals];
    cbCommunicationHandler(NO,error);
}

/*!
 *  @method connectPeripheral:completionHandler:
 *
 *  @discussion	 Connect to the peripheral.
 *
 */
- (void) connectPeripheral:(CBPeripheral*)peripheral completionHandler:(void (^)(BOOL success, NSError *error))completionHandler
{
      if((NSInteger)[centralManager state] == CBCentralManagerStatePoweredOn)
      {
          cbCommunicationHandler = completionHandler ;
         
          if ([peripheral state] == CBPeripheralStateDisconnected)
          {
              [centralManager connectPeripheral:peripheral options:nil];
//              //[[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@", peripheral.name, CONNECTION_REQUEST]];
          }
          else
          {
              [centralManager cancelPeripheralConnection:peripheral];
          }
          
          [self performSelector:@selector(timeOutMethodForConnect) withObject:nil afterDelay:DEVICE_CONNECTION_TIMEOUT];
      }
}

/*!
 *  @method disconnectPeripheral:
 *
 *  @discussion	 Disconnect the peripheral.
 *
 */
- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
    if(peripheral)
    {
        [centralManager cancelPeripheralConnection:peripheral];
    }
}

/*!
 *  @method centralManager:didConnectPeripheral:
 *
 *  @discussion	Central manager established connection with the peripheral.
 *
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
//    myPeripheral =  nil;
//    myPeripheral = [peripheral copy];
//    myPeripheral.delegate = self ;
//    [myPeripheral discoverServices:nil];
//    NSLog(@"--00--00--myPeripheral==%@",myPeripheral);

//    //[[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@", peripheral.name, CONNECTION_ESTABLISH]];
//    //[[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@", peripheral.name, SERVICE_DISCOVERY_REQUEST]];
}

/*!
 *  @method centralManager:didFailToConnectPeripheral:error:
 *
 *  @discussion	Central manager failed to established connection with the peripheral.
 *
 */
- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
     [self cancelTimeOutAlert];
     cbCommunicationHandler(NO,error);
}

/*!
 *  @method centralManager:didDisconnectPeripheral:error:
 *
 *  @discussion	Central manager terminated the connection with the peripheral.
 *
 */
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"--{Kaadas}--CyCBManager--didDisconnectPeripheral");
    
    [self cancelTimeOutAlert];

    /*  Check whether the disconnection is done by the device */
    if (error == nil && !isTimeOutAlert)
    {
        NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
        [errorDetail setValue:LOCALIZEDSTRING(@"deviceDisconnectedAlert") forKey:NSLocalizedDescriptionKey];
        NSError *disconnectError = [NSError errorWithDomain:MY_DOMAIN code:100 userInfo:errorDetail];
//        //[[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@",peripheral.name,DISCONNECTION_REQUEST]];

        cbCommunicationHandler(NO,disconnectError);
    }
    else
    {
        isTimeOutAlert = NO;
        
        // Checking whether the disconnected device has pending firmware upgrade
        if ([[CyCBManager sharedManager] bootloaderFileArray] != nil && error != nil)
        {
            NSMutableDictionary *errorDict = [NSMutableDictionary dictionary];
            [errorDict setValue:[NSString stringWithFormat:@"%@%@",[error.userInfo objectForKey:NSLocalizedDescriptionKey],LOCALIZEDSTRING(@"firmwareUpgradePendingMessage")] forKey:NSLocalizedDescriptionKey];
            
            NSError *disconnectionError = [NSError errorWithDomain:MY_DOMAIN code:100 userInfo:errorDict];
            cbCommunicationHandler(NO,disconnectionError);
        }
        else
            cbCommunicationHandler(NO,error);
    }

    [self redirectToRootViewController];
//    //[[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@",peripheral.name,DISCONNECTED]];
    [self clearDevices];
}

/*!
 *  @method redirectToRootViewController
 *
 *  @discussion	 Pops all the view controllers on the stack except the root view controller and updates the display. 
 *  This will redirect to BLE Devices Page which lists all discovered peripherals.
 *
 */
-(void)redirectToRootViewController
{
//    if(cbDiscoveryDelegate)
//    {
//        [[(UIViewController*)cbDiscoveryDelegate navigationController] popToRootViewControllerAnimated:YES];
//
//    }
//    else if(cbCharacteristicDelegate)
//    {
//        [[(UIViewController*)cbCharacteristicDelegate navigationController] popToRootViewControllerAnimated:YES];
//
//    }
}

#pragma mark - Service Discovery

/*!
 *  @method peripheral:didDiscoverServices:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    
    [self cancelTimeOutAlert];
//    if(error == nil)
//    {
//        KDSLog(@"--00--00--1111111");
//
//        ////[[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@- %@",peripheral.name,SERVICE_DISCOVERY_STATUS,SERVICE_DISCOVERED]];
//        BOOL isCapsenseExist = NO;
////        for (CBService *service in peripheral.services)
////        {
////            if (![foundServices containsObject:service])
////            {
////                [foundServices addObject:service];
////                if(([service.UUID isEqual:CAPSENSE_SERVICE_UUID] || [service.UUID isEqual:CUSTOM_CAPSENSE_SERVICE_UUID])
////                   && (NO == isCapsenseExist))//There is no need to perform characteristics discovery for subsequent CapSense services
////                {
////                    KDSLog(@"--00--00--4444444");
////
////                    isCapsenseExist = YES;
////                    cbCharacteristicDelegate = nil;
////                    [myPeripheral discoverCharacteristics:nil forService:service];
////                }
////            }
////        }
//        if(NO == isCapsenseExist)
//        {
//            KDSLog(@"--00--00--2222222");
//
////            cbCommunicationHandler(YES,nil);
//        }
//    }
//    else
//    {
//        //[[LoggerHandler logManager] addLogData:[NSString stringWithFormat:@"[%@] %@- %@%@]",peripheral.name,SERVICE_DISCOVERY_STATUS,SERVICE_DISCOVERY_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
//        KDSLog(@"--00--00--3333333");
//
//        cbCommunicationHandler(NO,error);
//    }
}

#pragma mark - Characteristic Discovery

/*!
 *  @method peripheral:didDiscoverCharacteristicsForService:error:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if([cbCharacteristicDelegate isKindOfClass:[CyCBManager class]] || cbCharacteristicDelegate == nil)
    {
        cbCommunicationHandler(YES,nil);
    }
    else
    {
        [cbCharacteristicDelegate peripheral:peripheral didDiscoverCharacteristicsForService:service error:error];
    }
}

/*!
 *  @method peripheral:didUpdateValueForCharacteristic:error:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        if (!characteristic.isNotifying)
        {
            [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:characteristic.UUID] descriptor:nil operation:[NSString stringWithFormat:@"%@- %@%@",READ_RESPONSE,READ_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
        }
    }
    
    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didUpdateValueForCharacteristic:error:)])
    {
        [cbCharacteristicDelegate peripheral:peripheral didUpdateValueForCharacteristic:characteristic error:error];
    }
}

/*!
 *  @method peripheral:didWriteValueForCharacteristic:error:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{

    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didWriteValueForCharacteristic:error:)])
    {
        [cbCharacteristicDelegate peripheral:peripheral didWriteValueForCharacteristic:characteristic error:error];
    }
}

/*!
 *  @method peripheral:didDiscoverDescriptorsForCharacteristic:error:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSLog(@"--{Kaadas}--didDiscoverDescriptorsForCharacteristic");

    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didDiscoverDescriptorsForCharacteristic:error:)])
    [cbCharacteristicDelegate peripheral:peripheral didDiscoverDescriptorsForCharacteristic:characteristic error:error];
}

/*!
 *  @method peripheral:didUpdateValueForDescriptor:error:
 *
 */
-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error
{
    if (error)
    {
        [Utilities logDataWithService:[ResourceHandler getServiceNameForUUID:descriptor.characteristic.service.UUID] characteristic:[ResourceHandler getCharacteristicNameForUUID:descriptor.characteristic.UUID] descriptor:[Utilities getDiscriptorNameForUUID:descriptor.UUID] operation:[NSString stringWithFormat:@"%@- %@%@",READ_RESPONSE,READ_ERROR,[error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
    }
    [cbCharacteristicDelegate peripheral:peripheral didUpdateValueForDescriptor:descriptor error:error];
}

/*!
 *  @method peripheral:didUpdateNotificationStateForCharacteristic:error:
 *
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if([cbCharacteristicDelegate respondsToSelector:@selector(peripheral:didUpdateNotificationStateForCharacteristic:error:)]) {
        [cbCharacteristicDelegate peripheral:peripheral didUpdateNotificationStateForCharacteristic:characteristic error:error];
    }
}


#pragma mark - BLE State

/*!
 *  @method clearDevices
 *
 *  @discussion	 Clear all listed peripherals and services.
 *
 */
- (void) clearDevices
{
    [peripheralArray removeAllObjects];
    [foundPeripherals removeAllObjects];
    [foundServices removeAllObjects];
}

/*
 * @method centralManagerDidUpdateState:
 * 
 * @discussion Invoked when the central manager’s state is updated. (required)
 * If the state is On then app start scanning for peripherals that are advertising services.
 * If the state is Off then call method [clearDevices] and redirect to Home screen.
 */
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch ((NSInteger)[centralManager state])
    {
        case CBCentralManagerStatePoweredOff:
        {
            //设备关闭状态
            [self clearDevices];
            /* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
            //Show Alert
//            [self redirectToRootViewController];
            [cbDiscoveryDelegate bluetoothStateUpdatedToState:NO];
            break;
        }
            
        case CBCentralManagerStateUnauthorized:
        {
            /* Tell user the app is not allowed. */
            [Utilities alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"appNotAuthorizedAlert")];
            break;
        }
            
        case CBCentralManagerStateUnknown:
        {
            /* Bad news, let's wait for another event. */
            [Utilities alertWithTitle:APP_NAME message:LOCALIZEDSTRING(@"stateUnknownAlert" )];
            break;
        }
            
        case CBCentralManagerStatePoweredOn:
        {
            [cbDiscoveryDelegate bluetoothStateUpdatedToState:YES];
            [self startScanning];
            break;
        }
            
        case CBCentralManagerStateResetting:
        {
            [self clearDevices];
            break;
        }
    }
}

/*!
 * @method refreshPeripherals
 *
 * @discussion	Clear all listed peripherals and services.
 * Also check the status of Bluetooth and alert the user if it is turned Off.
 *
 */
- (void) refreshPeripherals
{
    [self clearDevices];
    if([centralManager state] == CBCentralManagerStatePoweredOff)
    {
        [Utilities alertWithTitle:LOCALIZEDSTRING(@"warning") message:LOCALIZEDSTRING(@"bluetoothDeviceTurnOnAlert" )];
    }
    [[CyCBManager sharedManager] stopScanning];
    [[CyCBManager sharedManager] startScanning];
}

@end
