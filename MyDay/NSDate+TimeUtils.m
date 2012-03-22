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

@end
