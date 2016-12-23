//
//  JCStarkBanerView.m
//  JCBannerKit
//
//  Created by pg on 16/11/8.
//  Copyright © 2016年 starkShen. All rights reserved.
//
// timer 修饰问题
// 是否使用可变
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
// 

#import "SDImageCache.h"
#import "SDWebImageManager.h"

#import "JCStarkBanerView.h"
typedef NS_ENUM(NSInteger, RollingBannerDirection) {
    RollingBannerDirection_Left = -1,
    RollingBannerDirection_Right = 1,
};

@interface JCStarkBanerView ()<UIScrollViewDelegate>

@property (nonatomic, weak) NSTimer *starkTimer;// 自动轮播

@property (nonatomic, assign) NSInteger networkFailedRetryCount; // 加载失败处理

@property (nonatomic, strong) UIImageView *leftImage;

@property (nonatomic, strong) UIImageView *midImage;

@property (nonatomic, strong) UIImageView *rightImage;

@property (nonatomic, strong) UIView *containterView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, assign)CGFloat portion;

@property (nonatomic, assign)CGFloat lastMove;


@end

@implementation JCStarkBanerView

- (instancetype)initWithFrame:(CGRect)frame withPicArray:(NSArray *)picArray
{
    // 默认从第一张开始轮播
    return [self initWithFrame:frame withPicArray:picArray beginScrollFromIndex:0];
}

- (instancetype)initWithFrame:(CGRect)frame withPicArray:(NSArray *)picArray beginScrollFromIndex:(NSInteger)index
{
    if (self = [super initWithFrame:frame]) {
        self.delegate = self;
        self.portion = 0.6f;
        self.imageURLArray = picArray;
        self.contentSize = CGSizeMake(self.bounds.size.width *3, 0);
        self.contentOffset = CGPointMake(self.bounds.size.width, 0);
        self.pagingEnabled = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = NO;
        self.layer.masksToBounds = YES;
        
        [self resetSubView];
    }
    return self;
}

- (void)resetSubView
{
    NSInteger leftIndex = self.pageControl.currentPage - 1;
    if (leftIndex<0) {
        leftIndex = self.imageURLArray.count - 1;
    }
    [self loadImage:self.leftImage atIndex:leftIndex];
    self.leftImage.tag = leftIndex;
    
    [self loadImage:self.midImage atIndex:self.pageControl.currentPage];
    self.midImage.tag = self.pageControl.currentPage;
    
    NSInteger rightIndex = self.pageControl.currentPage +1;
    if (rightIndex>self.imageURLArray.count) {
        rightIndex = 0;
    }
    [self loadImage:self.rightImage atIndex:rightIndex];
    self.rightImage.tag = rightIndex;

    [self bringSubviewToFront:self.containterView];
    [self sendSubviewToBack:self.leftImage];
    [self sendSubviewToBack:self.rightImage];
    [self setContentOffset:CGPointMake(self.bounds.size.width, 0) animated:NO];
}

#pragma mark - Life Cycle
#pragma mark - getter && setter
- (UIView *)containterView
{
    if (!_containterView) {
        _containterView = [UIImageView new];
        _containterView.frame = CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height);
        _containterView.clipsToBounds = YES;// 裁剪到边界
        [self addSubview:_containterView];
    }
    return _containterView;
}
- (UIImageView *)leftImage
{
    if (!_leftImage) {
        _leftImage = [UIImageView new];
        _leftImage.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [self insertSubview:self.leftImage  belowSubview:self.containterView];
//        leftImage放到containterView下面

    }
    return _leftImage;
}

- (UIImageView *)midImage {
    if (!_midImage) {
        _midImage = [UIImageView new];
//        _midImage.clipsToBounds = YES;
        _midImage.frame = self.containterView.bounds;
        [self.containterView addSubview:_midImage];

    }
    return _midImage;
}

- (UIImageView *)rightImage {
    if (!_rightImage) {
        _rightImage = [UIImageView new];
        _rightImage.frame = CGRectMake(self.bounds.size.width*2, 0, self.bounds.size.width, self.bounds.size.height);
        [self insertSubview:self.rightImage  belowSubview:self.containterView];

    }
    return _rightImage;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPage = 0;
    }
    return _pageControl;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat moveX = scrollView.contentOffset.x - self.bounds.size.width;
    if (fabs(self.lastMove) >= self.bounds.size.width) {
        [self resetSubView];
        self.lastMove = 0;
        return;
    }
    [self adjustSubViews:moveX];
    
    
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    

}

#pragma mark - 自动轮播
#pragma mark - 图片缓存
- (void)loadImage:(UIImageView *)imageView atIndex:(NSInteger)index
{
    NSString *urlStr = self.imageURLArray[index];
    NSURL *url = nil;
    
    if ([urlStr isKindOfClass:[NSString class]]) {
        url = [NSURL URLWithString:urlStr];
    } else if ([urlStr isKindOfClass:[NSURL class]]) { // 兼容NSURL
        url = (NSURL *)urlStr;
    }
    
    UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
    if (image) {
        [imageView setImage:image];
    } else {
        [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                if (index < self.imageURLArray.count && [self.imageURLArray[index] isEqualToString:urlStr]) { // 修复频繁刷新异步数组越界问题
                    [imageView setImage:image];
                }
            } else {
                //  处理加载异常
                if (self.networkFailedRetryCount > 30) return;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self loadImage:imageView atIndex:index];
                });
                self.networkFailedRetryCount++;
            }
        }];
    }
}

- (void)adjustSubViews:(CGFloat)moveX{
    [self move:self.midImage from:0 byX:moveX * (1 - self.portion)];
    [self move:self.leftImage from:self.bounds.size.width * (1- self.portion) byX:moveX * (1- self.portion)];
    [self move:self.rightImage from:self.bounds.size.width * (1 + self.portion) byX:(moveX) *  (1 - self.portion)];
}

- (void)move:(UIView *)view from:(CGFloat)start byX:(CGFloat)x {
    CGRect frame = view.frame;
    frame.origin.x = x + start;
    view.frame = frame;
}

#pragma mark - PageControl
//- (void)setPageControlDotSize:(CGSize)pageControlDotSize
//{
//    _dotSize = pageControlDotSize;
//    [self setupPageControl];
//    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
//        TAPageControl *pageContol = (TAPageControl *)_pageControl;
//        pageContol.dotSize = pageControlDotSize;
//    }
//}
//
//- (void)setShowPageControl:(BOOL)showPageControl
//{
//    _showPageControl = showPageControl;
//    
//    _pageControl.hidden = !showPageControl;
//}
//
//- (void)setDotColor:(UIColor *)dotColor
//{
//    _dotColor = dotColor;
//    if ([self.pageControl isKindOfClass:[TAPageControl class]]) {
//        TAPageControl *pageControl = (TAPageControl *)_pageControl;
//        pageControl.dotColor = dotColor;
//    } else {
//        UIPageControl *pageControl = (UIPageControl *)_pageControl;
//        pageControl.currentPageIndicatorTintColor = dotColor;
//    }
//    
//}
//
//- (void)setPageControlStyle:(SDCycleScrollViewPageContolStyle)pageControlStyle
//{
//    _pageControlStyle = pageControlStyle;
//    
//    [self setupPageControl];
//}
//
//
//- (void)setupPageControl
//{
//    if (_pageControl) [_pageControl removeFromSuperview]; // 重新加载数据时调整
//    
//    if ((self.imagesGroup.count <= 1) && self.hidesForSinglePage) {
//        return;
//    }
//    
//    switch (self.pageControlStyle) {
//        case SDCycleScrollViewPageContolStyleAnimated:
//        {
//            TAPageControl *pageControl = [[TAPageControl alloc] init];
//            pageControl.numberOfPages = self.imagesGroup.count;
//            pageControl.dotColor = self.dotColor;
//            [self addSubview:pageControl];
//            _pageControl = pageControl;
//        }
//            break;
//            
//        case SDCycleScrollViewPageContolStyleClassic:
//        {
//            UIPageControl *pageControl = [[UIPageControl alloc] init];
//            pageControl.numberOfPages = self.imagesGroup.count;
//            pageControl.currentPageIndicatorTintColor = self.dotColor;
//            [self addSubview:pageControl];
//            _pageControl = pageControl;
//        }
//            break;
//            
//        default:
//            break;
//    }
//}


@end
