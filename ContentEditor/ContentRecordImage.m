//
//  ContentRecordImage.m
//  Events
//
//  Created by 毕鸣 on 27/11/2015.
//  Copyright © 2015 LLZG. All rights reserved.
//

#import "ContentRecordImage.h"

@implementation ContentRecordImage

- (instancetype)initWithType:(ContentType)type {
    self = [super initWithType:type];
    if (self) {
        self.image = [UIImage imageNamed:@"placeHolder2.png"];
        self.updated = NO;
        self.uploaded = NO;
    }
    return self;
}

- (NSString *)contentString {
    NSString *contentString = nil;
    if (self.imagePath) {
        contentString = [NSString stringWithFormat:@"{\"type\":\"imgs\", \"value\":[{\"url\":\"%@\"}]}", self.imagePath];
    }
    
    return contentString;
}

@end
