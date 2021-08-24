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

#import "NSString+hex.h"

@implementation NSString (NSString_hex)

-(NSString *) undecoratedHexString {
    NSMutableString *undecorated = [NSMutableString stringWithString:self];
    [undecorated replaceOccurrencesOfString:@"0x" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, undecorated.length)];
    [undecorated replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, undecorated.length)];
    return undecorated;
}

-(NSString *) decoratedHexStringLSB:(BOOL)isLSB {
    //First undecorate...
    NSString *undecorated = [self undecoratedHexString];
    //Pad with 0
    NSString *padded = [undecorated paddedHexStringLSB:isLSB];
    //...then decorate back
    NSMutableString *decorated = [NSMutableString stringWithString:padded];
    if (decorated.length > 0) {
        for (int count = 0, n = decorated.length * 0.5, i = 0; count < n; ++count, i += 5) {
            [decorated insertString:@" 0x" atIndex:i];
        }
        [decorated replaceCharactersInRange:NSMakeRange(0, 1) withString:@""];//Remove initial space
    }
    return decorated;
}

-(NSString *) paddedHexStringLSB:(BOOL)isLSB {
    NSMutableString *padded = [NSMutableString stringWithString:self];
    if (padded.length % 2 != 0) {//Odd number of digits
        if (isLSB) {//Prepend 0 to the last byte (0x123 -> 0x1203)
            [padded insertString:@"0" atIndex:(padded.length - 1)];
        } else  {//Prepend 0 to the first byte (0x123 -> 0x0123)
            [padded insertString:@"0" atIndex:0];
        }
    }
    return padded;
}

@end
