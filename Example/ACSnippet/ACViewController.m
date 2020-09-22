//
//  ACViewController.m
//  ACSnippet
//
//  Created by mrcrow on 09/22/2020.
//  Copyright (c) 2020 mrcrow. All rights reserved.
//

#import "ACViewController.h"
#import <ACSnippet/ACTileManager.h>

@interface ACViewController ()

@end

@implementation ACViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    ACTileManager *manager = [ACTileManager sharedManager];
    NSString *tileCode = [manager tileCodeWithZoom:19 atCoordinate:CLLocationCoordinate2DMake(39.893585, 116.452766)];
    NSLog(@"%@", tileCode);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
