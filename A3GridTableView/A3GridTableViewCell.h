//
//  A3GridTableViewCell.h
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

@interface A3GridTableViewCell : UIView

/**
 @Description: Designated initializer.
 @param: reuseIdentifier If the cell can be reused, you must pass in a reuse identifier. You should use the same reuse identifier for all cells of the same form.
 */
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

//======================================================================
#pragma mark - Views
/**
 @description: The default background which is visible.
*/
@property (nonatomic, strong) UIView *backgroundView;

/**
 @description: The contenView holds all subviews of the cell. Use this View if you wan't to customize (add subviews) to the cell, rather than manipulating directly the cell.
 */
@property (nonatomic, strong) UIView *contentView;

/**
 @description: The selectedBackgroundView is visible when the cell is selected. It is shown above the backgroundView but below the contentView.
 */
@property (nonatomic, strong) UIView *selectedBackgroundView;

/**
 @description: The highlightedBackgroundView is visible when the cell is highlighted. It is shown above the backgroundView but below the contentView.
 */
@property (nonatomic, strong) UIView *highlightedBackgroundView;

/**
 @description: The standard titleLabel. You can set it it nil if you don't need it.
 */
@property (nonatomic, strong) UILabel *titleLabel;


//======================================================================
#pragma mark - Information

/**
 @description: A string used to identify a cell that is reusable.
 */
@property (nonatomic, strong) NSString *reuseIdentifier;

/**
 @description: If the cell is reusable (has a reuse identifier), this is called just before the cell is returned from the table view method [dequeueReusableCellWithIdentifier:].
 */
- (void)prepareForReuse;


/**
 @description: The indexpath of the cell when it is visible. If the cell is not visible, the value is invalid and should not be trusted.
 */
@property (nonatomic, strong) NSIndexPath *indexPath;



/**
 @description: Set selected state (title, image, background). default is NO. animated is NO
 */
@property(nonatomic,getter=isSelected) BOOL selected;

/**
 @description: Animate between regular and selected state
 */
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;



/**
 @description: Set highlighted state (title, image, background). default is NO. animated is NO
 */
@property(nonatomic,getter=isHighlighted) BOOL highlighted;

/**
 @description: Animate between regular and highlighted state
 */
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated;               

@end
