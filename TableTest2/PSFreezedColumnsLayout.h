//
//  CustomLayout.h
//  TableTest2
//
//  Created by Pavel Shestak on 1/29/14.
//  Copyright (c) 2014 Yalantis. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SAFreezedColumnsLayoutDelegate;

@interface PSFreezedColumnsLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) NSInteger fixedColumnsCount;
@property (nonatomic, assign) NSInteger pagesBlockSize;
@property (nonatomic, assign) NSInteger pagesLeftToLoadBlock;
@property (nonatomic, weak) IBOutlet id<SAFreezedColumnsLayoutDelegate> delegate;

- (void)dropLayoutCache;
- (void)dropLayoutCacheFromRowIndex:(NSInteger)index;

@end


@protocol SAFreezedColumnsLayoutDelegate <NSObject>

- (CGFloat)widthForColumnAtIndex:(NSInteger)columnIndex;
- (CGFloat)heightForRowAtIndex:(NSInteger)columnIndex;

@end