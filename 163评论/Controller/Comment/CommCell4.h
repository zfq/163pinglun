#import <UIKit/UIKit.h>

extern NSString *const kCommCellTypeOnlyOne;
extern NSString *const kCommCellTypeTop;
extern NSString *const kCommCellTypeMiddle;
extern NSString *const kCommCellTypeBottom;

@class Content;

@interface CommCell4 : UITableViewCell
{
    Content *_content;
}

@property (nonatomic,weak) UIView *panGestureView;

- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount fontSizeChanged:(BOOL)isChanged;
- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount forHeight:(CGFloat *)height fontSizeChanged:(BOOL)isChanged;
@end