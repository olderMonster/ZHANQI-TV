//
//  ZQRecommendController.m
//  战旗TV
//
//  Created by 印聪 on 2017/1/4.
//  Copyright © 2017年 monster. All rights reserved.
//

#import "ZQSubsRecommendController.h"

#import "ZQDaRenCell.h"
#import "ZQLiveCell.h"

#import "ZQChanLiveManager.h"
#import "ZQGamerBannerManager.h"

#import "ZQBaiBianSectionHeaderView.h"

#import <MJRefresh/MJRefresh.h>

#import "ZQLoginController.h"

#define kSubsRecomCellIdentifier @"kSubsCellIdentifier"
#define kSubsRecomNormalCellIdentifier @"kSubsNormalCellIdentifier"
#define kNormalRecomSectionHeaderIdentifier @"kNormalSectionHeaderIdentifier"
#define kSubsRecomSectionFooterView @"kSubsSectionFooterView"

@interface ZQSubsRecommendController ()<UICollectionViewDataSource , UICollectionViewDelegateFlowLayout , CTAPIManagerCallBackDelegate,CTAPIManagerInterceptor>

@property (nonatomic , strong)UICollectionView *subsCollectionView;
@property (nonatomic , strong)ZQChanLiveManager *liveManager;
@property (nonatomic , strong)ZQGamerBannerManager *bannerManager;
@property (nonatomic , strong)NSMutableArray *subsMArray;

@end

@implementation ZQSubsRecommendController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.subsCollectionView];
    
    [self.liveManager loadData];
    [self.bannerManager loadData];
    
    [self setupRefresh];
}


- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    
    self.subsCollectionView.frame = self.view.bounds;
    
}

#pragma mark -- private method
- (void)setupRefresh{
    self.subsCollectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self.liveManager refreshingAction:@selector(loadData)];
}


#pragma mark -- UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}


#pragma mark -- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.subsMArray.count;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;{
    return [self.subsMArray[section] count];
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        ZQDaRenCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSubsRecomCellIdentifier forIndexPath:indexPath];
        cell.live = self.subsMArray[indexPath.section][indexPath.row];
        return cell;
    }else{
        ZQLiveCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSubsRecomNormalCellIdentifier forIndexPath:indexPath];
        cell.live = self.subsMArray[indexPath.section][indexPath.row];
        return cell;
    }
    
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {

            return nil;
            
        }else{
            UICollectionReusableView *reuseView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kSubsRecomSectionFooterView forIndexPath:indexPath];
            reuseView.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:249/255.0 alpha:1.0];
            return reuseView;
        }
        
    }else{
        
        if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
            
            ZQBaiBianSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kNormalRecomSectionHeaderIdentifier forIndexPath:indexPath];
            headerView.title = @"精彩不断 快来加入";
            headerView.font = [UIFont systemFontOfSize:12];
            return headerView;
            
        }else{
            return nil;
        }
        
    }
    
}


#pragma mark -- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0){
        CGFloat cellWidth = (collectionView.bounds.size.width - 1)/2;
        return CGSizeMake(cellWidth, cellWidth);
    }else{
        CGFloat cellW = (collectionView.bounds.size.width - 1)/2;
        CGFloat imageH = cellW * 150/280;
        CGFloat cellH = imageH + 30 + 25;
        return CGSizeMake(cellW, cellH);
    }
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return CGSizeZero;
    }else{
        return CGSizeMake(collectionView.bounds.size.width, 40);
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if (section == 0){
        return CGSizeMake(collectionView.bounds.size.width, 10);
    }
    return CGSizeZero;
}


#pragma mark -- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *roomInfo = self.subsMArray[indexPath.section][indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(recommendLiving:)]) {
        [self.delegate recommendLiving:roomInfo];
    }
    
}


#pragma mark -- CTAPIManagerCallBackDelegate
- (void)managerCallAPIDidSuccess:(CTAPIBaseManager *)manager{
    NSDictionary *dict = [manager fetchDataWithReformer: nil];
    
    if ([manager isEqual:self.liveManager]){
        if (self.subsMArray.count == 0){
            [self.subsMArray addObject:dict[@"data"][@"rooms"]];
        }else{
            [self.subsMArray insertObject:dict[@"data"][@"rooms"] atIndex:0];
            [self.subsCollectionView reloadData];
        }
        
    }
    
    if ([manager isEqual:self.bannerManager]){
        if (self.subsMArray.count == 0){
            [self.subsMArray addObject:dict[@"data"][@"banner"]];
        }else{
            [self.subsMArray insertObject:dict[@"data"][@"banner"] atIndex:1];
            [self.subsCollectionView reloadData];
        }
    }
    
    
}
- (void)managerCallAPIDidFailed:(CTAPIBaseManager *)manager{
    
}


#pragma mark -- CTAPIManagerInterceptor
- (void)manager:(CTAPIBaseManager *)manager afterCallingAPIWithParams:(NSDictionary *)params{
    
    if (self.subsMArray.count == 2){
        [self.subsCollectionView.mj_header endRefreshing];
    }
    
}

#pragma mark -- getters and setters
- (UICollectionView *)subsCollectionView{
    if (_subsCollectionView == nil) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 1;
        _subsCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _subsCollectionView.backgroundColor = [UIColor whiteColor];
        _subsCollectionView.dataSource = self;
        _subsCollectionView.delegate = self;
        
        [_subsCollectionView registerClass:[ZQDaRenCell class] forCellWithReuseIdentifier:kSubsRecomCellIdentifier];
        [_subsCollectionView registerClass:[ZQLiveCell class] forCellWithReuseIdentifier:kSubsRecomNormalCellIdentifier];
        [_subsCollectionView registerClass:[ZQBaiBianSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kNormalRecomSectionHeaderIdentifier];
        [_subsCollectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kSubsRecomSectionFooterView];
    }
    return _subsCollectionView;
}

- (ZQChanLiveManager *)liveManager{
    if (_liveManager == nil) {
        _liveManager = [[ZQChanLiveManager alloc]init];
        _liveManager.delegate = self;
        _liveManager.interceptor = self;
        _liveManager.channelId = @"116";
        _liveManager.pageSize = 4;
    }
    return _liveManager;
}

- (ZQGamerBannerManager *)bannerManager{
    if (_bannerManager == nil) {
        _bannerManager = [[ZQGamerBannerManager alloc]init];
        _bannerManager.interceptor = self;
        _bannerManager.delegate = self;
    }
    return _bannerManager;
}


- (NSMutableArray *)subsMArray{
    if (_subsMArray == nil) {
        _subsMArray = [NSMutableArray array];
    }
    return _subsMArray;
}
@end
