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

@interface UIScrollView (JCRefresh)
#pragma mark - 下拉刷新
/**
 *  添加一个下拉刷新控件
 *
 *  @param callback 回调
 */
- (void)addRefreshWithCallback:(void (^)())callback;

/**
 *  添加一个下拉刷新控件
 *
 *  @param target 目标
 *  @param action 回调方法
 */
- (void)addRefreshWithTarget:(id)target action:(SEL)action;

/**
 *  移除下拉刷新控件
 */
- (void)removeRefreshView;

/**
 *  主动让下拉刷新控件进入刷新状态
 */
- (void)refreshBeginRefreshing;

/**
 *  让下拉刷新控件停止刷新状态
 */
- (void)refreshEndRefreshing;

/**
 *  下拉刷新控件的可见性
 */
@property (nonatomic, assign, getter = isRefreshHidden) BOOL refreshHidden;

@end
