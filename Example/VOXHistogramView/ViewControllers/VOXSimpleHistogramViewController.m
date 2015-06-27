//
//  Created by Nickolay Sheika on 02.06.15.
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

#import <VOXHistogramView/VOXHistogramView.h>
#import <VOXHistogramView/VOXHistogramRenderingConfiguration.h>
#import <VOXHistogramView/VOXHistogramRenderer.h>
#import <VOXHistogramView/VOXHistogramLevelsConverter.h>
#import "VOXSimpleHistogramViewController.h"
#import "VOXJSONConverter.h"
#import "VOXPlayerWrapper.h"



@interface VOXSimpleHistogramViewController () <VOXPlayerWrapperDelegate>


#pragma mark - Outlets
@property(weak, nonatomic) IBOutlet UIButton *playButton;
@property(weak, nonatomic) IBOutlet VOXHistogramView *histogramView;

#pragma mark - Player
@property(nonatomic, strong) VOXPlayerWrapper *playerWrapper;

@end



@implementation VOXSimpleHistogramViewController


#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.playerWrapper = [[VOXPlayerWrapper alloc] initWithPlayer:[APAudioPlayer new]];
    self.playerWrapper.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    /* Histogram params */
    NSUInteger peakWidth = 4;
    NSUInteger marginWidth = 2;

    /* Setup rendering configuration */
    VOXHistogramRenderingConfiguration *renderingConfiguration = [VOXHistogramRenderingConfiguration new];
    renderingConfiguration.outputImageSize = self.histogramView.bounds.size;
    renderingConfiguration.renderingMode = UIImageRenderingModeAlwaysTemplate;
    renderingConfiguration.peaksColor = [UIColor whiteColor];
    renderingConfiguration.peakWidth = peakWidth;
    renderingConfiguration.marginWidth = marginWidth;

    /* Create renderer for histogram image */
    VOXHistogramRenderer *renderer = [VOXHistogramRenderer rendererWithRenderingConfiguration:renderingConfiguration];

    /* Load levels JSON */
    NSArray *levels = [VOXJSONConverter jsonObjectWithFileName:@"levels.json"];

    /* Setup levels converter */
    VOXHistogramLevelsConverter *converter = [VOXHistogramLevelsConverter new];
    [converter updateLevels:levels];

    /* Calculate number of levels that histogram can display in current bounds */
    NSUInteger samplingRate = [self _samplingRateForHistogramWidth:CGRectGetWidth(self.histogramView.bounds)
                                                         peakWidth:peakWidth
                                                       marginWidth:marginWidth];

    /* Convert levels array to sampling rate and render histogram image */
    [converter calculateLevelsForSamplingRate:samplingRate completion:^(NSArray *levelsResampled) {
        [renderer renderHistogramWithLevels:levelsResampled completion:^(UIImage *image) {\
            self.histogramView.image = image;
        }];
    }];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"pink20silence20" ofType:@"mp3"];
    [self.playerWrapper startPlayingTrackWithURL:[NSURL URLWithString:path]];
}

- (void)dealloc
{
    [self.playerWrapper cleanUp];
}


#pragma mark - Actions

- (IBAction)playButtonTap:(id)sender
{
    if ([self.playerWrapper isPlaying]) {
        [self.playerWrapper pause];
    }
    else {
        [self.playerWrapper play];
    }
}

#pragma mark - VOXPlayerWrapperDelegate

- (void)playerDidPause:(VOXPlayerWrapper *)playerWrapper
{
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
}

- (void)playerDidStartPlaying:(VOXPlayerWrapper *)playerWrapper
{
    [self.playButton setTitle:@"Pause" forState:UIControlStateNormal];
}

- (void)playerDidFinishCurrentTrack:(VOXPlayerWrapper *)playerWrapper
{
    [self.histogramView updatePlaybackProgress:0.0f];
}

- (void)  playerWrapper:(VOXPlayerWrapper *)playerWrapper
playbackProgressChanged:(CGFloat)playbackProgress
{
    [self.histogramView updatePlaybackProgress:playbackProgress];
}

- (void)  playerWrapper:(VOXPlayerWrapper *)playerWrapper
downloadProgressChanged:(CGFloat)downloadProgress
{
    [self.histogramView updateDownloadProgress:downloadProgress];
}

#pragma mark - Private

- (NSUInteger)_samplingRateForHistogramWidth:(CGFloat)histogramWidth
                                   peakWidth:(CGFloat)peakWidth
                                 marginWidth:(CGFloat)marginWidth
{
    CGFloat scale = [UIScreen mainScreen].scale;
    return (NSUInteger) ceilf((histogramWidth / (peakWidth + marginWidth)) * scale);
}

@end
