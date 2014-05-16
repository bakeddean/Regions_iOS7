//
//  RegionAnnotation.m
//  Regions_iOS7
//
//  Created by Dean Woodward on 16/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import "RegionAnnotation.h"

@implementation RegionAnnotation

- (id)init {
	self = [super init];
	if (self != nil) {
		self.title = @"Monitored Region";
	}
	
	return self;	
}

- (id)initWithCLCircularRegion:(CLCircularRegion *)newRegion {
	self = [self init];
	
	if (self != nil) {
		self.region = newRegion;
		self.coordinate = self.region.center;
		self.radius = self.region.radius;
		self.title = @"Monitored Region";
	}		

	return self;		
}

/*
 This method provides a custom setter so that the model is notified when the subtitle value has changed.
 */
/*- (void)setRadius:(CLLocationDistance)newRadius {
	//[self willChangeValueForKey:@"subtitle"];
	
	self.radius = newRadius;
	
	//[self didChangeValueForKey:@"subtitle"];
}*/

- (NSString *)subtitle {
	return [NSString stringWithFormat: @"Lat: %.4F, Lon: %.4F, Rad: %.1fm", self.coordinate.latitude, self.coordinate.longitude, self.radius];
}

@end
