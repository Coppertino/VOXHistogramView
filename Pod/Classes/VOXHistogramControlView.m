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

#import "VOXHistogramControlView.h"
#import "VOXHistogramView.h"
#import "VOXProgressLineView.h"
#import "VOXHistogramRenderer.h"
#import "VOXHistogramRenderingConfiguration.h"
#import "VOXHistogramLevelsConverter.h"
#import "VOXHistogramAnimator.h"
#import "UIView+Autolayout.h"
#import "FrameAccessor.h"



static NSUInteger const VOXHistogramControlViewDefaultPeakWidth = 3;
static NSUInteger const VOXHistogramControlViewDefaultMarginWidth = 1;



@interface VOXHistogramControlView () <UIGestureRecognizerDelegate, VOXHistogramAnimatorDelegate>


#pragma mark - Public
@property(nonatomic, assign, readwrite, getter=isTracking) BOOL tracking;
@property(nonatomic, assign, readwrite) CGFloat scrubbingSpeed;
@property(nonatomic, assign, readwrite) IBInspectable BOOL useScrubbing;

#pragma mark - Managed Views
@property(nonatomic, weak, readwrite) VOXHistogramView *histogramView;
@property(nonatomic, weak, readwrite) VOXProgressLineView *slider;

#pragma mark - Helpers
@property(assign, nonatomic) CGPoint beganTrackingLocation;
@property(assign, nonatomic) CGFloat realPositionValue;
@property(nonatomic, weak) UITouch *currentTouch;

@property(nonatomic, strong) VOXHistogramRenderer *histogramRenderer;
@property(nonatomic, strong) VOXHistogramAnimator *animator;
@end



@implementation VOXHistogramControlView


#pragma mark - Accessors

- (void)setCompleteColor:(UIColor *)completeColor
{
    _completeColor = completeColor;
    self.histogramView.completeColor = completeColor;
    self.slider.completeColor = completeColor;
}

- (void)setNotCompleteColor:(UIColor *)notCompleteColor
{
    _notCompleteColor = notCompleteColor;
    self.histogramView.notCompleteColor = notCompleteColor;
    self.slider.notCompleteColor = notCompleteColor;
}

- (void)setDownloadedColor:(UIColor *)downloadedColor
{
    _downloadedColor = downloadedColor;
    self.histogramView.downloadedColor = downloadedColor;
    self.slider.downloadedColor = downloadedColor;
}

- (void)setLevels:(NSArray *)levels
{
    _levels = [levels copy];
    [self _renderHistogram];
}

- (void)setPlaybackProgress:(CGFloat)playbackProgress
{
    if (_playbackProgress == playbackProgress || self.isTracking)
        return;

    _playbackProgress = [self _normalizedValue:playbackProgress];

    [self.slider updatePlaybackProgress:playbackProgress];

    if (! self.animator.animating) {
        [self.histogramView updatePlaybackProgress:playbackProgress];
    }
}

- (void)setDownloadProgress:(CGFloat)downloadProgress
{
    if (_downloadProgress == downloadProgress)
        return;

    _downloadProgress = [self _normalizedDownloadProgressValue:downloadProgress];

    [self.slider updateDownloadProgress:downloadProgress];

    if (! self.animator.animating) {
        [self.histogramView updateDownloadProgress:downloadProgress];
    }
}

- (BOOL)histogramPresented
{
    return self.animator.histogramPresented;
}

- (BOOL)animating
{
    return self.animator.animating;
}

#pragma mark - Init

- (id)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupHistogramView];
        [self setupDefaults];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupHistogramView];
        [self setupDefaults];
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setup];

    // we should set color to slider here because designable
    // properties are set between initWithCoder and awakeFromNib
    self.slider.completeColor = self.completeColor;
    self.slider.downloadedColor = self.downloadedColor;
    self.slider.notCompleteColor = self.notCompleteColor;
}

#pragma mark - Setup

- (void)setupDefaults
{
    /* No slider by default */
    self.sliderHeight = 0.0f;

    /* Use scrubbing */
    self.useScrubbing = YES;

    /* Histogram params */
    self.peakWidth = VOXHistogramControlViewDefaultPeakWidth;
    self.marginWidth = VOXHistogramControlViewDefaultMarginWidth;

    /* Colors */
    self.completeColor = [UIColor yellowColor];
    self.downloadedColor = [UIColor lightGrayColor];
    self.notCompleteColor = [UIColor darkGrayColor];

    /* Scrubbing setup */
    self.scrubbingSpeeds = [self _defaultScrubbingSpeeds];
    self.scrubbingSpeedChangePositions = [self _defaultScrubbingSpeedChangePositions];
    self.scrubbingSpeed = [self.scrubbingSpeeds[0] floatValue];
}

- (void)setup
{
    /* Setup managed views */
    [self setupSliderIfNeeded];
    [self setupViewsConstraints];

    /* Create animator */
    self.animator = [VOXHistogramAnimator animatorWithHistogramView:self.histogramView];
    self.animator.delegate = self;

    /* Gesture recognizer setup */
    [self setupGestureRecognizer];
}

- (void)setupHistogramView
{
    VOXHistogramView *histogramView = [VOXHistogramView autolayoutView];
    [self addSubview:histogramView];
    self.histogramView = histogramView;
}

- (void)setupSliderIfNeeded
{
    if (self.sliderHeight > 0) {
        VOXProgressLineView *slider = [VOXProgressLineView autolayoutView];
        [self addSubview:slider];
        self.slider = slider;
    }
}

- (void)setupViewsConstraints
{
    VOXHistogramView *histogramView = self.histogramView;

    NSDictionary *histogramBinding = NSDictionaryOfVariableBindings(histogramView);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[histogramView]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:histogramBinding]];

    if (self.slider) {
        VOXProgressLineView *slider = self.slider;
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[slider]|"
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(slider)]];
        NSString *format = [NSString stringWithFormat:@"V:[histogramView(%f)][slider(%f)]|", self.histogramHeight, self.sliderHeight];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                     options:0
                                                                     metrics:nil
                                                                       views:NSDictionaryOfVariableBindings(histogramView, slider)]];
    }
    else {
        NSString *format = self.histogramHeight == 0 ? @"V:|[histogramView]|" : [NSString stringWithFormat:@"V:[histogramView(%f)]|",
                                                                                                           self.histogramHeight];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                     options:0
                                                                     metrics:nil
                                                                       views:histogramBinding]];
    }
}

- (void)setupGestureRecognizer
{
    UILongPressGestureRecognizer *longPressGestureRecognizer;
    longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(tapOccured:)];
    longPressGestureRecognizer.delegate = self;
    CGFloat pressDuration = self.trackingMode == VOXHistogramControlViewTrackingModeLongTap ? 0.3f : 0.001f;
    longPressGestureRecognizer.minimumPressDuration = pressDuration;
    [self addGestureRecognizer:longPressGestureRecognizer];
}

#pragma mark - Public

- (void)showHistogramViewAnimated:(BOOL)animated
{
    [self.animator showHistogramViewAnimated:animated];
}

- (void)hideHistogramViewAnimated:(BOOL)animated
{
    [self.animator hideHistogramViewAnimated:animated];
}

- (void)stopHistogramRendering
{
    [self.histogramRenderer cancelCurrentRendering];
    self.histogramRenderer = nil;
}

#pragma mark - Gestures

- (void)tapOccured:(UIGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self _notifyDelegateDidStartTracking];
    }

    [self _updateValueForCurrentTouch];

    if (sender.state == UIGestureRecognizerStateBegan) {
        self.tracking = YES;

        self.beganTrackingLocation = CGPointMake(self.playbackProgress * self.bounds.size.width, self.histogramView.bottom);
        self.realPositionValue = self.playbackProgress;
    }
    else if (sender.state == UIGestureRecognizerStateChanged) {
        if (self.useScrubbing) {
            [self _updateScrubbingSpeed];
        }
    }
    else if (sender.state == UIGestureRecognizerStateCancelled || sender.state == UIGestureRecognizerStateEnded) {
        self.tracking = NO;
        self.currentTouch = nil;

        // set default scrubbing speed
        self.scrubbingSpeed = [self.scrubbingSpeeds[0] floatValue];

        CGFloat playbackProgress = self.playbackProgress;
        [self _notifyDelegateDidFinishTrackingWithValue:playbackProgress];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    self.currentTouch = touch;
    return YES;
}

#pragma mark - VOXHistogramAnimatorDelegate

- (void)histogramAnimatorWillShowHistogram:(VOXHistogramAnimator *)controlView
{
    [self _notifyDelegateWillShowHistogram];
}

- (void)histogramAnimatorDidShowHistogram:(VOXHistogramAnimator *)controlView
{
    [self _notifyDelegateDidShowHistogram];
}

- (void)histogramAnimatorWillHideHistogram:(VOXHistogramAnimator *)controlView
{
    [self _notifyDelegateWillHideHistogram];
}

- (void)histogramAnimatorDidHideHistogram:(VOXHistogramAnimator *)controlView
{
    [self _notifyDelegateDidHideHistogram];
}

#pragma mark - Helpers

- (void)_renderHistogram
{
    /* Cancel previous rendering */
    if (self.histogramRenderer) {
        [self.histogramRenderer cancelCurrentRendering];
    }

    /* Notify delegate */
    [self _notifyDelegateWillStartRendering];

    /* Setup levels converter */
    VOXHistogramLevelsConverter *converter = [VOXHistogramLevelsConverter new];
    [converter updateLevels:self.levels];

    /* Creating rendering configuration */
    VOXHistogramRenderingConfiguration *renderingConfiguration = [VOXHistogramRenderingConfiguration new];
    renderingConfiguration.outputImageSize = self.histogramView.bounds.size;
    renderingConfiguration.renderingMode = UIImageRenderingModeAlwaysTemplate;
    renderingConfiguration.peaksColor = [UIColor whiteColor];
    renderingConfiguration.peakWidth = self.peakWidth;
    renderingConfiguration.marginWidth = self.marginWidth;

    /* Calculate number of levels that histogram can display in current bounds */
    NSUInteger samplingRate = [self _samplingRateForHistogramWidth:CGRectGetWidth(self.histogramView.bounds)
                                                         peakWidth:self.peakWidth
                                                       marginWidth:self.marginWidth];

    /* Creating histogram renderer */
    self.histogramRenderer = [VOXHistogramRenderer rendererWithRenderingConfiguration:renderingConfiguration];

    /* Rendering histogram image */
    [converter calculateLevelsForSamplingRate:samplingRate completion:^(NSArray *levelsResampled) {
        [self.histogramRenderer renderHistogramWithLevels:levelsResampled completion:^(UIImage *image) {
            self.histogramView.image = image;

            /* Notify delegate */
            [self _notifyDelegateDidFinishRendering];
        }];
    }];
}

- (void)_updateValueForCurrentTouch
{
    /* Get touch params */
    CGPoint previousLocation = [self.currentTouch previousLocationInView:self];
    CGPoint currentLocation = [self.currentTouch locationInView:self];

    CGFloat trackingOffset = currentLocation.x - previousLocation.x;
    CGFloat controlViewWidth = CGRectGetWidth(self.bounds);

    self.realPositionValue = self.realPositionValue + (trackingOffset / controlViewWidth);

    CGFloat valueAdjustment = self.scrubbingSpeed * (trackingOffset / controlViewWidth);

    CGFloat thumbAdjustment = 0.0f;

    /* Vertical progress adjustment - when user moves finger down closer to histogram we should also adjust progress */
    if (((self.beganTrackingLocation.y < currentLocation.y) && (currentLocation.y < previousLocation.y)) ||
        ((self.beganTrackingLocation.y > currentLocation.y) && (currentLocation.y > previousLocation.y))) {
        // We are getting closer to the slider, go closer to the real location
        thumbAdjustment = (self.realPositionValue - self.playbackProgress) / (1 + fabs(currentLocation.y - self.beganTrackingLocation.y));
    }

    if ((trackingOffset == 0 && (currentLocation.y - previousLocation.y) == 0) || ! self.useScrubbing) {
        _playbackProgress = currentLocation.x / controlViewWidth;
    }
    else {
        _playbackProgress += valueAdjustment + thumbAdjustment; // should not call setter here
    }

    [self.slider updatePlaybackProgress:self.playbackProgress];
    [self.histogramView updatePlaybackProgress:self.playbackProgress];

    [self _notifyDelegateDidChangePlaybackProgress:self.playbackProgress];
}

- (void)_updateScrubbingSpeed
{
    CGPoint touchLocation = [self.currentTouch locationInView:self];
    CGFloat verticalOffset = ABS(touchLocation.y - self.beganTrackingLocation.y);
    NSUInteger scrubbingSpeedChangePosIndex = [self _indexOfLowerScrubbingSpeed:self.scrubbingSpeedChangePositions
                                                                      forOffset:verticalOffset];
    if (scrubbingSpeedChangePosIndex == NSNotFound) {
        scrubbingSpeedChangePosIndex = [self.scrubbingSpeeds count];
    }

    CGFloat scrubbingSpeed = [self.scrubbingSpeeds[scrubbingSpeedChangePosIndex - 1] floatValue];

    if (scrubbingSpeed != self.scrubbingSpeed) {
        self.scrubbingSpeed = scrubbingSpeed;
        [self _notifyDelegateDidChangeScrubbingSpeed:scrubbingSpeed];
    }
}

- (NSArray *)_defaultScrubbingSpeeds
{
    return @[ @1.0f, @0.5f, @0.25f, @0.1f ];
}

- (NSArray *)_defaultScrubbingSpeedChangePositions
{
    return @[ @0.0f, @50.0f, @100.0f, @150.0f ];
}

// Return the lowest index in the array of numbers passed in scrubbingSpeedPositions
// whose value is smaller than verticalOffset.
- (NSUInteger)_indexOfLowerScrubbingSpeed:(NSArray *)scrubbingSpeedPositions
                                forOffset:(CGFloat)verticalOffset
{
    for (NSUInteger i = 0; i < [scrubbingSpeedPositions count]; i ++) {
        NSNumber *scrubbingSpeedOffset = scrubbingSpeedPositions[i];
        if (verticalOffset < [scrubbingSpeedOffset floatValue]) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSUInteger)_samplingRateForHistogramWidth:(CGFloat)histogramWidth
                                   peakWidth:(CGFloat)peakWidth
                                 marginWidth:(CGFloat)marginWidth
{
    CGFloat scale = [UIScreen mainScreen].scale;
    return (NSUInteger) ceilf((histogramWidth / (peakWidth + marginWidth)) * scale);
}

- (CGFloat)_normalizedValue:(CGFloat)value
{
    return MAX(MIN(value, 1), 0);
}

- (CGFloat)_normalizedDownloadProgressValue:(CGFloat)downloadProgressValue
{
    return MAX(MIN(downloadProgressValue, 1), self.playbackProgress);
}

#pragma mark - Delegate Notifications

- (void)_notifyDelegateWillStartRendering
{
    if ([self.delegate respondsToSelector:@selector(histogramControlViewWillStartRendering:)]) {
        [self.delegate histogramControlViewWillStartRendering:self];
    }
}

- (void)_notifyDelegateDidFinishRendering
{
    if ([self.delegate respondsToSelector:@selector(histogramControlViewDidFinishRendering:)]) {
        [self.delegate histogramControlViewDidFinishRendering:self];
    }
}

- (void)_notifyDelegateDidStartTracking
{
    if ([self.delegate respondsToSelector:@selector(histogramControlViewDidStartTracking:)]) {
        [self.delegate histogramControlViewDidStartTracking:self];
    }
}

- (void)_notifyDelegateDidFinishTrackingWithValue:(CGFloat)playbackProgress
{
    if ([self.delegate respondsToSelector:@selector(histogramControlView:didFinishTrackingWithProgress:)]) {
        [self.delegate histogramControlView:self
              didFinishTrackingWithProgress:playbackProgress];
    }
}

- (void)_notifyDelegateDidChangeScrubbingSpeed:(CGFloat)scrubbingSpeed
{
    if ([self.delegate respondsToSelector:@selector(histogramControlView:didChangeScrubbingSpeed:)]) {
        [self.delegate histogramControlView:self
                    didChangeScrubbingSpeed:scrubbingSpeed];
    }
}

- (void)_notifyDelegateWillShowHistogram
{
    if ([self.delegate respondsToSelector:@selector(histogramControlViewWillShowHistogram:)]) {
        [self.delegate histogramControlViewWillShowHistogram:self];
    }
}

- (void)_notifyDelegateDidShowHistogram
{
    if ([self.delegate respondsToSelector:@selector(histogramControlViewDidShowHistogram:)]) {
        [self.delegate histogramControlViewDidShowHistogram:self];
    }
}

- (void)_notifyDelegateWillHideHistogram
{
    if ([self.delegate respondsToSelector:@selector(histogramControlViewWillHideHistogram:)]) {
        [self.delegate histogramControlViewWillHideHistogram:self];
    }
}

- (void)_notifyDelegateDidHideHistogram
{
    if ([self.delegate respondsToSelector:@selector(histogramControlViewDidHideHistogram:)]) {
        [self.delegate histogramControlViewDidHideHistogram:self];
    }
}

- (void)_notifyDelegateDidChangePlaybackProgress:(CGFloat)playbackProgress
{
    if ([self.delegate respondsToSelector:@selector(histogramControlView:didChangeProgress:)]) {
        [self.delegate histogramControlView:self
                          didChangeProgress:playbackProgress];
    }
}

@end