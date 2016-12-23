//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//


/**
 * <#Method#> : <#method#>
 * <#Param#>  : <#Param#>
 * <#Return#> : <#return#>
 */

#define BannerHeight 200

#import "JCRefresh.h"
#import "JCParallaxBanner.h"

#import "ViewController.h"
//#import "JCStarkBanerView.h"

@interface ViewController ()<JCBannerDelegate,UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) JCParallaxBanner *banner;

@end

@implementation ViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.frame];
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height + 200);
    self.scrollView.clipsToBounds = YES;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview: self.scrollView];

    self.scrollView.delegate = self;

    _banner = [JCParallaxBanner parallaxBannerViewWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, BannerHeight) placeholderImage:nil imageURLArray:@[@"http://www.jc.com/site/about/upload/cms/56a8785e6672a.jpg",@"http://www.jc.com/site/about/upload/cms/55c1c23de1e09.jpg",@"http://www.jc.com/site/about/upload/cms/55c1c23de1e09.jpg",@"http://www.jc.com/site/about/upload/cms/55ac6bb93c56b.jpg",@"http://www.jc.com/site/about/upload/cms/5656d844ccc40.jpg"]]; // 模拟网络延时情景
    _banner.bannerDelegate = self;
    [self.scrollView addSubview:_banner];
    
    [self.scrollView addRefreshWithTarget:self action:@selector(aa)];

}

- (void)aa{
    
    [self.scrollView performSelector:@selector(refreshEndRefreshing)  withObject:nil afterDelay:1.5];
}

#pragma mark - 下拉
#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    

    if (scrollView.contentOffset.y<0) {
        self.banner.autoScroll = NO;
        
        CGRect frame = self.banner.frame;
        //  MAX 取较大值
        frame.size.height =  MAX((BannerHeight - scrollView.contentOffset.y),0);
        frame.origin.y = scrollView.contentOffset.y;
        self.banner.frame = frame;
        self.banner.parallaxCollectionView.frame = frame;
        
        CGRect frame1 = self.banner.frame;
        frame1.size.height = frame.size.height;
        frame1.origin.y = 0;
        UIImageView *imageView = [self.banner imageViewOfCurrentCollectionCell];
        imageView.frame = frame1;
        
    }else{
        self.banner.autoScroll = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // 手动滑动时自动轮播关闭
    if (self.banner.autoScroll) {
        self.banner.autoScroll = NO;
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    // 手动滑动结束时自动轮播继续
    if (self.banner.autoScroll) {
        self.banner.autoScroll = YES;
    }
}

- (void)didSelectStarkBannerAtIndex:(NSInteger)index
{
    
    NSLog(@"================%ld===============",index);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
//    return self.banner.parallaxCollectionView;
//}


//    添加上移动化
//    }else if (scrollView.contentOffset.y > 0){
//
//        CGRect frame = self.banner.frame;
//        //  MAX 取较大值
//        frame.size.height =  MAX((BannerHeight - scrollView.contentOffset.y),0);
//        frame.origin.y = 0;
//        self.banner.frame = frame;
//        self.banner.parallaxCollectionView.frame = frame;
//
//        CGRect frame1 = self.banner.frame;
//        frame1.size.height = frame.size.height;
//        frame1.origin.y = 0;
//        UIImageView *imageView = [self.banner imageViewOfCurrentCollectionCell];
//        imageView.frame = frame1;
//    }
@end
