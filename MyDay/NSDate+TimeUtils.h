//
//  NSDate+TimeUtils.h
//  MyDay
//
//  Created by Stas Sviridenko on 22.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

@interface NSDate (TimeUtils)

- (BOOL)isSameDayWithDate:(NSDate *)date;
- (NSString *)formatSimple;
- (NSString *)dateKind;

@end
