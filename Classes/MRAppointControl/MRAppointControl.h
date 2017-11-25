//
//  MRAppointControl.h
//  Appoint
//
//  Created by MrXir on 2017/11/24.
//  Copyright © 2017年 MRXIR Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

/* 预约时间范围 */
typedef struct {
    int32_t begin;
    int32_t end;
} MRAppointTimeRange;

CG_INLINE MRAppointTimeRange
MRAppointTimeRangeMake(int32_t begin, int32_t end)
{
    MRAppointTimeRange range; range.begin = begin; range.end = end; return range;
}

UIKIT_EXTERN NSString *NSStringFromMRAppointTimeRange(MRAppointTimeRange range);

typedef void(^MatchSupportedAppointDatesCompletionBlock)(NSArray *dates);

@protocol MRAppointControlDataSource;

@protocol MRAppointControlDelegate;

IB_DESIGNABLE

/** 一个预约时间的控件，可以根据起始范围，工作日，营业时间来展示不同的可用选项，类似ZIROOM的预约功能 */
@interface MRAppointControl : UIControl

@property (nonatomic, strong, readonly) UIPickerView *pickerView;

@property (nonatomic, weak) id <MRAppointControlDataSource> dataSource;

@property (nonatomic, weak) id <MRAppointControlDelegate> delegate;

/** 需要提前预约的时长 单位：天 */
@property (nonatomic) int32_t numberOfServiceNeedAppointEarlyDays;

/** 接受预约的时间跨度 单位：天 */
@property (nonatomic) int32_t numberOfServiceAcceptAppointMaximumDays;

/** 接受预约的工作日 */
@property (nonatomic, strong) NSArray *serviceSupportedAppointmentWeekdays;

/** 服务商每天接受预约的时间段 */
@property (nonatomic) MRAppointTimeRange serviceSupportedAppointmentBusinessHours;

/** 每个小时的分段数 */
@property (nonatomic) int8_t numberOfNodeInHour;

/** 是否正在显示中 */
@property (nonatomic, getter=isDisplaying) BOOL displaying;

/** 当显示时重置 */
@property (nonatomic, getter=isResetWhenDisplay) BOOL resetWhenDisplay;

/** 可预约的最早日期 */
- (NSDate *)acceptableMinimumDate;

/** 可预约的最晚日期 */
- (NSDate *)acceptableMaximumDate;

/** 匹配支持的服务日期 */
- (void)matchSupportedAppointDateWithCompletionBlock:(MatchSupportedAppointDatesCompletionBlock)block;

- (void)showInView:(UIView *)view animated:(BOOL)animated;

- (void)dismissWithAnimated:(BOOL)animated;

@end

@protocol MRAppointControlDataSource <NSObject>

@required

/** 需要提前预约的时长 单位：天 */
- (int32_t)numberOfServiceNeedAppointEarlyDaysForAppointControl:(MRAppointControl *)appointControl;

/** 接受预约的时间跨度 单位：天 */
- (int32_t)numberOfServiceAcceptAppointMaximumDaysForAppointControl:(MRAppointControl *)appointControl;

/** 每个小时的分段数 */
- (int8_t)numberOfNodeInHourForAppointControl:(MRAppointControl *)appointControl;

/** 接受预约的工作日 */
- (NSArray *)serviceSupportedAppointmentWeekdaysForAppointControl:(MRAppointControl *)appointControl;

/** 服务商每天接受预约的时间段 */
- (MRAppointTimeRange)serviceSupportedAppointmentBusinessHoursForAppointControl:(MRAppointControl *)appointControl;

@end

@protocol MRAppointControlDelegate <NSObject>

@optional

/** 将要选择日期 */
- (void)appointControl:(MRAppointControl *)appointControl willSelectDate:(NSDate *)date;

@required

/** 已经选择日期 */
- (void)appointControl:(MRAppointControl *)appointControl didSelectDate:(NSDate *)date;

@end
