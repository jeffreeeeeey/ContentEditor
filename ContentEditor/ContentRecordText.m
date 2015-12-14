//
//  ContentRecordText.m
//  Events
//
//  Created by 毕鸣 on 27/11/2015.
//  Copyright © 2015 LLZG. All rights reserved.
//

#import "ContentRecordText.h"
#import "Settings.h"

@implementation ContentRecordText

- (instancetype)initWithType:(ContentType)type {
    self = [super initWithType:type];
    if (self) {
        self.text = TEXTVIEW_PLACEHOLDER;
    }
    return self;
}

- (NSString *)contentString {
    NSString *contentString = nil;
    if (![self.text isEqualToString:@""]) {
        contentString = [NSString stringWithFormat:@"{\"type\":\"html\", \"value\":\"%@\"}", self.text];
    }
    
    return contentString;
}

@end
