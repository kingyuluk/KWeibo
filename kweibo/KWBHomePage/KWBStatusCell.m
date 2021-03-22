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

@property (nonatomic, strong, readonly) UILabel *publishInfoLabel;  // 发布者与发布时间
@property (nonatomic, strong, readonly) UILabel *contentLabel;
@property (nonatomic, strong, readonly) UIImageView  *statusImageView;
@property (nonatomic, strong, readonly) UIView       *avatarContainerView;
@property (nonatomic, strong, readonly) UIImageView  *avatarImageView;


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
    _publishInfoLabel = [[UILabel alloc] init];
    _publishInfoLabel.textColor = [UIColor lightGrayColor];
    _publishInfoLabel.font = [UIFont systemFontOfSize:10];
    _publishInfoLabel.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_publishInfoLabel];
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 70, 0)];
    _contentLabel.backgroundColor = WhiteColor;
    _contentLabel.textColor = LightFontColor;
    _contentLabel.font = [UIFont systemFontOfSize:16];
    _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _contentLabel.numberOfLines = 0;
    [self.contentView addSubview:_contentLabel];
    
    _statusImageView = [[UIImageView alloc] init];
    _statusImageView.contentMode = UIViewContentModeScaleAspectFit;
    _statusImageView.clipsToBounds = YES;
    [self.contentView addSubview:_statusImageView];
    
    _avatarContainerView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 40, - 20, 40, 40)];
    _avatarContainerView.layer.cornerRadius = _avatarContainerView.frame.size.width / 2;
    _avatarContainerView.clipsToBounds = YES;
    _avatarContainerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_avatarContainerView];
    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 2, 36, 36)];
    _avatarImageView.layer.cornerRadius = _avatarImageView.frame.size.width / 2;
    _avatarImageView.clipsToBounds = YES;
    [_avatarContainerView addSubview:_avatarImageView];
}

- (void)loadDataWithModel:(KWBStatusModel *)model {
    NSString * statusImageURL = model.original_pic ? : model.bmiddle_pic;
    if (statusImageURL) {
        __weak typeof(self) weakSelf = self;
        [_statusImageView kwb_setImageWithUrl:[[NSURL alloc] initWithString:statusImageURL] completion:^(UIImage * _Nonnull image, NSError * _Nonnull error) {
            __strong typeof(self) strongSelf = weakSelf;
            image = [image scaleImage:image toFit:kStatusCellWidth];
            if (image.size.height > SCREEN_HEIGHT / 4 * 3) {
                image = [image cropImage:CGRectMake(0, 0, kStatusCellWidth, SCREEN_HEIGHT / 4 * 3)];
            }
            model.imageViewHeight = image.size.height;
            dispatch_sync_in_mainqueue_safe(^{
                [strongSelf.statusImageView addRoundedCorners:UIRectCornerTopLeft | UIRectCornerTopRight withRadius:CGSizeMake(20.0, 20.0)];
                [strongSelf.statusImageView setImage:image];
            })
        }];
        [_statusImageView setFrame:CGRectMake(0, 0, kStatusCellWidth, model.imageViewHeight)];
    }
    else{
        _statusImageView.image = nil;
        [_statusImageView setFrame:CGRectMake(0, 0, 0, 0)];
    }
    
    [_avatarImageView kwb_setImageWithUrl:[[NSURL alloc] initWithString:model.user.profile_image_url]];
    
    _contentLabel.text = model.text;
    [_contentLabel sizeToFit];
    model.contentHeight = _contentLabel.frame.size.height;
    
    [self calculateCellHeight:model];
    
    [_contentLabel setFrame:CGRectMake(15, model.cellHeight - model.contentHeight - kPublishInfoLabelHeight - 75, SCREEN_WIDTH - 70, model.contentHeight)];
    
    _publishInfoLabel.text = [NSString stringWithFormat:@"%@  %@", model.user.screen_name, [NSString kwb_stringFormatWithDateString:model.created_at]];
    [_publishInfoLabel setFrame:CGRectMake(0, model.cellHeight - kPublishInfoLabelHeight - 65, SCREEN_WIDTH - 55, kPublishInfoLabelHeight)];
}

- (void)calculateCellHeight:(KWBStatusModel *)model{
    if (model.bmiddle_pic || model.original_pic) {
        model.cellHeight = model.imageViewHeight + model.contentHeight + kPublishInfoLabelHeight + 95;
    }else{
        model.cellHeight = model.contentHeight + kPublishInfoLabelHeight + 110;
    }
}

@end
