//
//  ContentRecordImage.h
//  Events
//
//  Created by 毕鸣 on 27/11/2015.
//  Copyright © 2015 LLZG. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ContentRecord.h"

@interface ContentRecordImage : ContentRecord

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, assign) BOOL uploaded;

@end
