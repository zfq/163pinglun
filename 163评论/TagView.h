//
//  TagView.h
//  MyScrollTag
//
//  Created by zhaofuqiang on 14-10-23.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TagView : UIView
{
    UILabel *_tagLabel;
}
@property (nonatomic,strong) UILabel *tagLabel;
@property (nonatomic,assign) BOOL centerHorizontally; //水平居中 默认是YES
@property (nonatomic,assign) BOOL centerVertically; //垂直居中 默认是NO

- (instancetype)initWithString:(NSString *)tag;

@end
