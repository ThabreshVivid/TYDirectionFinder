//
//  TYGoogleAutoCompleteResult.h
//  MapkitAPI
//
//  Created by Thabresh on 8/9/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface TYGoogleAutoCompleteResult : NSObject
@property (readonly) NSString *name;
@property (readonly) NSString *description;
@property (readonly) NSString *placeID;

@property (readonly) CLLocationCoordinate2D locationCoordinates;

-(instancetype)initWithJSONData:(NSDictionary *)jsonDictionary;
@end
