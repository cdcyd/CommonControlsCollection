//
//  CCCalendarView.m
//  CCCalendar
//
//  Created by wsk on 2016/11/14.
//  Copyright © 2016年 cyd. All rights reserved.
//

#import "CCCalendarView.h"
#import "CCCollectionViewCell.h"
#import "CCCollectionHeaderView.h"

#import "CCMonthDataClient.h"
#import "CCChineseCalendar.h"
#import "CCDateManager.h"

#define kCellHeight 75
#define kHeaderViewHeight 25
#define kLineSpacing 0
#define kItemSpacing 0

static NSString *kCollectionCell = @"CCCollectionViewCell";
static NSString *kCollectionHeader = @"CCCollectionHeaderView";

@interface CCCalendarView()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    BOOL _isReq;
}

@property(nonatomic, readwrite)NSMutableArray<NSDate *> *selectedDates;
@property(nonatomic, readwrite)NSMutableArray<CCChineseCalendarModel *> *selectedLunarDates;

@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)NSMutableArray<NSDateComponents *> *dataSource;
@property(nonatomic, strong)NSMutableDictionary<NSString *, NSDate*> *selectIndexPaths;

@end

@implementation CCCalendarView

- (instancetype)init{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithFrame:" userInfo:nil];
}

+ (instancetype)new{
    @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Use -initWithFrame:" userInfo:nil];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    return [self initWithFrame:CGRectZero];
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectedDates = [NSMutableArray array];
        self.selectedLunarDates = [NSMutableArray array];
        
        self.dataSource = [NSMutableArray array];
        self.selectIndexPaths = [NSMutableDictionary dictionary];
        
        [self initDataSource];
        [self addSubview:self.collectionView];
    }
    return self;
}

-(UICollectionView *)collectionView{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(self.frame.size.width/7, kCellHeight);
        layout.minimumLineSpacing = kLineSpacing;
        layout.minimumInteritemSpacing = kItemSpacing;
        layout.headerReferenceSize = CGSizeMake(self.frame.size.width, kHeaderViewHeight);
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.frame collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        [_collectionView registerClass:[CCCollectionViewCell class] forCellWithReuseIdentifier:kCollectionCell];
        [_collectionView registerClass:[CCCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionHeader];
    }
    return _collectionView;
}

-(void)initDataSource{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComp = [[NSDateComponents alloc]init];
    [dateComp setMonth:-1];
    NSDate *resultDate = [calendar dateByAddingComponents:dateComp toDate:[NSDate date] options:0];
    NSCalendarUnit unit = NSCalendarUnitYear    | 
                          NSCalendarUnitDay     | 
                          NSCalendarUnitMonth   |
                          NSCalendarUnitCalendar;
    NSDateComponents *dateComponent = [calendar components:unit fromDate:resultDate];
    NSDate *date = [dateComponent.calendar dateFromComponents:dateComponent];
    NSDate *firstDayOfMonth;
    [calendar rangeOfUnit:NSCalendarUnitMonth startDate:&firstDayOfMonth interval:nil forDate:date]; 
    [self.dataSource addObjectsFromArray:[CCMonthDataClient requestMonthAfterDate:firstDayOfMonth count:12]];
}

-(void)setAllowsMultipleSelection:(BOOL)allowsMultipleSelection
{
    _allowsMultipleSelection = allowsMultipleSelection;
    _collectionView.allowsMultipleSelection = allowsMultipleSelection;
}

-(void)setDelegate:(id<CCCalendarViewDelegate>)delegate{
    _delegate = delegate;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self updateCurrentVisibleCellDate:indexPath];
}


#pragma mark - UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _dataSource.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSDateComponents *dateComponent = _dataSource[section];
    return [CCDateManager numberWeeksOfMonth:[dateComponent.calendar dateFromComponents:dateComponent]] * 7;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if (kind == UICollectionElementKindSectionHeader) {
        NSDateComponents *dateComponent = _dataSource[indexPath.section];
        CCCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kCollectionHeader forIndexPath:indexPath];
        headerView.titleLabel.text =  [NSString stringWithFormat:@"%ld 月",dateComponent.month];
        headerView.titleLabel.frame = CGRectMake(self.frame.size.width/7*(dateComponent.weekday-1)+15, 0, 80, kHeaderViewHeight);
        return headerView;
    }
    return nil;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDateComponents *dateComponent = _dataSource[indexPath.section];
    CCCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionCell forIndexPath:indexPath];
    cell.tag = indexPath.section;
    
    // 加载数据
    NSInteger daysOfMonth = [CCDateManager numberDaysOfMonth:[dateComponent.calendar dateFromComponents:dateComponent]];
    if ((indexPath.row < dateComponent.weekday-1) || indexPath.row > (dateComponent.weekday - 1) + daysOfMonth - 1) {
        cell.hidden = YES;
    }
    else{
        cell.hidden = NO;
        NSDateComponents *realDateComp = [self getRealDateComponentFromDataSource:indexPath];
        [cell setContent:realDateComp];
        
        // 设置选中cell的颜色
        NSString *key = [NSString stringWithFormat:@"%zd_%zd_%zd",realDateComp.year,realDateComp.month,realDateComp.day];
        if ([_selectIndexPaths objectForKey:key]) {
            [cell setSelected:YES dateComponents:realDateComp];
        }
        else{
            [cell setSelected:NO dateComponents:realDateComp];
        }
    }
    return cell;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDateComponents *realDateComp = [self getRealDateComponentFromDataSource:indexPath];
    NSString *key = [NSString stringWithFormat:@"%zd_%zd_%zd",realDateComp.year,realDateComp.month,realDateComp.day];
    
    CCCollectionViewCell *cell = (CCCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([self.selectIndexPaths objectForKey:key]) {
        [cell setSelected:NO dateComponents:realDateComp];
        [self.selectIndexPaths removeObjectForKey:key];
    }
    else{
        [cell setSelected:YES dateComponents:realDateComp];
        [self.selectIndexPaths setObject:[realDateComp.calendar dateFromComponents:realDateComp] forKey:key];
    }
    [self updateSelectedItems];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSDateComponents *realDateComp = [self getRealDateComponentFromDataSource:indexPath];
    NSString *key = [NSString stringWithFormat:@"%zd_%zd_%zd",realDateComp.year,realDateComp.month,realDateComp.day];
    
    CCCollectionViewCell *cell = (CCCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if ([self.selectIndexPaths objectForKey:key]) {
        [cell setSelected:NO dateComponents:realDateComp];
        [self.selectIndexPaths removeObjectForKey:key];
    }
    else{
        [cell setSelected:YES dateComponents:realDateComp];
        [self.selectIndexPaths setObject:[realDateComp.calendar dateFromComponents:realDateComp] forKey:key];
    }
    [self updateSelectedItems];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height < 100 && !_isReq) {
        _isReq = YES;
        NSDate *date = [_dataSource.lastObject.calendar dateFromComponents:_dataSource.lastObject];
        [_dataSource addObjectsFromArray:[CCMonthDataClient requestMonthAfterDate:date count:12]];
        [_collectionView reloadData];
        _isReq = NO;
    }
    
    if (scrollView.contentOffset.y < 100 && !_isReq) {
        _isReq = YES;
        CGPoint p = scrollView.contentOffset;
        NSDate *date = [_dataSource.firstObject.calendar dateFromComponents:_dataSource.firstObject];
        NSArray<NSDateComponents *> *dateArr = [CCMonthDataClient requestMonthBeforeDate:date count:12];
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,dateArr.count)];
        [_dataSource insertObjects:dateArr atIndexes:indexes];
        [_collectionView reloadData];

        CGFloat allHeight = dateArr.count * kHeaderViewHeight;
        for (int i = 0 ; i < dateArr.count; i ++) {
            allHeight += [CCDateManager numberWeeksOfMonth:[dateArr[i].calendar dateFromComponents:dateArr[i]]] * kCellHeight;
        }
        [scrollView setContentOffset:CGPointMake(p.x, p.y + allHeight)];
        _isReq = NO;
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSArray<UICollectionViewCell *> *cells = [self.collectionView visibleCells];
    if (cells.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:cells[0].tag];
        [self updateCurrentVisibleCellDate:indexPath];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    NSArray<UICollectionViewCell *> *cells = [self.collectionView visibleCells];
    if (cells.count > 0) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:cells[0].tag];
        [self updateCurrentVisibleCellDate:indexPath];
    }
}

#pragma mark - Private Methods
// 更新当前选中的所有日期
-(void)updateSelectedItems{
    [_selectedLunarDates removeAllObjects];
    [_selectedDates removeAllObjects];
    for (NSDate *date in [self.selectIndexPaths allValues]) {
        [_selectedDates addObject:date];
        [_selectedLunarDates addObject:[CCChineseCalendar getChineseCalenderWithDate:date]];
    }
}

// 更新当前滑动到的年份
-(void)updateCurrentVisibleCellDate:(NSIndexPath *)indexPath{
    NSDateComponents *realDateComp = [self getRealDateComponentFromDataSource:indexPath];
    NSDate *date = [realDateComp.calendar dateFromComponents:realDateComp];
    CCChineseCalendarModel *lunarModel = [CCChineseCalendar getChineseCalenderWithDate:date];
    if ([_delegate respondsToSelector:@selector(calendarDidScrollToYear:lunarYear:)]) {
        [_delegate calendarDidScrollToYear:realDateComp.year lunarYear:lunarModel.year];
    }
}

// 获取一个cell的时间组件
-(NSDateComponents *)getRealDateComponentFromDataSource:(NSIndexPath *)indexPath{
    if (self.dataSource.count > indexPath.section) {
        NSDateComponents *dateComponent = self.dataSource[indexPath.section];
        NSDateComponents *dateComp = [[NSDateComponents alloc]init];
        [dateComp setCalendar:[NSCalendar currentCalendar]];
        [dateComp setYear:dateComponent.year];
        [dateComp setMonth:dateComponent.month];
        [dateComp setWeekday:dateComponent.weekday];
        [dateComp setDay:indexPath.row - dateComponent.weekday+2];
        return dateComp;
    }
    return nil;
}

@end
