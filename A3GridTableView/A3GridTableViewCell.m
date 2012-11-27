//
//  A3GridTableViewCell.m
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


#import "A3GridTableViewCell.h"

@implementation A3GridTableViewCell

//===========================================================================================
#pragma mark - Memory

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    self = [super init];
    if (self) {
        // Set the reuseIdentifier
        _reuseIdentifier = [reuseIdentifier retain];
        
        // set up contentView
        self.contentView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.contentView.backgroundColor = [UIColor clearColor];
        
        // set up Background
        self.backgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.backgroundView.backgroundColor = [UIColor clearColor];
        
        // set up selected BG
        self.selectedBackgroundView = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
        
        // set up highlighted BG
        self.highlightedBackgroundView  = [[[UIView alloc] initWithFrame:self.bounds] autorelease];
        self.highlightedBackgroundView.backgroundColor = [UIColor clearColor];
        
        // set up titleLabel
        self.titleLabel = [[[UILabel alloc] init] autorelease];
        self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.titleLabel.textAlignment = UITextAlignmentLeft;
        
        [self.contentView addSubview: self.titleLabel];
        
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)dealloc{
    [_titleLabel release];
    [_reuseIdentifier release];
    [_backgroundView release];
    [_contentView release];
    [_selectedBackgroundView release];
    [_highlightedBackgroundView release];
    [_reuseIdentifier release];
    [_indexPath release];
    
    [super dealloc];
}


//===========================================================================================
#pragma mark - Reuse
- (void)prepareForReuse{}

//===========================================================================================
#pragma mark - Properties
- (void)setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    // update title label
    _titleLabel.frame = CGRectMake(10.0f, 0.0f, _contentView.bounds.size.width - 10.0f, _contentView.bounds.size.height);
    _titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (void)setSelected:(BOOL)selected{
    [self setSelected:selected animated:NO];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    _selected = selected;
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.selectedBackgroundView.alpha = selected?1.0f:0.0f;
        }];
    }
    else{
        self.selectedBackgroundView.alpha = selected?1.0f:0.0f;
    }
}

- (void)setHighlighted:(BOOL)highlighted{
    [self setHighlighted:highlighted animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated{
    _highlighted = highlighted;
    
    if (animated) {
        [UIView animateWithDuration:0.3 animations:^{
            self.highlightedBackgroundView.alpha = highlighted?1.0f:0.0f;
        }];
    }
    else{
        self.highlightedBackgroundView.alpha = highlighted?1.0f:0.0f;
    }
}

- (void)setBackgroundView:(UIView *)backgroundView{
    [_backgroundView removeFromSuperview];
    
    [backgroundView retain];
    [_backgroundView release];
    _backgroundView = backgroundView;
    
    _backgroundView.frame = self.bounds;
    _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self addSubview: _backgroundView];
    [self sendSubviewToBack:_backgroundView];
}

- (void)setContentView:(UIView *)contentView{
    [_contentView removeFromSuperview];
    
    [contentView retain];
    [_contentView release];
    _contentView = contentView;
    
    _contentView.frame = self.bounds;
    _contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _contentView.backgroundColor = [UIColor clearColor];
    
    [self addSubview: _contentView];
    [self bringSubviewToFront:_contentView];
}

- (void)setSelectedBackgroundView:(UIView *)selectedBackgroundView{
    [_selectedBackgroundView removeFromSuperview];
    
    [selectedBackgroundView retain];
    [_selectedBackgroundView release];
    _selectedBackgroundView = selectedBackgroundView;
    
    _selectedBackgroundView.frame = self.bounds;
    _selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _selectedBackgroundView.alpha = 0.0f;
    
    [self insertSubview:_selectedBackgroundView aboveSubview:_backgroundView];
}

- (void)setHighlightedBackgroundView:(UIView *)highlightedBackgroundView{
    [_highlightedBackgroundView removeFromSuperview];
    
    [highlightedBackgroundView retain];
    [_highlightedBackgroundView release];
    _highlightedBackgroundView = highlightedBackgroundView;
    
    _highlightedBackgroundView.frame = self.bounds;
    _highlightedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    _highlightedBackgroundView.alpha = 0.0f;
    
    [self insertSubview:_highlightedBackgroundView aboveSubview:_selectedBackgroundView];
}

@end
