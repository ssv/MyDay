//
//  DetailViewController.m
//  MyDay
//
//  Created by Stas Sviridenko on 22.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DetailViewController.h"
#import "NSDate+TimeUtils.h"
#import "AppDelegate.h"

#define ALERT_NO    -1l
#define ALERT_5_MIN 5*60l
#define ALERT_HOUR  60*60l
#define ALERT_DAY   24*60*60l

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController
@synthesize uiDate;
@synthesize uiTime;
@synthesize datePickerView;
@synthesize uiTitle;
@synthesize uiDateSwitch;
@synthesize uiAlertSwitch;

@synthesize detailItem = _detailItem;
@synthesize masterPopoverController = _masterPopoverController;

@synthesize taskPartDate, taskPartTime;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

#pragma mark - Messing with views

- (void)updateView {
    [self.uiDate setTitle:[self.taskPartDate formatShort] forState:UIControlStateNormal];
    [self.uiTime setTitle:[self.taskPartTime formatTime] forState:UIControlStateNormal];
    
    if ([self.taskPartDate isSameDayWithDate:[NSDate date]]) {
        [uiDateSwitch setSelectedSegmentIndex:0];
    } else if ([self.taskPartDate isNextDayAfterDate:[NSDate date]]) {
        [uiDateSwitch setSelectedSegmentIndex:1];
    } else {
        [uiDateSwitch setSelectedSegmentIndex:-1];
    }
}

- (void)configureView
{
    // Update the user interface for the detail item.
    
    if (self.detailItem) {
        self.uiTitle.text = [[self.detailItem valueForKey:@"title"] description];

        NSDate *taskDate = [self.detailItem valueForKey:@"date"];
        self.taskPartDate = [taskDate onlyDate];
        self.taskPartTime = [taskDate onlyTime];
        
        long alert = [[self.detailItem valueForKey:@"alert"] longValue];

        switch (alert) {
            case ALERT_5_MIN:  // 5 minutes
                [self.uiAlertSwitch setSelectedSegmentIndex:1];
                break;

            case ALERT_HOUR: // 1 hour
                [self.uiAlertSwitch setSelectedSegmentIndex:2];
                break;
            
            case ALERT_DAY: // 1 day
                [self.uiAlertSwitch setSelectedSegmentIndex:3];
                break;
                
            default:
                [self.uiAlertSwitch setSelectedSegmentIndex:0];
                break;
        }
        
        [self updateView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 150, 320, 300)];
    
    UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDateEdit)];
    buttonCancel.title = NSLocalizedString(@"Cancel", @"Cancel");
    UIBarButtonItem *spring = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneDateEdit)];
    buttonDone.title = NSLocalizedString(@"Done", @"Done");
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar setItems:[NSArray arrayWithObjects:buttonCancel, spring, buttonDone, nil]];
    [self.datePickerView addSubview:toolbar];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 50, 320, 320)];
    [self.datePickerView addSubview:datePicker];

    [self configureView];
}

- (void)viewDidUnload
{
    [self setUiDateSwitch:nil];
    [self setUiAlertSwitch:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    self.datePickerView = nil;
    
    self.uiTitle = nil;
    self.uiTime = nil;
    self.uiDate = nil;
    self.uiAlertSwitch = nil;

    self.taskPartDate = nil;
    self.taskPartTime = nil;
}

- (void)viewDidAppear:(BOOL)animated {
    [self updateView];
    
    if ([[self.detailItem valueForKey:@"title"] isEqualToString:@""]) {
        [self.uiTitle becomeFirstResponder];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

#pragma mark - Editing content

- (IBAction)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done {
    [self save];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save {
    NSString *titleText = self.uiTitle.text;
    [self.detailItem setValue:titleText forKey:@"title"];

    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDate *compiledDate = [gregorian dateByAddingComponents:[self.taskPartTime timeComponents] toDate:self.taskPartDate options:0];
    [self.detailItem setValue:compiledDate forKey:@"date"];
    
    long alert;
    switch (self.uiAlertSwitch.selectedSegmentIndex) {
        case 1:
            alert = ALERT_5_MIN;
            break;

        case 2:
            alert = ALERT_HOUR;
            break;
        
        case 3:
            alert = ALERT_DAY;
            break;
            
        default:
            alert = ALERT_NO;
            break;
    }
    
    long oldAlert = [[self.detailItem valueForKey:@"alert"] longValue];

    // TODO date can be changed too!
    if (oldAlert != alert) {
        
        if (oldAlert != ALERT_NO) {
            NSArray *allNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
            NSArray *toDiscard = [allNotifications filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
                UILocalNotification *testedNotification = (UILocalNotification *)evaluatedObject;
                return [[[testedNotification userInfo] objectForKey:@"taskId"] isEqual:[self.detailItem objectID]];
            }]];
            for (UILocalNotification *notification in toDiscard) {
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
            }
        }

        if (alert != ALERT_NO) {
            UILocalNotification *notification = [UILocalNotification new];
            notification.alertBody = titleText;
            notification.alertAction = @"";
            notification.fireDate = [NSDate dateWithTimeInterval:-(double)alert sinceDate:compiledDate];
            [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        }
    }
    
    [self.detailItem setValue:[NSNumber numberWithLong:alert] forKey:@"alert"];

    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate saveContext];

}

#pragma mark - Date and time picker

- (void)stylePickerForTime {
    UIDatePicker *picker = (UIDatePicker *)[[self.datePickerView subviews] objectAtIndex:1];
    picker.datePickerMode = UIDatePickerModeTime;
    picker.minuteInterval = 10;
}

- (void)stylePickerForDate {
    UIDatePicker *picker = (UIDatePicker *)[[self.datePickerView subviews] objectAtIndex:1];
    picker.datePickerMode = UIDatePickerModeDate;
}

- (void)cancelDateEdit {
    [self.datePickerView removeFromSuperview];
}

- (void)doneDateEdit {
    UIDatePicker *picker = (UIDatePicker *)[[self.datePickerView subviews] objectAtIndex:1];
    
    if (picker.datePickerMode == UIDatePickerModeDate) {
        self.taskPartDate = [picker.date onlyDate];
    } else {
        self.taskPartTime = [picker.date onlyTime];
    }
    [self updateView];
    
    [self.datePickerView removeFromSuperview];
}

- (IBAction)changeDate {
    if ([uiTitle isFirstResponder])
        [uiTitle resignFirstResponder];
    
    [self stylePickerForDate];
    UIDatePicker *picker = (UIDatePicker *)[[self.datePickerView subviews] objectAtIndex:1];
    picker.date = self.taskPartDate;
    [self.view addSubview:self.datePickerView];
}

- (IBAction)changeTime {
    if ([uiTitle isFirstResponder])
        [uiTitle resignFirstResponder];

    [self stylePickerForTime];
    UIDatePicker *picker = (UIDatePicker *)[[self.datePickerView subviews] objectAtIndex:1];
    picker.date = self.taskPartTime;
    [self.view addSubview:self.datePickerView];
}

- (IBAction)changeDateViaButton:(id)sender {
    if ([uiTitle isFirstResponder])
        [uiTitle resignFirstResponder];

    if ([(UISegmentedControl *)sender selectedSegmentIndex] == 0) {
        // today
        self.taskPartDate = [[NSDate date] onlyDate];
        [self updateView];
    } else {
        // tomorrow
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *aDay = [NSDateComponents new];
        aDay.day = 1;
        self.taskPartDate = [[gregorian dateByAddingComponents:aDay toDate:[NSDate date] options:0] onlyDate];
        [self updateView];
    }
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (self.datePickerView.superview) {
        [self.datePickerView removeFromSuperview];
    }
    return YES;
}

@end
