//
//  RegionAnnotatonView.m
//  Regions_iOS7
//
//  Created by Dean Woodward on 16/05/14.
//  Copyright (c) 2014 Dean Woodward. All rights reserved.
//

#import "RegionAnnotatonView.h"
#import "RegionAnnotation.h"

@implementation RegionAnnotatonView{
    MKCircle *radiusOverlay;
	BOOL isRadiusUpdated;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithAnnotation:(id <MKAnnotation>)annotation {
	self = [super initWithAnnotation:annotation reuseIdentifier:[annotation title]];	
	
	if (self) {		
		self.canShowCallout	= YES;		
		self.multipleTouchEnabled = NO;
		self.draggable = YES;
		self.animatesDrop = YES;
		self.map = nil;
		self.theAnnotation = (RegionAnnotation *)annotation;
		self.pinColor = MKPinAnnotationColorPurple;
		radiusOverlay = [MKCircle circleWithCenterCoordinate:self.theAnnotation.coordinate radius:self.theAnnotation.radius];
		
		[self.map addOverlay:radiusOverlay];
	}
	
	return self;	
}


- (void)removeRadiusOverlay {
	// Find the overlay for this annotation view and remove it if it has the same coordinates.
	for (id overlay in [self.map overlays]) {
		if ([overlay isKindOfClass:[MKCircle class]]) {						
			MKCircle *circleOverlay = (MKCircle *)overlay;			
			CLLocationCoordinate2D coord = circleOverlay.coordinate;
			
			if (coord.latitude == self.theAnnotation.coordinate.latitude && coord.longitude == self.theAnnotation.coordinate.longitude) {
				[self.map removeOverlay:overlay];
			}			
		}
	}
	
	isRadiusUpdated = NO;
}


- (void)updateRadiusOverlay {
	if (!isRadiusUpdated) {
		isRadiusUpdated = YES;
		
		[self removeRadiusOverlay];
		self.canShowCallout = NO;
		[self.map addOverlay:[MKCircle circleWithCenterCoordinate:self.theAnnotation.coordinate radius:self.theAnnotation.radius]];
		self.canShowCallout = YES;		
	}
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
