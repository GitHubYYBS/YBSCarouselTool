# YBSCarouselTool
缩放轮播可以配置各种参数各种样式
- 效果 ```` 最左 及 最右 有补位效果 ````
-![](https://github.com/GitHubYYBS/YBSCarouselTool/blob/master/%E6%BC%94%E7%A4%BA.gif?raw=true)


- 效果 ```` 左右可以无限滚动的效果 ````
-![](https://github.com/GitHubYYBS/YBSCarouselTool/blob/master/%E6%BC%94%E7%A4%BA_1.gif?raw=true)

#### 自由配置
````
/** 需要显示的图片数据(要求里面存放UIImage\NSURL对象) 支持在中途刷新数据 需要刷新时只需要给该数组重新赋值就好了 */
@property(nonatomic,strong)NSMutableArray *imageArray;
/// 图片圆角大小 默认为0 无圆角
@property (nonatomic, assign) CGFloat ybs_circularFloat;
/** 用来监听框架内部事件的代理 */
@property (nonatomic, weak) id delegate;
/// cell 之间的间距 ->默认为 0
@property (nonatomic, assign) CGFloat ybs_cellDistanceFlost;
/// 邻近左右两个cell 露出屏幕的大小 (如果 cell 之间的间距为0 该值也就没有了任何意义) 该值起作用的前提是 ybs_cellDistanceFlost != 0
@property (nonatomic, assign) CGFloat ybs_leftRightDistanceFlost;
/// item 在缩小时 与其中间的item 在高度上的比例(取值0-1) -> 默认 0.7
@property (nonatomic, assign) CGFloat ybs_smallScaleFloat;
/// 是否需要左右无限滑动 -> 默认YES 可以无限滑动 用户可以向一个方向滑到死 滑到 地老天荒
@property (nonatomic, assign,getter=isybs_neetInfinitiScrollEnabledBool) BOOL ybs_neetInfinitiScrollEnabledBool;
/// 加载完毕后 默认选中第几个(计数从第0位开始) ->内部默认选中最中间的一个 请不要超过数组容量
@property (nonatomic, assign) NSInteger ybs_firstSelectedInteger;
/// 是否需要滑动到最左 及 最右 毛玻璃补位功能 (该功能 只在 ybs_neetInfinitiScrollEnabledBool == NO 时起作用 如果可以无限滑动 该功能将无法使用)
@property (nonatomic, assign,getter=isybs_placeholderViewBool) BOOL ybs_placeholderViewBool;
/// 是否需要扩容(默认YES 需要) 如果需要左右无限滑动 会强制扩容(考虑到性能和交互体验) ->扩容的效果imageArray中的数量会被倍数增加
@property (nonatomic, assign,getter=isybs_marketExpansionBool) BOOL ybs_marketExpansionBool;
/// 是否开启点击居中 默认YES
@property (nonatomic, assign,getter=isybs_clickMoveToCenterBool) BOOL ybs_clickMoveToCenterBool;
/// 是否需要自动轮播 ->默认yes 会自动轮播
@property (nonatomic, assign,getter=isybs_neetAutomaticCarouselBool) BOOL ybs_neetAutomaticCarouselBool;
/// 定时轮播时间间隔 (单位: 秒 默认 4秒) 如果该值 > 0 ybs_neetAutomaticCarouselBool 会被强制开启
@property (nonatomic, assign) NSInteger ybs_timeIntervalInteger;

````


#### 使用

````
 YBSCarouselTool *carouseTool = [[YBSCarouselTool alloc] initWithFrame:CGRectMake(0, 150, self.view.width, 160)];
    carouseTool.ybs_cellDistanceFlost = 25;
    carouseTool.ybs_leftRightDistanceFlost = 20;
    carouseTool.delegate = self;
    carouseTool.ybs_neetInfinitiScrollEnabledBool = true;
    carouseTool.ybs_firstSelectedInteger = 0;
    carouseTool.ybs_marketExpansionBool = false;
    carouseTool.ybs_placeholderViewBool = true;
    carouseTool.imageArray = [NSMutableArray arrayWithArray:@[
                                                              [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528693868757&di=0076decdc22adbd8c0fee6f2d61d55da&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3Da47f71c2ac86c9171c0e5a79a04515a3%2F80cb39dbb6fd5266e1a3a92ea018972bd407367b.jpg"],
                                                              [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528695763709&di=6588d615d3a5f7446a5044aa266a96b4&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F018e1d581400d0a84a0e282b82d02e.JPG%401280w_1l_2o_100sh.jpg"],
//                                                              [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529300741&di=e2fd6d058f603fef4ca80ac297338499&imgtype=jpg&er=1&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2Fd8f9d72a6059252d70068bd03e9b033b5ab5b9d5.jpg"],
                                                              ]];
    [self.view addSubview: carouseTool];

````
