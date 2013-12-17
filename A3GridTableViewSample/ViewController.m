//
//  ViewController.m
//  A3GridTableViewSample
//
//  Created by Botond Kis on 28.09.12.
//  Copyright (c) 2012 AllAboutApps. All rights reserved.
//

#import "ViewController.h"

@interface ViewController (){
    NSMutableArray *numberOfRowsInSection;
    CGFloat dayheight;
}
@property (nonatomic, strong) UIImage *normalImage;
@property (nonatomic, strong)  UIImage *selectedImage;

@end

#define ITEMS 500

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // initialize Random Data
    numberOfRowsInSection = [[NSMutableArray alloc] init];
    for (int i = 0; i < ITEMS; i++) {
        [numberOfRowsInSection addObject:[NSNumber numberWithInt: arc4random()%60+1]];
    }
    
    dayheight = 1000.0f;
    
    // Initialize Grid View
    gridTableView = [[A3GridTableView alloc] initWithFrame:self.view.bounds];
    gridTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // images
    self.normalImage = [UIImage imageNamed:@"cellBG-normal"];
    self.normalImage = [self.normalImage  resizableImageWithCapInsets:UIEdgeInsetsMake(14, 16, 18, 16)];
    self.selectedImage = [UIImage imageNamed:@"cellBG-highlighted"];
    self.selectedImage = [self.selectedImage  resizableImageWithCapInsets:UIEdgeInsetsMake(14, 16, 18, 16)];
    
    // set datasource and delegate
    gridTableView.dataSource = self;
    gridTableView.delegate = self;
    
    // set paging
    gridTableView.pagingPosition = A3GridTableViewCellAlignmentCenter;
    gridTableView.gridTableViewPagingEnabled = YES;
    gridTableView.backgroundColor = [UIColor lightGrayColor];
    
    // scrolling
    gridTableView.directionalLockEnabled = YES;
    
    // add as subview
    [self.view addSubview:gridTableView];
    [self.view sendSubviewToBack:gridTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload {
    [self setButtonReload:nil];
    [super viewDidUnload];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

//===========================================================================================
#pragma mark - DataSource

// Data handling
- (NSInteger)numberOfSectionsInA3GridTableView:(A3GridTableView *)aGridTableView{
    return ITEMS;
}

- (NSInteger)A3GridTableView:(A3GridTableView *) aGridTableView numberOfRowsInSection:(NSInteger) section{
    NSNumber *n = numberOfRowsInSection[section];
    return [n integerValue];
}

// header handling
- (A3GridTableViewCell *)A3GridTableView:(A3GridTableView *)aGridTableView headerForSection:(NSInteger)section{
    A3GridTableViewCell *headerCell;
    
    headerCell = [aGridTableView dequeueReusableHeaderWithIdentifier:@"headerID"];
    
    if (!headerCell) {
        headerCell = [[A3GridTableViewCell alloc] initWithReuseIdentifier:@"headerID"];
        UIImageView *normalBG = [[UIImageView alloc] initWithImage:self.normalImage];
        UIImageView *selectedBG = [[UIImageView alloc] initWithImage:self.selectedImage];
        headerCell.backgroundView = normalBG;
        headerCell.highlightedBackgroundView = selectedBG;
        
        headerCell.titleLabel.textAlignment = UITextAlignmentCenter;
        headerCell.backgroundView.backgroundColor = [UIColor clearColor];
    }
    
    headerCell.titleLabel.text = [NSString stringWithFormat:@"Header: %d", section];
    
    return headerCell;
}

- (CGFloat)heightForHeadersInA3GridTableView:(A3GridTableView *)aGridTableView{
    return 88.0f;
}

- (CGFloat)A3GridTableView:(A3GridTableView *)aGridTableView widthForSection:(NSInteger)section{
    return 300;
}



// Cell handling
- (A3GridTableViewCell *)A3GridTableView:(A3GridTableView *)aGridTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    A3GridTableViewCell *cell;
    cell = [aGridTableView dequeueReusableCellWithIdentifier:@"cellID"];
    
    if (!cell) {
        cell = [[A3GridTableViewCell alloc] initWithReuseIdentifier:@"cellID"];
        cell.backgroundColor = [UIColor clearColor];
        UIImageView *normalBG = [[UIImageView alloc] initWithImage:self.normalImage];
        UIImageView *selectedBG = [[UIImageView alloc] initWithImage:self.selectedImage];
        cell.backgroundView = normalBG;
        cell.highlightedBackgroundView = selectedBG;
    }
    cell.titleLabel.text = [NSString stringWithFormat:@"Cell: %d-%d", indexPath.section, indexPath.row];
    
    return cell;
}

- (CGFloat)A3GridTableView:(A3GridTableView *)aGridTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *n = numberOfRowsInSection[indexPath.section];
    return (int)(dayheight/n.integerValue);
}


//===========================================================================================
#pragma mark - Button Actions

- (IBAction)buttonReloadTouchUpInside:(id)sender {
    // Randomize height and reload Table    
    dayheight = (arc4random()%10+2)*1000;
    [gridTableView reloadCellsWithViewAnimation:YES];
}

@end
