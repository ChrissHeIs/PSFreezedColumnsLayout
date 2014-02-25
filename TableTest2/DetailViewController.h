//
//  DetailViewController.h
//  TableTest2
//
//  Created by Pavel Shestak on 1/29/14.
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
