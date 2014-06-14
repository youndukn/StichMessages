//
//  SMPublishTableViewController.m
//  StichMS
//
//  Created by Younduk Nam on 5/30/14.
//  Copyright (c) 2014 Younduk Nam. All rights reserved.
//

#import "SMPublishTableViewController.h"

#import "SMUtility.h"

@interface SMPublishTableViewController ()

@property (nonatomic,strong) UIBarButtonItem *backItem;

@end

@implementation SMPublishTableViewController

@synthesize backItem;
@synthesize imageArray;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //
    self.title = @"Removes";
    
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    //Mask Button
    UIBarButtonItem *barButton =[[UIBarButtonItem alloc]
                                 initWithTitle:@"Save It"
                                 style:UIBarButtonItemStyleBordered
                                 target:self
                                 action:@selector(doneAction:)];
    
    self.navigationItem.rightBarButtonItem = barButton;
    
    
    //
    self.tableView.separatorColor = [UIColor clearColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [imageArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIImage *image =  [imageArray objectAtIndex:indexPath.row];
    return (image.size.height+60.0f)/2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellID = @"ImageCell";
    
    // Try to dequeue a cell and create one if necessary
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if(!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [imageView setTag:1];
        cell.backgroundColor = [SMUtility gCancelColor];
        [cell addSubview:imageView];
    }
    UIImage *image = [self.imageArray objectAtIndex:indexPath.row];
    
    UIImageView *imageView = (UIImageView*)[cell viewWithTag:1];
    imageView.frame = CGRectMake(0, 0.0f, image.size.width/2, image.size.height/2);
    imageView.image = image;
    
    return cell;
}


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.imageArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.imageArray removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];

}

-(void)doneAction:(id)sender{
    
    NSArray *colorArray = [[NSArray alloc] initWithObjects:[SMUtility gMainColor],[SMUtility gChangeColor],[SMUtility gOverlayColor],[SMUtility gSubmitColor], nil];
    
    for(int i = 0; i < [imageArray count];i++){
        UILabel *label= [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        label.backgroundColor = [colorArray objectAtIndex:i%4];
        label.textColor = [UIColor whiteColor];
        label.text = [NSString stringWithFormat:@"%d",i+1];
        
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, label.opaque, 0.0);
        [label.layer renderInContext:UIGraphicsGetCurrentContext()];
        
        UIImage * numberImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        UIImage *image = [imageArray objectAtIndex:i];
        UIImageWriteToSavedPhotosAlbum(numberImage, nil, nil, nil);
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Picture is saved" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alert show];
}

@end
