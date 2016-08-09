//
//  TYGooglePlace.h
//  MapkitAPI
//
//  Created by Thabresh on 8/9/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TYGooglePlace : NSObject
@property (readonly) NSString *name;
@property (readonly) CLLocation *location;
@property (readonly) NSString *formatted_address;

-(instancetype)initWithJSONData:(NSDictionary *)jsonDictionary;
@end
