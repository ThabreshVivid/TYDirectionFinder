//
//  RouteFinderViewController.h
//  MapkitAPI
//
//  Created by Thabresh on 8/9/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@interface RouteFinderViewController : UIViewController<UITextFieldDelegate,MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtFrom;
@property (weak, nonatomic) IBOutlet UITextField *txtTo;
@property (weak, nonatomic) IBOutlet MKMapView *mapShow;
@property (weak, nonatomic) IBOutlet UIButton *btnDirection;
@property (strong, nonatomic) IBOutlet UIView *popupDirect;
@property (weak, nonatomic) IBOutlet UITableView *directionTbl;

@end
