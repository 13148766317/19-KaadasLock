//
//  ViewController.h
//  kxmovieapp
//
//  Created by Kolyvan on 11.10.12.
//  Copyright (c) 2012 Konstantin Boukreev . All rights reserved.
//
//  https://github.com/kolyvan/kxmovie
//  this file is part of KxMovie
//  KxMovie is licenced under the LGPL v3, see lgpl-3.0.txt

#import <UIKit/UIKit.h>

@class KdsKxMovieDecoder;

extern NSString * const KdsKxMovieParameterMinBufferedDuration;    // Float
extern NSString * const KdsKxMovieParameterMaxBufferedDuration;    // Float
extern NSString * const KdsKxMovieParameterDisableDeinterlacing;   // BOOL

@interface KdsKxMovieViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

+ (id) kdsmovieViewControllerWithContentPath: (NSString *) path
                               parameters: (NSDictionary *) parameters;

@property (readonly) BOOL playing;

- (void) play;
- (void) pause;

@end
