//
//  GravityParallaxImages.h
//  
//
//  Created by Tywin on 2018/12/3.
//  Copyright © 2018 Tywin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GravityParallaxImages : UIView


@property(nonatomic, copy) NSArray *imgDataArr;//图片序列(层次:最底层---->最上层)

/*
   停止各种基于陀螺仪的使用和监听
 */
- (void)stopParallax;

/*
   直接保存图片
 */
- (void)saveImage;

/*
   合并后的图片
 */
- (void)mergeImage:(void(^)(UIImage *image))imageBlock;

@end

NS_ASSUME_NONNULL_END
