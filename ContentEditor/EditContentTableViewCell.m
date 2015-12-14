//
//  EditContentTableViewCell.m
//  Events
//
//  Created by 毕鸣 on 20/11/2015.
//  Copyright © 2015 LLZG. All rights reserved.
//

#import "EditContentTableViewCell.h"

@implementation EditContentTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    
    return self;
}

- (void)setRecord:(ContentRecord *)record {
    self.record = record;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
