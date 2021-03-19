//
//  KWBStatusModel.m
//  kweibo
//
//  Created by Kingyu on 2021/3/15.
//

#import "KWBStatusModel.h"
#import "KWBStatusCell.h"

@implementation KWBStatusModel

- (CGFloat)cellHeight
{
    if(_cellHeight == 0){
        _cellHeight = [KWBStatusCell calculateCellHeight:self];
    }
    return _cellHeight;
}

@end
