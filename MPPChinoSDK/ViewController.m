//
//  ViewController.m
//  MPPChinoSDK
//
//  Created by Diego Flores Domenech on 10/17/16.
//  Copyright © 2016 MercadoPago. All rights reserved.
//

#import "ViewController.h"
#import "MPPChinoSDK-Swift.h"

@interface ViewController ()
@property(strong,nonatomic) MPPMagReader *magReader;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.magReader = [[MPPMagReader alloc] init];
    [self.magReader startReading];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end



