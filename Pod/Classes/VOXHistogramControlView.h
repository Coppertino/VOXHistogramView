//
// Created by Nickolay Sheika on 10/21/14.
// Copyright (c) 2014 Coppertino Inc. All rights reserved. (http://coppertino.com/)
//
// VOX, VOX Player, LOOP for VOX are registered trademarks of Coppertino Inc in US.
// Coppertino Inc. 910 Foulk Road, Suite 201, Wilmington, County of New Castle, DE, 19803, USA.
// Contact phone: +1 (888) 765-7069
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

@class VOXHistogramControlView;
@class VOXHistogramView;
@class VOXProgressLineView;


typedef NS_ENUM(NSUInteger, VOXHistogramControlViewTrackingMode)
{
    VOXHistogramControlViewTrackingModeNone = 0,
    VOXHistogramControlViewTrackingModeTap,
    VOXHistogramControlViewTrackingModeLongTap
};



@protocol VOXHistogramControlViewDelegate <NSObject>


@optional

/**
*   Called when histogram will be shown soon.
*/
- (void)histogramControlViewWillShowHistogram:(VOXHistogramControlView *)controlView;

/**
*   Called right after histogram is showed.
*/
- (void)histogramControlViewDidShowHistogram:(VOXHistogramControlView *)controlView;

/**
*   Called when histogram will be hidden soon.
*/
- (void)histogramControlViewWillHideHistogram:(VOXHistogramControlView *)controlView;

/**
*   Called right after histogram is hidden.
*/
- (void)histogramControlViewDidHideHistogram:(VOXHistogramControlView *)controlView;

/**
*   Called when user start tracking.
*/
- (void)histogramControlViewDidStartTracking:(VOXHistogramControlView *)controlView;

/**
*   Called when progress changed even if tracking is not finished yet.
*/
- (void)histogramControlView:(VOXHistogramControlView *)controlView
           didChangeProgress:(CGFloat)progress;

/**
*   Called when user did finish tracking.
*/
- (void) histogramControlView:(VOXHistogramControlView *)controlView
didFinishTrackingWithProgress:(CGFloat)progress;

/**
*   Called when user did change scrubbing speed.
*/
- (void)histogramControlView:(VOXHistogramControlView *)controlView
     didChangeScrubbingSpeed:(CGFloat)scrubbingSpeed;

/**
*   Called when histogram rendering is about to start.
*/
- (void)histogramControlViewWillStartRendering:(VOXHistogramControlView *)controlView;

/**
*   Called when histogram rendering finished.
*/
- (void)histogramControlViewDidFinishRendering:(VOXHistogramControlView *)controlView;

@end



@interface VOXHistogramControlView : UIView


#pragma mark - Delegate
@property(nonatomic, weak) id <VOXHistogramControlViewDelegate> delegate;


#pragma mark - Managed Views
@property(nonatomic, weak, readonly) VOXHistogramView *histogramView;
@property(nonatomic, weak, readonly) VOXProgressLineView *slider;


#pragma mark - Inspectable Properties

/**
*   Peaks colors setup
*/
@property(nonatomic, strong) IBInspectable UIColor *completeColor;
@property(nonatomic, strong) IBInspectable UIColor *notCompleteColor;
@property(nonatomic, strong) IBInspectable UIColor *downloadedColor;

/**
*   Width of one peak in pixels (not points!)
*/
@property(nonatomic, assign) IBInspectable NSUInteger peakWidth;

/**
*   Margin between two peaks in pixels (not points!)
*/
@property(nonatomic, assign) IBInspectable NSUInteger marginWidth;

/**
*   Histogram view height.
*
*   @default self.bounds.size.height
*/
@property(nonatomic, assign) IBInspectable CGFloat histogramHeight;

/**
*   Height of VOXProgressLineView under histogram.
*   If 0.0f then slider will not be created.
*
*   @default 0.0f
*/
@property(nonatomic, assign) IBInspectable CGFloat sliderHeight;

/**
*   Use scrubbing or not
*
*   @default YES
*/
@property(nonatomic, assign, readonly) IBInspectable BOOL useScrubbing;


#pragma mark - Setup

/**
*   Current tracking mode
*
*   VOXHistogramControlViewTrackingModeNone - tracking will be off
*   VOXHistogramControlViewTrackingModeTap  - tracking will start from tap
*   VOXHistogramControlViewTrackingModeLongTap - tracking will start from long tap
*
*   @default VOXHistogramControlViewTrackingModeTap
*/
@property(nonatomic, assign) VOXHistogramControlViewTrackingMode trackingMode;


#pragma mark - State

/**
*   Array of NSNumbers representing histogram levels.
*   All values should be between @0.0 and @1.0.
*
*   @discussion
*   If levels count more than histogram can display in current bounds then levels would be averaged.
*   This would be done on background thread. But then rendering process will take more time.
*
*   If you do not want to do additional work while rendering histogram then you should always provide
*   exact count of levels that histogram can display. To know how much levels you need you should
*   use maximumSamplingRate property - it always shows how much levels do you need in current bounds.
*/
@property(nonatomic, copy) NSArray *levels;

/**
*   Playback progress value.
*/
@property(nonatomic, assign) CGFloat playbackProgress;

/**
*   Download progress value.
*/
@property(nonatomic, assign) CGFloat downloadProgress;

/**
*   Returns YES if tracking began.
*/
@property(nonatomic, assign, readonly, getter=isTracking) BOOL tracking;

/**
*   Returns YES if histogram currently presented.
*/
@property(nonatomic, assign, readonly) BOOL histogramPresented;

/**
*   Return YES if currently animating histogram show/hide.
*/
@property(nonatomic, assign, readonly) BOOL animating;

/**
*   Returns maximum count of samples that histogram can show in current bounds.
*   Calculated from peakWidth and marginWidth and bound.size.width.
*/
@property(nonatomic, assign, readonly) NSUInteger maximumSamplingRate;


#pragma mark - Scrubbing

/**
*   Returns current scrubbing speed.
*/
@property(nonatomic, assign, readonly) CGFloat scrubbingSpeed;

/**
*   Array of NSNumbers representing scrubbing speeds for different zones.
*
*   @example @[ @1.0f, @0.5f, @0.25f, @0.1f ] - this means first zone has 100% speed,
*   second zone 50%, and so on.
*/
@property(nonatomic, copy) NSArray *scrubbingSpeeds;

/**
*   Array of NSNumbers representing zones when scrubbing speed changes. Every element of array
*   means distance by Y from user first touch where tracking began.
*
*   @example @[ @0.0f, @50.0f, @100.0f, @150.0f ] -  this means scrubbingSpeeds[0] acts
*   between 0 and 50pt distance from users touch by Y, scrubbingSpeeds[1] acts between
*   50 and 100pt and so on.
*/
@property(nonatomic, copy) NSArray *scrubbingSpeedChangePositions;


#pragma mark - Public

/**
*   Show or hide histogram view.
*/
- (void)showHistogramViewAnimated:(BOOL)animated;
- (void)hideHistogramViewAnimated:(BOOL)animated;

/**
*   Will stop current histogram rendering if any.
*/
- (void)stopHistogramRendering;

@end