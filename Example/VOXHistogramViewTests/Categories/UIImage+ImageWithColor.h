//
// Created by Nickolay Sheika on 07.07.15.
// Copyright (c) 2015 Nickolay Sheika. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>



@interface UIImage (ImageWithColor)

+ (UIImage *)imageWithColor:(UIColor *)color
                     ofSize:(CGSize)size;
@end