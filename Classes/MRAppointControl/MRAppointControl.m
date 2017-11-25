//
//  MRAppointControl.m
//  Appoint
//
//  Created by MrXir on 2017/11/24.
//  Copyright © 2017年 MRXIR Inc. All rights reserved.
//

#import <UIView+SDAutoLayout.h>

#import "MRAppointControl.h"

CGFloat const k_controlHeight = 260.0f;

UIKIT_EXTERN  NSString *NSStringFromMRAppointTimeRange(MRAppointTimeRange range)
{
    return [NSString stringWithFormat:@"MRAppointTimeRange { begin: %d oclock, end: %d oclock }; Unit: 'hour'", range.begin, range.end];
}

@interface MRAppointControl ()<UIPickerViewDataSource, UIPickerViewDelegate, MRAppointControlDataSource>
{
    /** 工具条 */
    UIView *_topToolbar;
    
    /** 取消按钮 */
    UIButton *_cancelButton;
    
    /** 确认按钮 */
    UIButton *_confirmButton;
    
    /** 工具条顶线 */
    CAShapeLayer *_topToolbarToplineLayer;
    
    /** 工具条基线 */
    CAShapeLayer *_topToolbarBaselineLayer;
    
    /** 动画中 */
    BOOL _isAnimating;
    
    NSString *_dateComponent;
    
    NSString *_hourComponent;
    
    NSString *_minuteComponent;
    
    NSString *_dateHourMinuteDescription;
}

@property (nonatomic, strong) NSArray *matchedDates;

@end

@implementation MRAppointControl

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self setupSubviews];
    }
    return self;
}

// custom method
- (void)setupSubviews
{
    [self setupTopToolbar];
    
    [self setupPickerView];
    
    [self layoutSubviews];
}

// system method
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutTopToolbar];
    
    [self layoutPickerView];
}

#pragma mark - top toolbar

- (void)setupTopToolbar
{
    UIView *topToolbar = [[UIView alloc] init];
    [self addSubview:_topToolbar = topToolbar];
    
    [self setupCancelButton];
    
    [self setupConfirmButton];
    
    [self setupTopToolbarTopline];
    [self setupTopToolbarBaseline];
}

- (void)layoutTopToolbar
{
    _topToolbar.sd_layout.topSpaceToView(self, 0);
    _topToolbar.sd_layout.leftSpaceToView(self, 0);
    _topToolbar.sd_layout.rightSpaceToView(self, 0);
    _topToolbar.sd_layout.heightIs(50);
    
    [self layoutCancelButton];
    
    [self layoutConfirmButton];
    
    [self layoutTopToolbarTopline];
    [self layoutTopToolbarBaseline];
}

#pragma mark - cancel button

- (void)setupCancelButton
{
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_topToolbar addSubview:_cancelButton = cancelButton];
    
    [_cancelButton reversesTitleShadowWhenHighlighted];

    [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    
    [_cancelButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    [_cancelButton addTarget:self action:@selector(didClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutCancelButton
{
    _cancelButton.sd_layout.topSpaceToView(_topToolbar, 0);
    _cancelButton.sd_layout.leftSpaceToView(_topToolbar, 0);
    _cancelButton.sd_layout.bottomSpaceToView(_topToolbar, 0);
    _cancelButton.sd_layout.widthRatioToView(_topToolbar, 0.4);
    _cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    _cancelButton.contentEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 0);
}

#pragma mark - confirm button

- (void)setupConfirmButton
{
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [_topToolbar addSubview:_confirmButton = confirmButton];
    
    [_confirmButton reversesTitleShadowWhenHighlighted];
    
    [_confirmButton setTitle:@"确认" forState:UIControlStateNormal];
    
    [_confirmButton addTarget:self action:@selector(didClickConfirmButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)layoutConfirmButton
{
    _confirmButton.sd_layout.topSpaceToView(_topToolbar, 0);
    _confirmButton.sd_layout.rightSpaceToView(_topToolbar, 0);
    _confirmButton.sd_layout.bottomSpaceToView(_topToolbar, 0);
    _confirmButton.sd_layout.widthRatioToView(_topToolbar, 0.4);
    _confirmButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    _confirmButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
}

#pragma mark - line

- (void)setupTopToolbarTopline
{
    CAShapeLayer *topToolbarToplineLayer = [CAShapeLayer layer];
    topToolbarToplineLayer.fillColor = [UIColor groupTableViewBackgroundColor].CGColor;
    [_topToolbar.layer addSublayer:_topToolbarToplineLayer = topToolbarToplineLayer];
}

- (void)layoutTopToolbarTopline
{
    
    CGRect topBarToplineLayerFrame = CGRectMake(0,
                                                 0,
                                                 CGRectGetWidth(_topToolbar.layer.bounds),
                                                 0.5);
    
    _topToolbarToplineLayer.frame = topBarToplineLayerFrame;
    
    UIBezierPath *topToolbarToplineLayerPath = [UIBezierPath bezierPathWithRect:_topToolbarToplineLayer.bounds];
    _topToolbarToplineLayer.path = topToolbarToplineLayerPath.CGPath;
}

- (void)setupTopToolbarBaseline
{
    CAShapeLayer *topToolbarBaselineLayer = [CAShapeLayer layer];
    topToolbarBaselineLayer.fillColor = [UIColor groupTableViewBackgroundColor].CGColor;
    [_topToolbar.layer addSublayer:_topToolbarBaselineLayer = topToolbarBaselineLayer];
}

- (void)layoutTopToolbarBaseline
{
    
    CGRect topBarBaselineLayerFrame = CGRectMake(0,
                                                 CGRectGetHeight(_topToolbar.layer.bounds) - 0.5,
                                                 CGRectGetWidth(_topToolbar.layer.bounds),
                                                 0.5);
    
    _topToolbarBaselineLayer.frame = topBarBaselineLayerFrame;
    
    UIBezierPath *topToolbarBaselineLayerPath = [UIBezierPath bezierPathWithRect:_topToolbarBaselineLayer.bounds];
    _topToolbarBaselineLayer.path = topToolbarBaselineLayerPath.CGPath;
}

#pragma mark - picker view

- (void)setupPickerView
{
    UIPickerView *pickerView = [[UIPickerView alloc] init];
    [self addSubview:_pickerView = pickerView];
}

- (void)layoutPickerView
{
    _pickerView.sd_layout.topSpaceToView(_topToolbar, 0);
    _pickerView.sd_layout.leftSpaceToView(self, 0);
    _pickerView.sd_layout.bottomSpaceToView(self, 0);
    _pickerView.sd_layout.rightSpaceToView(self, 0);
}

#pragma mark - picker view data source

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component __TVOS_PROHIBITED
{
    if (component == 0) {
        return CGRectGetWidth(pickerView.bounds)*0.5f;
    } else if (component == 1) {
        return CGRectGetWidth(pickerView.bounds)*0.5f/3.0f;
    } else {
        return CGRectGetWidth(pickerView.bounds)*0.5f/3.0f*2.0f;
    }
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component __TVOS_PROHIBITED
{
    return 40.0f;
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return self.matchedDates.count;
    } else if (component == 1) {
        return [self hoursBetweenBeginAndEnd];
    } else {
        return self.numberOfNodeInHour;
    }
}

#pragma mark - picker view delegate

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED
{
    if (component == 0) {
        return  [self formattedDateDescriptionWithDate:self.matchedDates[row]];
    } else if (component == 1) {
        return [NSString stringWithFormat:@"%d%@", (unsigned)[self oclockForRow:row], @"点"];
    } else {
        return [NSString stringWithFormat:@"%02d%@", (unsigned)[self minuteForRow:row], @"分"];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSDate *date = [self currentSelectedDate];
    
    if ([self.delegate respondsToSelector:@selector(appointControl:willSelectDate:)]) {
        [self.delegate appointControl:self willSelectDate:date];
    }
    
}

#pragma mark - sign protocol

- (void)setDataSource:(id<MRAppointControlDataSource>)dataSource
{
    _dataSource = dataSource;
    
    self.numberOfServiceNeedAppointEarlyDays = [self numberOfServiceNeedAppointEarlyDaysForAppointControl:self];
    
    self.numberOfServiceAcceptAppointMaximumDays = [self numberOfServiceAcceptAppointMaximumDaysForAppointControl:self];
    
    self.serviceSupportedAppointmentWeekdays = [self serviceSupportedAppointmentWeekdaysForAppointControl:self];
    
    self.serviceSupportedAppointmentBusinessHours = [self serviceSupportedAppointmentBusinessHoursForAppointControl:self];
    
    self.numberOfNodeInHour = [self numberOfNodeInHourForAppointControl:self];
   
    __weak typeof(self) _self = self;
    
    [self matchSupportedAppointDateWithCompletionBlock:^(NSArray *dates) {
        
        _self.matchedDates = dates;
        
        _self.pickerView.dataSource = _self;
        _self.pickerView.delegate = _self;
        
    }];
    
}

#pragma mark - data source getter

- (int32_t)numberOfServiceNeedAppointEarlyDaysForAppointControl:(MRAppointControl *)appointControl
{
    return [self.dataSource numberOfServiceNeedAppointEarlyDaysForAppointControl:appointControl];
}

- (int32_t)numberOfServiceAcceptAppointMaximumDaysForAppointControl:(MRAppointControl *)appointControl
{
    return [self.dataSource numberOfServiceAcceptAppointMaximumDaysForAppointControl:appointControl];
}

- (int8_t)numberOfNodeInHourForAppointControl:(MRAppointControl *)appointControl
{
    return [self.dataSource numberOfNodeInHourForAppointControl:appointControl];
}

- (NSArray *)serviceSupportedAppointmentWeekdaysForAppointControl:(MRAppointControl *)appointControl
{
    return [self.dataSource serviceSupportedAppointmentWeekdaysForAppointControl:appointControl];
}

- (MRAppointTimeRange)serviceSupportedAppointmentBusinessHoursForAppointControl:(MRAppointControl *)appointControl
{
    return [self.dataSource serviceSupportedAppointmentBusinessHoursForAppointControl:appointControl];
}

#pragma mark - data source analyze

- (NSCalendar *)sharedCalendar
{
    static NSCalendar *s_calendar = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_calendar = [NSCalendar currentCalendar];
        [s_calendar setFirstWeekday:1];
    });
    return s_calendar;
}

/** 日历工作日对应转换 */
- (NSArray *)transferedSupportedWeekdays
{
    NSDictionary *weekdayTransferInfo = @{@"周日": @"1",
                                          @"周一": @"2",
                                          @"周二": @"3",
                                          @"周三": @"4",
                                          @"周四": @"5",
                                          @"周五": @"6",
                                          @"周六": @"7"};
    
    NSMutableArray *transferedWeekdays = [NSMutableArray array];
    
    [self.serviceSupportedAppointmentWeekdays enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *transferedWeekday = weekdayTransferInfo[obj];
        
        if (transferedWeekday) [transferedWeekdays addObject:transferedWeekday];
        
    }];

    return transferedWeekdays;
    
}

- (NSDate *)acceptableMinimumDate
{
    return [[self sharedCalendar] dateByAddingUnit:NSCalendarUnitDay
                                             value:self.numberOfServiceNeedAppointEarlyDays
                                            toDate:[NSDate date]
                                           options:0];
}

- (NSDate *)acceptableMaximumDate
{
    return [[self sharedCalendar] dateByAddingUnit:NSCalendarUnitDay
                                             value:self.numberOfServiceAcceptAppointMaximumDays
                                            toDate:[NSDate date]
                                           options:0];
}

- (void)matchSupportedAppointDateWithCompletionBlock:(MatchSupportedAppointDatesCompletionBlock)block
{
    __weak typeof(self) _self = self;
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
    NSMutableArray *supportedAppointDates = [NSMutableArray array];
    
    NSDate *acceptableMinimumDate = [self acceptableMinimumDate];
    
    NSDate *acceptableMaximumDate = [self acceptableMaximumDate];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        [[_self transferedSupportedWeekdays] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            dateComponents.weekday = [obj integerValue];
            
            [[_self sharedCalendar] enumerateDatesStartingAfterDate:acceptableMinimumDate matchingComponents:dateComponents options:NSCalendarMatchStrictly usingBlock:^(NSDate *date, BOOL exactMatch, BOOL *stop) {
                
                if ([date compare:acceptableMaximumDate] == NSOrderedAscending) {
                    [supportedAppointDates addObject:date];
                } else {
                    *stop = YES;
                }
                
            }];
            
        }];
        
        if (block != NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                block([supportedAppointDates sortedArrayUsingSelector:@selector(compare:)]);
            });
        }
        
    });
}

#pragma mark - tool

- (NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.dateFormat = @"yyyy-MM-dd HH-mm";
    
    return [dateFormatter dateFromString:dateString];
}

- (NSString *)dateFormattedDescriptionWithDate:(NSDate *)date
{
    static NSDateFormatter *s_dateFormatter = nil;
    if (!s_dateFormatter) {
        s_dateFormatter = [[NSDateFormatter alloc] init];
        s_dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    
    return [s_dateFormatter stringFromDate:date];
}

- (NSString *)formattedDateDescriptionWithDate:(NSDate *)date
{
    static NSDateFormatter *s_dateFormatter = nil;
    if (!s_dateFormatter) {
        s_dateFormatter = [[NSDateFormatter alloc] init];
        s_dateFormatter.dateFormat = @"M月d日 EEEE";
    }
    
    return [s_dateFormatter stringFromDate:date];
}

- (NSInteger)hoursBetweenBeginAndEnd
{
    return self.serviceSupportedAppointmentBusinessHours.end - self.serviceSupportedAppointmentBusinessHours.begin + 1;
}

- (NSInteger)oclockForRow:(NSInteger)row
{
    return self.serviceSupportedAppointmentBusinessHours.begin + row;
}

- (NSInteger)minuteForRow:(NSInteger)row
{
    static int8_t perNode = 0;
    if (!perNode) {
        perNode = 60 / self.numberOfNodeInHour;
    }
    
    return perNode * row;
}

- (NSDate *)currentSelectedDate
{
    _dateComponent = [self dateFormattedDescriptionWithDate:self.matchedDates[[self.pickerView selectedRowInComponent:0]]];
    
    _hourComponent = [NSString stringWithFormat:@"%02d", (unsigned)[self oclockForRow:[self.pickerView selectedRowInComponent:1]]];
    
    _minuteComponent = [NSString stringWithFormat:@"%02d", (unsigned)[self minuteForRow:[self.pickerView selectedRowInComponent:2]]];
    
    _dateHourMinuteDescription = [NSString stringWithFormat:@"%@ %@:%@", _dateComponent, _hourComponent, _minuteComponent];
    
    return [self dateFromString:_dateHourMinuteDescription];
}

#pragma mark - display life cycle

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    
    if (self.isDisplaying) return;
    
    if (self.isResetWhenDisplay) {
        
        for (int components =  0; components < self.pickerView.numberOfComponents; components++) {
            
            if ([self.pickerView numberOfRowsInComponent:components]) {
                [self.pickerView selectRow:0 inComponent:components animated:NO];
            }
            
        }
    }
    
    [view addSubview:self];
    
    self.sd_layout.bottomSpaceToView(view, 0);
    self.sd_layout.leftSpaceToView(view, 0);
    self.sd_layout.rightSpaceToView(view, 0);
    self.sd_layout.heightIs(k_controlHeight);
    
    if (_isAnimating) return;
    _isAnimating = YES;
    self.transform = CGAffineTransformMakeTranslation(0, k_controlHeight);
    
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:1.2 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.displaying = YES;
        _isAnimating = NO;
    }];
    
    
}

- (void)dismissWithAnimated:(BOOL)animated
{
    if (_isAnimating) return;
    _isAnimating = YES;
    [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:1.2 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.transform = CGAffineTransformMakeTranslation(0, k_controlHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.displaying = NO;
        _isAnimating = NO;
    }];
}

#pragma mark - button action

- (void)didClickCancelButton:(UIButton *)button
{
    [self dismissWithAnimated:YES];
}

- (void)didClickConfirmButton:(UIButton *)button
{
    NSDate *date = [self currentSelectedDate];
    
    [self.delegate appointControl:self didSelectDate:date];
    
    [self dismissWithAnimated:YES];
}

@end
