//
//  DateSelectViewController.h
//  daqin
//
//  Created by BurizaDo on 7/29/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DateSelectDelegate <NSObject>

- (void)handleDateChange:(NSDate*)date;

@end

@interface DateSelectViewController : UIViewController
@property(nonatomic, strong) id<DateSelectDelegate> delegate;
@property(nonatomic, weak) IBOutlet UIDatePicker* datePicker;
@end
