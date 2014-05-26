//
//  MenuViewController.m
//  Regions_iOS7
//
//  Created by Dean Woodward on 26/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@property (weak, nonatomic) IBOutlet UIButton *polygonButton;
@property (weak, nonatomic) IBOutlet UIButton *circleButton;

@end

@implementation MenuViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.polygonButton.layer.borderWidth = 1.0f;
    self.polygonButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.polygonButton.layer.cornerRadius = 4.0f;
    
    self.circleButton.layer.borderWidth = 1.0f;
    self.circleButton.layer.borderColor = [UIColor whiteColor].CGColor;
    self.circleButton.layer.cornerRadius = 4.0f;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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
