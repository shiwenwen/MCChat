//
//  WWPageController.m
//  WWPageController
//
//  Created by 石文文 on 16/2/4.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "WWPageController.h"
#import "UICommons.h"
#import "TitleCell.h"
#import "UIViewExt.h"
@interface WWPageController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic,assign)NSInteger page;//页数
@property (nonatomic,copy)NSMutableArray<NSString *> *titles;//所有标题
@property (nonatomic,copy)NSMutableArray<UIViewController *> *tabControllers;//所有子控制器
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)NSMutableArray <NSNumber *> *selected;//标签选择状态数组
@end
static NSString *identifier = @"title_cell";
@implementation WWPageController
- (instancetype)init
{
    self = [super init];
    if (self) {

        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    



}
- (void)setDataSource:(id<WWPageControllerDataSource>)dataSource{
    _dataSource = dataSource;
    
    [self initDataSource];
    
}
- (void)setDelegate:(id<WWPageControllerDelegate>)delegate{
    
    _delegate = delegate;
    [self initDelegate];
}

/**
 *  初始化数据源
 */
- (void)initDataSource{

    //页数
    _page = [self.dataSource numberOfPages];
    
    [self createUI];
    


}
/**
 *  创建UI
 */
- (void)createUI{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];

    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0,KNavigationBarHeight, KScreenWidth, KNavigationBarHeight) collectionViewLayout:layout];

    if (self.navigationController) {
        
        [self.navigationController.navigationBar addSubview:_collectionView];
        
    }else{
        
        [self.view addSubview:_collectionView];
        
    }
    [_collectionView registerClass:[TitleCell class] forCellWithReuseIdentifier:identifier];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, KNavigationBarHeight*2, KScreenWidth, KScreenHeight - KNavigationBarHeight*2)];
    _scrollView.contentSize = CGSizeMake(KScreenWidth * self.page, _scrollView.height);
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    //标题//子控制器
    _titles = [NSMutableArray arrayWithCapacity:_page];
    _tabControllers = [NSMutableArray arrayWithCapacity:_page];
    
    _selected = [NSMutableArray arrayWithCapacity:_page];
    
    for (int page = 0; page < self.page ; page ++) {
        
        [_titles addObject:[self.dataSource pageTitle:page]];
        [_tabControllers addObject:[self.dataSource controllerOfPage:page]];
        [_scrollView addSubview:_tabControllers[page].view];
        _tabControllers[page].view.frame = CGRectMake(KScreenWidth * page,0, KScreenWidth, KScreenHeight - KNavigationBarHeight);
        //标签选择数组
        NSNumber *select;

        if (page == 0) {
            select = [NSNumber numberWithBool:YES];
        }else{
            
            select = [NSNumber numberWithBool:NO];
        }
        [_selected addObject:select];
        
    }
}
- (void)setTitleTabColor:(UIColor *)titleTabColor{
    
    _titleTabColor = titleTabColor;
    
    _collectionView.backgroundColor = _titleTabColor;
    
}
- (void)setTitleColor:(UIColor *)titleColor{
    
    _titleColor = titleColor;
    [self.collectionView reloadData];
}
/**
 *  代理方法
 */
- (void)initDelegate{
    
    if (self.delegate) {
        
        
        
    }
    
    
}
#pragma mark -- UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [self.dataSource numberOfPages];
    
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TitleCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.titleLabel.text = self.titles[indexPath.item];
    cell.isSelected = [_selected[indexPath.item]boolValue];
    cell.titleLabel.textColor = self.titleColor;
    return cell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *title = self.titles[indexPath.item];
    
    CGSize size;
    if ([_selected[indexPath.item]boolValue] == YES) {
        
        size = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:KTextFont + 4]}];
    }else{
        
       size = [title sizeWithAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:KTextFont]}];
    }
    
    
    return CGSizeMake(size.width + 15 * proportation, KNavigationBarHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
     NSInteger index = 0;
    for (int i = 0; i < _selected.count; i++) {
        
        NSNumber *select = [_selected objectAtIndex:i];
        
        if ([select boolValue] == YES) {
            index = i;
        }
        
    }
    [_selected exchangeObjectAtIndex:indexPath.item withObjectAtIndex:index];
    if (index != indexPath.item) {
        if (ABS(indexPath.item - index) > 2) {
            [_scrollView scrollRectToVisible:CGRectMake(KScreenWidth * indexPath.item, 0, KScreenWidth, KScreenHeight) animated:NO];
        }else{
            [_scrollView scrollRectToVisible:CGRectMake(KScreenWidth * indexPath.item, 0, KScreenWidth, KScreenHeight) animated:YES];
        }
        
        [collectionView reloadData];
        
         [collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
    
    
    
}
#pragma mark -- scrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (scrollView == _scrollView) {
        CGFloat x = _scrollView.contentOffset.x;
        
        NSInteger page = x / KScreenWidth;
        NSInteger index = 0;
        for (int i = 0; i < _selected.count; i++) {
            
            NSNumber *select = [_selected objectAtIndex:i];
            
            if ([select boolValue] == YES) {
                index = i;
            }
            
        }
        
        
            [_selected exchangeObjectAtIndex:page withObjectAtIndex:index];
         [_collectionView reloadData];
        [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:page inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
