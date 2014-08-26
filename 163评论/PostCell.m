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
   
}
@end
@implementation PostCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.isFlip = YES;
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    [super awakeFromNib];
    self.backgroundColor = [UIColor lightGrayColor];
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
    _views.text = [NSString stringWithFormat:@"%ld人浏览",(long)[post.views integerValue]];
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
    anim.duration = 0.3;
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
    fadeAnim.duration = 0.3;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[anim,fadeAnim];
    group.duration = 0.3;
    [animLayer addAnimation:group forKey:nil];
}


@end
