//
// Created by Nickolay Sheika on 23.01.15.
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

#import "VOXHistogramAnimator.h"

static CGFloat const VOXHistogramAnimatorAnimationDuration = 0.25f;



@interface VOXHistogramAnimator ()


#pragma mark - Public
@property(nonatomic, weak, readwrite) UIView *histogramView;
@property(nonatomic, assign, readwrite, getter=didHistogramShowed) BOOL histogramPresented;

#pragma mark - Helpers
@property(nonatomic, assign) BOOL animatingShowHistogram;
@property(nonatomic, assign) BOOL animatingHideHistogram;

@end



@implementation VOXHistogramAnimator


#pragma mark - Accessors

- (BOOL)animating
{
    return self.animatingHideHistogram || self.animatingShowHistogram;
}

#pragma mark - Init

- (instancetype)initWithHistogramView:(UIView *)histogramView
{
    self = [super init];
    if (self) {
        self.histogramView = histogramView;
        self.histogramPresented = YES;
    }
    return self;
}

+ (instancetype)animatorWithHistogramView:(UIView *)histogramView
{
    return [[self alloc] initWithHistogramView:histogramView];
}

#pragma mark - Public

- (void)showHistogramViewAnimated:(BOOL)animated
{
    if ((self.histogramPresented && ! self.animatingHideHistogram) || self.animatingShowHistogram)
        return;

    if ([self.delegate respondsToSelector:@selector(histogramAnimatorWillShowHistogram:)]) {
        [self.delegate histogramAnimatorWillShowHistogram:self];
    }

    void (^animations)() = ^{
        [self transformToShowedState];
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        self.animatingShowHistogram = NO;
        if (finished) {
            self.histogramPresented = YES;
            if ([self.delegate respondsToSelector:@selector(histogramAnimatorDidShowHistogram:)]) {
                [self.delegate histogramAnimatorDidShowHistogram:self];
            }
        }
    };

    if (animated) {
        self.animatingShowHistogram = YES;
        [self makeTransitionAnimationWithAnimations:animations
                                      andCompletion:completion];
    }
    else {
        animations();
        completion(YES);
    }
}

- (void)hideHistogramViewAnimated:(BOOL)animated
{
    if ((! self.histogramPresented && ! self.animatingShowHistogram) || self.animatingHideHistogram)
        return;

    if ([self.delegate respondsToSelector:@selector(histogramAnimatorWillHideHistogram:)]) {
        [self.delegate histogramAnimatorWillHideHistogram:self];
    }

    void (^animations)() = ^{
        [self transformToHiddenState];
    };
    void (^completion)(BOOL) = ^(BOOL finished) {
        self.animatingHideHistogram = NO;
        if (finished) {
            self.histogramPresented = NO;
            if ([self.delegate respondsToSelector:@selector(histogramAnimatorDidHideHistogram:)]) {
                [self.delegate histogramAnimatorDidHideHistogram:self];
            }
        }
    };

    if (animated) {
        self.animatingHideHistogram = YES;
        [self makeTransitionAnimationWithAnimations:animations
                                      andCompletion:completion];
    }
    else {
        animations();
        completion(YES);
    }
}

#pragma mark - Animations

- (void)makeTransitionAnimationWithAnimations:(void (^)(void))animations
                                andCompletion:(void (^)(BOOL finished))completion
{
    [UIView animateWithDuration:VOXHistogramAnimatorAnimationDuration
                          delay:0.0f
         usingSpringWithDamping:0.9f
          initialSpringVelocity:0.8f
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animations
                     completion:completion];
}

#pragma mark - Frames Setup

- (void)transformToHiddenState
{
    CGFloat histogramHeight = CGRectGetHeight(self.histogramView.frame);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0.0f, histogramHeight / 2);
    CGAffineTransform scale = CGAffineTransformMakeScale(1.0f, 0.00001f);
    CGAffineTransform transform = CGAffineTransformConcat(scale, translation);
    self.histogramView.transform = transform;
}

- (void)transformToShowedState
{
    self.histogramView.transform = CGAffineTransformIdentity;
}

@end