//
//  YBSCarouselTool.m
//  YBSCarouselTool
//
//  Created by 严兵胜 on 2018/6/5.
//  Copyright © 2018年 严兵胜. All rights reserved.
//

#import "YBSCarouselTool.h"
#import <SDImageCache.h>
#import <SDWebImageManager.h>
#import "UIView+Frame.h"
#import <Masonry.h>



#pragma mark - ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ YBSInfiniteScrollViewWebCache 网络图片加载工具 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

@interface UIImageView (YBSInfiniteScrollViewWebCache)

- (void)ybs_getImageFromeCacheWithImageUrl:(NSURL *)imageURL;

@end


@implementation UIImageView (YBSInfiniteScrollViewWebCache)

- (void)ybs_getImageFromeCacheWithImageUrl:(NSURL *)imageURL{
    
    if (imageURL == nil){
        
        self.image = [UIImage imageNamed:@"YBSCarouselTool.bundle/placeholderImage"]; // 默认站位图
        return;
    }
    
    UIImage *imageNone = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:imageURL.absoluteString];      // 内存
    if(!imageNone) imageNone = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURL.absoluteString];  // SD卡
    
    if (!imageNone) { // 如果 内存 和 SD卡 都没有 就去下载
        
        self.image = [UIImage imageNamed:@"YBSCarouselTool.bundle/placeholderImage"]; // 默认站位图
        
        [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options: SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            
            if (!image || error){
                self.image = [UIImage imageNamed:@"YBSCarouselTool.bundle/placeholderImage"];
                return ;
            }
            self.image = image;
        }];
    }
    self.image = imageNone;
}

@end


#pragma mark - ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ YBSCarouselToolCollectionViewLayout  ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

// 一般是继承于UICollectionViewLayout就行了 但是如果你自定义继承于UICollectionViewLayout，代表着你没有流水布局功能，也就是在你不想要流水布局功能的时候就选择继承UICollectionViewLayout
@interface YBSCarouselToolCollectionViewLayout : UICollectionViewFlowLayout

/// item 在缩小时 与其中间的item 在高度上的比例(取值0-1) -> 默认 0.7
@property (nonatomic, assign) CGFloat ybs_smallScaleFloat;

@end


@implementation YBSCarouselToolCollectionViewLayout

// 这个方法的返回值是一个数组（数组里面存放着rect范围内所有元素的布局属性） 这个方法的返回值决定了rect范围内所有元素的排布（frame）说白了就是决定你的cell摆在哪里，怎么去摆
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    // 获得super已经计算好的布局属性（在super已经算好的基础上，再去做一些改进）
    NSArray *array = [super layoutAttributesForElementsInRect:rect];

    // 计算collectionView最中心点的x值
    CGFloat centerX = self.collectionView.contentOffset.x + self.collectionView.frame.size.width * 0.5; // (要记住collectionView的坐标原点是以内容contentSize的原点为原点 计算collectionView中心点的x值，千万不要用collectionView的宽度除以2。而是用collectionView的偏移量加上collectionView宽度的一半 坐标原点弄错了就没有可比性了，因为后面要判断cell的中心点与collectionView中心点的差值)

    // 在原有布局属性的基础上进行微调
    for (UICollectionViewLayoutAttributes *attrs in array) {
        

        // cell的中心点x和collectionView最中心点的x值 的间距
        CGFloat delta = ABS(attrs.center.x - centerX); // ABS() 表示取绝对值
        
        if (delta > self.collectionView.frame.size.width) continue;

        // 根据间距值计算cell的缩放比例
        CGFloat scale = 1 - delta / self.collectionView.frame.size.width;
        
        // 设置缩放比例 最小为 (self.ybs_smallScaleFloat) 其余的发挥空间为(1 - self.ybs_smallScaleFloat)
        attrs.transform = CGAffineTransformMakeScale(1, self.ybs_smallScaleFloat + scale * (1 - self.ybs_smallScaleFloat));
    }
    
    return array;
}

/**
 * 用来做布局的初始化操作（不建议在init方法中进行布局的初始化操作--可能布局还未加到View中去，就会返回为空）
 */
- (void)prepareLayout{
    [super prepareLayout];
}

//  当collectionView的显示范围发生改变的时候，判断是否需要重新刷新布局
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds{
    
    return YES; // 默认return NO
}


// 它的返回值，就决定了collectionView停止滚动时的偏移量 这个方法在你手离开屏幕之前会调用，也就是cell即将停止滚动的时候 （记住这一点）
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    // 计算出最终显示的矩形框
    CGRect rect;
    rect.origin.y = 0;
    rect.origin.x = proposedContentOffset.x;
    rect.size = self.collectionView.frame.size;
    
    // 获得super已经计算好的布局属性
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    
    // 计算collectionView最中心点的x值
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    // 存放最小的间距值
    CGFloat minDelta = MAXFLOAT;
    for (UICollectionViewLayoutAttributes *attrs in array) {
        if (ABS(minDelta) > ABS(attrs.center.x - centerX)) {
            minDelta = attrs.center.x - centerX;
        }
    }
    
    // 修改原有的偏移量
    proposedContentOffset.x += minDelta;
    return proposedContentOffset;
}


@end



#pragma mark - ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ YBSCarouselToolCollectionCell cell ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

@interface YBSCarouselToolCollectionCell : UICollectionViewCell


/// bagView
@property (nonatomic, weak) UIView *ybs_bagView;
/// <# 请输入注释 #>
@property (nonatomic, weak) UIImageView *imageView;
/// 图片圆角大小 默认为0 无圆角
@property (nonatomic, assign) CGFloat ybs_cellImageCircularFloat;

@end


@implementation YBSCarouselToolCollectionCell


- (UIView *)ybs_bagView{
    
    if (!_ybs_bagView) {
        
        UIView *ybs_bagView = [UIView new];
        [self.contentView addSubview:_ybs_bagView = ybs_bagView];
    }
    return _ybs_bagView;
}

- (UIImageView *)imageView{
    
    if (!_imageView) {
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.cornerRadius = self.ybs_cellImageCircularFloat;
        imageView.clipsToBounds = true;
        [self.ybs_bagView addSubview:_imageView = imageView];
    }
    return _imageView;
}

- (void)setYbs_cellImageCircularFloat:(CGFloat)ybs_cellImageCircularFloat{
    
    _ybs_cellImageCircularFloat = ybs_cellImageCircularFloat;
    self.imageView.layer.cornerRadius = ybs_cellImageCircularFloat;
}



- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        self.ybs_bagView.backgroundColor = [UIColor whiteColor];// [UIColor colorWithRed:arc4random_uniform(256) / 255.0f green:arc4random_uniform(256) / 255.0f blue:arc4random_uniform(256) / 255.0f alpha:1];
        
        [self.ybs_bagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
        }];
        
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
        }];
        
    }
    
    return self;
}

@end







#pragma mark - ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓ YBSCarouselTool 轮播 ↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓

@interface YBSCarouselTool ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

/// <# 请输入注释 #>
@property (nonatomic, weak) UICollectionView *collectionView;
/// <# 请输入注释 #>
@property (nonatomic, weak) YBSCarouselToolCollectionViewLayout *ybs_flowLauout;
/// 为了保证在无法左右无限滚动的情况下 滚动到最左边 或者最右边 依然有良好的UI效果 而设计的占位Cell
@property (nonatomic, weak) UIView *ybs_placeholderView;
/// <# 请输入注释 #>
@property (nonatomic, weak) UIImageView *ybs_placeholderViewImageView;
/// 轮播定时器
@property(nonatomic, strong) NSTimer *ybs_timer;
/// 当前indexPath
@property (nonatomic, strong) NSIndexPath *ybs_curIndexPath;


@end

static NSString *const YBSCarouselToolCollectiongCellId = @"YBSCarouselToolCollectiongCell";
static NSInteger YBSItemCount = 30;


@implementation YBSCarouselTool



- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        
        [self setUpUI];
        
        // 有些都是有顺序关系的 请不要随意改动这里的赋值顺序
        self.ybs_smallScaleFloat = 0.7;
        self.ybs_neetInfinitiScrollEnabledBool = true;
        self.ybs_marketExpansionBool = true;
        self.ybs_clickMoveToCenterBool = true;
        self.ybs_timeIntervalInteger = 4;
        self.ybs_neetAutomaticCarouselBool = true;
        
    }
    
    return self;
}

- (void)setUpUI{
    
    
    // 流水布局
    YBSCarouselToolCollectionViewLayout *flowLauout = [[YBSCarouselToolCollectionViewLayout alloc] init];
    flowLauout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLauout.minimumLineSpacing = self.ybs_cellDistanceFlost;
    flowLauout.minimumInteritemSpacing = 0;
    flowLauout.itemSize = CGSizeMake(self.width, self.height);
    
    
    // UICollectionView
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) collectionViewLayout:_ybs_flowLauout = flowLauout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
//    collectionView.pagingEnabled = true;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.decelerationRate = UIScrollViewDecelerationRateNormal; // 速率
    
    // 注册cell -- 不暴露给外界
    [collectionView registerClass:[YBSCarouselToolCollectionCell class] forCellWithReuseIdentifier:YBSCarouselToolCollectiongCellId];
    [self addSubview:self.collectionView = collectionView];
    
}


#pragma mark - <UICollectionViewDataSource> 数据源方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return self.imageArray.count == 0? 1 : YBSItemCount * _imageArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    YBSCarouselToolCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:YBSCarouselToolCollectiongCellId forIndexPath:indexPath];
    cell.ybs_cellImageCircularFloat = self.ybs_circularFloat;
    
    // 设置轮播图片
    if (self.imageArray.count != 0) {
        
        id imageData = self.imageArray[indexPath.item % self.imageArray.count];
        if ([imageData isKindOfClass:[UIImage class]]) {
            
            cell.imageView.image = imageData;
            
        }else if ([imageData isKindOfClass:[NSURL class]]){
            
            [cell.imageView ybs_getImageFromeCacheWithImageUrl:imageData];
        }
        
    }else{ // 在没有传入任何图片的情况下 就直接显示占位图片
        
        NSLog(@"轮播_容错处理--没有传入任何图片");
        cell.imageView.image = [UIImage imageNamed:@"YBSCarouselTool.bundle/placeholderImage"];
    }
    return cell;
}



#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.ybs_clickMoveToCenterBool) return;
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:true];
    
    // 数据回传
    if ([self.delegate respondsToSelector:@selector(ybs_carouselTool:currentAtIndex:)]) {
        [self.delegate ybs_carouselTool:self currentAtIndex:indexPath.item % self.imageArray.count];
    }
}


#pragma mark - UIScrollViewDelegate

//只要view有滚动(不管是拖、拉、放大、缩小  等导致) 都会执行此函数
- (void)scrollViewDidScroll:(UIScrollView*)scrollView{
    
    // 只有在 非无限滚动 且 需要补位时 才执行下面的一大推
    if (!(!self.isybs_neetInfinitiScrollEnabledBool && self.isybs_placeholderViewBool)) return;
    

    CGFloat contentOffsetX = scrollView.contentOffset.x + self.collectionView.contentInset.left;
    
    NSLog(@"只要有滚动scrollViewDidScroll___contentOffsetX = %f",contentOffsetX);
    
    
    // 所有的item 的最大滚动距离 (最后一个 cell 会留在屏幕正中间 所以 -1  而最右侧的滚动间距 是通过额外滚动距离来实现的 最后一个cell 实际只有一个列间距)
    CGFloat allCellW = (self.imageArray.count * YBSItemCount - 1) * self.ybs_flowLauout.itemSize.width + (self.imageArray.count * YBSItemCount - 1) * self.ybs_cellDistanceFlost;
    
    
    // 获取这一点的indexPath
    CGPoint pInView = [self convertPoint:self.collectionView.center toView:self.collectionView];
    NSIndexPath *indexPathNow = [self.collectionView indexPathForItemAtPoint:pInView];
    // 防止 滑动到最后一个的时候继续拖拽 造成 indexPathNow.row == 0了
    indexPathNow = (contentOffsetX >= allCellW)? [NSIndexPath indexPathForRow:self.imageArray.count * YBSItemCount - 1 inSection:indexPathNow.section] : indexPathNow;
    
    // 控制补位视图的位置
    if (contentOffsetX <= self.ybs_flowLauout.itemSize.width && self.ybs_placeholderView) {
        self.ybs_placeholderView.right = contentOffsetX * -1 + self.ybs_leftRightDistanceFlost;
    }else{
        if (self.ybs_placeholderView)
            self.ybs_placeholderView.left = allCellW - contentOffsetX + (self.width - self.ybs_leftRightDistanceFlost);
    }
    
    
    // 控制补位视图的缩放
    contentOffsetX = (contentOffsetX < 0)? contentOffsetX * -1 : contentOffsetX;
    // 当 滚动不是在最左 或者 最右的时候 会出现负值 由于不影响我的功能 所以没有处理
    CGFloat scalOffsetX = contentOffsetX - indexPathNow.row * self.ybs_flowLauout.itemSize.width - (indexPathNow.row - 1) * self.ybs_cellDistanceFlost;
//    NSLog(@"self.collectionView.width = %f__self.ybs_flowLauout.itemSize.width = %f__contentOffsetX = %f___scalOffsetX = %f__第%ld个cell",self.collectionView.width, self.ybs_flowLauout.itemSize.width,contentOffsetX,scalOffsetX ,indexPathNow.row);
    // 缩放比例 我们有一个 最下缩放比例保护 剩下的才是变化空间
    CGFloat scal = scalOffsetX / self.ybs_flowLauout.itemSize.width;
    scal = (scal <= 0)? 0 : ((scal >= 1)? 1 : scal);
    self.ybs_placeholderView.transform = CGAffineTransformMakeScale(1, self.ybs_smallScaleFloat + scal * (1 - self.ybs_smallScaleFloat));
    
    // 配置图片
    [self.ybs_placeholderViewImageView ybs_getImageFromeCacheWithImageUrl:self.imageArray[indexPathNow.item % self.imageArray.count]];
}


// scrollView滚动完毕的时候调用(速度为0) (如果是通过 setContentOffset 来调整的位置 不会来这里)
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self ybs_resetPosition];
}

// 将要开始拖拽，手指已经放在view上并准备拖动的那一刻（开始滑动，滑动一小段距离，只要手指不松开，只算一次滑动只执行一次）
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    // 停止定时器
    [self stopTimer];
}

// 已经结束拖拽，手指刚离开view的那一刻(。一次有效滑动，只执行一次)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    // 开启定时器 (在允许定时轮播的情况下)
    if (self.ybs_neetAutomaticCarouselBool && self.ybs_timer == nil) [self startTimer];
}

// 当滚动视图动画完成后，调用该方法，如果没有动画，那么该方法将不被调用 (手指拖拽造成的滚动 不会来这里) (setContentOffset 来调整的位置  并且动画为YES 会来这里)
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    
    // 完成一次自动轮播之后 跳转cell居中显示 
    [self ybs_resetPosition];
}




#pragma mark - 参数赋值

// 配置cell 间距
- (void)setYbs_cellDistanceFlost:(CGFloat)ybs_cellDistanceFlost{
    
    _ybs_cellDistanceFlost = ybs_cellDistanceFlost;
    
    [self ybs_setCollectionViewContentInsetAndItemSize];
}

- (void)setYbs_leftRightDistanceFlost:(CGFloat)ybs_leftRightDistanceFlost{
    
    _ybs_leftRightDistanceFlost = ybs_leftRightDistanceFlost;
    // 如果cell间距 == 0 直接返回了
    if (self.ybs_cellDistanceFlost == 0) return;
    
    [self ybs_setCollectionViewContentInsetAndItemSize];
    
}

// 配置 缩小比例
- (void)setYbs_smallScaleFloat:(CGFloat)ybs_smallScaleFloat{
    
    _ybs_smallScaleFloat = ybs_smallScaleFloat;
    self.ybs_flowLauout.ybs_smallScaleFloat = ybs_smallScaleFloat;
}

- (void)setYbs_firstSelectedInteger:(NSInteger)ybs_firstSelectedInteger{
    
    _ybs_firstSelectedInteger = ybs_firstSelectedInteger;
    
    // 如果需要展示的图片为空 还搞个屁 当然第一次需要被选中的 肯定也是不可以大于总数的
    if (!self.imageArray.count || ybs_firstSelectedInteger > self.imageArray.count) return;
    
    [self ybs_scrollToItem];
}

// 是否需要无线滚动
- (void)setYbs_neetInfinitiScrollEnabledBool:(BOOL)ybs_neetInfinitiScrollEnabledBool{
    
    _ybs_neetInfinitiScrollEnabledBool = ybs_neetInfinitiScrollEnabledBool;
    
    if (ybs_neetInfinitiScrollEnabledBool){
        
        self.ybs_marketExpansionBool = true; // 强制 扩容
        self.ybs_placeholderViewBool = false; // 强制将 毛玻璃补位效果关闭
    }
}

// 配置是否需要扩容
- (void)setYbs_marketExpansionBool:(BOOL)ybs_marketExpansionBool{

    _ybs_marketExpansionBool = ybs_marketExpansionBool;
    YBSItemCount =  self.ybs_neetInfinitiScrollEnabledBool? 30 : ybs_marketExpansionBool? 30 : 1;
    
    if (!self.imageArray.count) return;
    
    [self ybs_scrollToItem];
}

// 是否会自动轮播
- (void)setYbs_neetAutomaticCarouselBool:(BOOL)ybs_neetAutomaticCarouselBool{
    
    _ybs_neetAutomaticCarouselBool = ybs_neetAutomaticCarouselBool;
    
    // 强制无限滚动
    self.ybs_neetInfinitiScrollEnabledBool = ybs_neetAutomaticCarouselBool;
    
    // 之前有创建
    if (ybs_neetAutomaticCarouselBool && self.ybs_timer) return;
    
    // 之前没有创建
    if (ybs_neetAutomaticCarouselBool && !self.ybs_timer) {
        self.ybs_timer = [NSTimer scheduledTimerWithTimeInterval:self.ybs_timeIntervalInteger target:self selector:@selector(ybs_nextPage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.ybs_timer forMode:NSRunLoopCommonModes];
    }
    
    // 之前有创建 但是 这次要销毁
    if (!ybs_neetAutomaticCarouselBool && self.ybs_timer) {
        [self.ybs_timer invalidate];
        self.ybs_timer = nil;
    }
}

// 定时轮播 时间间距
- (void)setYbs_timeIntervalInteger:(NSInteger)ybs_timeIntervalInteger{
    _ybs_timeIntervalInteger = ybs_timeIntervalInteger;
    self.ybs_neetAutomaticCarouselBool = (ybs_timeIntervalInteger > 0)? true : false;
}

// 配置圆角
- (void)setYbs_circularFloat:(CGFloat)ybs_circularFloat{
    
    _ybs_circularFloat = ybs_circularFloat;
    if (self.isybs_placeholderViewBool) self.ybs_placeholderView.layer.cornerRadius = ybs_circularFloat;
}

// 是否需要占位 只有在 非无限滚动 且 非定时轮播 下 起作用
- (BOOL)isYbs_placeholderViewBool{
//    NSLog(@"isybs_neetInfinitiScrollEnabledBool = %@___isybs_neetAutomaticCarouselBool = %@",self.isybs_neetInfinitiScrollEnabledBool? @"yes" : @"no", self.isybs_neetAutomaticCarouselBool? @"YES" : @"NO");
    return (self.ybs_neetInfinitiScrollEnabledBool || self.ybs_neetAutomaticCarouselBool)? false : _ybs_placeholderViewBool;
}



#pragma mark - 其他

//
- (void)setImageArray:(NSMutableArray *)imageArray{
    
    if (_imageArray.count) {
        [_imageArray removeAllObjects];
    }
    
    _imageArray = [NSMutableArray arrayWithArray:imageArray];
    
    
    if (imageArray.count) [self ybs_scrollToItem];
     
}

// 偏移collectionView 并处理回调
- (void)ybs_scrollToItem{
    
    [self.collectionView reloadData];
    
    // (YBSItemCount * imageArray.count) / 2 + (self.ybs_firstSelectedInteger) -> 首先我们定位到 最中间 由于collectionView 是从第0为开始计数 所以我们不需要向后偏移一位
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.ybs_marketExpansionBool? (YBSItemCount * _imageArray.count) / 2 + (self.ybs_firstSelectedInteger) : self.ybs_firstSelectedInteger inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    // 由于 如果一开始的偏移量为 0 scrollViewDidScroll 的代理不会被调用 那我们就主动调用一次 来保证 需要补位时的UI 
    if (self.ybs_firstSelectedInteger == 0)  [self scrollViewDidScroll:self.collectionView];
   
    
    // 回调当前选中页
    if ([self.delegate respondsToSelector:@selector(ybs_carouselTool:currentAtIndex:)]) {
        [self.delegate ybs_carouselTool:self currentAtIndex:(self.ybs_marketExpansionBool? ((YBSItemCount * _imageArray.count) / 2 + (self.ybs_firstSelectedInteger)) : self.ybs_firstSelectedInteger) % _imageArray.count];
    }
}

// 配置 itemSize 的大小 及 cell 间距 和额为滚动距离
- (void)ybs_setCollectionViewContentInsetAndItemSize{
    
    self.ybs_flowLauout.minimumLineSpacing = self.ybs_cellDistanceFlost; // cell 直接的间距
    // 最左边 及最右边 额外的滚动距离 为了保持 UI的风格
    self.collectionView.contentInset = UIEdgeInsetsMake(0, self.ybs_cellDistanceFlost + self.ybs_leftRightDistanceFlost, 0, self.ybs_cellDistanceFlost  + self.ybs_leftRightDistanceFlost); // collectionView 最左边 及 最右边 额外的滚动距离
    // 改变cell宽度 cell 左右各一个间距 并且为上一个 和 下一个 cell也会露出一些距离 (如果我们连个cell之间的间距 == 0 上一个 和 下一个 露出大小也不起作用)
    self.ybs_flowLauout.itemSize = CGSizeMake(self.collectionView.width - ((self.ybs_cellDistanceFlost == 0)? 0 : (2 * self.ybs_cellDistanceFlost + 2 * self.ybs_leftRightDistanceFlost)), self.ybs_flowLauout.itemSize.height);
    
    [self invalidateIntrinsicContentSize];
}

// 下一张 -自动轮播
- (void)ybs_nextPage{
    
    CGFloat contentOffSetX = self.collectionView.contentOffset.x;
//    NSLog(@"当前偏移量__self.collectionView.contentOffset.x = %f",contentOffSetX);
    contentOffSetX += self.ybs_flowLauout.itemSize.width; // 向右偏移 item的宽度
    contentOffSetX += self.ybs_cellDistanceFlost; // 还有左边的cell 间距
//    NSLog(@"下一个偏移量__self.collectionView.contentOffset.x = %f",contentOffSetX);
    [self.collectionView setContentOffset:CGPointMake(contentOffSetX, self.collectionView.contentOffset.y) animated:YES];

}

// 停止定时器
- (void)stopTimer{
    
    if (self.ybs_timer) {
        [self.ybs_timer invalidate];
        self.ybs_timer = nil;
    }
    
}

// 开启定时器
- (void)startTimer{
    
    if (self.isybs_neetAutomaticCarouselBool && !self.ybs_timer) {
        self.ybs_timer = [NSTimer scheduledTimerWithTimeInterval:self.ybs_timeIntervalInteger target:self selector:@selector(ybs_nextPage) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.ybs_timer forMode:NSRunLoopCommonModes];
    }
}


// 跳转位置居中显示
- (void)ybs_resetPosition{
    
    NSIndexPath *indexPath;
    //判断滑动到第几个
    if (self.collectionView.contentOffset.x > 0) {
        
        CGPoint pInView = [self convertPoint:self.collectionView.center toView:self.collectionView];
        // 获取这一点的indexPath
        NSIndexPath *indexPathNow = [self.collectionView indexPathForItemAtPoint:pInView];
        indexPath = [NSIndexPath indexPathForItem:indexPathNow.row%self.imageArray.count+YBSItemCount * 0.5 *self.imageArray.count inSection:0];
    }
    else{
        indexPath = [NSIndexPath indexPathForItem:YBSItemCount * 0.5 *self.imageArray.count inSection:0];
    }
    
    
    // 数据回传
    if ([self.delegate respondsToSelector:@selector(ybs_carouselTool:currentAtIndex:)]) {
        [self.delegate ybs_carouselTool:self currentAtIndex:indexPath.item % self.imageArray.count];
    }
    
    
    // 中间位置调整 (可以无限轮播 及 定时轮播 都会居中)
    if (self.ybs_neetInfinitiScrollEnabledBool || self.ybs_neetAutomaticCarouselBool) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}




- (UIView *)ybs_placeholderView{
    
    if (!_ybs_placeholderView) {
        UIView *ybs_placeholderView = [[UIView alloc] init];
        ybs_placeholderView.size = CGSizeMake(self.ybs_flowLauout.itemSize.width , self.ybs_flowLauout.itemSize.height);
        ybs_placeholderView.centerY = self.height * 0.5;
        ybs_placeholderView.userInteractionEnabled = false;
        ybs_placeholderView.clipsToBounds = true;
        ybs_placeholderView.backgroundColor = [UIColor redColor];
        [self addSubview:_ybs_placeholderView = ybs_placeholderView];
        
        // 图片
        UIImageView *imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = true;
        [ybs_placeholderView addSubview:_ybs_placeholderViewImageView = imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
        }];
        
        // 毛玻璃效果
        UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        effectView.alpha = 0.5;
        [imageView addSubview:effectView];

        [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
        }];
        
    }
    
    return _ybs_placeholderView;
}

- (void)dealloc{
    if (self.ybs_timer) {
        [self.ybs_timer invalidate];
        self.ybs_timer = nil;
    }
}








@end
