//
//  MenuItem.h
//  163评论
//
//  Created by zhaofuqiang on 14-9-22.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MenuItem : NSObject

@property (nonatomic, weak, readonly) id target;
@property (nonatomic, assign, readonly) SEL action;
@property (nonatomic,assign) CGRect frame;
@property (nonatomic,copy,readonly) NSString *title;
@property (nonatomic,copy,readonly) NSString *imageName;
@property (nonatomic,assign) UIEdgeInsets titleEdageInsets;
@property (nonatomic,assign) UIEdgeInsets imageEdageInsets;

- (instancetype)initWithTitle:(NSString *)title titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
                        imageName:(NSString *)imageName imageEdgeInset:(UIEdgeInsets)imageEdgeInsets
                            frame:(CGRect)frame target:(id)target action:(SEL)action;
@end
