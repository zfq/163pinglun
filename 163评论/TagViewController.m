//
//  TagViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-10-23.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "TagViewController.h"
#import "TagScrollView.h"
#import "ItemStore.h"
#import "Tag.h"
#import "Tags.h"

@interface TagViewController ()

@end

@implementation TagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TagScrollView *tagScrollView = [[TagScrollView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEITHT-64)];
    tagScrollView.leftMargin = 5;
    tagScrollView.rightMargin = 5;
    tagScrollView.topMargin = 5;
    tagScrollView.horizontalPadding = 5;
    tagScrollView.verticalPadding = 5;
    [self.view addSubview:tagScrollView];
    
    NSDictionary *colors = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tagColor" ofType:@"plist"]];
    
    __block NSMutableArray *tagViews;
    //获取数据
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [[ItemStore sharedItemStore] fetchTagsWithCompletion:^(Tags *tags, NSError *error) {
        if (error == nil) {
            __block Tag *tag = nil;
            tagViews = [NSMutableArray arrayWithCapacity:tags.tagItems.count];
            //创建tagView
            [tags.tagItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                tag = (Tag *)obj;
                TagView *view = [[TagView alloc] initWithString:tag.tagName]; //tag.tagName
                NSDictionary *dic = [colors objectForKey:[tag.tagID stringValue]];
                NSString *colorName = [dic objectForKey:@"color"];
                if (colorName == nil) {
                    view.tagLabel.textColor = [UIColor blackColor];
                }else {
                    view.tagLabel.textColor = [self colorFromHexStr:colorName];
                }
                view.frame = CGRectMake(0, 0, view.frame.size.width, 50);
                view.centerVertically = YES;
                [tagViews addObject:view];
            }];
            
            tagScrollView.tagViews = tagViews;
        }
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }];
}

- (UIColor *)colorFromHexStr:(NSString *)hexStr
{
    NSString *prefix = @"0x";
    NSString *r = [hexStr substringWithRange:NSMakeRange(0, 2)];
    NSString *g = [hexStr substringWithRange:NSMakeRange(2, 2)];
    NSString *b = [hexStr substringWithRange:NSMakeRange(4, 2)];
    
    unsigned int R = 0;
    unsigned int G = 0;
    unsigned int B = 0;
    
    [[NSScanner scannerWithString:[prefix stringByAppendingString:r]] scanHexInt:&R];
    [[NSScanner scannerWithString:[prefix stringByAppendingString:g]] scanHexInt:&G];
    [[NSScanner scannerWithString:[prefix stringByAppendingString:b]] scanHexInt:&B];
    
    return [UIColor colorWithRed:(float)R/255.0f green:(float)G/255.0f blue:(float)B/255.0f alpha:1.0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
