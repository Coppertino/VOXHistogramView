#VOXHistogramView [![Version](https://img.shields.io/badge/version-0.1.0-cacaca.svg)](https://github.com/Coppertino/VOXHistogramView) [![Platform](https://img.shields.io/badge/platform-ios-blue.svg)](https://github.com/Coppertino/VOXHistogramView)

**The best way to display histogram in your project. Free Software, Hell Yeah!**

This software is used in our [VOX Player](https://itunes.apple.com/us/app/vox-player/id916215494).

/* Here is the place for beatiful GIF */


## Usage

There is two ways how you can use our software. 

####1. VOXHistogramControlView

This is a wrapper view over the entire histogram rendering process and playback control.

- Handles users touches and tells delegate about all events.
- Scrubbing speed support for precise control over audio track rewind.
- Can animate histogram show/hide.
- Controls playback and download progress.
- Controls all histogram rendering process. 
- Can display slider view at the bottom of histogram.

VOXHistogramControlView has full support for autolayout, can be instantiated from storyboard and many params can be setup by IBInspectable properties.

This is the way we use histogram in our VOX Player project. 


```objc

CGRect frame = /* Build frame… */
VOXHistogramControlView *histogramControlView = [[VOXHistogramControlView alloc] initWithFrame:frame];
histogramControlView.delegate = self;

NSArray *levels = /* Get levels from API or from player… */
histogramControlView.levels = levels;
```

####2. Plain VOXHistogramView.

If VOXHistogramControlView do not suits your needs you can use all components separately. 

Lets describe them:

#####VOXHistogramView 

Allows you to display rendered histogram image and provides control over playback progress and download progress. It supports autolayout and can be instantiated from storyboard.

```objc
CGRect frame = /* Setup histogram frame */
VOXHistogramView *histogramView = [[VOXHistogramView alloc] initWithFrame:frame];

UIImage *image = /* Render histogram image */
histogramView.image = image;
```

#####VOXHistogramRenderer

This is main hard worker - it is used to render histogram image from array of levels. Rendering goes in background thread and not blocking the UI.

```objc

VOXHistogramRenderingConfiguration *renderingConfiguration = /* Setup rendering configuration… */

VOXHistogramRenderer *renderer = [VOXHistogramRenderer rendererWithRenderingConfiguration:renderingConfiguration];

NSArray *levels = /* Get levels from API or from player… */

[renderer renderHistogramWithLevels:levels completion:^(UIImage *image) {
    /* Use histogram image */
}];
```

#####VOXHistogramLevelsConverter

This class allows you to convert levels array in background. For example you have received 1000 levels from API but you need only 300 to display VOXHistogramView in current bounds. So you need to convert those levels by averaging them. This is what VOXHistogramLevelsConverter was created for. 

```objc
VOXHistogramLevelsConverter *converter = [VOXHistogramLevelsConverter new];

NSArray *levels = /* Get levels from API or from player… */
[converter updateLevels:levels];

    
NSUInteger samplingRate = /* Calculate number of levels that histogram can display in current bounds */

/* Convert levels array to sampling rate and render histogram image */
[converter calculateLevelsForSamplingRate:samplingRate completion:^(NSArray *levelsResampled) {
    /* Use resampled levels to render histogram image */
}];

```

###Levels for audio track

To use our library you should provide array of audio track levels. This is simple NSArray of NSNumbers from @0.0 to @1.0 representing sound level for moment in time. You can get those levels from your audio engine (like BASS) or from API (like Soundcloud).

How many levels do you need?

It depends from many parameters like width of one peak, margin between peaks, current VOXHistogramView bounds, device screen scale. For convenience you can use maximumSamplingRate property in  VOXHistogramControlView or you should calculate this by yourself if you are using plain VOXHistogramView (take a look in example project).



## Roadmap

1. A lot more unit tests. 
2. Separate pod for VOXHistogramControlView.
3. Speed improvements in VOXHistogramLevelsConverter.

## Example

To run the example project, clone the repo, and run pod install from the Example directory first.

## Requirements

- iOS 7.1 and higher
- ARC

## Installation

VOXHistogramView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "VOXHistogramView"
```

## Author

Nickolay Sheika, hawk.ukr@gmail.com

## License

VOXHistogramView is available under the MIT license. See the LICENSE file for more info.
**VOX**, **VOX Player**, **LOOP for VOX** are registered trademarks of Coppertino Inc in US.

