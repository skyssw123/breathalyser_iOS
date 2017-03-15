//
//  ViewController.h
//  Breathalyser
//
//  Created by Thomas Sin on 2017-02-25.
//  Copyright © 2017 sin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NuweScoreCharts/NuweScoreCharts.h>
#import "Breathalyser-Swift.h"


@interface ViewController : UIViewController <NUDialChartDataSource, NUDialChartDelegate, NUBarChartDelegate, NUBarChartDataSource, CBCentralManagerDelegate, MqttManagerDelegate, BLEPeripheralDelegate>
- (IBAction)buttonPressed:(UIButton *)sender;

@property (strong, nonatomic) IBOutlet NUDialChart *BigDialChart;
@property (strong, nonatomic) IBOutlet NUDialChart *TopDialChart1;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) IBOutlet NUDialChart *TopDialChart2;

@property (strong, nonatomic) IBOutlet NUDialChart *BottomDialChart1;
@property (strong, nonatomic) IBOutlet NUDialChart *BottomDialChart2;
@property (strong, nonatomic) IBOutlet NUDialChart *BottomDialChart3;
@property(nonatomic, assign) double bacValue;
@property (strong, nonatomic) IBOutlet NUBarChart *LandBarChart;


@property (strong, nonatomic) CBCentralManager* cm;
@property (strong, nonatomic) dispatch_queue_t cbcmQueue;
@property (strong, nonatomic) BLEPeripheral* currentPeripheral;

-(void)receiveData:(NSData*)data;
- (UIColor *)colorFromHexString:(NSString *)hexString;
@end
