//
//  PostCell.m
//  163评论
//
//  Created by zhaofuqiang on 14-7-12.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "PostCell.h"
#import "Post.h"
#import "MacroDefinition.h"
#import "Masonry.h"

@interface PostCell()
{
   
}
@end
@implementation PostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //创建subView
        self.isFlip = YES;
        
        UIColor *highlightedColor = [UIColor whiteColor];
        
        _title = [[UILabel alloc] init];
        _title.textColor = [UIColor blackColor];
        _title.highlightedTextColor = highlightedColor;
        _title.font = [UIFont systemFontOfSize:16];
        _title.numberOfLines = 0;
        [self.contentView addSubview:_title];
        
        _time = [[UILabel alloc] init];
        _time.textColor = RGBCOLOR(170,170,170,1);
        _time.highlightedTextColor = highlightedColor;
        _time.font = [UIFont systemFontOfSize:8];
        [self.contentView addSubview:_time];
        
        _views = [[UILabel alloc] init];
        _views.textColor = RGBCOLOR(170,170,170,1);
        _views.highlightedTextColor = highlightedColor;
        _views.font = [UIFont systemFontOfSize:8];
        [self.contentView addSubview:_views];
        
        _excerpt = [[UILabel alloc] init];
        _excerpt.textColor = RGBCOLOR(85,85,85,1);
        _excerpt.highlightedTextColor = highlightedColor;
        _excerpt.font = [UIFont systemFontOfSize:12];
        _excerpt.numberOfLines = 0;
        [self.contentView addSubview:_excerpt];
        
        UIView *sv = self.contentView;
        CGFloat sw = SCREEN_WIDTH;
        CGFloat marginLeft = 15;
        _title.preferredMaxLayoutWidth = sw - 2 * marginLeft;
        [_title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(sv).offset(15);
            make.left.equalTo(sv).offset(marginLeft);
            make.right.equalTo(sv).offset(-marginLeft);
        }];
        
        [_time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_title.mas_bottom).offset(12);
            make.left.equalTo(_title);
            make.width.mas_equalTo(182);
            make.height.mas_equalTo(10);
        }];
        
        [_views mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_time);
            make.left.equalTo(_time.mas_right);
            make.width.mas_equalTo(64);
            make.height.mas_equalTo(10);
        }];
        
        _excerpt.preferredMaxLayoutWidth = _title.preferredMaxLayoutWidth;
        [_excerpt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_time.mas_bottom).offset(15);
            make.left.equalTo(sv).offset(marginLeft);
            make.right.equalTo(sv).offset(-marginLeft);
        }];
        
        UIView *separatorLine = [[UIView alloc] init];
        separatorLine.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [sv addSubview:separatorLine];
        [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_excerpt.mas_bottom).offset(15);
            make.left.right.equalTo(sv);
            make.height.mas_equalTo(1);
            make.bottom.equalTo(sv);
        }];
        
        //    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = RGBCOLOR(51,153,255,1.0f);
        self.selectedBackgroundView = backgroundView;
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

- (void)setPost:(Post *)post
{
    _post = post;
    _title.text = post.title;

    _time.text = post.date;
    
    _views.text = [NSString stringWithFormat:@"已有%ld人浏览",(long)post.views];
    _excerpt.text = post.excerpt;
}

static CATransform3D RTSpinKit3DRotationWithPerspective(CGFloat perspective,
                                                        CGFloat angle,
                                                        CGFloat x,
                                                        CGFloat y,
                                                        CGFloat z)
{
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = perspective;
    return CATransform3DRotate(transform, angle, x, y, z);
}

- (void)flip:(CALayer *)animLayer
{
    animLayer.anchorPoint = CGPointMake(0.5, 0.5);
    animLayer.anchorPointZ = 0.5;
    animLayer.shouldRasterize = YES;
    animLayer.rasterizationScale = [[UIScreen mainScreen] scale];
 
    //翻转
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    anim.repeatCount =1;
    anim.duration = 0.4;
    anim.timingFunctions = @[
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                             [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]
                             ];
    
    anim.values = @[                    
                    [NSValue valueWithCATransform3D:RTSpinKit3DRotationWithPerspective(1.0/120.0, M_PI_2, 1.0, 0.0,0.0)],
                    [NSValue valueWithCATransform3D:RTSpinKit3DRotationWithPerspective(1.0/120.0, M_PI_4, 1.0, 0.0, 0)],
                    [NSValue valueWithCATransform3D:RTSpinKit3DRotationWithPerspective(1.0/120.0, 0, 1.0, 0.0,0)],
                    [NSValue valueWithCATransform3D:RTSpinKit3DRotationWithPerspective(1.0/120.0, -M_PI_4/4, 1.0, 0.0,0)],
                    [NSValue valueWithCATransform3D:RTSpinKit3DRotationWithPerspective(1.0/120.0, 0, 1.0, 0.0,0)]
                   ];
    
    //透明度
    CABasicAnimation *fadeAnim = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fadeAnim.fromValue = [NSNumber numberWithFloat:0.2];
    fadeAnim.toValue = [NSNumber numberWithFloat:1.0];
    fadeAnim.duration = 0.4;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[anim,fadeAnim];
    group.duration = 0.4;
    [animLayer addAnimation:group forKey:nil];
}


@end
