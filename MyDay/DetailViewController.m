//
//  DetailViewController.m
//  MyDay
//
//  Created by Stas Sviridenko on 22.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "NSDate+TimeUtils.h"

@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController
@synthesize uiDateSwitch;

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

- (void)updateView {
    [self.uiDate setTitle:[self.taskPartDate formatShort] forState:UIControlStateNormal];
    [self.uiTime setTitle:[self.taskPartTime formatTime] forState:UIControlStateNormal];
    
    if ([self.taskPartDate isSameDayWithDate:[NSDate date]]) {
        [uiDateSwitch setSelectedSegmentIndex:0];
    } else if ([self.taskPartDate isNextDayAfterDate:[NSDate date]]) {
        [uiDateSwitch setSelectedSegmentIndex:1];
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

        [self updateView];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 168, 320, 300)];
    
    UIBarButtonItem *buttonCancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelDateEdit)];
    UIBarButtonItem *spring = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *buttonDone = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneDateEdit)];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 32)];
    [toolbar setBarStyle:UIBarStyleBlackOpaque];
    [toolbar setItems:@[buttonCancel, spring, buttonDone]];
    [self.datePickerView addSubview:toolbar];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 32, 320, 320)];
    [self.datePickerView addSubview:datePicker];

    [self configureView];
}

- (void)viewDidUnload
{
    [self setUiDateSwitch:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    self.datePickerView = nil;
    
    self.uiTitle = nil;
    self.uiTime = nil;
    self.uiDate = nil;

    self.taskPartDate = nil;
    self.taskPartTime = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (IBAction)cancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)done {
    [self save];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)save {
    [self.detailItem setValue:self.uiTitle.text forKey:@"title"];

    NSCalendar *gregorian = [NSCalendar currentCalendar];
    NSDate *compiledDate = [gregorian dateByAddingComponents:[self.taskPartTime timeComponents] toDate:self.taskPartDate options:0];
    [self.detailItem setValue:compiledDate forKey:@"date"];
}

- (void)stylePickerForTime {
    UIDatePicker *picker = (UIDatePicker *)[[self.datePickerView subviews] objectAtIndex:1];
    picker.datePickerMode = UIDatePickerModeTime;
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
    [self stylePickerForDate];
    UIDatePicker *picker = (UIDatePicker *)[[self.datePickerView subviews] objectAtIndex:1];
    picker.date = self.taskPartDate;
    [self.view addSubview:self.datePickerView];
}

- (IBAction)changeTime {
    [self stylePickerForTime];
    UIDatePicker *picker = (UIDatePicker *)[[self.datePickerView subviews] objectAtIndex:1];
    picker.date = self.taskPartTime;
    [self.view addSubview:self.datePickerView];
}

- (IBAction)changeDateViaButton:(id)sender {
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
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
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

@end
