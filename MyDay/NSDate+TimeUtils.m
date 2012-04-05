//
//  NSDate+TimeUtils.m
//  MyDay
//
//  Created by Stas Sviridenko on 22.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "NSDate+TimeUtils.h"

@implementation NSDate (TimeUtils)

- (NSDateComponents *)timeComponents {
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:unitFlags fromDate:self];
}

- (NSDateComponents *)dateComponents {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar components:unitFlags fromDate:self];
}

- (BOOL)isSameDayWithDate:(NSDate *)date {
    NSDateComponents *myComponents = [self dateComponents];
    NSDateComponents *otherComponents = [date dateComponents];

    return [myComponents isEqual:otherComponents];
}

- (BOOL)isNextDayAfterDate:(NSDate *)date {
    NSCalendar *gregorian = [NSCalendar currentCalendar];

    NSDateComponents *aDay = [NSDateComponents new];
    aDay.day = 1;
    
    NSDate *tomorrow = [gregorian dateByAddingComponents:aDay toDate:date options:0];
    return [self isSameDayWithDate:tomorrow];
}

- (BOOL)isBeforeDate:(NSDate *)date {
    return [self compare:date] == NSOrderedAscending;
}

- (NSDate *)onlyTime {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateFromComponents:[self timeComponents]];
}

- (NSDate *)onlyDate {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    return [calendar dateFromComponents:[self dateComponents]];
}

- (NSString *)formatWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeStyle:timeStyle];
    [dateFormatter setDateStyle:dateStyle];

    [dateFormatter setLocale:[NSLocale currentLocale]];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)formatShort {
    return [self formatWithDateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)formatMiddle {
    return [self formatWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)formatTime {
    return [self formatWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)dateKind {
    NSDate *now = [NSDate date];
    if ([self compare:now] == NSOrderedAscending) return NSLocalizedString(@"Overdue", @"For tasks that are overdue");
    return [self isSameDayWithDate:now] ? NSLocalizedString(@"Today", @"Tasks for today") : [self formatMiddle];
}

@end
