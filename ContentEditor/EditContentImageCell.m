//
//  EditContentImageCell.m
//  Events
//
//  Created by 毕鸣 on 20/11/2015.
//  Copyright © 2015 LLZG. All rights reserved.
//

#import "EditContentImageCell.h"
#import "PureLayout.h"

@interface EditContentImageCell ()


@property (nonatomic, assign) CGSize newSize;

@end

@implementation EditContentImageCell
@synthesize record = _record;

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
        //self.isEditting = YES;
    }
    return self;
}


- (void)setRecord:(ContentRecord *)record {
    _record = record;
    
    if (self.theImageView) {
        [self.theImageView removeFromSuperview];
    }
    
    self.theImageView = [UIImageView newAutoLayoutView];
    
    [self.theImageView setUserInteractionEnabled:YES];
    [self.theImageView setClipsToBounds:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageViewTapped)];
    //UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(imageLongPressed)];
    
    [self.theImageView addGestureRecognizer:tapGesture];
    //[self.theImageView addGestureRecognizer:longPressGesture];
    
    self.theImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.theImageView];
    
    
    
    ContentRecordImage *imageRecord = (ContentRecordImage *)record;
    UIImage *image = imageRecord.image;
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width - 60;
    float f = image.size.width / screenWidth;
    float newWidth = image.size.width / f;
    float newHeight = image.size.height / f;
    self.newSize = CGSizeMake(newWidth, newHeight);
    [self.theImageView autoSetDimensionsToSize:self.newSize];
    
    [self.theImageView setImage:image];
    
}

/*- (void)setInfo:(NSDictionary *)info {
    UIImage *image = info[@"content"];
    self.theImageView.image = image;
    NSLog(@"Setting imageView");
    
    float screenWidth = [UIScreen mainScreen].bounds.size.width - 60;
    float f = image.size.width / screenWidth;
    float newWidth = image.size.width / f;
    float newHeight = image.size.height / f;
    self.newSize = CGSizeMake(newWidth, newHeight);
    
    [self.theImageView setImage:image];
}*/

- (void)imageViewTapped {
    [self.contentCellDelegate selectImageForCell:self];
}

- (void)updateConstraints {
    [NSLayoutConstraint autoSetPriority:UILayoutPriorityRequired forConstraints:^{
        [self.theImageView autoSetContentCompressionResistancePriorityForAxis:ALAxisVertical];
    }];
    
    
    [self.theImageView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    //[self.theImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:10];
//    [self.theImageView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:10];
//    [self.theImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:10];
//    [self.theImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
    
    [super updateConstraints];
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
