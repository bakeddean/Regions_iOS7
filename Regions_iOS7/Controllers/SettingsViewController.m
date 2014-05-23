//
//  SettingsViewController.m
//  Regions_iOS7
//
//  Created by Dean Woodward on 23/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import "SettingsViewController.h"

#define OVERLAY_SWITCH 11
#define LOCAL_NOTIFICATIONS_SWITCH 21
#define FORCE_QUIT_SWITCH 31

#define OVERLAY_KEY @"Overlay_default"
#define LOCAL_NOTIFICATIONS_KEY @"Local_notification_default"
#define FORCE_QUIT_KEY @"Force_quit_default"

@interface SettingsViewController ()

@property (nonatomic, weak) IBOutlet UISwitch *showOverlaysSwitch;

@end

@implementation SettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//------------------------------------------------------------------------------
// Set the settings switches according to the appropriate user default.
//------------------------------------------------------------------------------
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _showOverlaysSwitch.on = [defaults boolForKey:OVERLAY_KEY];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(UIBarButtonItem *)sender
{
}

//------------------------------------------------------------------------------
// Handle settings switch changes. Get the switch that changed and update
// the appropriate user default.
//------------------------------------------------------------------------------
- (IBAction)settingsSwitchValueChanged:(UISwitch *)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    switch (sender.tag) {
        case OVERLAY_SWITCH:
            [defaults setBool:sender.isOn forKey:OVERLAY_KEY];
        break;
        case LOCAL_NOTIFICATIONS_SWITCH:
            [defaults setBool:sender.isOn forKey:LOCAL_NOTIFICATIONS_KEY];
        break;
        case FORCE_QUIT_SWITCH:
            [defaults setBool:sender.isOn forKey:FORCE_QUIT_KEY];
        break;

        default:
        break;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
