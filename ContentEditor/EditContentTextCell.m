//
//  EditContentTextCell.m
//  Events
//
//  Created by 毕鸣 on 20/11/2015.
//  Copyright © 2015 LLZG. All rights reserved.
//

#import "EditContentTextCell.h"
#import "PureLayout.h"

@interface EditContentTextCell ()<UITextViewDelegate>



@end



@implementation EditContentTextCell
@synthesize record = _record; // Need use it to set the property belong to super class.

- (void)awakeFromNib {
    // Initialization code
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textView = [UITextView newAutoLayoutView];
        self.textView.delegate = self;
        [self.contentView addSubview:self.textView];
        
        
        //[self addDoneToolBarToKeyboard:self.textView];
    }
    return self;
}

- (void)setInfo:(NSDictionary *)info {


}

- (void)setRecord:(ContentRecord *)record {

    _record = record;

    ContentRecordText *textRecord = (ContentRecordText *)record;
    self.textView.text = textRecord.text;
    
}
- (void)updateConstraints {
    
    [self.textView autoSetDimension:ALDimensionHeight toSize:100];
    [self.textView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    
    
    [super updateConstraints];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

    [self.contentCellDelegate textViewDidBeginEditingForCell:self];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self.contentCellDelegate textViewDidEndEditingForCell:self];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}



// get the width of the contentView correct, or the imageView will be wrong size.
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
}


@end
