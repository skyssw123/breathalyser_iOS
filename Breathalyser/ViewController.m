//
//  ViewController.m
//  Breathalyser
//
//  Created by Thomas Sin on 2017-02-25.
//  Copyright © 2017 sin. All rights reserved.
//

#import "ViewController.h"
#import "Breathalyser-Swift.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface ViewController ()

@end

@implementation ViewController
//@synthesize BigDialChart, TopDialChart1, TopDialChart2, BottomDialChart1, BottomDialChart2, BottomDialChart3;
//@synthesize LandBarChart;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //[self.label setFont:[UIFont fontWithName:@"System" size:1000]];
    
    
    [self updateBACValue:0.0];
    self.indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indicator.frame = CGRectMake(0.0, 0.0, 100.0, 100.0);
    self.indicator.center = self.view.center;
    NUBarChart* BarChart = nil;
    
    [BarChart setupWithFrame:BarChart.frame];
    [BarChart setBarDataSource:self];
    [BarChart setBarDelegate:self];
    
    
    //Connecting to Bluetooth
    self.cbcmQueue = dispatch_queue_create("com.sin.Breathalyser", DISPATCH_QUEUE_CONCURRENT);
    if (self.cm == nil) {
        self.cm = [[CBCentralManager alloc]initWithDelegate:self queue:(dispatch_get_main_queue())];
        self.cm.delegate = self;
    }
    
    
    
    MqttManager* mqttManager = [MqttManager sharedInstance];
    mqttManager.connectFromSavedSettings;
    
    if (MqttSettings.sharedInstance.isConnected) {
        mqttManager.delegate = self;
        mqttManager.connectFromSavedSettings;
    }
    
    //CBPeripheral* peripheral = [CBPeripheral alloc];
    //peripheral.name = @"Adafruit Bluefruit LE";
    //peripheral.state = CBPeripheralStateConnected;
    //peripheral
    //[self connectPeripheral:(CBPeripheral *)];
}

-(void) viewWillAppear:(BOOL)animated {
}

//CBCentralManagerDelegate Methods
-(void) centralManagerDidUpdateState:(CBCentralManager*) central {
    if(central.state == CBManagerStatePoweredOn)
    {
        [self.cm scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    }
    
}
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    if([peripheral.name  isEqual: @"Adafruit Bluefruit LE"])
    {
        peripheral.delegate = self;
        [self connectPeripheral:peripheral];
        
    }
    
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error reading characteristics: %@", [error localizedDescription]);
        return;
    }
    
    if (characteristic.value != nil) {
        dispatch_async(dispatch_get_main_queue(), ^(void){
            [self receiveData:characteristic.value];
        });
    }
}

- (void)receiveData:(NSData *)newData
{
    NSString* message = [[NSString alloc] initWithData:newData encoding:NSUTF8StringEncoding];
    [self.indicator stopAnimating];
    [self.indicator removeFromSuperview];
    [self.mask removeFromSuperview];
    if(message != NULL)
    {
        double number = [message doubleValue];
        self.bacValue = number/1000.0;
        [self updateBACValue:self.bacValue];
        [self.BigDialChart reloadDialWithAnimation:YES];
    }
}

- (void)sendUartMessage:(NSString*)message
{
    // MQTT publish to TX
    //MqttSettings* mqttSettings = MqttSettings.sharedInstance;
//    if(mqttSettings.isPublishEnabled) {
//        if (mqttSettings.getPublishTopic(MqttSettings.PublishFeed.TX.rawValue) != NULL) {
//            let qos = mqttSettings.getPublishQos(MqttSettings.PublishFeed.TX.rawValue)
//            MqttManager.sharedInstance.publish(message as String, topic: topic, qos: qos)
//        }
//    }
    
    // Send to uart
    //if (!wasReceivedFromMqtt || mqttSettings.subscribeBehaviour == .Transmit) {
    NSData* data = [message dataUsingEncoding:NSUTF8StringEncoding];
    if(self.currentPeripheral == nil)
        return;
    
    [self.currentPeripheral writeRawData:data];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    //self.currentPeripheral = peripheral;
    
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics)
    {
//        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:dfuServiceUUIDString]] || [characteristic.UUID isEqual:[CBUUID UUIDWithString:dfuControlPointCharacteristicUUIDString]] ||
//            [characteristic.UUID isEqual:[CBUUID UUIDWithString:dfuPacketCharacteristicUUIDString]] ||
//            [characteristic.UUID isEqual:[CBUUID UUIDWithString:dfuVersionCharacteritsicUUIDString]]) {
            // If it is, subscribe to it
            //6E400001-B5A3-F393-E0A9-E50E24DCCA9E
        
        
        
        
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        
            //TX
            if(characteristic != nil && [[characteristic.UUID UUIDString] isEqualToString:[@"6e400002-b5a3-f393-e0a9-e50e24dcca9e" uppercaseString]] )
            {
                self.currentPeripheral.txCharacteristic = characteristic;
                //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        
            if(characteristic != nil && [[characteristic.UUID UUIDString] isEqualToString:[@"6e400003-b5a3-f393-e0a9-e50e24dcca9e" uppercaseString]])
            {
                
                self.currentPeripheral.rxCharacteristic = characteristic;
                //[peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
       // }
    }
    
    peripheral.delegate = self;
//    if(peripheral.services)
//    {
//        [self peripheral:peripheral didDiscoverServices:nil];
//    }
//    else
//    {
//        [peripheral discoverServices:@[[CBUUID UUIDWithString:@"6e400002-b5a3-f393-e0a9-e50e24dcca9e"]]];
//    }
}


-(void) connectPeripheral:(CBPeripheral*)peripheral
{
        
        //Check if Bluetooth is enabled
        if(self.cm.state == CBCentralManagerStatePoweredOff) {
            return;
        }
        else {
            // Fallback on earlier versions
        }
        
        
        if (self.cm == nil) {
            //            println(self.description)
            return ;
        }
        
        self.cm.stopScan;
        
        
    //Connect
    self.currentPeripheral = [[BLEPeripheral alloc]initWithPeripheral:peripheral delegate:self];
    self.currentPeripheral.delegate = self;
    //self.cm.connectPeripheral(peripheral, options: [CBConnectPeripheralOptionNotifyOnDisconnectionKey: NSNumber(bool:true)])
    
    [self.cm connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:[NSNumber numberWithBool:TRUE]}];
    
    return;
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    
}


//Mqtt Manager
-(void) onMqttConnected{
    
}

-(void) onMqttDisconnected {
    
}

-(void) onMqttMessageReceived:(NSString*) message :(NSString*)topic {
    int a = 4;
}

-(void) onMqttError:(NSString*) message {
    
}









-(void)updateBACValue:(float) bacValue
{
    self.bacValue = bacValue;
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
        
    }
    else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight )
    {
        NSLog(@"Landscape!!!");
        
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    // initialize part ******************************* */
    
    [self.BigDialChart setupWithCount:1 TotalValue:190];
    [self.BigDialChart setChartDataSource:self];
    [self.BigDialChart setChartDelegate:self];
    [self.BigDialChart reloadDialWithAnimation:YES];
    
    
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
    [self updateBACValue:0.0];
    [self sendUartMessage:@"ELEPHANT"];
    [self.BigDialChart reloadDialWithAnimation:YES];
    
    
    self.mask = [[UIView alloc] initWithFrame:self.view.window.frame];
    [self.mask setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.78]];
    [self.view addSubview:self.mask];
    [self.view addSubview:self.indicator];
    [self.view bringSubviewToFront:self.indicator];
    self.indicator.hidden = NO;
    self.indicator.color = [UIColor whiteColor];
    [self.indicator startAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = TRUE;
}
@end
