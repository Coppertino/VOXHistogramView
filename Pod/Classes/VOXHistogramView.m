//
// Created by Nickolay Sheika on 10/8/14.
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


#import "VOXHistogramView.h"
#import "FrameAccessor.h"


@interface VOXHistogramView ()


@property(nonatomic, assign) CGFloat playbackProgress;
@property(nonatomic, assign) CGFloat downloadProgress;

@property(nonatomic, weak) UIImageView *completeImageView;
@property(nonatomic, weak) UIImageView *notCompleteImageView;
@property(nonatomic, weak) UIImageView *downloadedImageView;

@end



@implementation VOXHistogramView


#pragma mark - Accessors

- (void)setCompleteColor:(UIColor *)completeColor
{
    _completeColor = completeColor;
    self.completeImageView.tintColor = completeColor;
}

- (void)setNotCompleteColor:(UIColor *)notCompleteColor
{
    _notCompleteColor = notCompleteColor;
    self.notCompleteImageView.tintColor = notCompleteColor;
}

- (void)setDownloadedColor:(UIColor *)downloadedColor
{
    _downloadedColor = downloadedColor;
    self.downloadedImageView.tintColor = downloadedColor;
}

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    return [self initWithFrame:CGRectZero];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.notCompleteImageView.frame = self.bounds;
    self.completeImageView.frame = (CGRect) {
            .origin = CGPointZero,
            .size.width = CGRectGetWidth(self.bounds) * self.playbackProgress,
            .size.height = CGRectGetHeight(self.bounds)
    };
    self.downloadedImageView.frame = (CGRect) {
            .origin = CGPointZero,
            .size.width = CGRectGetWidth(self.bounds) * self.downloadProgress,
            .size.height = CGRectGetHeight(self.bounds)
    };
}

#pragma mark - Setup

- (void)setup
{
    self.notCompleteImageView = [self _buildImageView];
    self.downloadedImageView = [self _buildImageView];
    self.completeImageView = [self _buildImageView];
}

- (UIImageView *)_buildImageView
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imageView.clipsToBounds = YES;
    imageView.contentMode = UIViewContentModeLeft;
    [self addSubview:imageView];
    return imageView;
}

#pragma mark - Accessors

- (void)setImage:(UIImage *)image
{
    if ([_image isEqual:image])
        return;

    _image = image;

    self.completeImageView.image = image;
    self.notCompleteImageView.image = image;
    self.downloadedImageView.image = image;

    [self setNeedsLayout];
}

#pragma mark - Public

- (void)updatePlaybackProgress:(CGFloat)playbackProgress
{
    self.playbackProgress = [self _normalizedValue:playbackProgress];
    [self setNeedsLayout];
}

- (void)updateDownloadProgress:(CGFloat)downloadProgress
{
    self.downloadProgress = [self _normalizedDownloadProgressValue:downloadProgress];
    [self setNeedsLayout];
}

#pragma mark - Helpers

- (CGFloat)_normalizedValue:(CGFloat)value
{
    return MAX(MIN(value, 1), 0);
}

- (CGFloat)_normalizedDownloadProgressValue:(CGFloat)downloadProgressValue
{
    return MAX(MIN(downloadProgressValue, 1), self.playbackProgress);
}

@end