//
//  SKViewController.m
//  SKButtons
//
//  Created by shrek wang on 12/22/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "SKViewController.h"

#import "SKButton.h"

@interface SKViewController ()

@property (weak, nonatomic) IBOutlet SKButton *button;

@end

@implementation SKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    [self.button becomeRoundIfPossible];
//    self.button.borderWidth = 1.0f;
//    self.button.borderColor = [UIColor redColor];
//    self.button.tintColor = [UIColor redColor];
}

@end
