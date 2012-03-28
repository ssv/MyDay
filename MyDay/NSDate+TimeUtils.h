//
//  NSDate+TimeUtils.h
//  MyDay
//
//  Created by Stas Sviridenko on 22.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface NSDate (TimeUtils)

- (BOOL)isSameDayWithDate:(NSDate *)date;
- (BOOL)isTomorrowForDate:(NSDate *)date;

- (NSString *)formatShort;
- (NSString *)formatMiddle;
- (NSString *)formatTime;

- (NSString *)dateKind;

- (NSDate *)onlyTime;
- (NSDate *)onlyDate;

- (NSDateComponents *)timeComponents;
- (NSDateComponents *)dateComponents;

@end
