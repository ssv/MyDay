//
//  MasterViewController.h
//  MyDay
//
//  Created by Stas Sviridenko on 22.03.12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (assign, nonatomic) BOOL completed;

- (IBAction)iconTapped:(id)sender;
- (IBAction)activeFilterSwitched:(id)sender;
- (void)showTaskForURI:(NSString *)objectURI;

- (void)refresh;

@end
