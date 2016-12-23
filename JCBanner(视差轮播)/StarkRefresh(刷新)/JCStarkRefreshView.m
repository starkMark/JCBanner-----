//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "JCStarkConst.h"
#import "JCStarkRefreshView.h"
#define RefreshOffset 30
static CGFloat const kTransformRotateRate = 0.05 * M_PI;

@interface JCStarkRefreshView()
@property (nonatomic,assign)CGFloat lastOffsetY;
@end

@implementation JCStarkRefreshView
+ (instancetype)refreshWithPostion:(JCRefreshPosition)postion;
{
    CGRect rect;
    
    switch (postion) {
        case JCRefreshPositionTop:
            rect = CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 15, 0, 30, 30);
            break;
        case JCRefreshPositionLeft:
            rect = CGRectMake(50, 0, 30, 30);
            break;
        case JCRefreshPositionRight:
            rect = CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 0, 30, 30);
            break;
        default:
            rect = CGRectMake([UIScreen mainScreen].bounds.size.width - 50, 0, 30, 30);
            break;
    }
        
    return [[JCStarkRefreshView alloc] initWithFrame:rect];

}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.animationImage.hidden = YES;
        self.animationImage.alpha = 0;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 设置自己的位置和尺寸
}

#pragma mark - 监听UIScrollView的contentOffset属性
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // 不能跟用户交互就直接返回
    if (!self.userInteractionEnabled || self.alpha <= 0.01 || self.hidden) return;
    
    // 如果正在刷新，直接返回
    if (self.state == JCRefreshStateRefreshing) return;
    
    if ([JCRefreshContentOffset isEqualToString:keyPath]) {
        [self adjustStateWithContentOffset];
    }
}

/**
 *  调整状态
 */
- (void)adjustStateWithContentOffset
{
    // 当前的contentOffset
    CGFloat currentOffsetY = self.scrollView.contentOffset.y;
    // 头部控件刚好出现的offsetY
    CGFloat happenOffsetY = 0;
    
    // 如果是向上滚动到看不见头部控件，直接返回
    if (currentOffsetY >= happenOffsetY) return;
    
    if (currentOffsetY > -10) {
        [UIView animateWithDuration:0.5 animations:^{
            self.animationImage.alpha = 0;
        } completion:^(BOOL finished) {
            self.animationImage.hidden = YES;
        }];
    }else{
        self.animationImage.hidden = NO;
        [UIView animateWithDuration:0.35 animations:^{
            self.animationImage.alpha = 1;
        } completion:nil];
    }
    
    if (self.scrollView.isDragging) {
        
        if (self.lastOffsetY) {
            if (self.lastOffsetY > currentOffsetY) {
                //  向上滑动
                if(![self.animationImage.layer animationForKey:@"rotationAnimation"])[self transformWithClockwise:YES];

            }else{
                //  向下滑动
                if(![self.animationImage.layer animationForKey:@"rotationAnimation"])[self transformWithClockwise:NO];

            }
        }
        
        self.lastOffsetY = currentOffsetY;
        
        // 普通 和 即将刷新 的临界点
        CGFloat normal2pullingOffsetY = happenOffsetY - self.bounds.size.height;
        
        if (self.state == JCRefreshStateNormal && currentOffsetY < normal2pullingOffsetY) {
            // 转为即将刷新状态
            self.state = JCRefreshStatePulling;
        }else if (self.state == JCRefreshStatePulling && currentOffsetY >= normal2pullingOffsetY) {
            // 转为普通状态
            self.state = JCRefreshStateNormal;
        }
    } else if (self.state == JCRefreshStatePulling) {// 即将刷新 && 手松开
            // 开始刷新
            self.state = JCRefreshStateRefreshing;
    }
}
- (void)transformWithClockwise:(BOOL)clockwise{
    if (self.animationImage != nil) {
        self.animationImage.transform = CGAffineTransformRotate(self.animationImage.transform,clockwise ? kTransformRotateRate : -kTransformRotateRate);
    }
}

#pragma mark 设置状态
- (void)setState:(JCRefreshState)state
{
    // 1.一样的就直接返回
    if (self.state == state) return;
    
    // 2.保存旧状态
    JCRefreshState oldState = self.state;
    
    // 3.调用父类方法
    [super setState:state];
    
    self.animationImage.hidden = NO;
    self.animationImage.alpha = 1;
    
    // 4.根据状态执行不同的操作
    switch (state) {
        case JCRefreshStateNormal:
        {
            // 刷新完毕
            if (JCRefreshStateRefreshing == oldState) {
                // 保存刷新时间
                [self.animationImage.layer removeAllAnimations];
                [UIView animateWithDuration:0.35 animations:^{
                    CGRect frame = self.frame;
                    frame.origin.y = 0;
                    self.frame = frame;
                    self.animationImage.alpha = 0;
                } completion:^(BOOL finished) {
                    self.animationImage.hidden = YES;
                }];
                NSLog(@"4444444");
                
            } else {
                // 初始状态
                // 停止动画
                NSLog(@"11111111");
            }
            
            break;
        }
            
        case JCRefreshStatePulling: // 松开可立即刷新
        {
            //下拉状态
            NSLog(@"2222222");
            break;
        }
            
        case JCRefreshStateRefreshing: // 正在刷新中
        {
            NSLog(@"3333333");
            
            //刷新中
            CGRect frame = self.frame;
            frame.origin.y = RefreshOffset;
            self.frame = frame;
            
            [self.animationImage.layer removeAllAnimations];
            CABasicAnimation* rotationAnimation;
            rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
            rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
            rotationAnimation.duration = 0.8;
            rotationAnimation.cumulative = YES;
            rotationAnimation.repeatCount = CGFLOAT_MAX;
            [self.animationImage.layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
            
            break;
        }
            
        default:
            break;
    }
}

@end
