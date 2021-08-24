# ti_oad

[![CI Status](http://img.shields.io/travis/Ole Andreas Torvmark/ti_oad.svg?style=flat)](https://travis-ci.org/Ole Andreas Torvmark/ti_oad)
[![Version](https://img.shields.io/cocoapods/v/ti_oad.svg?style=flat)](http://cocoapods.org/pods/ti_oad)
[![License](https://img.shields.io/cocoapods/l/ti_oad.svg?style=flat)](http://cocoapods.org/pods/ti_oad)
[![Platform](https://img.shields.io/cocoapods/p/ti_oad.svg?style=flat)](http://cocoapods.org/pods/ti_oad)

## Manifest

[Software manifest file](TI_OAD-iOS_1.0_manifest.html)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## How to get started

ti_oad is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ti_oad'
```

### Obj-C usage

```objectivec
#import "TIOAD.h"

@property TIOADToadImageReader *imgReader;

TIOADClient *client;


TIOADToadImageReader *imgReader = [[TIOADToadImageReader alloc] initWithImageData:[NSData dataWithContentsOfFile:str] fileName:str];
client = [[TIOADClient alloc] initWithPeripheral:self.d.p           //<-- Peripheral to upgrade
                                    andImageData:imgReader          //<-- Image data reader with the bin file loaded (see line above)
                                     andDelegate:self               //<-- Delegate to get the callbacks in on
                                     andManager:self.d.manager];    //<-- CBCentralManager that delivered the CBPeripheral



[client startOAD]; //Start actual download..



#pragma mark -- TIOADClientProgressDelegate methods below

-(void) client:(TIOADClient *)client oadProgressUpdated:(TIOADClientProgressValues_t)progress {
    //Show some kind of progress bar or text from the progress delivered

}

-(void) client:(TIOADClient *)client oadProcessStateChanged:(TIOADClientState_t)state error:(NSError *)error {
    switch (state) {
        case tiOADClientReady:
            self.progressState.text = @"Client Ready";
            break;
        case tiOADClientDisconnectedDuringDownload:
            //Handle a disconnection while download was in progress
            break;
    }

}

```

## Supported platforms
### Version 1.0.0

| Platform  | SDK         | Stack Bluetooth Version                   |
|-----------|-------------|-------------------------------------------|
| CC2640R2F | 1.40.00.45  | Only BLE 4.2 projects with OAD enabled (1)|
| CC2640R2F | 1.50.00.58  | Only BLE 4.2 projects with OAD enabled (1)|
| CC264X2R1 | 2.10.00.44  | BLE 5.0 projects with OAD enabled(2)      |
| CC13X2R1  | 2.10.00.48  | BLE 5.0 projects with OAD enabled(2)      |

(1) Bluetooth 5.0 OAD projects use the old ti OAD profile not implemented by this library yet.

(2) No Bluetooth 4.2 projects available on CC264X2R1 & CC13X2R1

## Author

Ole Andreas Torvmark, o.a.torvmark@ti.com

## License

ti_oad is available under the Apache 2.0 license
