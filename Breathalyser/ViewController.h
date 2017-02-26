//
//  ViewController.h
//  Breathalyser
//
//  Created by Thomas Sin on 2017-02-25.
//  Copyright © 2017 sin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NuweScoreCharts/NuweScoreCharts.h>

@interface ViewController : UIViewController <NUDialChartDataSource, NUDialChartDelegate, NUBarChartDelegate, NUBarChartDataSource>

@property (strong, nonatomic) IBOutlet NUDialChart *BigDialChart;
@property (strong, nonatomic) IBOutlet NUDialChart *TopDialChart1;
@property (strong, nonatomic) IBOutlet NUDialChart *TopDialChart2;

@property (strong, nonatomic) IBOutlet NUDialChart *BottomDialChart1;
@property (strong, nonatomic) IBOutlet NUDialChart *BottomDialChart2;
@property (strong, nonatomic) IBOutlet NUDialChart *BottomDialChart3;

@property (strong, nonatomic) IBOutlet NUBarChart *LandBarChart;

@end
