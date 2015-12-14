//
//  EditContentTableViewCell.h
//  Events
//
//  Created by 毕鸣 on 20/11/2015.
//  Copyright © 2015 LLZG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MGSwipeTableCell.h"
#import "MGSwipeButton.h"
#import "ContentRecord.h"


@protocol EditContentCellDelegate;

@interface EditContentTableViewCell : MGSwipeTableCell

@property (nonatomic, strong) ContentRecord *record;

@property (nonatomic, strong) NSDictionary *info;
@property (nonatomic, strong, getter=getContent) id content;
@property (nonatomic, assign) BOOL isEditting;

@property (nonatomic, strong) id<EditContentCellDelegate> contentCellDelegate;


@end

@protocol EditContentCellDelegate <NSObject>

- (void)didUpdateContent:(EditContentTableViewCell *)cell;

@optional
- (void)selectImageForCell:(EditContentTableViewCell *)cell;

- (void)textViewDidBeginEditingForCell:(EditContentTableViewCell *)cell;

- (void)textViewDidEndEditingForCell:(EditContentTableViewCell *)cell;

@end