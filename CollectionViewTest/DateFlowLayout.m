
#import "DateFlowLayout.h"

@implementation DateFlowLayout

-(id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
	
	self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
	self.headerReferenceSize = CGSizeMake(50, 50);
	self.minimumInteritemSpacing = 5;
	self.minimumLineSpacing = 5;
	self.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
	
	return self;
}

-(NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    UICollectionView * const cv = self.collectionView;
    CGPoint const contentOffset = cv.contentOffset;
	
    NSMutableArray *cells = [[NSMutableArray alloc] initWithCapacity:100];
    
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if (layoutAttributes.representedElementCategory == UICollectionElementCategoryCell) {
            [missingSections addIndex:layoutAttributes.indexPath.section];
            
            [cells addObject:layoutAttributes];
        }
    }
    for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
            [missingSections removeIndex:layoutAttributes.indexPath.section];
        }
    }
	
    [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
		
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
		
        UICollectionViewLayoutAttributes *layoutAttributes = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
		
        [answer addObject:layoutAttributes];
		
    }];
    
    /////////
    for (UICollectionViewLayoutAttributes *layoutAttributes in cells) {
        CGPoint origin = layoutAttributes.frame.origin;
        
        if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        } else {
            origin.x -= 50;
            origin.y += 50;
        }
        
        layoutAttributes.zIndex = 1;
        layoutAttributes.frame = (CGRect){
            .origin = origin,
            .size = layoutAttributes.frame.size
        };
    }
    /////////
	
	for (UICollectionViewLayoutAttributes *layoutAttributes in answer) {
		
        if ([layoutAttributes.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
			
            NSInteger section = layoutAttributes.indexPath.section;
            NSInteger numberOfItemsInSection = [cv numberOfItemsInSection:section];
			
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            NSIndexPath *lastCellIndexPath = [NSIndexPath indexPathForItem:MAX(0, (numberOfItemsInSection - 1)) inSection:section];
			
            UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            UICollectionViewLayoutAttributes *lastCellAttrs = [self layoutAttributesForItemAtIndexPath:lastCellIndexPath];
			
			if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
				CGFloat headerHeight = CGRectGetHeight(layoutAttributes.frame);
				CGPoint origin = layoutAttributes.frame.origin;
				origin.y = MIN(
							   MAX(contentOffset.y, (CGRectGetMinY(firstCellAttrs.frame) - headerHeight)),
							   (CGRectGetMaxY(lastCellAttrs.frame) - headerHeight)
							   );
				
				layoutAttributes.zIndex = 1024;
				layoutAttributes.frame = (CGRect){
					.origin = origin,
					.size = layoutAttributes.frame.size
				};
			} else {
				CGFloat headerWidth = CGRectGetWidth(layoutAttributes.frame);
				CGPoint origin = layoutAttributes.frame.origin;
				origin.x = MIN(
							   MAX(contentOffset.x, (CGRectGetMinX(firstCellAttrs.frame) - headerWidth)),
							   (CGRectGetMaxX(lastCellAttrs.frame) - headerWidth)
							   );
				
				layoutAttributes.zIndex = 1024;
				layoutAttributes.frame = (CGRect){
					.origin = origin,
					.size = CGSizeMake(cv.frame.size.width, layoutAttributes.frame.size.width)
				};
                
                //cv.contentInset =  UIEdgeInsetsMake(0, 0, 0, 0);
                
			}

        }
    }
	
    return answer;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBound {
    return YES;
}

@end