//
//  KWBStatusCell.m
//  kweibo
//
//  Created by Kingyu on 2021/3/12.
//

#import "KWBStatusCell.h"
#import "NSString+KWBDateFormat.h"
#import "UIImageView+KWBImage.h"
#import "UIView+KWBCorner.h"

@interface KWBStatusCell()

@property (nonatomic, strong, readonly) UILabel *publishInfoLabel;  // 发布者与发布时间
@property (nonatomic, strong, readonly) UILabel *contentLabel;
@property (nonatomic, strong, readonly) UIImageView  *statusImageView;


@end


@implementation KWBStatusCell

const CGFloat kPublishInfoLabelHeight = 12.0;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        self.layer.cornerRadius = 20;
        self.layer.masksToBounds = YES;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = DarkGrayColor;
        [self initSubviews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    frame.origin.x += 20;
    frame.size.width -= 40;
    frame.origin.y += 10;
    frame.size.height -= 50;
    [super setFrame:frame];
}

- (void)initSubviews {
    _publishInfoLabel = [[UILabel alloc] init];
    _publishInfoLabel.textColor = [UIColor lightGrayColor];
    _publishInfoLabel.font = [UIFont systemFontOfSize:10];
    _publishInfoLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_publishInfoLabel];
    
    _contentLabel = [[UILabel alloc] init];
    _contentLabel.backgroundColor = DarkGrayColor;
    _contentLabel.textColor = FontColor;
    _contentLabel.font = [UIFont systemFontOfSize:16];
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _contentLabel.numberOfLines = 0;
    [self.contentView addSubview:_contentLabel];
    
    _statusImageView = [[UIImageView alloc] init];
    _statusImageView.contentMode = UIViewContentModeScaleAspectFill;
    _statusImageView.clipsToBounds = YES;
    [self.contentView addSubview:_statusImageView];
}

- (void)setDataWithModel:(KWBStatusModel *)model {
    CGFloat imageHeight = 0;
    if (model.bmiddle_pic) {
        imageHeight = SCREEN_HEIGHT / 3;

        [_statusImageView kwb_setImageWithUrl:[[NSURL alloc] initWithString:model.bmiddle_pic]];
        [_statusImageView setFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, imageHeight)];
    }
    else{
        _statusImageView.image = nil;
        [_statusImageView setFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    _contentLabel.text = model.text;
    [_contentLabel setFrame:CGRectMake(15, imageHeight + 10, SCREEN_WIDTH - 70, model.cellHeight - kPublishInfoLabelHeight - imageHeight - 80)];
    
    _publishInfoLabel.text = [NSString stringWithFormat:@"%@  %@", model.user[@"screen_name"], [NSString kwb_stringFormatWithDateString:model.created_at]];
    [_publishInfoLabel setFrame:CGRectMake(0, model.cellHeight - kPublishInfoLabelHeight - 65, SCREEN_WIDTH - 55, kPublishInfoLabelHeight)];
}

+ (CGFloat)calculateCellHeight:(KWBStatusModel *)model{
    CGFloat contentHeight = [model.text boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size.height;

    if (model.bmiddle_pic){
        return  contentHeight + kPublishInfoLabelHeight + 100 + SCREEN_HEIGHT / 3;
    }else{
        return  contentHeight + kPublishInfoLabelHeight + 100;
    }
}

@end
