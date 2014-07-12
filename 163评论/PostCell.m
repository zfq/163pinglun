//
//  PostCell.m
//  163评论
//
//  Created by zhaofuqiang on 14-7-12.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "PostCell.h"
#import "Post.h"

@interface PostCell()
{
    CGFloat _height;
}
@end
@implementation PostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setPost:(Post *)post
{
    _post = post;
    _title.text = post.title;
    _views.text = [NSString stringWithFormat:@"%d人浏览",post.views];
    _excerpt.text = post.excerpt;
    
    [self initSubViews];
}

- (void)initSubViews
{
    CGFloat originViewsHeight = _excerpt.frame.size.height;
    _views.numberOfLines = 0;
    _views.lineBreakMode = NSLineBreakByCharWrapping;
    [_views sizeToFit];
    
    CGFloat deltaHeight = _excerpt.frame.size.height - originViewsHeight;
    _height = self.frame.size.height + deltaHeight;
}

- (CGFloat)height
{
    return _height;
}
@end
