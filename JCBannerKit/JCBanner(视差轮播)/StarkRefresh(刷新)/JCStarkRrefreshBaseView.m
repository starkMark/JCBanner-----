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
#import "JCStarkRrefreshBaseView.h"
#import <objc/message.h>

@interface JCStarkRrefreshBaseView()
{
    __weak UIImageView *_animationImage;
}
@end
@implementation JCStarkRrefreshBaseView
/**
 *  animationImage
 */
- (UIImageView *)animationImage
{
    if (!_animationImage) {
        UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wechat_moment"]];
        arrowImage.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        [self addSubview:_animationImage = arrowImage];
    }
    return _animationImage;
}

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 1.自己的属性
        // self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        
        // 2.设置默认状态
        self.state = JCRefreshStateNormal;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat arrowX = self.bounds.size.width * 0.5 ;
    self.animationImage.center = CGPointMake(arrowX, self.bounds.size.height * 0.5);
    
}


- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    // 旧的父控件
    [self.superview removeObserver:self forKeyPath:JCRefreshContentOffset context:nil];
    
    if (newSuperview) { // 新的父控件
        
        [newSuperview addObserver:self forKeyPath:JCRefreshContentOffset options:NSKeyValueObservingOptionNew context:nil];
        
        // 记录UIScrollView
        _scrollView = (UIScrollView *)newSuperview;
        // 记录UIScrollView最开始的contentInset
        //_scrollViewOriginalInset = _scrollView.contentInset;
    }
}

#pragma mark - 显示到屏幕上
- (void)drawRect:(CGRect)rect
{
    if (self.state == JCRefreshStateWillRefreshing) {
        self.state = JCRefreshStateRefreshing;
    }
}

#pragma mark - 刷新相关
#pragma mark 是否正在刷新
- (BOOL)isRefreshing
{
    return JCRefreshStateRefreshing == self.state;
}

#pragma mark 开始刷新
- (void)beginRefreshing
{
    if (self.window) {
        self.state = JCRefreshStateRefreshing;
    } else {
        //#warning 不能调用set方法
        _state = JCRefreshStateWillRefreshing;
        [super setNeedsDisplay];
    }
}

#pragma mark 结束刷新
- (void)endRefreshing
{
    double delayInSeconds = 0.3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        self.state = JCRefreshStateNormal;
    });
}


- (void)setState:(JCRefreshState)state
{
    // 0.存储当前的contentInset
    if (self.state != JCRefreshStateRefreshing) {
        //        _scrollViewOriginalInset = self.scrollView.contentInset;
    }
    
    // 1.一样的就直接返回
    if (self.state == state) return;
    
    // 2.根据状态执行不同的操作
    switch (state) {
        case JCRefreshStateNormal: // 普通状态
        {
            break;
        }
            
        case JCRefreshStatePulling:
            break;
            
        case JCRefreshStateRefreshing:
        {
            // 回调
            if ([self.beginRefreshingTaget respondsToSelector:self.beginRefreshingAction]) {
                objc_msgSend(self.beginRefreshingTaget, self.beginRefreshingAction, self);
            }
            
            if (self.beginRefreshingCallback) {
                self.beginRefreshingCallback();
            }
            break;
        }
        default:
            break;
    }
    
    // 3.存储状态
    _state = state;
    
}

@end

