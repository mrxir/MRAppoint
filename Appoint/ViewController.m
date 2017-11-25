
//  ViewController.m
//  Appoint
//
//  Created by MrXir on 2017/11/23.
//  Copyright © 2017年 MRXIR Inc. All rights reserved.
//

#import "ViewController.h"

#import "MRAppointControl.h"

#import <UIView+SDAutoLayout.h>

@interface ViewController ()<MRAppointControlDataSource, MRAppointControlDelegate>

@property (nonatomic, strong) MRAppointControl *appointControl;

@property (nonatomic, weak) IBOutlet UIButton *showHideButton;

@end

@implementation ViewController

- (void)showOrHide:(id)sender
{
    _appointControl.isDisplaying ? [_appointControl dismissWithAnimated:YES] : [_appointControl showInView:self.view animated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.appointControl = [[MRAppointControl alloc] init];
    _appointControl.dataSource = self;
    _appointControl.delegate = self;
    _appointControl.resetWhenDisplay = YES;
    
    [self.showHideButton addTarget:self action:@selector(showOrHide:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - data source

- (int32_t)numberOfServiceNeedAppointEarlyDaysForAppointControl:(MRAppointControl *)appointControl
{
    return 6;
}

- (int32_t)numberOfServiceAcceptAppointMaximumDaysForAppointControl:(MRAppointControl *)appointControl
{
    return 50;
}

- (int8_t)numberOfNodeInHourForAppointControl:(MRAppointControl *)appointControl
{
    return 2;
}

- (NSArray *)serviceSupportedAppointmentWeekdaysForAppointControl:(MRAppointControl *)appointControl
{
    return @[@"周一", @"周三", @"周五"];
}

- (MRAppointTimeRange)serviceSupportedAppointmentBusinessHoursForAppointControl:(MRAppointControl *)appointControl
{
    return MRAppointTimeRangeMake(9, 19);
}

#pragma mark - delegate

- (void)appointControl:(MRAppointControl *)appointControl willSelectDate:(NSDate *)date
{
    NSLog(@"willSelectDate %@", [self stringFromDate:date]);
}

- (void)appointControl:(MRAppointControl *)appointControl didSelectDate:(NSDate *)date
{
    NSLog(@"didSelectDate %@", [self stringFromDate:date]);
}

#pragma mark - tool

- (NSString *)stringFromDate:(NSDate *)date
{
    static NSDateFormatter *dateFormatter = nil;
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy年MM月dd日 EEEE HH时mm分ss秒";
    }
    
    return [dateFormatter stringFromDate:date];
}

@end
