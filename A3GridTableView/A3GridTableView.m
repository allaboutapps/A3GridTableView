//
//  A3GridTableView.m
//  A3GridTableViewSample
//
//  A3GridView for iOS
//  Created by Botond Kis on 28.09.12.
//  Copyright (c) 2012 aaa - All About Apps
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification,
//  are permitted provided that the following conditions are met:
//
//      - Redistributions of source code must retain the above copyright notice, this list
//      of conditions and the following disclaimer.
//
//      - Redistributions in binary form must reproduce the above copyright notice, this list
//      of conditions and the following disclaimer in the documentation and/or other materials
//      provided with the distribution.
//
//      - Neither the name of the "aaa - All About Apps" nor the names of its contributors may be used
//      to endorse or promote products derived from this software without specific prior written
//      permission.
//
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
//  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
//  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//  OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//  NO DOUGHNUTS WHERE HARMED DURING THE CODING OF THIS CLASS. BUT CHEESECAKES
//  WHERE. IF YOU READ THIS YOU ARE EITHER BORED OR A LAWYER.


#import "A3GridTableView.h"

//===========================================================================================
#pragma mark - Default Values
//===========================================================================================

//===========================================================================================
#pragma mark - Private Category
//===========================================================================================
@interface A3GridTableView (){
    
    //=======================================================
    // Datasource and delegate
    id<A3GridTableViewDataSource> _dataSource;
    id<A3GridTableViewDelegate> _delegateGridTableView;
    
    //=======================================================
    // visible Cells
    NSMutableSet *_visibleHeaders;
    NSMutableSet *_visibleCells;
    NSMutableArray *_visibleIndexPaths;
    NSMutableArray *_visibleSectionIndexPaths;
    
    /** Containers for unused cells
        @description Holds all unused cells in NSSets keyed by the reuseIdentifiers of the cells
        @usage Used by the dequeue() and _purge() methods
     */
    NSMutableDictionary *_unusedHeaders;
    NSMutableDictionary *_unusedCells;
    
    // selected Cells
    NSMutableArray *_selectedIndexPaths;
    
    //=======================================================
    // Layouting Information
    NSInteger numberOfSections;
    NSInteger *numberOfRowsInSection;
    
    /**
     @description Holds the widths of the sections.
     */
    CGFloat *_sectionWidths;
    
    CGFloat *_sectionXOrigins;
    
    /**
     @description Holds the frames for all cells. The Frame at[section][row]
     */
    CGRect **_cellFrames;
    
    /* custom paging*/
    BOOL _gridTableViewPagingEnabled;
    
    
    //=======================================================
    // Touches
    BOOL _touchesAreDirty;
    
    //=======================================================
    // paging
    BOOL _deceleratingFromPaging;
}

// designated init
- (void)_init;

// Cell handling
- (void)_purgeHeaderCell:(A3GridTableViewCell *)headerCell;
- (void)_purgeCell:(A3GridTableViewCell *)cell;

// layouting
- (void)_layoutCells;
- (void)_layoutHeaders;
- (CGFloat)_heightForHeaders;

/**
 @description This method updates the Layout by building all frames and store them in cellFrames
 */
- (void)_updateCellFrames;

// memory
- (void)freeSectionWidths;
- (void)freeCellFrames;
- (void)freeSectionXOrigins;

// paging
- (void)_alignPageAnimated:(BOOL) animated;

// alignment
/**
 @description This method returns the section for a given contentOffset
 @return The section for the contentOffset. Returns -1 if none found
 */
- (NSInteger)_sectionIndexForContentOffset:(CGPoint)contentOffset;

// selection
- (void)_deselectAllCells;
- (void)_unhighlightAllCells;

@end



//===========================================================================================
#pragma mark - A3GridTableView
//===========================================================================================
@implementation A3GridTableView
@synthesize delegate = _delegateGridTableView;

//===========================================================================================
#pragma mark - Constructors

//======================================
// init called by all other init methods
- (void)_init{
    self.backgroundColor = [UIColor clearColor];
    
    // visible Item Containers
    _visibleHeaders = [[NSMutableSet alloc] init];
    _visibleCells = [[NSMutableSet alloc] init];
    _visibleIndexPaths = [[NSMutableArray alloc] init];
    _visibleSectionIndexPaths = [[NSMutableArray alloc] init];
    
    // unused Item Containers
    _unusedHeaders = [[NSMutableDictionary alloc] init];
    _unusedCells = [[NSMutableDictionary alloc] init];
    
    // layout helper
    _sectionWidths = NULL;
    _sectionXOrigins = NULL;
    _cellFrames = NULL;
    
    numberOfSections = 0;
    numberOfRowsInSection = NULL;
    
    // Scrollview delegate
    [super setDelegate:self];
    
    // paging
    _pagingPosition = A3GridTableViewCellAlignmentCenter;
    self.gridTableViewPagingEnabled = NO;
    
    // selection
    _allowsSelection = YES;
    _allowsMultipleSelection = NO;
    _selectedIndexPaths = [[NSMutableArray alloc] init];
}

//======================================
// dealloc
- (void)dealloc{
    
    // unused Item Containers
    [_visibleHeaders release];
    [_visibleCells release];
    [_visibleIndexPaths release];
    [_visibleSectionIndexPaths release];
    
    // unused Item Containers
    [_unusedHeaders release];
    [_unusedCells release];
    
    // layout helper
    [self freeSectionWidths];
    [self freeSectionXOrigins];
    [self freeCellFrames];
    free(numberOfRowsInSection);
    
    // selection
    [_selectedIndexPaths release];
    
    [super dealloc];
}

//======================================
// Initializers
- (id)init{
    self = [super init];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self _init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _init];
    }
    return self;
}


//===========================================================================================
#pragma mark - Message forwarding for scrollView Delegate

/* called when not implementing a method asked by [respondsToSelector:]*/
- (void) forwardInvocation:(NSInvocation *)anInvocation{
    
    // ask delegate if it's responding to selector 
    if ([self.delegate respondsToSelector:[anInvocation selector]])
        [anInvocation invokeWithTarget:self.delegate];
    else
        [super forwardInvocation:anInvocation];
}

/* ask the delegate if responds to a selector which we don't */
- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ( [super respondsToSelector:aSelector] ){
        return YES;
    }
    else {
        // respond to selector if the delegate does
        if ([self.delegate respondsToSelector:aSelector]){
            return YES;
        }
    }
    return NO;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    // page if paging is enabled
    if (self.isGridTableViewPagingEnabled && !scrollView.tracking) {
        [self _alignPageAnimated:YES];
    }
    
    // tell delegate, that this method was called
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
        [self.delegate scrollViewDidEndDecelerating:scrollView];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (!decelerate) {
        // page if paging is enabled
        if (self.isGridTableViewPagingEnabled) {
            [self _alignPageAnimated:YES];
        }
    }
    
    // tell delegate, that this method was called
    if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)])
        [self.delegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

//===========================================================================================
#pragma mark - Layout
- (void)layoutSubviews{
    [super layoutSubviews];
    
    // cells
    [self _layoutCells];
    
    // headers
    [self _layoutHeaders];
}


- (void)_layoutCells{
    
    @autoreleasepool {
        // get new visible indexPath
        NSArray *newVisibleIndexPaths = [self indexPathsForVisibleRect];
        
        // create help array for enumarating
        NSArray *visibleCellsHelper = [NSArray arrayWithArray:[_visibleCells allObjects]];
        
        // purge not visible cells
        for (A3GridTableViewCell *cell in visibleCellsHelper) {
            if (!CGRectIntersectsRect(cell.frame, [self visibleRect])) {
                
                // remove from visible cells
                [_visibleCells removeObject:cell];
                
                // purge
                [self _purgeCell:cell];
            }
        }
        
        // load new cells and add them as subview
        for (NSIndexPath *indexPath in newVisibleIndexPaths) {
            if (![_visibleIndexPaths containsObject:indexPath]) {
                // don't do an integrity check ([respondsToSelector:]) because the dataSource has to implement it.
                A3GridTableViewCell *newCell = [self.dataSource A3GridTableView:self cellForRowAtIndexPath:indexPath];
                
                // set correct cellframe
                newCell.frame = _cellFrames[indexPath.section][indexPath.row];
                newCell.indexPath = indexPath;
                
                // add cell as subview
                [self insertSubview:newCell atIndex:0];
                
                // select / deselect cell
                if ([_selectedIndexPaths containsObject:newCell.indexPath]) {
                    newCell.selected = YES;
                }
                else{
                    newCell.selected = NO;
                }
                
                // add to visible cells
                [_visibleCells addObject:newCell];
                
                // call delegate if it responds
                if ([self.delegate respondsToSelector:@selector(A3GridTableView:willDisplayCellAtIndexPath:)]) {
                    [self.delegate A3GridTableView:self willDisplayCellAtIndexPath:newCell.indexPath];
                }
            }
        }
        
        // udpate visible paths
        [_visibleIndexPaths removeAllObjects];
        [_visibleIndexPaths addObjectsFromArray:newVisibleIndexPaths];
    }
}


- (void)_layoutHeaders{
    // check if datasource implements the required method
    if (![self.dataSource respondsToSelector:@selector(A3GridTableView:headerForSection:)])
        return;
    
    // get new visible indexPath
    NSArray *newVisibleIndexPaths = [self indexPathsForVisibleSections];
    
    // create help array for enumarating
    NSArray *visibleHeadersHelper = [NSArray arrayWithArray:[_visibleHeaders allObjects]];
    
    // purge not visible headers
    for (A3GridTableViewCell *header in visibleHeadersHelper) {
        CGRect helpHeaderFrame = [self visibleRect];
        helpHeaderFrame.origin.x = header.frame.origin.x;
        helpHeaderFrame.size.width = header.frame.size.width;
        
        if (!CGRectIntersectsRect(helpHeaderFrame, [self visibleRect])) {
            
            // remove from visible cells
            [_visibleHeaders removeObject:header];
            
            // purge
            [self _purgeHeaderCell:header];
        }
    }
    
    
    // load new headers and add them as subview
    for (NSIndexPath *indexPath in newVisibleIndexPaths) {
        if (![_visibleSectionIndexPaths containsObject:indexPath]) {
            // don't do an integrity check ([respondsToSelector:]) because i do it at the top if this function
            A3GridTableViewCell *newHeader = [self.dataSource A3GridTableView:self headerForSection:indexPath.section];
            newHeader.indexPath = indexPath;
            
            // add cell as subview
            [self addSubview:newHeader];
            
            // set correct cellframe
            newHeader.frame = (CGRect){0, 0, _sectionWidths[indexPath.section], [self _heightForHeaders]};
            
            // add to visible cells
            [_visibleHeaders addObject:newHeader];
            
            // call delegate if it responds
            if ([self.delegate respondsToSelector:@selector(A3GridTableView:willDisplaySection:)]) {
                [self.delegate A3GridTableView:self willDisplaySection:indexPath.section];
            }
        }
    }
    
    // allign headers
    for (A3GridTableViewCell *header in _visibleHeaders) {
        // set correct cellframe
        header.frame = (CGRect){_sectionXOrigins[header.indexPath.section], self.contentOffset.y, header.frame.size};
        //[self bringSubviewToFront:header];
    }
    
    
    // udpate visible paths
    [_visibleSectionIndexPaths removeAllObjects];
    [_visibleSectionIndexPaths addObjectsFromArray:newVisibleIndexPaths];
}

- (CGFloat)_heightForHeaders{
    CGFloat heightForHeader = 0.0f;
    if ([self.dataSource respondsToSelector:@selector(A3GridTableView:headerForSection:)]) {
        // check header height and store the offset
        if ([self.dataSource respondsToSelector:@selector(heightForHeadersInA3GridTableView:)])
            heightForHeader = [self.dataSource heightForHeadersInA3GridTableView:self];
        else
            heightForHeader = 44.0f;
    }
    
    return heightForHeader;
}

- (void)_updateCellFrames{
    // check if datasource is aviable
    if (!self.dataSource) {
        return;
    }
    
    /*There won't be many dataSource integrity checks (aka. [respondsToSelector:]) here,
     because most of the used methods are required by the dataSource!
     So if a developer doesn't implement these, this code SHOULD crash.
     Just like in a UITableView.
     */
    
    // whipe old info
    [self freeSectionWidths];
    [self freeSectionXOrigins];
    [self freeCellFrames];
    free(numberOfRowsInSection);
    
    // get the number of sections
    numberOfSections = [self.dataSource numberOfSectionsInA3GridTableView:self];
    numberOfRowsInSection = (NSInteger*)calloc(1, sizeof(NSInteger) * numberOfSections +1);
    
    // create new sectionWidth Array
    _sectionWidths = (CGFloat*)malloc(sizeof(CGFloat) * numberOfSections);
    _sectionXOrigins = (CGFloat*)malloc(sizeof(CGFloat) * numberOfSections);
    CGFloat originSectionX = 0.0f;
    
    // fill sections array
    for (int i = 0; i < numberOfSections; i++) {
        if ([self.dataSource respondsToSelector:@selector(A3GridTableView:widthForSection:)]){
            // ask the datasource for the width
            _sectionWidths[i] = [self.dataSource A3GridTableView:self widthForSection:i];
        }
        else{ // Use the screenwidth as default
            _sectionWidths[i] = self.frame.size.width;
        }
        
        // set section origin
        _sectionXOrigins[i] = originSectionX;
        originSectionX += _sectionWidths[i];
    }
    
    
    // create new cellFrames Array and create correct Frames for the position
    _cellFrames = (CGRect**)calloc(1, sizeof(CGRect *) * numberOfSections + 1);
    
    // Contentsize
    CGSize newContentSize = CGSizeMake(0.0f, self.bounds.size.height+1.0f);
    
    // origins
    CGFloat originX = 0.0f;
    CGFloat originY = 0.0f;
    CGFloat offsetYForHeader = [self _heightForHeaders];
    
    // build frame map
    for (int i = 0; i < numberOfSections; i++) {
        // get number of rows in section from datasource and alloc the array
        numberOfRowsInSection[i] = [self.dataSource A3GridTableView:self numberOfRowsInSection:i];
        _cellFrames[i] = (CGRect*)malloc(sizeof(CGRect) * numberOfRowsInSection[i]);
        
        // sizes
        CGFloat width = _sectionWidths[i];
        CGFloat height = 0.0f;
        
        // build frames for that collumn
        for (int j = 0; j < numberOfRowsInSection[i]; j++) {
            
            // ask the datasource for the cell height
            if ([self.dataSource respondsToSelector:@selector(A3GridTableView:heightForRowAtIndexPath:)])
                height = [self.dataSource A3GridTableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            else
                // default ist 44 points
                height = 44.0f;
            
            // set the frame
            _cellFrames[i][j] = (CGRect){originX, originY+offsetYForHeader, width, height};
            
            // update originY
            originY += height;
        }
        
        // update contentsize
        newContentSize.width += width;
        newContentSize.height = MAX(newContentSize.height, originY + offsetYForHeader);
        
        // update originX and Y
        originX += width;
        originY = 0.0f;
    }
    
    // set contentsize
    self.contentSize = newContentSize;
}


//================================
#pragma mark Paging

- (void)setGridTableViewPagingEnabled:(BOOL)enabled{
    _gridTableViewPagingEnabled = enabled;
}

- (BOOL)isGridTableViewPagingEnabled{
    return _gridTableViewPagingEnabled;
}


// Disable original scrollview paging
- (BOOL)isPagingEnabled{
    return NO;
}
- (void)setPagingEnabled:(BOOL)enabled{
    [super setPagingEnabled:NO];
}
// end disable

- (void)_alignPageAnimated:(BOOL) animated{
    
    // set info flag
    _deceleratingFromPaging = YES;
    
    // get the correct section
    CGPoint offsetForSection = self.contentOffset;
    
    switch (self.pagingPosition) {
        case A3GridTableViewCellAlignmentCenter:
            offsetForSection.x += self.frame.size.width/2.0f;
            break;
        case A3GridTableViewCellAlignmentRight:
            offsetForSection.x += self.frame.size.width-1;
            break;
        case A3GridTableViewCellAlignmentLeft:
            offsetForSection.x += 1;
            break;
            
        default:
            break;
    }
    
    // get item for offset
    int indexOfCell = [self _sectionIndexForContentOffset:offsetForSection];
    
    // don't do anything when there is no item
    if (indexOfCell < 0)
        return;
    
    CGPoint newOffset = self.contentOffset;
    CGFloat pagingPositionOffset = 0.0f;
    
    
    switch (self.pagingPosition) {
        case A3GridTableViewCellAlignmentCenter:
            pagingPositionOffset = -self.frame.size.width/2.0f + _sectionWidths[indexOfCell]/2.0f;
            break;
        case A3GridTableViewCellAlignmentRight:
             pagingPositionOffset = -self.frame.size.width + _sectionWidths[indexOfCell];
            break;
            
        case A3GridTableViewCellAlignmentLeft:
        default:
            pagingPositionOffset = 0.0f;
            break;
    }
    
    newOffset.x = _sectionXOrigins[indexOfCell] + pagingPositionOffset;
    newOffset.x = MAX(0.0f, newOffset.x);
    newOffset.x = MIN(newOffset.x, self.contentSize.width-self.frame.size.width);
    
    //[self setContentOffset:newOffset animated:animated];
    if (animated) {
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.contentOffset = newOffset;
                         }
                         completion:^(BOOL finished) {
                             
                             _deceleratingFromPaging = NO;
                             
                             // call delegate
                             if ([self.delegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)])
                                 [self.delegate scrollViewDidEndDecelerating:self];
                         }
         ];
    }
    else{
        self.contentOffset = newOffset;
        _deceleratingFromPaging = NO;
    }
}

//===========================================================================================
#pragma mark - Reload

- (void)reloadData{
    
    // purge headers
    for (A3GridTableViewCell *headerCell in _visibleHeaders) {
        [self _purgeHeaderCell:headerCell];
    }
    
    // purge cells
    for (A3GridTableViewCell *cell in [self visibleCells]) {
        [self _purgeCell:cell];
    }
    
    // reset stuff
    [_visibleIndexPaths removeAllObjects];
    [_visibleSectionIndexPaths removeAllObjects];
    [_visibleHeaders removeAllObjects];
    [_visibleCells removeAllObjects];
    
    // relayout
    [self _updateCellFrames];
    
    // cells
    [self _layoutCells];
    
    // headers
    [self _layoutHeaders];
}


- (void)reloadCellsWithViewAnimation:(BOOL)animated{
    // relayout
    [self _updateCellFrames];
    
    // change their frames
    for (A3GridTableViewCell *cell in [self visibleCells]) {
        if (animated) {
            [UIView animateWithDuration:0.4 animations:^{
                cell.frame = _cellFrames[cell.indexPath.section][cell.indexPath.row];
            }];
        }
        else{
            cell.frame = _cellFrames[cell.indexPath.section][cell.indexPath.row];
        }
    }
}


//===========================================================================================
#pragma mark - datasource and delegate
// DataSource
- (void)setDataSource:(id<A3GridTableViewDataSource>)aDataSource{
    
    // ignore if both sources are equal
    if (aDataSource == _dataSource)
        return;
    
    // memory stuff
    [aDataSource retain];
    [_dataSource release];
    _dataSource = aDataSource;
    
    // reload data
    [self reloadData];
}


// Delegate
- (void)setDelegate:(id<A3GridTableViewDelegate>)aDelegate{
    
    // memory stuff
    [aDelegate retain];
    [_delegateGridTableView release];
    _delegateGridTableView = aDelegate;
    
    // set scrollviewDelegate
    [super setDelegate:nil];
    [super setDelegate:self];
}


//===========================================================================================
#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // call super
    [super touchesBegan:touches withEvent:event];
    
    // reset moved
    _touchesAreDirty = NO;
    
    // return if selection is disabled
    if (!self.allowsSelection && !self.allowsMultipleSelection)
        return;    
    
    // get the touch
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    // iterate through visible headers
    for (A3GridTableViewCell *header in _visibleHeaders) {
        
        // if touch is inside cell highlight it and break
        if (CGRectContainsPoint(header.frame, touchPoint)) {
            
            // highlighted cell
            [header setHighlighted:YES animated:YES];
            
            return;
        }
    }
    
    
    // iterate through visible cells
    for (A3GridTableViewCell *cell in [self visibleCells]) {
        
        // Ask delegate if cell is selectable.
        if ([self.delegate respondsToSelector:@selector(A3GridTableView:canSelectCellAtIndexPath:)]) {
            BOOL canSelectCell = [self.delegate A3GridTableView:self canSelectCellAtIndexPath:cell.indexPath];
            
            // When not break loop.
            if (!canSelectCell) break;
        }
        
        // if touch is inside cell highlight it and break
        if (CGRectContainsPoint(cell.frame, touchPoint)) {
            
            // highlighted cell
            [cell setHighlighted:YES animated:YES];
            
            // ignore others when header was selected
            break;
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    // call super
    [super touchesMoved:touches withEvent:event];
    
    // deselect all
    if (!_touchesAreDirty) {
        [self _unhighlightAllCells];
        _touchesAreDirty = YES;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    // call super
    [super touchesCancelled:touches withEvent:event];
    
    // deselect all
    if (!_touchesAreDirty) {
        [self _unhighlightAllCells];
        _touchesAreDirty = YES;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // call super
    [super touchesEnded:touches withEvent:event];
    
    // unhighlight all cells
    [self _unhighlightAllCells];
    
    // return if selection is disabled
    if (!self.allowsSelection && !self.allowsMultipleSelection)
        return;
    
    // get the touch
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    
    // iterate through visible headers
    for (A3GridTableViewCell *header in _visibleHeaders) {
        
        if (CGRectContainsPoint(header.frame, touchPoint)){
            // call delegate if it responds
            if ([self.delegate respondsToSelector:@selector(A3GridTableView:didSelectHeaderAtSection:)]) {
                [self.delegate A3GridTableView:self didSelectHeaderAtSection:header.indexPath.section];
            }
            
            // ignore others when header was selected
            return;
        }
    }
    
    // iterate through visible cells
    for (A3GridTableViewCell *cell in [self visibleCells]) {
        
        // Ask delegate if cell is selectable.
        if ([self.delegate respondsToSelector:@selector(A3GridTableView:canSelectCellAtIndexPath:)]) {
            BOOL canSelectCell = [self.delegate A3GridTableView:self canSelectCellAtIndexPath:cell.indexPath];
            
            // When not, ignore touches
            if (!canSelectCell) continue;
        }
        
        if (CGRectContainsPoint(cell.frame, touchPoint)) {
            // deselect cell
            if ([_selectedIndexPaths containsObject:cell.indexPath]) {
                [self deselectCellAtIndexPath:cell.indexPath animated:YES];
            }
            // Select cell
            else{
                [self selectCellAtIndexPath:cell.indexPath animated:YES];
            }
        }
        else{
            // deselect not touched cell if multiple selection isn't enabled
            if (!self.allowsMultipleSelection && [_selectedIndexPaths containsObject:cell.indexPath]) {
                [self deselectCellAtIndexPath:cell.indexPath animated:YES];
            }
        }
    }
}

//===========================================================================================
#pragma mark - Cell Handling

//======================
#pragma mark Dequeue
/////////////////
// Dequeue Header
- (A3GridTableViewCell *)dequeueReusableHeaderWithIdentifier:(NSString *)identifier{
    // header to dequeue
    A3GridTableViewCell *headerToDequeue = nil;
    
    // get a Set of unusedHeaders for the reuseIdentifier
    NSMutableSet *setFromReuseIdentifier = [_unusedHeaders objectForKey:identifier];
    
    // get headerCell from set if set exists
    if (setFromReuseIdentifier) {
        headerToDequeue = [[setFromReuseIdentifier anyObject] retain];
        if (headerToDequeue)
            [setFromReuseIdentifier removeObject:headerToDequeue];
    }
    
    // prepare cell for reuse
    [headerToDequeue prepareForReuse];
    
    // return dequeued header
    return [headerToDequeue autorelease];
}

///////////////
// Dequeue Cell
- (A3GridTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier{
    
    // cell to dequeue
    A3GridTableViewCell *cellToDequeue = nil;
    
    // get a Set of unusedCell for the reuseIdentifier
    NSMutableSet *setFromReuseIdentifier = [_unusedCells objectForKey:identifier];
    
    // get cell from set if set exists
    if (setFromReuseIdentifier) {
        cellToDequeue = [[setFromReuseIdentifier anyObject] retain];
        if (cellToDequeue)
            [setFromReuseIdentifier removeObject:cellToDequeue];
    }
    
    // prepare cell for reuse
    [cellToDequeue prepareForReuse];
    
    // return dequeued cell
    return [cellToDequeue autorelease];
}


//======================
#pragma mark Purging
///////////////
// Purge Header
- (void)_purgeHeaderCell:(A3GridTableViewCell *)headerCell{
    // remove headerCell from view
    [headerCell removeFromSuperview];
    
    // reset indexpath
    headerCell.indexPath = nil;
    
    // don't cache if there is no reuse identifier
    if (headerCell.reuseIdentifier) {
        
        // get Set for reuse identifier
        NSMutableSet *setFromIdentifier = [[_unusedHeaders objectForKey:headerCell.reuseIdentifier] retain];
        
        // make new set if there is none
        if (!setFromIdentifier) {
            // create new set
            setFromIdentifier = [[NSMutableSet alloc] initWithCapacity:16];
            
            // add to unused headers
            [_unusedHeaders setObject:setFromIdentifier forKey:headerCell.reuseIdentifier];
        }
        
        // add headerCell to set and clean up
        [setFromIdentifier addObject:headerCell];
        
        // clean
        [setFromIdentifier release];
    }
}

/////////////
// Purge Cell
- (void)_purgeCell:(A3GridTableViewCell *)cell{
    // remove headerCell from view
    [cell removeFromSuperview];
    
    // reset indexpath
    cell.indexPath = nil;
    
    // don't cache if there is no reuse identifier
    if (cell.reuseIdentifier) {
        
        // get Set for reuse identifier
        NSMutableSet *setFromIdentifier = [[_unusedCells objectForKey:cell.reuseIdentifier] retain];
        
        // make new set if there is none
        if (!setFromIdentifier) {
            // create new set
            setFromIdentifier = [[NSMutableSet alloc] initWithCapacity:32];
            
            // add to unused headers
            [_unusedCells setObject:setFromIdentifier forKey:cell.reuseIdentifier];
        }
        
        // add cell to set and clean up
        [setFromIdentifier addObject:cell];
        
        // clean
        [setFromIdentifier release];
    }
}

//===========================================================================================
#pragma mark - memory
- (void)freeSectionWidths{
    free(_sectionWidths);
    _sectionWidths = NULL;
}


- (void)freeSectionXOrigins{
    free(_sectionXOrigins);
    _sectionXOrigins = NULL;
}

- (void)freeCellFrames{
    if (_cellFrames) {
        for (int i = 0; _cellFrames[i]; i++) {
            free(_cellFrames[i]);
            _cellFrames[i] = NULL;
        }
    }
    free(_cellFrames);
    _cellFrames = NULL;
}



//===========================================================================================
#pragma mark - selections

- (NSIndexPath *)indexPathForSelectedCell{
    NSIndexPath *selectedIndexPath = nil;
    
    if ([_selectedIndexPaths count] > 0) {
        selectedIndexPath = [_selectedIndexPaths objectAtIndex:0];
    }
    
    return selectedIndexPath;
}

- (NSArray *)indexPathsForSelectedCells{
    return _selectedIndexPaths;
}

- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated{
    
    // add index to selected indices
    [_selectedIndexPaths addObject:indexPath];
    
    // set cell selection
    for (A3GridTableViewCell *cell in [self visibleCells]) {
        // select / deselect cell
        if ([indexPath isEqual: cell.indexPath]) {
            [cell setSelected:YES animated:animated];
            break;
        }
    }
    
    // call delegate if it responds
    if ([self.delegate respondsToSelector:@selector(A3GridTableView:didSelectCellAtIndexPath:)]) {
        [self.delegate A3GridTableView:self didSelectCellAtIndexPath:indexPath];
    }
    
}

- (void)deselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated{
    
    // remove indexpath from selected indices
    [_selectedIndexPaths removeObject:indexPath];
    
    // set cell selection
    for (A3GridTableViewCell *cell in [self visibleCells]) {
        // select / deselect cell
        if ([indexPath isEqual: cell.indexPath]) {
            [cell setSelected:NO animated:animated];
            break;
        }
    }
    
    // call delegate if it responds
    if ([self.delegate respondsToSelector:@selector(A3GridTableView:willDeselectCellAtIndexPath:)]) {
        [self.delegate A3GridTableView:self willDeselectCellAtIndexPath:indexPath];
    }
}

- (void)scrollToCellAtIndexPath:(NSIndexPath *)indexPath atCellAlignment:(A3GridTableViewCellAlignment)alignment atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated{
    // get frame of cell at the index
    CGRect rectOfCellAtIndexPath = _cellFrames[indexPath.section][indexPath.row];
    CGPoint newContentOffset = rectOfCellAtIndexPath.origin;
    
    // align horizontaly
    switch (alignment) {
        case A3GridTableViewCellAlignmentCenter:
            newContentOffset.x = -self.frame.size.width/2.0f + rectOfCellAtIndexPath.size.width/2.0f;
            break;
        case A3GridTableViewCellAlignmentRight:
            newContentOffset.x = -self.frame.size.width + rectOfCellAtIndexPath.size.width;
            break;
        case A3GridTableViewCellAlignmentLeft:
        default:
            break;
    }
    
    // align vertically
    switch (scrollPosition) {
        case UITableViewScrollPositionMiddle:
            newContentOffset.y = -self.frame.size.width/2.0 + rectOfCellAtIndexPath.size.width/2.0;
            break;
        case UITableViewScrollPositionBottom:
            newContentOffset.y = -self.frame.size.width + rectOfCellAtIndexPath.size.width;
            break;
        case UITableViewScrollPositionTop:
        default:
            break;
    }
    
    // set content offset
    [self setContentOffset:newContentOffset animated:animated];
}

- (void)_deselectAllCells{
    for (A3GridTableViewCell *cell in [self visibleCells]) {
        // unselect
        cell.selected = NO;
    }
}

- (void)_unhighlightAllCells{
    // header
    for (A3GridTableViewCell *header in _visibleHeaders) {
        // unhighlight
        [header setHighlighted:NO animated:YES];
    }
    
    // cells
    for (A3GridTableViewCell *cell in [self visibleCells]) {
        // unhighlight
        [cell setHighlighted:NO animated:YES];
    }
}

//===========================================================================================
#pragma mark - Index stuff

- (NSArray *)indexPathsForRect:(CGRect)rect{
    
    // initialize return array
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    // iterate through all cells
    for (int i = 0; i < numberOfSections; i++) {
        for (int j = 0; j < numberOfRowsInSection[i]; j++) {
            
            // get frame of cell at the indexpath
            CGRect cellFrame = _cellFrames[i][j];
            
            // if frame of cell is inside the visible frame of
            // the scrollview then add it to the indexPath array
            if (CGRectIntersectsRect(cellFrame, rect)) {
                [indexPaths addObject:[NSIndexPath indexPathForRow:j inSection:i]];
            }
        }
    }
    
    return [indexPaths autorelease];
}

- (NSArray *)indexPathsForVisibleRect{
    return [self indexPathsForRect:[self visibleRect]];
}

- (NSArray *)indexPathsForSectionsInRect:(CGRect)rect{
    // initialize return array
    NSMutableArray *indexPaths = [[NSMutableArray alloc] init];
    
    // iterate through all sections
    CGFloat posX = 0.0f;
    
    for (int i = 0; i < numberOfSections; i++) {
        
        // Build rect for section
        CGRect rectOfsection = rect;
        rectOfsection.origin.x = posX;
        rectOfsection.size.width = _sectionWidths[i];
        
        // add to indexpaths if it contains it
        if (CGRectIntersectsRect(rect, rectOfsection)) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:0 inSection:i]];
        }
        
        // update posx
        posX += _sectionWidths[i];
    }
    
    return [indexPaths autorelease];
}

- (NSArray *)indexPathsForVisibleSections{
    return [self indexPathsForSectionsInRect:[self visibleRect]];
}

// alignment
- (NSInteger)_sectionIndexForContentOffset:(CGPoint)contentOffset{
    int section = -1;
    CGFloat minDeltaX = -1.0;
    
    for (int i = 0 ; i < numberOfSections; i++) {
        
        CGFloat deltaX = fabs(contentOffset.x - _sectionXOrigins[i] - _sectionWidths[i]/2.0f);
        
        if (deltaX < minDeltaX || section < 0) {
            section = i;
            minDeltaX = deltaX;
        }
    }
    
    return section;
}


//===========================================================================================
#pragma mark - Properties

- (NSArray *)visibleCells{
    return [_visibleCells allObjects];
}

- (BOOL)isDecelerating{
    BOOL superDecel = [super isDecelerating];
    return superDecel || _deceleratingFromPaging;
}

//===========================================================================================
#pragma mark - helper

- (CGRect)visibleRect{
    // calc visible Rect
    CGRect visibleRect = self.bounds;
    visibleRect.origin = self.contentOffset;
    
    return visibleRect;
}

@end
