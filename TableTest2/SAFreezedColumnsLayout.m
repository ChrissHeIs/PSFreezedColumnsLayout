//
//  CustomLayout.m
//  TableTest2
//
//  Created by Pavel Shestak on 1/29/14.
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import "SAFreezedColumnsLayout.h"

NSInteger halfDivideFindIndexOfClosestValueInFloatArray(NSArray *array, CGFloat value) {
    NSInteger bottomIndex = 0;
    NSInteger topIndex = array.count - 1;
    
    while ((topIndex - bottomIndex) != 1) {
        NSInteger centerIndex = (topIndex + bottomIndex)/2;
        CGFloat centerValue = [array[centerIndex] floatValue];
        
        if (value > centerValue) {
            bottomIndex = centerIndex;
        }
        else if (value < centerValue) {
            topIndex = centerIndex;
        }
        else {
            bottomIndex = centerIndex;
            break;
        }
    }
    
    return bottomIndex;
}


@implementation SAFreezedColumnsLayout {
    NSInteger _rowsCount;
    NSInteger _columnsCount;
    NSMutableArray *_columnWidths;
    NSMutableArray *_rowHeights;
    NSMutableArray *_columnXPositions;
    NSMutableArray *_rowYPositions;
    
    CGSize _contentSize;
    
    NSInteger _lastLoadedRow;
    
    BOOL _resetFlag;
}

-(id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _columnWidths = [NSMutableArray array];
        _columnXPositions = [NSMutableArray array];
        _rowHeights = [NSMutableArray array];
        _rowYPositions = [NSMutableArray array];
    }
    
    return self;
}

- (void)setupColumns {
    _contentSize = CGSizeZero;
    _lastLoadedRow = -1;
    _columnsCount = self.collectionView.numberOfSections;
    _rowsCount = [self.collectionView numberOfItemsInSection:0];
    
    for (NSInteger section = 0; section < _columnsCount; ++section) {
        NSAssert([self.collectionView numberOfItemsInSection:0] == _rowsCount,
                 @"All sections should have the same items number");
        CGFloat width = [self.delegate widthForColumnAtIndex:section];
        _columnWidths[section] = @(width);
        _columnXPositions[section] = @(_contentSize.width);
        _contentSize.width += width;
    }
}

-(void)prepareLayout {
    if (!_columnsCount) {
        [self setupColumns];
    }
    
    [self loadMoreRowSizesIfNeeded];
}


- (void)loadMoreRowSizesIfNeeded {
    CGPoint const contentOffset = self.collectionView.contentOffset;
    if (_contentSize.height - contentOffset.y < self.pagesLeftToLoadBlock * self.collectionView.bounds.size.height) {
        for (NSInteger row = _lastLoadedRow + 1; row < _rowsCount; ++row) {
            CGFloat height = [self.delegate heightForRowAtIndex:row];
            _rowHeights[row] = @(height);
            _rowYPositions[row] = @(_contentSize.height);
            _contentSize.height += height;
            _lastLoadedRow = row;
            if (_contentSize.height - contentOffset.y >= self.pagesBlockSize * self.collectionView.bounds.size.height) {
                break;
            }
        }
    }
}


- (NSSet *)indexPathsForElementsInRect:(CGRect)rect {
    NSMutableSet *retValue = [NSMutableSet set];
    
    NSInteger startRow = halfDivideFindIndexOfClosestValueInFloatArray(_rowYPositions, rect.origin.y);
    NSInteger endRow = halfDivideFindIndexOfClosestValueInFloatArray(_rowYPositions, rect.origin.y + rect.size.height) + 1;
    NSInteger startCol = halfDivideFindIndexOfClosestValueInFloatArray(_columnXPositions, rect.origin.x);
    NSInteger endCol = halfDivideFindIndexOfClosestValueInFloatArray(_columnXPositions, rect.origin.x + rect.size.width) + 1;
    
    for (NSInteger row = startRow; row <= endRow; ++row) {
        for (NSInteger column = startCol; column <= endCol; ++column) {
            [retValue addObject:[NSIndexPath indexPathForRow:row inSection:column]];
        }
        
        for (NSInteger column = 0; column < self.fixedColumnsCount; ++column) {
            [retValue addObject:[NSIndexPath indexPathForRow:row inSection:column]];
        }
    }
    
    
    return retValue;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect) rect {
    [self loadMoreRowSizesIfNeeded];
    
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    for (NSIndexPath *indexPath in [self indexPathsForElementsInRect:rect]) {
        UICollectionViewLayoutAttributes *layout = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        
        CGPoint contentOffset = self.collectionView.contentOffset;
        CGPoint origin = CGPointMake([_columnXPositions[indexPath.section] floatValue],
                                     [_rowYPositions[indexPath.row] floatValue]);
        if (indexPath.section < self.fixedColumnsCount) {
            origin.x += contentOffset.x;
            static const NSInteger zLevelAbove = 1;
            layout.zIndex = zLevelAbove;
        }
        
        layout.frame = (CGRect)
        {
            .origin = origin,
            .size = CGSizeMake([_columnWidths[indexPath.section] floatValue],
                               [_rowHeights[indexPath.row] floatValue])
        };
        [attributes addObject:layout];
    }

    return attributes;
}


- (CGSize)collectionViewContentSize {
    return _contentSize;
}


- (void)dropLayoutCache {
    _columnsCount = 0;
    [self invalidateLayout];
}

- (void)dropLayoutCacheFromRowIndex:(NSInteger)index {
    NSRange rangeToDeleteFromArrays = NSMakeRange(index, _rowHeights.count - index + 1);
    [_rowHeights removeObjectsInRange:rangeToDeleteFromArrays];
    [_rowYPositions removeObjectsInRange:rangeToDeleteFromArrays];
}

@end
