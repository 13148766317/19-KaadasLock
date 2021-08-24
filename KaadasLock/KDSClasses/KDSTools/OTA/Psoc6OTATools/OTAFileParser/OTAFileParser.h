/*
 * Copyright Cypress Semiconductor Corporation, 2015-2018 All rights reserved.
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

#import <Foundation/Foundation.h>

@interface OTAFileParser : NSObject

#define SILICON_ID          @"SiliconID"
#define SILICON_REV         @"SiliconRev"
#define CHECKSUM_TYPE       @"CheckSumType"
#define ROW_ID              @"RowID"
#define ROW_COUNT           @"RowCount"
#define ARRAY_ID            @"ArrayID"
#define ROW_NUMBER          @"RowNumber"
#define DATA_LENGTH         @"DataLength"
#define DATA_ARRAY          @"DataArray"
#define CHECKSUM_OTA        @"CheckSum"
#define ROW_TYPE            @"RowType"
#define FILE_VERSION        @"FileVersion"
#define APPINFO_APP_START   @"APPINFO_APP_START"
#define APPINFO_APP_SIZE    @"APPINFO_APP_SIZE"

typedef NS_ENUM(uint8_t, RowType) {
    RowTypeEiv = 0,
    RowTypeData
};

/*!
 *  @method parseFirmwareFileWithName: andPath: onFinish:
 *
 *  @discussion Method for parsing the OTA firmware file (CYACD)
 *
 */
- (void) parseFirmwareFileWithName:(NSString *)fileName path:(NSString *)filePath onFinish:(void(^)(NSMutableDictionary * header, NSArray * rowData, NSArray * rowIdArray, NSError * error))finish;

/*!
 *  @method parseFirmwareFileWithName_v1: andPath: onFinish:
 *
 *  @discussion Method for parsing the OTA firmware file (CYACD2)
 *
 */
- (void) parseFirmwareFileWithName_v1:(NSString *)fileName path:(NSString *)filePath onFinish:(void(^)(NSMutableDictionary *header, NSDictionary *appInfo, NSArray *rowData, NSError *error))finish;

@end
