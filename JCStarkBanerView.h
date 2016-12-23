//
//  JCStarkBanerView.h
//  JCBannerKit
//
//  Created by pg on 16/11/8.
//  Copyright © 2016年 starkShen. All rights reserved.
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

#import <UIKit/UIKit.h>
/** Define Enum */
typedef enum {
    JCPageContolAlimentRight,
    JCPageContolAlimentCenter
} JCPageContolAliment;               // PageControl 显示位置

typedef enum {
    JCPageContolStyleClassic,        // PageControl 经典样式
    JCPageContolStyleAnimated,       // PageControl 动画效果
    JCPageContolStyleNone            // PageControl 不显示
} JCPageContolStyle;


/** Protocol */
@protocol JCBannerDelegate <NSObject>
- (void)didSelectStarkBannerAtIndex:(NSInteger)index;

@end


@interface JCStarkBanerView : UIScrollView

/** Banner Settings*/
@property (nonatomic, assign) BOOL autoScroll;// 是否自动滚动,默认Yes

@property (nonatomic, assign) CGFloat autoScrollInterval;// 自动滚动间隔时间,默认3s

@property (nonatomic, strong) NSArray *imageURLArray;// 网络图片 URL字符串数组

@property (nonatomic, strong) NSArray *titleArray;// 图片对应要显示的文字数组

@property (nonatomic, weak) id<JCBannerDelegate> bannerDelegate;


/** Define PageControl*/
@property (nonatomic, assign) CGSize dotSize; // 点大小

@property (nonatomic, strong) UIColor *dotColor;// 点颜色

@property (nonatomic, assign) BOOL showPageControl;// PageControl 是否显示

@property (nonatomic, assign) JCPageContolAliment pageControlAliment;// 位置

@property (nonatomic, assign) JCPageContolStyle pageControlStyle;// 样式

@property (nonatomic, strong) UIColor *titleLabelTextColor;

@property (nonatomic, strong) UIFont  *titleLabelTextFont;

@property (nonatomic, strong) UIColor *titleLabelBackgroundColor;

@property (nonatomic, assign) CGFloat titleLabelHeight;

/**
 * 初始化方法
 */
- (instancetype)initWithFrame:(CGRect)frame withPicArray:(NSArray *)picArray;
/**
 * beginScrollFromIndex ：从 index 开始滚动
 */
- (instancetype)initWithFrame:(CGRect)frame withPicArray:(NSArray *)picArray beginScrollFromIndex:(NSInteger)index;

@end
