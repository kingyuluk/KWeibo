//
//  KWBStatusCell.m
//  kweibo
//
//  Created by Kingyu on 2021/3/12.
//

#import "KWBStatusCell.h"
#import "NSString+KWBDateFormat.h"
#import "UIImageView+KWBImage.h"
#import "UIImage+KWBImageView.h"
#import "UIView+KWBCorner.h"
#import "KWBUserModel.h"
#import "KWBStatusModel.h"

@interface KWBStatusCell()

@property (nonatomic, strong) UILabel *publishInfoLabel;  // 发布者与发布时间
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIImageView  *statusImageView;
@property (nonatomic, strong) UIView       *avatarContainerView;
@property (nonatomic, strong) UIImageView  *avatarImageView;

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
        self.contentLabel.frame = CGRectMake(15, self.frame.size.height - contentSize.height - kPublishInfoLabelHeight - 40, SCREEN_WIDTH - 70, contentSize.height);
    }else{
        self.contentLabel.frame = CGRectMake(15, self.frame.size.height - contentSize.height - kPublishInfoLabelHeight - 30, SCREEN_WIDTH - 70, contentSize.height);
    }
    self.publishInfoLabel.frame = CGRectMake(0, self.frame.size.height - kPublishInfoLabelHeight - 15, SCREEN_WIDTH - 55, kPublishInfoLabelHeight);
}

- (CGSize)sizeThatFits:(CGSize)size{
    CGFloat contentWidth = kStatusCellWidth;
    CGSize contentSize = [self.contentLabel sizeThatFits:CGSizeMake(contentWidth, 9999)];
    self.contentLabel.frame = CGRectMake(15, 0, SCREEN_WIDTH - 70, contentSize.height);
    
    CGFloat imageHeight = 0;
    if (self.currentModel.bmiddle_pic || self.currentModel.original_pic) {
        imageHeight = self.currentModel.imageViewHeight == 0 ? SCREEN_HEIGHT / 3 : self.currentModel.imageViewHeight;
    }
    self.statusImageView.frame = CGRectMake(0, 0, kStatusCellWidth, imageHeight);
    
    CGFloat cellHeight = imageHeight + contentSize.height + kPublishInfoLabelHeight + 110;
    return CGSizeMake(kStatusCellWidth, cellHeight);
}

- (void)updateDataWithModel:(KWBStatusModel *)model {
    self.currentModel = model;
    NSString * statusImageURL = model.original_pic ? : model.bmiddle_pic;
    if (statusImageURL) {
        NSURL *url = [[NSURL alloc] initWithString:statusImageURL];
        [self.statusImageView kwb_setImageWithUrl:url completion:^(UIImage * _Nonnull image, NSURLResponse * _Nullable response) {
            UIImage *scaleImage = [image scaleImage:image toFit:kStatusCellWidth];
            if (scaleImage.size.height > SCREEN_HEIGHT / 4 * 3) {
                scaleImage = [scaleImage cropImage:CGRectMake(0, 0, kStatusCellWidth, SCREEN_HEIGHT / 4 * 3)];
            }
            self.currentModel.imageViewHeight = scaleImage.size.height;
            dispatch_sync_in_mainqueue_safe(^{
                self.statusImageView.image = scaleImage;
                self.statusImageView.hidden = NO;
            })
        }];
    }
    else{
        self.statusImageView.image = nil;
        self.statusImageView.hidden = YES;
        self.currentModel.imageViewHeight = 0;
    }
    
    [self.avatarImageView kwb_setImageWithUrl:[[NSURL alloc] initWithString:self.currentModel.user.profile_image_url]];
    self.contentLabel.text = self.currentModel.text;
    self.publishInfoLabel.text = [NSString stringWithFormat:@"%@  %@", self.currentModel.user.screen_name, [NSString kwb_stringFormatWithDateString:model.created_at]];
}

@end
