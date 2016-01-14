//
//  TestShareControllerViewController.m
//  163评论
//
//  Created by zhaofuqiang on 14-8-6.
//  Copyright (c) 2014年 zhaofuqiang. All rights reserved.
//

#import "TestShareControllerViewController.h"
#import "SocialSharing.h"

@interface TestShareControllerViewController ()

@end

@implementation TestShareControllerViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

- (IBAction)sendWB:(UIButton *)sender
{
    [[SocialSharing sharedInstance] sendWeiboWithText:@"第一条分享的微博" image:[UIImage imageNamed:@"tom.png"] completion:^(BOOL success) {
        if (success == YES) {
            NSLog(@"成功");
        } else {
            NSLog(@"失败");
        }
    }];
}

- (IBAction)sendTencent:(UIButton *)sender
{
    UIImage *tom = [UIImage imageNamed:@"tom"];
    [[SocialSharing sharedInstance] sendQQShareWithTitle:@"title" description:@"a lot of description" image:tom url:@"www.163pinglun.com"];
}

- (IBAction)capture:(id)sender
{
    
}

- (UIImage *)captureView:(UIView *)captureView rect:(CGRect)rect
{
    UIGraphicsBeginImageContextWithOptions(captureView.bounds.size, captureView.opaque, 0.0);
    [captureView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage *finalImage = [UIImage imageWithCIImage:CFBridgingRelease(CGImageCreateWithImageInRect([image CGImage], rect))];
    return finalImage;
}

- (UIImage *)captureScrollView:(UIScrollView *)scrollView{
    UIImage* image = nil;
    UIGraphicsBeginImageContext(scrollView.contentSize);
    {
        CGPoint savedContentOffset = scrollView.contentOffset;
        CGRect savedFrame = scrollView.frame;
        scrollView.contentOffset = CGPointZero;
        scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
        
        [scrollView.layer renderInContext: UIGraphicsGetCurrentContext()];
        image = UIGraphicsGetImageFromCurrentImageContext();
        
        scrollView.contentOffset = savedContentOffset;
        scrollView.frame = savedFrame;
    }
    UIGraphicsEndImageContext();
    
    if (image != nil) {
        return image;
    }
    return nil;
}

- (NSString *)savePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}
@end


