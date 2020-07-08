#import <UIKit/UIKit.h>

@interface PSSpecifier ()
- (id)propertyForKey:(NSString *)key;
@end

@protocol PSBaseView <NSObject>
- (void)setParentController:(id)parentController;
@end

@interface PSViewController ()
- (instancetype)initForContentSize:(CGSize)contentSize;
@end

@interface PSViewController (Legacy)
- (void)viewWillBecomeVisible:(void *)source;
@end

@interface PSListController ()
- (PSSpecifier *)specifierForID:(NSString *)identifier;
@end
