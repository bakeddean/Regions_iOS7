//
//  GeoJsonParser.h
//  Regions_iOS7
//
//  Created by Dean Woodward on 19/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeoJsonParser : NSObject

+ (instancetype)sharedInstance;
- (NSArray *)parseGeoJson;

@end
