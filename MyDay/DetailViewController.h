//
//  DetailViewController.h
//  MyDay
//
//  Created by Stas Sviridenko on 22.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate, UITextFieldDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UITextField *uiTitle;
@property (strong, nonatomic) IBOutlet UIButton *uiDate;
@property (strong, nonatomic) IBOutlet UIButton *uiTime;
@property (strong, nonatomic) IBOutlet UISegmentedControl *uiDateSwitch;

@property (strong, nonatomic) NSDate *taskPartDate;
@property (strong, nonatomic) NSDate *taskPartTime;

- (IBAction)cancel;
- (IBAction)done;
- (void)save;

- (IBAction)changeDate;
- (IBAction)changeTime;
- (IBAction)changeDateViaButton:(id)sender;

@end
