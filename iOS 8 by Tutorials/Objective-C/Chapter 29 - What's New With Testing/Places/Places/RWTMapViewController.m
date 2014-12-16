/*
 * Copyright (c) 2014 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 *  RWTMapViewController.m
 *  Places
 *
 *  Created by Soheil Azarpour on 6/24/14.
 *  Copyright (c) 2014 Razeware LLC. All rights reserved.
 */

#import "RWTMapViewController.h"
#import "RWTPlace.h"
@import MapKit;

static NSString * const kRWTMapAnnotationViewIdentifier = @"RWTMapAnnotationViewIdentifier";
static CLLocationDegrees const kRWTZoomFactorRegularLayout = 0.02;
static CLLocationDegrees const kRWTZoomFactorCompactLayout = 0.05;

@interface RWTMapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) RWTPlace *place;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation RWTMapViewController

- (void)viewDidAppear:(BOOL)animated {
  [self updateMapViewWithPlace:self.place];
  [super viewDidAppear:animated];
}

#pragma mark - Public

- (BOOL)isDisplayingPlace {
  return (self.place != nil) ? YES : NO;
}

- (void)displayPlace:(RWTPlace *)place {
  self.place = place;
  self.title = place.title;
  [self updateMapViewWithPlace:place];
}

- (void)clearMap {
  self.place = nil;
  [self updateMapViewWithPlace:nil];
}

#pragma mark - Helper

/** @brief A helper method to update the map view with a given RWTPlace. */
- (void)updateMapViewWithPlace:(RWTPlace *)place {
  // Remove any old places that is being displayed.
  for (id<MKAnnotation> annotation in self.mapView.annotations) {
    [self.mapView removeAnnotation:annotation];
  }
  // If the new place is not nil, display it.
  if (place) {
    [self.mapView addAnnotation:place];
    // Zoom in to the new place. Zoom in more if layout class is Regular.
    CLLocationDegrees delta = (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) ? kRWTZoomFactorCompactLayout : kRWTZoomFactorRegularLayout;
    MKCoordinateRegion region = MKCoordinateRegionMake(place.coordinate, MKCoordinateSpanMake(delta, delta));
    [self.mapView setRegion:region animated:YES];
  }
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  MKAnnotationView* annotationView = nil;
  if ([annotation isKindOfClass:[RWTPlace class]]) {
    annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:kRWTMapAnnotationViewIdentifier];
    if (!annotationView) {
      annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:kRWTMapAnnotationViewIdentifier];
      annotationView.enabled = NO;
      annotationView.canShowCallout = NO;
      annotationView.image = ((RWTPlace *)annotation).image;
    } else {
      annotationView.annotation = annotation;
    }
  }
  return annotationView;
}

@end
