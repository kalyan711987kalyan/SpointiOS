//
//  PSLocationManagerDelegate.h
//
//  Copyright (c) 2015-present PathSense. All rights reserved.
//

@class PSLocationManager;

/*!
	@abstract Delegate for PSLocationManager.
 
 */
@protocol PSLocationManagerDelegate <CLLocationManagerDelegate>

@optional

/*!
	@abstract Invoked when a PSActivityType and/or a PSActivityConfidence level has changed. Return the CLLocationAccuracy
	desired for this activity and or confidence.
 
 	@param manager the PSLocationManager.
 	@param activityType the PSActivityType.
 	@param confidence the PSActivityConfidence.
 	@return the desired location accuarcy for the given activity (including kPSLocationAccuracyPathSenseNavigation).
 */
- (CLLocationAccuracy)psLocationManager:(PSLocationManager *)manager
    desiredAccuracyForActivity:(PSActivityType)activityType
    withConfidence:(PSActivityConfidence)confidence;

/*!
	@abstract Invoked when a PSActivityType and/or a PSActivityConfidence level has changed. Return the CLLocationDistance
	for this activity and or confidence.
 
 	@param manager the PSLocationManager.
 	@param activityType the PSActivityType.
 	@param confidence the PSActivityConfidence.
 
 	@return the desired location distance for the given activity.
 */
- (CLLocationDistance)psLocationManager:(PSLocationManager *)manager
    distanceFilterForActivity:(PSActivityType)activityType
	withConfidence:(PSActivityConfidence)confidence;

/*!
	@abstract Invoked when departure has started.
 
 	@param manager the PSLocationManager.
 	@param coordinate the coordinate being observed for the departure.
 */
- (void)psLocationManager:(PSLocationManager *)manager
    didStartMonitoringDepartureCoordinate:(CLLocationCoordinate2D)coordinate;

/*!
	@abstract Invoked when a new coordinate is set for the departure service to monitor.
 
 	@param manager the PSLocationManager.
 	@param coordinate the coordinate being observed for the departure.
 */
- (void)psLocationManager:(PSLocationManager *)manager
    didUpdateDepartureCoordinate:(CLLocationCoordinate2D)coordinate;

/*!
	@abstract Invoked when departure has been observed. 
 
 	@param manager the PSLocationManager.
 	@param coordinate the coordinate being observed for the departure.
 */
- (void)psLocationManager:(PSLocationManager *)manager
    didDepartCoordinate:(CLLocationCoordinate2D)coordinate  __attribute__ ((deprecated("Use 'psLocationManager:didDepartCoordinate:location:' instead.")));

/*!
	@abstract Invoked when departure has been observed. 
 
 	@param manager the PSLocationManager.
 	@param coordinate the coordinate being observed for the departure.
 	@param location the location at the time of departure.
 */
- (void)psLocationManager:(PSLocationManager *)manager
    didDepartCoordinate:(CLLocationCoordinate2D)coordinate
    atLocation:(CLLocation *)location;

/*!
	@abstract Invoked when the departure service is no longer monitoring a coordinate for departure.
 
 	@param manager the PSLocationManager.
 */
- (void)psLocationManagerDepartureMonitoringEnded:(PSLocationManager *)manager;

@end
