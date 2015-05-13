#ifdef DEBUG
#define NSLog(FORMAT, ...) NSLog(@"[TokeTime: %s / %i] %@", __FILE__, __LINE__, [NSString stringWithFormat:FORMAT, ##__VA_ARGS__])

#else
#define NSLog(FORMAT, ...) do {} while (0);
#endif

#define kSnoopTag 133742069

@interface SBLockScreenView : UIView
@end

SBLockScreenView* _lsView = nil;

%hook SBLockScreenView
-(id)initWithFrame:(CGRect)arg1 {
    id r = %orig;
    if (r) {
        _lsView = r;
    }
    return r;
}
%end

%hook SBLockScreenDateViewController
-(void)_updateView {
    %log;
    %orig;

    //This gets called when the time changes
    //This will be our entry point for detecting 4:20 without doing any gross infinitely-running NSTimers
    NSDate* date = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *hourComp = [gregorian components:NSCalendarUnitHour fromDate:date];
    NSDateComponents *minuteComp = [gregorian components:NSCalendarUnitMinute fromDate:date];

    //this gives us a 24hr formatted time, so convert it to 12hr format for ease of programming
    int formattedHour = ([hourComp hour] >= 12) ? [hourComp hour] - 12 : [hourComp hour];
    int formattedMinute = [minuteComp minute];

    NSLog(@"Hour: %i", formattedHour);
    NSLog(@"Minute: %i", formattedMinute);

    if (formattedHour == 4 && formattedMinute == 20) {
        //smoke day every weed

        UIImageView* snoop = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:@"/Library/Application Support/TokeTime/snoop.png"]];
        snoop.frame = CGRectMake(-snoop.frame.size.width/4, snoop.frame.size.height/8, snoop.frame.size.width*0.9, snoop.frame.size.height*0.9);
        snoop.alpha = 0.0;
        snoop.tag = kSnoopTag;
        //add view at the back of the LS view
        [_lsView insertSubview:snoop atIndex:0];
        [UIView animateWithDuration:1.0 animations:^{
            snoop.alpha = 1.0;
        }];
    }
    else {
        //if we've added snoop to the view
        UIImageView* snoop = (UIImageView*)[_lsView viewWithTag:kSnoopTag];
        if (snoop != nil) {
            [UIView animateWithDuration:1.0 animations:^{
                snoop.alpha = 0.0;
            } completion:^(BOOL finished){
                if (finished) [snoop removeFromSuperview];
            }];
        }
    }
}
%end
