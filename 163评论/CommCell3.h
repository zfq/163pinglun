#import <UIKit/UIKit.h>

extern NSString *const kCommCellTypeOnlyOne;
extern NSString *const kCommCellTypeTop;
extern NSString *const kCommCellTypeMiddle;
extern NSString *const kCommCellTypeBottom;

@class Content;

@interface CommCell3 : UITableViewCell
{
    Content *_content;
}

- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount height:(CGFloat *)height fontSizeChanged:(BOOL)isChanged;
- (void)bindContent:(Content *)content floorCount:(NSInteger)floorCount forHeight:(CGFloat *)height fontSizeChanged:(BOOL)isChanged;
@end