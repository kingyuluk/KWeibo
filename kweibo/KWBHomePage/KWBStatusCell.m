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
#import "KWBUserModel.h"
#import "UIImage+KWBImageView.h"

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
        self.backgroundColor = WhiteColor;
        [self setupSubviews];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
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
    
    self.contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 70, 0)];
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

- (void)loadDataWithModel:(KWBStatusModel *)model {
    self.currentModel = model;
    NSString * statusImageURL = model.original_pic ? : model.bmiddle_pic;
    if (statusImageURL) {
        NSURL *url = [[NSURL alloc] initWithString:statusImageURL];
        [self.statusImageView kwb_setImageWithUrl:url completion:^(UIImage * _Nonnull image, NSURLResponse * _Nullable response) {
            UIImage *scaleImage = [image scaleImage:image toFit:kStatusCellWidth];
            if (scaleImage.size.height > SCREEN_HEIGHT / 4 * 3) {
                scaleImage = [scaleImage cropImage:CGRectMake(0, 0, kStatusCellWidth, SCREEN_HEIGHT / 4 * 3)];
            }
            model.imageViewHeight = scaleImage.size.height;
            dispatch_sync_in_mainqueue_safe(^{
                self.statusImageView.image = scaleImage;
                self.statusImageView.hidden = NO;
            })
        }];
    }
    else{
        self.statusImageView.image = nil;
        self.statusImageView.hidden = YES;
        model.imageViewHeight = 0;
    }
    [self.avatarImageView kwb_setImageWithUrl:[[NSURL alloc] initWithString:model.user.profile_image_url]];
    
    self.contentLabel.text = model.text;
    [self.contentLabel sizeToFit];
    model.contentHeight = self.contentLabel.frame.size.height;
    
    [self calculateCellHeight:model];
    
    [self.contentLabel setFrame:CGRectMake(15, model.cellHeight - model.contentHeight - kPublishInfoLabelHeight - 75, SCREEN_WIDTH - 70, model.contentHeight)];
    
    self.publishInfoLabel.text = [NSString stringWithFormat:@"%@  %@", model.user.screen_name, [NSString kwb_stringFormatWithDateString:model.created_at]];
    [self.publishInfoLabel setFrame:CGRectMake(0, model.cellHeight - kPublishInfoLabelHeight - 65, SCREEN_WIDTH - 55, kPublishInfoLabelHeight)];
}

//+ (CGFloat)calculateCellHeight:(KWBStatusModel *)model{
//    if (model.bmiddle_pic || model.original_pic) {
//        CGFloat imageHeight = model.imageViewHeight == 0 ? SCREEN_HEIGHT / 3 : model.imageViewHeight;
//        return imageHeight + model.contentHeight + kPublishInfoLabelHeight + 95;
//    }else{
//        return model.contentHeight + kPublishInfoLabelHeight + 110;
//    }
//}

- (void)calculateCellHeight:(KWBStatusModel *)model{
    if (model.bmiddle_pic || model.original_pic) {
        CGFloat imageHeight = model.imageViewHeight == 0 ? SCREEN_HEIGHT / 3 : model.imageViewHeight;
        model.cellHeight = imageHeight + model.contentHeight + kPublishInfoLabelHeight + 95;
    }else{
        model.cellHeight = model.contentHeight + kPublishInfoLabelHeight + 110;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    if(self.currentModel.imageViewHeight == 0){
//        self.statusImageView.frame = CGRectMake(0, 0, kStatusCellWidth, SCREEN_HEIGHT / 3);
//    }else{
//        self.statusImageView.frame = CGRectMake(0, 0, kStatusCellWidth, self.currentModel.imageViewHeight);
//    }
    
    self.statusImageView.frame = CGRectMake(0, 0, kStatusCellWidth, self.currentModel.imageViewHeight);
}

@end
