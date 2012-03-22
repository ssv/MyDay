//
//  NSDate+TimeUtils.m
//  MyDay
//
//  Created by Stas Sviridenko on 22.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//


#import "NSDate+TimeUtils.h"

@implementation NSDate (TimeUtils)

- (BOOL)isSameDayWithDate:(NSDate *)date {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *myComponents = [calendar components:unitFlags fromDate:self];
    NSDateComponents *otherComponents = [calendar components:unitFlags fromDate:date];

    return [myComponents isEqual:otherComponents];
}

- (NSDate *)onlyTime {
    unsigned unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *myComponents = [calendar components:unitFlags fromDate:self];
    return [calendar dateFromComponents:myComponents];
}

- (NSDate *)onlyDate {
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *myComponents = [calendar components:unitFlags fromDate:self];
    return [calendar dateFromComponents:myComponents];
}

- (NSString *)formatWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle {
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setTimeStyle:timeStyle];
    [dateFormatter setDateStyle:dateStyle];

    [dateFormatter setLocale:[NSLocale currentLocale]];
    return [dateFormatter stringFromDate:self];
}

- (NSString *)formatSimple {
    return [self formatWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
}

- (NSString *)formatTime {
    return [self formatWithDateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
}

- (NSString *)dateKind {
    NSDate *now = [NSDate date];
    if ([self compare:now] == NSOrderedAscending) return @"Overdue";
    return [self isSameDayWithDate:now] ? @"Today" : [self formatSimple];
}

@end
