//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "UIScrollView+JCRefresh.h"
#import "JCStarkRefreshView.h"
#import <objc/runtime.h>

@interface UIScrollView()
@property (weak, nonatomic) JCStarkRefreshView *refreshView;
@end

@implementation UIScrollView (JCRefresh)
static char JCStarkRefreshViewKey;
- (void)setRefreshView:(JCStarkRefreshView *)refreshView {
    [self willChangeValueForKey:@"JCRefreshHeaderViewKey"];
    objc_setAssociatedObject(self, &JCStarkRefreshViewKey,
                             refreshView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"JCRefreshHeaderViewKey"];
}

- (JCStarkRefreshView *)refreshView {
    return objc_getAssociatedObject(self, &JCStarkRefreshViewKey);
}


- (void)addRefreshWithCallback:(void (^)())callback{

    // 1.创建新的刷新组件
    if (!self.refreshView) {
        JCStarkRefreshView *refreshView = [JCStarkRefreshView refreshWithPostion:JCRefreshPositionRight];
        [self addSubview:refreshView];
        self.refreshView = refreshView;
    }
    
    // 2.设置block回调
    self.refreshView.beginRefreshingCallback = callback;
}

/**
 *  添加一个下拉刷新头部控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addRefreshWithTarget:(id)target action:(SEL)action{
    // 1.创建新的header
    if (!self.refreshView) {
        JCStarkRefreshView *refreshView = [JCStarkRefreshView refreshWithPostion:JCRefreshPositionRight];
        //        [self insertSubview:header atIndex:[self.subviews count]];
        [self addSubview:refreshView];
        self.refreshView = refreshView;
    }
    
    // 2.设置目标和回调方法
    self.refreshView.beginRefreshingTaget = target;
    self.refreshView.beginRefreshingAction = action;
}

/**
 *  移除下拉刷新头部控件
 */
- (void)removeRefreshView{
    [self.refreshView removeFromSuperview];
    self.refreshView = nil;
}

/**
 *  主动让下拉刷新控件进入刷新状态
 */
- (void)refreshBeginRefreshing{
    [self.refreshView beginRefreshing];

}

/**
 *  让下拉刷新控件停止刷新状态
 */
- (void)refreshEndRefreshing{
    [self.refreshView endRefreshing];

}

/**
 *  下拉刷新控件的可见性
 */
- (void)setRefreshHidden:(BOOL)hidden{
    self.refreshView.hidden = hidden;
}

- (BOOL)isRefreshHidden{
    return self.refreshView.isHidden;
}

@end
