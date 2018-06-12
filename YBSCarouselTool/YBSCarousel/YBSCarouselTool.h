//
//  YBSCarouselTool.h
//  YBSCarouselTool
//
//  Created by 严兵胜 on 2018/6/5.
//  Copyright © 2018年 严兵胜. All rights reserved.
//

/**
 
 使用说明: -> 该工具设计的最初需求是 左右滚动缩小 中间放大 为了工具的灵活性 所以很多配置都交个外界来配置 通过配置我们可以实现不同的效果
    1.形势为横向轮播方式 暂时还没有加入定时轮播 目前都是手动滑动
    2.可以通过 ybs_cellDistanceFlost 来自由配置 item 之间的列间距 (默认为0 此时item的宽度 与控件宽度相等)
    3.可以通过 ybs_leftRightDistanceFlost 来配置 左右 item 在屏幕中的显示大小 (当屏幕中有一个item在最大化显示时) 如果我们将 item的列间距 == 0 该值将失效
    4.item 的宽度 是由 ybs_cellDistanceFlost 及 ybs_leftRightDistanceFlost 共同决定的
    5.我们外界可以通过 配置 ybs_firstSelectedInteger 来指定选中某一个 其默认值我们会自动选中最中间的那个
    6.支持是否可以无限滚动 (ybs_neetInfinitiScrollEnabledBool) 当该值配置为YES 时 补位功能将失效 (因为此时已不再需要补位)
    7.支持是否扩容(及 外界只传来了 3个 我们会自动扩容 3 * 20个 可以通过 ybs_marketExpansionBool 来配置是否扩容 ) 这样做的目的是 如果用户向左 或者向右 滑动是滑不到头的(前提是 开启了ybs_neetInfinitiScrollEnabledBool)
    8.
 
 */

#import <UIKit/UIKit.h>


@class YBSCarouselTool;
@protocol YBSCarouselToolDalegate <NSObject>

@optional

/// 当前是第几张 每次切换时 会回调
- (void)ybs_carouselTool:(YBSCarouselTool *)carouselTool currentAtIndex:(NSInteger )index;

@end

@interface YBSCarouselTool : UIView


/** 需要显示的图片数据(要求里面存放UIImage\NSURL对象) 支持在中途刷新数据 需要刷新时只需要给该数组重新赋值就好了 */
@property(nonatomic,strong)NSMutableArray *imageArray;
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

@end
