//
//  TestViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-5-14.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "TestViewController.h"
#import "UILabel+VerticalAlignment.h"
#import "VerticalAlignmentLabel.h"
#define LABEL_COLOR [UIColor  colorWithRed:0.2f green:0.6f blue:1.0f alpha:1.0f] //3399FF
@interface TestViewController ()

@end

@implementation TestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    VerticalAlignmentLabel *label = [[VerticalAlignmentLabel alloc] initWithFrame:CGRectMake(100, 50, 200, 60)];
    label.backgroundColor = [UIColor redColor];
    label.text = @"网易浙江[疯狂的人]";
//    label.font = [UIFont systemFontOfSize:11];
    label.textColor = LABEL_COLOR;
//    label.frame = [label textRectForBounds:label.frame limitedToNumberOfLines:0];
    label.numberOfLines =1;
    [label setVerticalAlignment:VerticalAlignmentBottom];

//    [label sizeToFit];

    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
