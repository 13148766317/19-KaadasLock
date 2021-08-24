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

#ifndef TIOADDefines_h
#define TIOADDefines_h

#define TI_OAD_SERVICE                                      @"F000FFC0-0451-4000-B000-000000000000"
#define TI_OAD_IMAGE_NOTIFY                                 @"F000FFC1-0451-4000-B000-000000000000"
#define TI_OAD_IMAGE_BLOCK_REQUEST                          @"F000FFC2-0451-4000-B000-000000000000"
#define TI_OAD_COUNT                                        @"F000FFC3-0451-4000-B000-000000000000"
#define TI_OAD_STATUS                                       @"F000FFC4-0451-4000-B000-000000000000"
#define TI_OAD_CONTROL                                      @"F000FFC5-0451-4000-B000-000000000000"


#define TI_TOAD_CONTROL_CMD_GET_BLOCK_SIZE                  0x01

#define TI_TOAD_CONTROL_CMD_START_OAD_PROCESS               0x03
#define TI_TOAD_CONTROL_CMD_ENABLE_OAD_IMAGE_CMD            0x04
#define TI_TOAD_CONTROL_CMD_GET_DEVICE_TYPE_CMD             0x10
#define TI_TOAD_CONTROL_CMD_IMAGE_BLOCK_WRITE_CHAR_RESPONSE 0x12


#define TI_EOAD_STATUS_CODE_SUCCESS                         0x00
#define TI_EOAD_STATUS_CODE_CRC_ERR                         0x01
#define TI_EOAD_STATUS_CODE_FLASH_ERR                       0x02
#define TI_EOAD_STATUS_CODE_BUFFER_OFL                      0x03
#define TI_EOAD_STATUS_CODE_ALREADY_STARTED                 0x04
#define TI_EOAD_STATUS_CODE_NOT_STARTED                     0x05
#define TI_EOAD_STATUS_CODE_DL_NOT_COMPLETE                 0x06
#define TI_EOAD_STATUS_CODE_NO_RESOURCES                    0x07
#define TI_EOAD_STATUS_CODE_IMAGE_TOO_BIG                   0x08
#define TI_EOAD_STATUS_CODE_INCOMPATIBLE_IMAGE              0x09
#define TI_EOAD_STATUS_CODE_INVALID_FILE                    0x0A
#define TI_EOAD_STATUS_CODE_INCOMPATIBLE_FILE               0x0B
#define TI_EOAD_STATUS_CODE_AUTH_FAIL                       0x0C
#define TI_EOAD_STATUS_CODE_EXT_NOT_SUPPORTED               0x0D
#define TI_EOAD_STATUS_CODE_DL_COMPLETE                     0x0E
#define TI_EOAD_STATUS_CODE_CCCD_NOT_ENABLED                0x0F
#define TI_EOAD_STATUS_CODE_IMG_ID_TIMEOUT                  0x10


#define TI_EOAD_STATUS_STRINGS      @"OAD Succeeded",\
                                    @"The downloaded image’s CRC doesn’t match the one expected from the metadata",\
                                    @"Flash function failure such as flashOpen/flashRead/flash write/flash erase",\
                                    @"The block number of the received packet doesn’t match the one requested, an overflow has occurred.",\
                                    @"OAD start command received, while OAD is already is progress",\
                                    @"OAD data block received with OAD start process",\
                                    @"OAD enable command received without complete OAD image download",\
                                    @"Memory allocation fails/ used only for backward compatibility",\
                                    @"Image is too big",\
                                    @"Stack and flash boundary mismatch, program entry mismatch",\
                                    @"Invalid image ID received",\
                                    @"BIM/image header/firmware version mismatch",\
                                    @"Start OAD process / Image Identify message/image payload authentication/validation fail",\
                                    @"Data length extension or OAD control point characteristic not supported",\
                                    @"OAD image payload download complete",\
                                    @"Internal (target side) error code used to halt the process if a CCCD has not been enabled",\
                                    @"OAD Image ID has been tried too many times and has timed out. Device will disconnect.", nil

#define TI_EOAD_STATE_STRINGS       @"Initializing",\
                                    @"Peripheral not connected anymore",\
                                    @"OAD Service is missing on peripheral",\
                                    @"Ready",\
                                    @"Get device type command sent",\
                                    @"Got device type response received",\
                                    @"EOAD block size request sent",\
                                    @"EOAD block size response received",\
                                    @"Header sent",\
                                    @"Header OK received",\
                                    @"Header FAIL received",\
                                    @"EOAD Start download process sent",\
                                    @"Image transfer in progress",\
                                    @"Image transfer failed",\
                                    @"Image transfer completed",\
                                    @"EOAD enable new image command sent",\
                                    @"Feedback complete OK",\
                                    @"Feedback complete FAILED", \
                                    @"Disconnect during download !",\
                                    @"Device disconnect, OAD complete !",\
                                    @"RSSI getting too low to program !", nil





#define TI_EOAD_IMAGE_IDENTIFY_PACKAGE_LEN                  22

#define TI_EOAD_IMAGE_INFO_CC2640R2                         @"OAD IMG "
#define TI_EOAD_IMAGE_INFO_CC26x2R1                         @"CC26x2R1"
#define TI_EOAD_IMAGE_INFO_CC13x2R1                         @"CC13x2R1"

//*****************************************************************************
//
//! \brief HW revision enumeration.
//
//*****************************************************************************
typedef enum {
    HWREV_Unknown     = -1, //!< -1 means that the chip's HW revision is unknown.
    HWREV_1_0         = 10, //!< 10 means that the chip's HW revision is 1.0
    HWREV_1_1         = 11, //!< 10 means that the chip's HW revision is 1.0
    HWREV_2_0         = 20, //!< 20 means that the chip's HW revision is 2.0
    HWREV_2_1         = 21, //!< 21 means that the chip's HW revision is 2.1
    HWREV_2_2         = 22, //!< 22 means that the chip's HW revision is 2.2
    HWREV_2_3         = 23, //!< 23 means that the chip's HW revision is 2.3
    HWREV_2_4         = 24  //!< 24 means that the chip's HW revision is 2.4
} HwRevision_t;

//*****************************************************************************
//
//! \brief Chip family enumeration
//
//*****************************************************************************
typedef enum {
    FAMILY_Unknown          = -1, //!< -1 means that the chip's family member is unknown.
    FAMILY_CC26x0           =  0, //!<  0 means that the chip is a CC26x0 family member.
    FAMILY_CC13x0           =  1, //!<  1 means that the chip is a CC13x0 family member.
    FAMILY_CC26x1           =  2, //!<  2 means that the chip is a CC26x1 family member.
    FAMILY_CC26x0R2         =  3, //!<  3 means that the chip is a CC26x0R2 family (new ROM contents).
    FAMILY_CC13x2_CC26x2    =  4  //!<  4 means that the chip is a CC13x2, CC26x2 family member.
} ChipFamily_t;

//*****************************************************************************
//
//! \brief Chip type enumeration
//
//*****************************************************************************
typedef enum {
    CHIP_TYPE_Unknown       = -1, //!< -1 means that the chip type is unknown.
    CHIP_TYPE_CC1310        =  0, //!<  0 means that this is a CC1310 chip.
    CHIP_TYPE_CC1350        =  1, //!<  1 means that this is a CC1350 chip.
    CHIP_TYPE_CC2620        =  2, //!<  2 means that this is a CC2620 chip.
    CHIP_TYPE_CC2630        =  3, //!<  3 means that this is a CC2630 chip.
    CHIP_TYPE_CC2640        =  4, //!<  4 means that this is a CC2640 chip.
    CHIP_TYPE_CC2650        =  5, //!<  5 means that this is a CC2650 chip.
    CHIP_TYPE_CUSTOM_0      =  6, //!<  6 means that this is a CUSTOM_0 chip.
    CHIP_TYPE_CUSTOM_1      =  7, //!<  7 means that this is a CUSTOM_1 chip.
    CHIP_TYPE_CC2640R2      =  8, //!<  8 means that this is a CC2640R2 chip.
    CHIP_TYPE_CC2642        =  9, //!<  9 means that this is a CC2642 chip.
    CHIP_TYPE_CC2644        =  10,//!< 10 means that this is a CC2644 chip.
    CHIP_TYPE_CC2652        =  11,//!< 11 means that this is a CC2652 chip.
    CHIP_TYPE_CC1312        =  12,//!< 12 means that this is a CC1312 chip.
    CHIP_TYPE_CC1352        =  13,//!< 13 means that this is a CC1352 chip.
    CHIP_TYPE_CC1352P       =  14 //!< 14 means that this is a CC1354 chip.
} ChipType_t;

#endif /* TIOADDefines_h */
