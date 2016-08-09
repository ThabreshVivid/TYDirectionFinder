//
//  TYPlaceSearchViewController.h
//  MapkitAPI
//
//  Created by Thabresh on 8/9/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TYGooglePlace.h"
@class TYPlaceSearchViewController;

@protocol TYPlaceSearchViewControllerDelegate <NSObject>

-(void)searchViewController:(TYPlaceSearchViewController *)controller didReturnPlace:(TYGooglePlace *)place;


@end
@interface TYPlaceSearchViewController : UIViewController

@property (nonatomic) id<TYPlaceSearchViewControllerDelegate> delegate;

@end
