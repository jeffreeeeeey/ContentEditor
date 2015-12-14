//
//  ContentRecord.h
//  Events
//
//  Created by 毕鸣 on 27/11/2015.
//  Copyright © 2015 LLZG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Settings.h"

@interface ContentRecord : NSObject

@property (nonatomic, readonly, assign) ContentType type;
@property (nonatomic, assign) BOOL updated;
/**
 *  Use this to trace the cell.Only set it before uploading Images to server. so we don't need to update it's value when moving, deleting rows.
 */
@property (nonatomic, assign) NSIndexPath *indexPath;

- (instancetype)initWithType:(ContentType)type NS_DESIGNATED_INITIALIZER;

- (NSString *)contentString;

@end
