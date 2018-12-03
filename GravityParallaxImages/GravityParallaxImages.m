//
//  GravityParallaxImages.m
//
//
//  Created by Tywin on 2018/12/3.
//  Copyright © 2018 Tywin. All rights reserved.
//

#import "GravityView.h"
#import "UIView+MWParallax.h"

#define Base_Offset 5

@interface GravityParallaxImages()

@property(nonatomic, strong) NSMutableArray *mainImgArr;

@end

@implementation GravityParallaxImages


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.mainImgArr = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    [self stopParallax];
    _imgDataArr = nil;
    _mainImgArr = nil;
}

- (void)setImgDataArr:(NSArray *)imgDataArr
{
    _imgDataArr = imgDataArr;
    
    //干干净净的开始
    [_mainImgArr removeAllObjects];
    for(UIView *view in [self subviews]){
        view.viewParallaxIntensity = 0.0f;
        [view removeFromSuperview];
    }
    
    for (int i=0; i<imgDataArr.count-1; i++) {
        UIImageView *img_view  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgDataArr[i]]];
        img_view.backgroundColor = [UIColor clearColor];
        img_view.contentMode = UIViewContentModeScaleAspectFill;
        img_view.frame = CGRectMake(0, 0, self.frame.size.width+(imgDataArr.count-i)*Base_Offset, self.frame.size.height+(imgDataArr.count-i)*Base_Offset);
        img_view.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
        img_view.viewParallaxIntensity = (imgDataArr.count-i)*Base_Offset+0.0f;
        [self addSubview:img_view];
        [_mainImgArr addObject:img_view];
    }
    
    //默认最上层不参与视差效果
    UIImageView *front_img_view  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imgDataArr[imgDataArr.count-1]]];
    front_img_view.backgroundColor = [UIColor clearColor];
    front_img_view.contentMode = UIViewContentModeScaleAspectFill;
    front_img_view.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height+10);
    [self addSubview:front_img_view];
    [_mainImgArr addObject:front_img_view];
    
}

- (void)stopParallax
{
    if (_mainImgArr.count>0) {
        for (UIView *v in _mainImgArr) {
            v.viewParallaxIntensity = 0.0f;
        }
    }
}

- (void)saveImage
{
    if (_mainImgArr.count>1) {
        //将除底层以外的图片依次绘制在底层图片至上
        [self savedPhotosToAlbum:[self cutView]];
    }else{
        NSLog(@"只有一张图片不用绘制");
    }
}

- (void)mergeImage:(void(^)(UIImage *))imageBlock
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [self cutView];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (image!=nil) {
                imageBlock(image);
            }else{
                imageBlock(nil);
            }
        });
    });
}

//使用截图方式获得要保存的图片
- (UIImage *)cutView{
    
    UIView *targetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    for (int i=0; i<_imgDataArr.count; i++) {
        UIImageView *img_view  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_imgDataArr[i]]];
        img_view.backgroundColor = [UIColor clearColor];
        img_view.contentMode = UIViewContentModeScaleAspectFill;
        img_view.frame = CGRectMake(0, 0, self.frame.size.width+(_imgDataArr.count-i)*10, self.frame.size.height+(_imgDataArr.count-i)*10);
        img_view.center = CGPointMake(self.frame.size.width/2,self.frame.size.height/2);
        [targetView addSubview:img_view];
    }
    
    UIGraphicsBeginImageContextWithOptions(targetView.bounds.size, NO, 0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [targetView.layer renderInContext:ctx];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)savedPhotosToAlbum:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), (__bridge void *)self);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    
    NSLog(@"image = %@, error = %@, contextInfo = %@", image, error, contextInfo);
}

@end
