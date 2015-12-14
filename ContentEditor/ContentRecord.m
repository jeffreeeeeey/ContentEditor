//
//  ContentRecord.m
//  Events
//
//  Created by 毕鸣 on 27/11/2015.
//  Copyright © 2015 LLZG. All rights reserved.
//

#import "ContentRecord.h"

@interface ContentRecord ()
@property (nonatomic, readwrite, assign) ContentType type;
@end

@implementation ContentRecord

- (instancetype)initWithType:(ContentType)type {
    self = [super init];
    if (self) {
        self.type = type;
        self.updated = NO;
    }
    return self;
}

@end
