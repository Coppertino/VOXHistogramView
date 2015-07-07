//
// Created by Nickolay Sheika on 07.07.15.
// Copyright (c) 2015 Nickolay Sheika. All rights reserved.
//

#import "UIImage+ImageWithColor.h"



@implementation UIImage (ImageWithColor)


+ (UIImage *)imageWithColor:(UIColor *)color
                     ofSize:(CGSize)size
{
    CGRect rect = (CGRect) {
            .origin = CGPointZero,
            .size = size
    };
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end