//
//  KWBStatusCell.m
//  kweibo
//
//  Created by Kingyu on 2021/3/12.
//

#import "KWBStatusCell.h"
#import "NSString+KWBDateFormat.h"
#import "UIImageView+KWBImage.h"
#import "UIImage+KWBImage.h"
#import "UIView+KWBCorner.h"
#import "KWBUserModel.h"
#import "KWBStatusModel.h"

@interface KWBStatusCell()

@property (nonatomic, strong) UILabel                    *publishInfoLabel;  // 发布者与发布时间
@property (nonatomic, strong) UILabel                    *contentLabel;
@property (nonatomic, strong) UIImageView                *statusImageView;
@property (nonatomic, strong) UIView                     *avatarContainerView;
@property (nonatomic, strong) UIImageView                *avatarImageView;
@property (nonatomic ,strong) CAGradientLayer            *gradientLayer;

@property (nonatomic, strong) KWBStatusModel *currentModel;

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
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += kIntervelFromScreenLeft;
    frame.size.width -= (kIntervelFromScreenLeft * 2);
    frame.origin.y += 30;
    frame.size.height -= 50;
    [super setFrame:frame];
}

- (void)setupSubviews {
    self.publishInfoLabel = [[UILabel alloc] init];
    self.publishInfoLabel.textColor = [UIColor lightGrayColor];
    self.publishInfoLabel.font = [UIFont systemFontOfSize:10];
    self.publishInfoLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:self.publishInfoLabel];
    
    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.backgroundColor = WhiteColor;
    self.contentLabel.textColor = LightFontColor;
    self.contentLabel.font = [UIFont systemFontOfSize:16];
    self.contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.contentLabel.numberOfLines = 0;
    [self.contentView addSubview:self.contentLabel];
    
    self.statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kStatusCellWidth, SCREEN_HEIGHT / 4 * 3)];
    self.statusImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.statusImageView.clipsToBounds = YES;
    [self.statusImageView addRoundedCorners:UIRectCornerTopLeft | UIRectCornerTopRight withRadius:CGSizeMake(20.0, 20.0)];
    [self.contentView addSubview:self.statusImageView];
    
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.colors = @[(__bridge id)ColorClear.CGColor, (__bridge id)ColorBlackAlpha10.CGColor, (__bridge id)ColorBlackAlpha20.CGColor];
    self.gradientLayer.locations = @[@0.8, @0.9, @1.0];
    self.gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
    self.gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
    [self.statusImageView.layer addSublayer:self.gradientLayer];
    
    self.avatarContainerView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, - 20, 40, 40)];
    self.avatarContainerView.layer.cornerRadius = self.avatarContainerView.frame.size.width / 2;
    self.avatarContainerView.clipsToBounds = YES;
    self.avatarContainerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.avatarContainerView];
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 36, 36)];
    self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2;
    self.avatarImageView.clipsToBounds = YES;
    [self.avatarContainerView addSubview:self.avatarImageView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat contentWidth = kStatusCellWidth;
    CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(contentWidth, 9999)];
    if (self.currentModel.bmiddle_pic || self.currentModel.original_pic) {
        self.contentLabel.frame = CGRectMake(15, self.frame.size.height - contentSize.height - kPublishInfoLabelHeight - 30, kStatusCellWidth - 30, contentSize.height);
    }else{
        self.contentLabel.frame = CGRectMake(15, self.frame.size.height - contentSize.height - kPublishInfoLabelHeight - 30, kStatusCellWidth - 30, contentSize.height);
    }
    self.publishInfoLabel.frame = CGRectMake(0, self.frame.size.height - kPublishInfoLabelHeight - 15, SCREEN_WIDTH - 55, kPublishInfoLabelHeight);
}

- (CGSize)sizeThatFits:(CGSize)size{
    CGFloat contentWidth = kStatusCellWidth - 30;
    CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(contentWidth, 9999)];
    self.contentLabel.frame = CGRectMake(15, 0, contentWidth, contentSize.height);
    
    CGFloat imageHeight = 0;
    CGFloat cellHeight = 0;
    if (self.currentModel.bmiddle_pic || self.currentModel.original_pic) {
        imageHeight = self.statusImageView.image.size.height;
        cellHeight = imageHeight + contentSize.height + kPublishInfoLabelHeight + 90;
        self.gradientLayer.frame = CGRectMake(0, 0, kStatusCellWidth, imageHeight);
    } else{
        cellHeight = contentSize.height + kPublishInfoLabelHeight + 110;
    }
    self.statusImageView.frame = CGRectMake(0, 0, kStatusCellWidth, imageHeight);
    return CGSizeMake(kStatusCellWidth, cellHeight);
}

- (void)updateDataWithModel:(KWBStatusModel *)model {
    self.currentModel = model;
    if (self.currentModel.imageData) {
        UIImage *image = [UIImage imageWithData:self.currentModel.imageData];
        UIImage *scaleImage = [image scaleImage:image toFit:kStatusCellWidth];
        if (scaleImage.size.height > SCREEN_HEIGHT / 4 * 3) {
            scaleImage = [scaleImage cropImage:CGRectMake(0, 0, kStatusCellWidth, SCREEN_HEIGHT / 4 * 3)];
        }
        dispatch_sync_in_mainqueue_safe(^{
            [self.statusImageView setImage:scaleImage];
            self.statusImageView.hidden = NO;
        })
    }
    else{
        self.statusImageView.image = nil;
        self.statusImageView.hidden = YES;
    }
    
    [self.avatarImageView kwb_setImageWithUrl:[[NSURL alloc] initWithString:self.currentModel.user.profile_image_url]];
    self.contentLabel.text = self.currentModel.text;
    self.publishInfoLabel.text = [NSString stringWithFormat:@"%@  %@", self.currentModel.user.screen_name, [NSString kwb_stringFormatWithDateString:model.created_at]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.contentLabel.text = nil;
    self.publishInfoLabel.text = nil;
    self.avatarImageView.image = nil;
    self.statusImageView.hidden = YES;
}

@end
