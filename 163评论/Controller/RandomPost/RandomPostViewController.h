//
//  RandomPostViewController.h
//  163评论
//
//  Created by zhaofuqiang on 14-8-31.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RandomPostViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>

- (void)showRandomPostView;
- (void)dismissRandomPostView;

@end
