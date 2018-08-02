//
//  ViewController.m
//  YBSCarouselTool
//
//  Created by 严兵胜 on 2018/6/5.
//  Copyright © 2018年 严兵胜. All rights reserved.
//

#import "ViewController.h"


#import "YBSCarouselTool.h"
#import "UIView+Frame.h"

@interface ViewController ()<YBSCarouselToolDalegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    
    
    YBSCarouselTool *carouseTool = [[YBSCarouselTool alloc] initWithFrame:CGRectMake(0, 150, self.view.width, 160)];
    carouseTool.ybs_cellDistanceFlost = 15;
    carouseTool.ybs_leftRightDistanceFlost = 20;
    carouseTool.delegate = self;
    carouseTool.ybs_neetInfinitiScrollEnabledBool = false;
    carouseTool.ybs_firstSelectedInteger = 0;
    carouseTool.ybs_marketExpansionBool = false;
    carouseTool.ybs_placeholderViewBool = true;
    carouseTool.ybs_neetAutomaticCarouselBool = true;
    carouseTool.ybs_circularFloat = 5;
    carouseTool.imageArray = [NSMutableArray arrayWithArray:@[
                                                              [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528693868757&di=0076decdc22adbd8c0fee6f2d61d55da&imgtype=0&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimage%2Fc0%253Dpixel_huitu%252C0%252C0%252C294%252C40%2Fsign%3Da47f71c2ac86c9171c0e5a79a04515a3%2F80cb39dbb6fd5266e1a3a92ea018972bd407367b.jpg"],
                                                              [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528695763709&di=6588d615d3a5f7446a5044aa266a96b4&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F018e1d581400d0a84a0e282b82d02e.JPG%401280w_1l_2o_100sh.jpg"],
                                                              [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1529300741&di=e2fd6d058f603fef4ca80ac297338499&imgtype=jpg&er=1&src=http%3A%2F%2Fimgsrc.baidu.com%2Fimgad%2Fpic%2Fitem%2Fd8f9d72a6059252d70068bd03e9b033b5ab5b9d5.jpg"],
                                                              ]];
    [self.view addSubview: carouseTool];
}

- (void)ybs_carouselTool:(YBSCarouselTool *)carouselTool currentAtIndex:(NSInteger)index{
    
    NSLog(@"当前显示的__ index = %ld",index);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
