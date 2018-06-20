//
//  IEMosaicTool.h
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/20.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface IEMosaicTool : NSObject

+ (UIImage *)createMosaicImageFromSourceImage:(UIImage *)image level:(NSInteger)level;

@end
