//
//  ViewController.m
//  Breathalyser
//
//  Created by Thomas Sin on 2017-02-25.
//  Copyright © 2017 sin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize BigDialChart, TopDialChart1, TopDialChart2, BottomDialChart1, BottomDialChart2, BottomDialChart3;
@synthesize LandBarChart;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //[self.label setFont:[UIFont fontWithName:@"System" size:1000]];
    
    [self updateBACValue];
    
    NUBarChart* BarChart = nil;
    
    [BarChart setupWithFrame:BarChart.frame];
    [BarChart setBarDataSource:self];
    [BarChart setBarDelegate:self];
}

-(void)updateBACValue
{
    self.bacValue = [self randomFloatBetween:0.0 and:0.19];
    self.label.text = [NSString stringWithFormat:@"%.3f %%", self.bacValue];
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown
    | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    NSLog(@"to orientation = %d", (int)toInterfaceOrientation);
    
    if ( toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown )
    {
        NSLog(@"Portrait!!!");
        
        LandBarChart.hidden = YES;
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight )
    {
        NSLog(@"Landscape!!!");
        
        LandBarChart.hidden = NO;
        [LandBarChart reloadDialWithAnimation:YES];
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    // initialize part ******************************* */
    
    [BigDialChart setupWithCount:1 TotalValue:190];
    [BigDialChart setChartDataSource:self];
    [BigDialChart setChartDelegate:self];
    [BigDialChart reloadDialWithAnimation:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma NUDialChart Datasource
- (NSNumber*) dialChart:(NUDialChart*) dialChart valueOfCircleAtIndex:(int) _index
{
    
    //my input
    //randomNumber = 50;
    
    int a = self.bacValue * 1000;
    return [NSNumber numberWithInteger: a];
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}


/* Get a color of specific dial by index
 @param : Index of specific dial
 @return : Color of the dial
 */
- (UIColor* ) dialChart:(NUDialChart*) dialChart colorOfCircleAtIndex:(int) _index
{
    //my input
    //return [UIColor blackColor];
    if(_index == 0 && self.bacValue > 0.07)
        return [UIColor redColor];
    
    
    else if(_index == 0 && self.bacValue <= 0.07)
        return [self colorFromHexString:@"#006400"];
    
    //if(_index == 1)
    //    return [UIColor yellowColor];
    
    //if(_index == 2)
    //    return [UIColor whiteColor];
    
    
    
    //return [UIColor colorWithRed:(float)(arc4random() % 255) / 255.0f green:(float)(arc4random() % 255) / 255.0f blue:(float)(arc4random() % 255) / 255.0f alpha:1.0f];
    
    return [UIColor greenColor];
}


/* Get a text of specific dial by index
 @param : Index of specific dial
 @return : Text of the dial
 */ // It's for just Nutribu
- (NSString* ) dialChart:(NUDialChart*) dialChart textOfCircleAtIndex:(int) _index
{
    //my input
    if(_index == 0 && self.bacValue > 0.07)
    return [NSString stringWithFormat:@"  You are not allowed to drive.."];
    
    else
        return NULL;
    return [NSString stringWithFormat:@"test message"];
}

- (UIColor* ) dialChart:(NUDialChart*) dialChart textColorOfCircleAtIndex:(int) _index
{
    
    return [UIColor whiteColor];
}

/* Show center label and text
 @param : No params
 @return : Is show center label?
 */
- (BOOL) isShowCenterLabelInDial:(NUDialChart*) dialChart
{
    if ( dialChart == BottomDialChart1 || dialChart == BottomDialChart3)
        return NO;
    return YES;
}

/* Show only border of dial
 @param : Index of specific dial
 @return : Is only frame of dial?
 */
- (BOOL) dialChart:(NUDialChart*) dialChart defaultCircleAtIndex:(int) _index
{
    //if ( _index == 3 )
    //    return YES;
    
    return NO;
}

/* Get current nuscore
 @param : No params
 @return : NU score
 */
- (int) nuscoreInDialChart:(NUDialChart*) dialChart
{
    //my
    return 0.08;
    return (arc4random() % 100);
}

- (UIColor*) centerBackgroundColorInDialChart:(NUDialChart *)dialChart
{
    return [UIColor blackColor];
    return [UIColor blueColor];
}

- (UIColor*) centerTextColorInDialChart:(NUDialChart *)dialChart
{
    return [UIColor blackColor];
    return [UIColor whiteColor];
}


#pragma mark - NUDialChart Delegate

- (void) touchNuDialChart:(NUDialChart *)chart
{
    //if ( chart == BigDialChart ){
    //    [BigDialChart reloadDialWithAnimation:YES];
    //}
}

#pragma mark - NUBarChart Delegates and DataSource

- (void) touchNUBar:(NUBarChart *)barChart index:(int)_index
{
    NSLog(@"touch bar index = %d", _index);
}


- (NSArray*) valuesOfYWithBarChart:(NUBarChart *)barChart
{
    NSArray* yValues = @[@10, @20, @30, @40, @50, @20, @30, @10, @40, @20, @35, @45, @10, @50, @20, @50, @10, @10, @25, @10];
    return yValues;
}


- (NSArray*) barColorsWithBarChart:(NUBarChart *)barChart
{
    NSArray* barColors = [NSArray arrayWithObjects:APP_COLOR_BLUE, APP_COLOR_RED, APP_COLOR_BLUE, APP_COLOR_BLUE, APP_COLOR_BLUE,APP_COLOR_BLUE, APP_COLOR_RED, APP_COLOR_BLUE, APP_COLOR_BLUE, APP_COLOR_BLUE,APP_COLOR_BLUE, APP_COLOR_RED, APP_COLOR_BLUE, APP_COLOR_BLUE, APP_COLOR_BLUE,APP_COLOR_BLUE, APP_COLOR_RED, APP_COLOR_BLUE, APP_COLOR_BLUE, APP_COLOR_BLUE, nil];
    return barColors;
}

- (int) maxYValueWithBarChart:(NUBarChart *)barChart
{
    return 90;
}

- (float)randomFloatBetween:(float)smallNumber and:(float)bigNumber {
    float diff = bigNumber - smallNumber;
    return (((float) (arc4random() % ((unsigned)RAND_MAX + 1)) / RAND_MAX) * diff) + smallNumber;
}

- (IBAction)buttonPressed:(UIButton *)sender {
    [self updateBACValue];
    [BigDialChart reloadDialWithAnimation:YES];
}
@end
