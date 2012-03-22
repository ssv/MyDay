//
//  DetailViewController.h
//  MyDay
//
//  Created by Stas Sviridenko on 22.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UITextField *uiTitle;
@property (strong, nonatomic) IBOutlet UILabel *uiDate;
@property (strong, nonatomic) IBOutlet UILabel *uiTime;

- (IBAction)cancel;
- (IBAction)done;
- (void)save;

@end
