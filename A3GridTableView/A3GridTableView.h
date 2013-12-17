//
//  A3GridTableView.h
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


#import <UIKit/UIKit.h>
#import "A3GridTableViewCell.h"
@class A3GridTableView;


//==========================================================================================
#pragma mark - Paging position enumeration
//==========================================================================================
typedef enum {
    A3GridTableViewCellAlignmentLeft,
    A3GridTableViewCellAlignmentCenter,
    A3GridTableViewCellAlignmentRight
} A3GridTableViewCellAlignment;

//==========================================================================================
#pragma mark - DataSource for the gridTableView
//==========================================================================================
/**
 @brief The Controller of a A3GridTableView has to be its DataSource and implement the required methods to work.
 */
@protocol A3GridTableViewDataSource <NSObject>

@required
/**
 @param gridTableView The gridTableView which asks for the number of sections.
 @return Returns the GridTableView the number of sections. A section will be presented as a custom column in the GridTableView.
 */
- (NSInteger)numberOfSectionsInA3GridTableView:(A3GridTableView *) gridTableView;

/**
 @param gridTableView The gridTableView which asks for the number of items in a section.
 @param section The section of the GridTableView for which the dataSource should return the number of rows.
 @return return the GridTableView the number of sections. A section will be presented as a custom column in the GridTableView.
 */
- (NSInteger)A3GridTableView:(A3GridTableView *) tableView numberOfRowsInSection:(NSInteger) section;

/**
 @param gridTableView The gridTableView which asks for a cell.
 @param section The indexPath of the cell.
 @return return the GridTableView a A3GridTableViewCell for the cell at the indexPath. Must not be nil.
 */
- (A3GridTableViewCell *)A3GridTableView:(A3GridTableView *)gridTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@optional
/**
 @brief Called before the cell will be displayed or updated. Default is 44 points.
 @param gridTableView The gridTableView which asks for the Height for a cell.
 @param indexPath The indexPath of the cell
 @return return the height for the Cell at the indexPath.
 */
- (CGFloat)A3GridTableView:(A3GridTableView *) gridTableView heightForHeaders:(NSIndexPath *) indexPath;

/**
 @param gridTableView The gridTableView which asks for a header.
 @param section The section of the header.
 @return return the GridTableView a A3GridTableViewCell as a Header. If nil or not implemented, there will be no header in the section.
 */
- (A3GridTableViewCell *)A3GridTableView:(A3GridTableView *) gridTableView headerForSection:(NSInteger) section;

/**
 @param gridTableView The gridTableView which asks for the Height.
 @return return the Height for all Headers in the gridTableView.
 @brief Called once for all headers in reloadData(). Default is 44 points.
 */
- (CGFloat)heightForHeadersInA3GridTableView:(A3GridTableView *) gridTableView;

/**
 @param gridTableView The gridTableView which asks for the width for a section.
 @return return the Width for the section.
 @brief Called once for all headers in reloadData(). Default is the Screenwidth.
 */
- (CGFloat)A3GridTableView:(A3GridTableView *) gridTableView widthForSection:(NSInteger) section;

/**
 @param gridTableView The gridTableView which asks for the Height for a cell.
 @param indexPath The indexPath of the cell
 @return return the height for the Cell at the indexPath.
 @brief Called before the cell will be displayed or updated. Default is 44 points.
 */
- (CGFloat)A3GridTableView:(A3GridTableView *) gridTableView heightForRowAtIndexPath:(NSIndexPath *) indexPath;

@end


//==========================================================================================
#pragma mark - Delegate for the gridTableView
//==========================================================================================
/*
 @brief The GridTableViewDelegate extends the UIScrollViewDelegate. The Controller which acts as a delegate for a GridTableView can implement methods similar to a UITableView.
 */
@protocol A3GridTableViewDelegate <UIScrollViewDelegate, NSObject>

@optional
// Header/Sections

/**
 @param gridTableView The gridTableView which calls the delegate.
 @param section The index of the section which will be displayed.
 @brief Called before the section will be displayed.
 */
- (void) A3GridTableView:(A3GridTableView *)gridTableView willDisplaySection:(NSInteger) section;

/**
 @param gridTableView The gridTableView which calls the delegate.
 @param section The index of the section which was selected.
 @brief Called when the section is selected.
 */
- (void) A3GridTableView:(A3GridTableView *)gridTableView didSelectHeaderAtSection:(NSInteger) section;


// Cells

/**
 @param gridTableView The gridTableView which calls the delegate.
 @param section The indexPath of the Cell which will be displayed.
 @brief Called before the Cell will be displayed.
 */
- (void) A3GridTableView:(A3GridTableView *)gridTableView willDisplayCellAtIndexPath:(NSIndexPath *) indexPath;

/**
 @param gridTableView The gridTableView which calls the delegate. If not implemented, every cell is selectable.
 @param section The indexPath of the Cell which will be selected.
 @brief Called before the Cell is selected.
 @return Whether the cell is selectable or not
 */
- (BOOL) A3GridTableView:(A3GridTableView *)gridTableView canSelectCellAtIndexPath:(NSIndexPath *) indexPath;

/**
 @param gridTableView The gridTableView which calls the delegate.
 @param section The indexPath of the Cell which was selected.
 @brief Called when the Cell is selected.
 */
- (void) A3GridTableView:(A3GridTableView *)gridTableView didSelectCellAtIndexPath:(NSIndexPath *) indexPath;

/**
 @param gridTableView The gridTableView which calls the delegate.
 @param section The indexPath of the Cell which will be deselected.
 @brief Called before the Cell will be selected.
 */
- (void) A3GridTableView:(A3GridTableView *)gridTableView willDeselectCellAtIndexPath:(NSIndexPath *) indexPath;

@end


//==========================================================================================
#pragma mark - Actual TableView
//==========================================================================================
/**
 @brief The GridTableView displays his Cells like a UITableView but in a grid based layout where the sections are represented as columns.
 */
@interface A3GridTableView : UIScrollView <UIScrollViewDelegate>

//===========================================
#pragma mark datasource and delegate
//===========================================
// DataSource
@property (nonatomic, weak) id<A3GridTableViewDataSource> dataSource;
/**
 @brief Sets the DataSource of the GridTableView. By doing this, the GridTableView will automatically reload his data.
 @param aDataSource The ViewController which acts as the DataSource for the GridTableView.
 */
- (void)setDataSource:(id<A3GridTableViewDataSource>)aDataSource;

// Delegate
@property (nonatomic, weak) id<A3GridTableViewDelegate> delegate;
/**
 @brief Sets the Delegate of the GridTableView.
 @param aDelegate The ViewController which acts as the Delegate for the GridTableView.
 */
- (void)setDelegate:(id<A3GridTableViewDelegate>)aDelegate;


//===========================================
#pragma mark Update
//===========================================
- (void)reloadData;

- (void)reloadCellsWithViewAnimation:(BOOL)animated;

//===========================================
#pragma mark Header
//===========================================
- (A3GridTableViewCell *)dequeueReusableHeaderWithIdentifier:(NSString *)identifier;


//===========================================
#pragma mark Cell 
//===========================================
- (A3GridTableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (NSArray *)visibleCells;


//===========================================
#pragma mark selections
//===========================================

/**
 @brief return the indexPath of the currently selected cell.
 @return return nil if none item is selected.
 */
- (NSIndexPath *)indexPathForSelectedCell;

/**
 @brief returns the indexPaths for all selected items. Empty array if no item is selected.
 @return returns nil if none item is selected.
 */
- (NSArray *)indexPathsForSelectedCells;

/**
 @brief Selects the Cell at the given sindexPath.
 @param indexPath Index Path of the cell to be selected.
 @param animated Whether this should be animated or not.
 @param scrollPosition Vertical position of the cell.
 @param alignment Hoprizontal position of the cell.
 */
- (void)selectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

/**
 @discussion Delects the Cell at the given indexPath.
 @param indexPath Index Path of the cell to be deselected.
 @param animated Whether this should be animated or not.
 */
- (void)deselectCellAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;

/**
 @brief scrolls to the Cell at the given indexPath.
 @param indexPath IndexPath of the cell whcih will be scrolled to.
 @param scrollPosition Vertical position of the cell.
 @param alignment Hoprizontal position of the cell.
 @param animated Whether this should be animated or not.
 */
- (void)scrollToCellAtIndexPath:(NSIndexPath *)indexPath atCellAlignment:(A3GridTableViewCellAlignment)alignment atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;


/**
 @brief Enables/disables selection. Default is YES.
 */
@property (nonatomic, assign) BOOL allowsSelection;

/**
 @brief Enables/disables multiple selection. Default is NO.
 */
@property (nonatomic, assign) BOOL allowsMultipleSelection;

//===========================================
#pragma mark Index stuff
//===========================================
/**
 @return Returns the indexPaths for the given Rect.
 */
- (NSArray *)indexPathsForRect:(CGRect)rect;

/**
 @return Returns the indexPaths for the visible rect.
 */
- (NSArray *)indexPathsForVisibleRect;

/**
 @return Returns the indexPaths of the sections for the given Rect.
 */
- (NSArray *)indexPathsForSectionsInRect:(CGRect)rect;

/**
 @return Returns the indexPaths of the sections the visible Rect.
 */
- (NSArray *)indexPathsForVisibleSections;


//===========================================
#pragma mark other
//===========================================
- (CGRect)visibleRect;


//===========================================
#pragma mark paging
//===========================================
/**
    @brief Sets the position of the paging when paging is enabled.Default is A3GridTableViewPagingPositionCenter.
 */
@property(nonatomic, assign) A3GridTableViewCellAlignment pagingPosition;

/**
 @brief A Boolean value that determines whether paging is enabled for the A3GridTableView.
 @discussion If the value of this property is YES, the scroll view alligns his section defined by pagingPosition when the user scrolls. The default value is NO.
 */
@property(nonatomic, getter = isGridTableViewPagingEnabled) BOOL gridTableViewPagingEnabled;
- (BOOL)isGridTableViewPagingEnabled;

@end
