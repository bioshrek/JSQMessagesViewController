//
//  SKViewController.m
//  SKToolbarDemo
//
//  Created by shrek wang on 3/31/15.
//  Copyright (c) 2015 Hexed Bits. All rights reserved.
//

#import "SKViewController.h"

#import "SKDemoToolbar.h"

@interface SKViewController () <UITableViewDataSource, SKToolbarKeyboardDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (weak, nonatomic) IBOutlet SKDemoToolbar *toolbar;

@property (assign, nonatomic) UIEdgeInsets originalScrollViewContentInsets;
@property (assign, nonatomic) UIEdgeInsets originalScrollViewIndicatorInsets;

@end

@implementation SKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.tableView.dataSource = self;
    
    // toolbar
    UITextView *textView = self.toolbar.contentView.textView;
    [self.toolbar configWithTextView:textView adjustToolbarHeightWhenTextViewContentSizeChange:YES contextView:self.view scrollView:self.tableView topLayoutGuide:self.topLayoutGuide bottomLayoutGuide:self.bottomLayoutGuide panGestureRecognizer:self.tableView.panGestureRecognizer delegate:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.toolbar beginListeningForKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.toolbar endListeningForKeyboard];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 99;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = @"shrek wang";
    
    return cell;
}

- (void)keyboardDidChangeFrame:(CGRect)keyboardFrame
{
   
}


@end
