//
//  SideViewController.h
//  ColorPallete
//
//  Created by Ishaan Singal on 30/8/13.
//  Copyright (c) 2013 ishaan.practise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideViewController : UITableViewController <UITableViewDelegate,
UITableViewDataSource>

//EFFECTS: sets the frame of the tableview of this controller
//MODIFIES: the frame of the tableview
- (void)setTablesFrame: (CGRect)thisTableFrame;

@end
