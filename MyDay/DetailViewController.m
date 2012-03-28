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

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.uiTitle.text = [[self.detailItem valueForKey:@"title"] description];

        NSDate *taskDate = [self.detailItem valueForKey:@"date"];
        self.taskPartDate = [taskDate onlyDate];
        self.taskPartTime = [taskDate onlyTime];

        self.uiDate.titleLabel.text = [self.taskPartDate formatShort];
        self.uiTime.titleLabel.text = [self.taskPartTime formatTime];
        
        if ([self.taskPartDate isSameDayWithDate:[NSDate date]]) {
            [uiDateSwitch setSelectedSegmentIndex:0];
        } else if ([self.taskPartDate isTomorrowForDate:[NSDate date]]) {
            [uiDateSwitch setSelectedSegmentIndex:1];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)viewDidUnload
{
    [self setUiDateSwitch:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
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

- (IBAction)changeDate {
    NSLog(@"changedate!");
}

- (IBAction)changeTime {
    NSLog(@"changetime!");
}

- (IBAction)changeDateViaButton:(id)sender {
    if ([(UISegmentedControl *)sender selectedSegmentIndex] == 0) {
        // today
        self.taskPartDate = [[NSDate date] onlyDate];
        self.uiDate.titleLabel.text = [self.taskPartDate formatShort];
    } else {
        // tomorrow
        NSCalendar *gregorian = [NSCalendar currentCalendar];
        NSDateComponents *aDay = [NSDateComponents new];
        aDay.day = 1;
        self.taskPartDate = [[gregorian dateByAddingComponents:aDay toDate:[NSDate date] options:0] onlyDate];
        self.uiDate.titleLabel.text = [self.taskPartDate formatShort];
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
