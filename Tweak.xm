#import <UIKit/UIKit.h>

#define kOverlayViewTag 6942069

@interface SBLockScreenDateViewController: UIViewController
-(void)_updateView;
@end

%hook SBLockScreenDateViewController

-(void)_updateView {
    %orig;
    
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    UIView *v = [self view];
    
    // you can also convert them
    if([[NSString stringWithFormat: @"%@", newDateString] isEqualToString: @"04:20"] || [[NSString stringWithFormat: @"%@", newDateString] isEqualToString: @"4:20"] || [[NSString stringWithFormat: @"%@", newDateString] isEqualToString: @"16:20"]) {
      UIImageView *snoopImageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/HighDate/s.jpg"]];
      snoopImageView.frame = v.superview.bounds;
      snoopImageView.tag = kOverlayViewTag;
      snoopImageView.contentMode = UIViewContentModeScaleAspectFill;

      if (![snoopImageView isDescendantOfView: v.superview.superview.superview]) {
        [v.superview.superview.superview insertSubview: snoopImageView atIndex: 0];
      }
    } else {
        // directly getting the view with the tag id doess not seem to work, it works for now, i'll look into this later
        for (UIView *view in v.superview.superview.superview.subviews) {
            if(view.tag == kOverlayViewTag) {
              [view removeFromSuperview];
            }
        }
    }
}

%end
