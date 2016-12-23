//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>
@class JCStarkRrefreshBaseView;
#pragma mark - 控件的刷新状态
typedef enum {
    JCRefreshStatePulling = 1, // 下拉松开刷新的状态
    JCRefreshStateNormal = 2, // 普通状态
    JCRefreshStateRefreshing = 3, // 正在刷新中的状态
    JCRefreshStateWillRefreshing = 4
} JCRefreshState;
typedef enum {
    JCRefreshPositionTop = 0,
    JCRefreshPositionLeft = 1,
    JCRefreshPositionRight = 2, // Defalut
    JCRefreshPositionBottomLeft = 3,
    JCRefreshPositionBottomRight = 4
} JCRefreshPosition;
@interface JCStarkRrefreshBaseView : UIView

#pragma mark - 父控件
@property (nonatomic, weak, readonly) UIScrollView *scrollView;
@property (nonatomic, assign, readonly) UIEdgeInsets scrollViewOriginalInset;

#pragma mark - 内部的控件
@property (nonatomic, weak, readonly) UIImageView *animationImage;

#pragma mark - 回调
/**
 *  开始进入刷新状态的监听器
 */
@property (weak, nonatomic) id beginRefreshingTaget;
/**
 *  开始进入刷新状态的监听方法
 */
@property (assign, nonatomic) SEL beginRefreshingAction;
/**
 *  开始进入刷新状态就会调用
 */
@property (nonatomic, copy) void (^beginRefreshingCallback)();

#pragma mark - 刷新相关
/**
 *  是否正在刷新
 */
@property (nonatomic, readonly, getter=isRefreshing) BOOL refreshing;
/**
 *  开始刷新
 */
- (void)beginRefreshing;
/**
 *  结束刷新
 */
- (void)endRefreshing;

#pragma mark - 交给子类去实现 和 调用
@property (assign, nonatomic) JCRefreshState state;

@end
