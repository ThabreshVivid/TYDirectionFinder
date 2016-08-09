//
//  TYGooglePlacesApiClient.h
//  MapkitAPI
//
//  Created by Thabresh on 8/9/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TYGooglePlacesApiClient : NSObject
@property (strong, nonatomic) NSMutableArray *searchResults;

+ (instancetype)sharedInstance;

- (void)retrieveGooglePlaceInformation:(NSString *)searchWord withCompletion:(void (^)(BOOL isSuccess, NSError *error))completion;

- (void)retrieveJSONDetailsAbout:(NSString *)place withCompletion:(void (^)(NSDictionary *placeInformation, NSError *error))completion;
@end
