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

@interface ViewController : UIViewController

/*
 
 
 @property (nonatomic, weak) UICollectionView *mainView; // 显示图片的collectionView
 @property (nonatomic, weak) JCParallaxCollectionLayout *flowLayout;
 @property (nonatomic, strong) NSMutableArray *imagesGroup;
 @property (nonatomic, weak) NSTimer *timer;
 @property (nonatomic, assign) NSInteger totalItemsCount;
 @property (nonatomic, weak) UIControl *pageControl;
 
 @property (nonatomic, weak) UIImageView *backgroundImageView; // 当imageURLs为空时的背景图
 @property (nonatomic, strong) NSArray *localizationImagesGroup;
 
 @property (nonatomic, assign) NSInteger networkFailedRetryCount;
 
 
 
 @end
 @implementation JCParallaxBanner
 
 - (instancetype)initWithFrame:(CGRect)frame
 {
 if (self = [super initWithFrame:frame]) {
 //        [self initialization];
 [self setupMainView];
 }
 return self;
 }
 
 
 + (instancetype)cycleScrollViewWithFrame:(CGRect)frame imageURLStringsGroup:(NSArray *)imageURLsGroup
 {
 JCParallaxBanner *cycleScrollView = [[self alloc] initWithFrame:frame];
 cycleScrollView.imageURLStringsGroup = [NSMutableArray arrayWithArray:imageURLsGroup];
 return cycleScrollView;
 }
 
 // 设置显示图片的collectionView
 - (void)setupMainView
 {
 _infiniteLoop = YES;
 
 JCParallaxCollectionLayout *parallaxLayout = [[JCParallaxCollectionLayout alloc]init];
 _flowLayout = parallaxLayout;
 
 UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:parallaxLayout];
 mainView.backgroundColor = [UIColor clearColor];
 mainView.pagingEnabled = YES;
 mainView.showsHorizontalScrollIndicator = NO;
 mainView.showsVerticalScrollIndicator = NO;
 
 [mainView registerClass:[JCCollectionViewCell class] forCellWithReuseIdentifier:[JCCollectionViewCell reuseIdentifier]];
 mainView.dataSource = self;
 mainView.delegate = self;
 [self addSubview:mainView];
 _mainView = mainView;
 }
 
 
 #pragma mark - properties
 - (void)setFrame:(CGRect)frame
 {
 [super setFrame:frame];
 
 _flowLayout.parallaxItemSize = self.frame.size;
 }
 
 - (void)setPlaceholderImage:(UIImage *)placeholderImage
 {
 _placeholderImage = placeholderImage;
 
 if (!self.backgroundImageView) {
 UIImageView *bgImageView = [UIImageView new];
 [self insertSubview:bgImageView belowSubview:self.mainView];
 self.backgroundImageView = bgImageView;
 }
 
 self.backgroundImageView.image = placeholderImage;
 }
 
 - (void)setImagesGroup:(NSMutableArray *)imagesGroup
 {
 _imagesGroup = imagesGroup;
 
 //    _totalItemsCount = self.infiniteLoop ? self.imagesGroup.count * 100 : self.imagesGroup.count;
 _totalItemsCount = self.imagesGroup.count;
 if (imagesGroup.count != 1) {
 self.mainView.scrollEnabled = YES;
 [self setAutoScroll:self.autoScroll];
 } else {
 self.mainView.scrollEnabled = NO;
 }
 [self.mainView reloadData];
 }
 
 - (void)setImageURLStringsGroup:(NSArray *)imageURLStringsGroup
 {
 _imageURLStringsGroup = imageURLStringsGroup;
 
 NSMutableArray *images = [NSMutableArray arrayWithCapacity:imageURLStringsGroup.count];
 for (int i = 0; i < imageURLStringsGroup.count; i++) {
 UIImage *image = [[UIImage alloc] init];
 [images addObject:image];
 }
 self.imagesGroup = images;
 [self loadImageWithImageURLsGroup:imageURLStringsGroup];
 }
 
 - (void)setLocalizationImagesGroup:(NSArray *)localizationImagesGroup
 {
 _localizationImagesGroup = localizationImagesGroup;
 self.imagesGroup = [NSMutableArray arrayWithArray:localizationImagesGroup];
 }
 
 #pragma mark - actions
 - (void)loadImageWithImageURLsGroup:(NSArray *)imageURLsGroup
 {
 for (int i = 0; i < imageURLsGroup.count; i++) {
 [self loadImageAtIndex:i];
 }
 }
 
 - (void)loadImageAtIndex:(NSInteger)index
 {
 NSString *urlStr = self.imageURLStringsGroup[index];
 NSURL *url = nil;
 
 
 if ([urlStr isKindOfClass:[NSString class]]) {
 url = [NSURL URLWithString:urlStr];
 } else if ([urlStr isKindOfClass:[NSURL class]]) { // 兼容NSURL
 url = (NSURL *)urlStr;
 }
 
 UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:urlStr];
 if (image) {
 [self.imagesGroup setObject:image atIndexedSubscript:index];
 } else {
 [[SDWebImageManager sharedManager] downloadImageWithURL:url options:SDWebImageRetryFailed progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
 if (image) {
 if (index < self.imageURLStringsGroup.count && [self.imageURLStringsGroup[index] isEqualToString:urlStr]) { // 修复频繁刷新异步数组越界问题
 [self.imagesGroup setObject:image atIndexedSubscript:index];
 dispatch_async(dispatch_get_main_queue(), ^{
 [self.mainView reloadData];
 });
 }
 } else {
 if (self.networkFailedRetryCount > 30) return;
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 [self loadImageAtIndex:index];
 });
 self.networkFailedRetryCount++;
 }
 }];
 }
 
 
 }
 
 
 - (void)automaticScroll
 {
 if (0 == _totalItemsCount) return;
 int currentIndex = _mainView.contentOffset.x / _flowLayout.parallaxItemSize.width;
 int targetIndex = currentIndex + 1;
 if (targetIndex == _totalItemsCount) {
 if (self.infiniteLoop) {
 targetIndex = _totalItemsCount * 0.5;
 }else{
 targetIndex = 0;
 }
 [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
 }
 [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
 }
 
 - (void)layoutSubviews
 {
 [super layoutSubviews];
 
 _mainView.frame = self.bounds;
 if (_mainView.contentOffset.x == 0 &&  _totalItemsCount) {
 int targetIndex = 0;
 if (self.infiniteLoop) {
 targetIndex = _totalItemsCount * 0.5;
 }else{
 targetIndex = 0;
 }
 [_mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
 }
 
 }
 
 #pragma mark - UICollectionViewDataSource
 - (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
 {
 return _totalItemsCount;
 }
 
 - (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
 {
 JCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[JCCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
 long itemIndex = indexPath.item % self.imagesGroup.count;
 UIImage *image = self.imagesGroup[itemIndex];
 if (image.size.width == 0 && self.placeholderImage) {
 image = self.placeholderImage;
 [self loadImageAtIndex:itemIndex];
 }
 cell.parallaxImageView.image = image;
 
 return cell;
 }
 
 
 #pragma mark - UIScrollViewDelegate
 //- (void)scrollViewDidScroll:(UIScrollView *)scrollView
 //{
 //    int itemIndex = (scrollView.contentOffset.x + self.mainView.sd_width * 0.5) / self.mainView.sd_width;
 //    if (!self.imagesGroup.count) return; // 解决清除timer时偶尔会出现的问题
 //    int indexOnPageControl = itemIndex % self.imagesGroup.count;
 //}
 
 - (void)scrollViewDidScroll:(UIScrollView *)scrollView{
 _currentIndex = scrollView.contentOffset.x/self.frame.size.width;//  .不调用 setter 方法
 
 NSInteger leftIndex = -1;
 NSInteger rightIndex = -1;
 
 leftIndex = _currentIndex;
 
 if(_currentIndex < (_totalItemsCount - 1)) {
 rightIndex = leftIndex + 1;
 }
 
 CGFloat leftImageMargingLeft = scrollView.contentOffset.x > 0 ? ((fmod(scrollView.contentOffset.x + self.frame.size.width,self.frame.size.width))):0.0f;
 CGFloat leftImageWidth = (self.frame.size.width) - (fmod(fabs(scrollView.contentOffset.x),self.frame.size.width));
 CGFloat rightImageMarginLeft = 0.0f;
 CGFloat rightImageWidth = leftImageMargingLeft;
 
 if(leftIndex >= 0){
 JCCollectionViewCell * leftCell = (JCCollectionViewCell*)[self.parallaxCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:leftIndex inSection:0]];
 CGRect frame = leftCell.parallaxImageView.frame;
 frame.origin.x = leftImageMargingLeft;
 frame.size.width = leftImageWidth;
 leftCell.parallaxImageView.frame = frame;
 }
 if(rightIndex >= 0){
 JCCollectionViewCell * rightCell = (JCCollectionViewCell*)[self.parallaxCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:rightIndex inSection:0]];
 CGRect frame = rightCell.parallaxImageView.frame;
 frame.origin.x = rightImageMarginLeft;
 frame.size.width = rightImageWidth;
 rightCell.parallaxImageView.frame = frame;
 }
 
 //    当滚动到最后一张图片时，继续滚向后动跳到第一张
 //            if (scrollView.contentOffset.x > self.frame.size.width * (self.imageURLArray.count -1) + _minOffset)
 //            {
 //                _currentIndex = 0;
 //                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
 //                [self.parallaxCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
 //            }
 //
 //    //当滚动到第一张图片时，继续向前滚动跳到最后一张
 //
 //            if (scrollView.contentOffset.x < - _minOffset)
 //            {
 //                _currentIndex = _imageURLArray.count -1;
 //                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.currentIndex inSection:0];
 //                [self.parallaxCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
 //            }
 NSLog(@"============%.2f==========",scrollView.contentOffset.x);
 
 }

 */
@end

