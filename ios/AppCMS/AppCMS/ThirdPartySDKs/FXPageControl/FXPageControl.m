//
//  FXPageControl.m
//
//  Version 1.4
//
//  Created by Nick Lockwood on 07/01/2010.
//  Copyright 2010 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version of FXPageControl from here:
//
//  https://github.com/nicklockwood/FXPageControl
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "FXPageControl.h"


#pragma GCC diagnostic ignored "-Wgnu"
//#pragma GCC diagnostic ignored "-Wreceiver-is-weak"
#pragma GCC diagnostic ignored "-Warc-repeated-use-of-weak"
#pragma GCC diagnostic ignored "-Wdirect-ivar-access"


#import <Availability.h>
#if !__has_feature(objc_arc)
#error This class requires automatic reference counting
#endif


const CGPathRef FXPageControlDotShapeCircle = (const CGPathRef)1;
const CGPathRef FXPageControlDotShapeSquare = (const CGPathRef)2;
const CGPathRef FXPageControlDotShapeTriangle = (const CGPathRef)3;
#define LAST_SHAPE FXPageControlDotShapeTriangle


@implementation NSObject (FXPageControl)

- (UIImage *)pageControl:(__unused FXPageControl *)pageControl imageForDotAtIndex:(__unused NSInteger)index { return nil; }
- (CGPathRef)pageControl:(__unused FXPageControl *)pageControl shapeForDotAtIndex:(__unused NSInteger)index { return NULL; }
- (UIColor *)pageControl:(__unused FXPageControl *)pageControl colorForDotAtIndex:(__unused NSInteger)index { return nil; }

- (UIImage *)pageControl:(__unused FXPageControl *)pageControl selectedImageForDotAtIndex:(__unused NSInteger)index { return nil; }
- (CGPathRef)pageControl:(__unused FXPageControl *)pageControl selectedShapeForDotAtIndex:(__unused NSInteger)index { return NULL; }
- (UIColor *)pageControl:(__unused FXPageControl *)pageControl selectedColorForDotAtIndex:(__unused NSInteger)index { return nil; }

@end


@implementation FXPageControl

- (void)setUp
{	
    //needs redrawing if bounds change
    self.contentMode = UIViewContentModeRedraw;
    
	//set defaults
    _alignment = SFPageControlAlignmentCenter;
	_dotSpacing = 10.0;
	_dotSize = 6.0;
    _dotShadowOffset = CGSizeMake(0, 1);
    _selectedDotShadowOffset = CGSizeMake(0, 1);
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		[self setUp];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
		[self setUp];
	}
	return self;
}

- (void)dealloc
{
    if (_dotShape > LAST_SHAPE) CGPathRelease(_dotShape);
    if (_selectedDotShape > LAST_SHAPE) CGPathRelease(_selectedDotShape);
}

- (CGSize)sizeForNumberOfPages:(__unused NSInteger)pageCount
{
    CGFloat marginSpace = MAX(0, _numberOfPages - 1) * _dotSpacing;
    CGFloat indicatorSpace = _numberOfPages * _dotWidth;
    CGSize size = CGSizeMake(marginSpace + indicatorSpace, _dotSize);
    return size;
//    CGFloat width = _dotSize + (_dotSize + _dotSpacing) * (_numberOfPages - 1);
//    return _vertical? CGSizeMake(_dotSize, width): CGSizeMake(width, _dotSize);
}

- (void)updateCurrentPageDisplay
{
    [self setNeedsDisplay];
}

- (void)drawRect:(__unused CGRect)rect
{
	if (_numberOfPages > 1 || !_hidesForSinglePage)
	{
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGSize size = [self sizeForNumberOfPages:_numberOfPages];
        CGFloat offset = [self _leftOffset];

        if (_vertical)
        {
            CGContextTranslateCTM(context, self.frame.size.width / 2, (self.frame.size.height - size.height) / 2);
        }
        else
        {
            CGContextTranslateCTM(context, offset, self.frame.size.height / 2);
        }
        
        for (int i = 0; i < _numberOfPages; i++)
		{
			UIImage *dotImage = nil;
            UIColor *dotColor = nil;
            CGPathRef dotShape = NULL;
            CGFloat dotSize = 0;
            UIColor *dotShadowColor = nil;
            CGSize dotShadowOffset = CGSizeZero;
            CGFloat dotShadowBlur = 0;
            CGFloat dotWidth = 0;
            
			if (i == _currentPage)
			{
				[_selectedDotColor setFill];
				dotImage = [_delegate pageControl:self selectedImageForDotAtIndex:i] ?: _selectedDotImage;
                dotShape = [_delegate pageControl:self selectedShapeForDotAtIndex:i] ?: _selectedDotShape ?: _dotShape;
				dotColor = [_delegate pageControl:self selectedColorForDotAtIndex:i] ?: _selectedDotColor ?: [UIColor blackColor];
                dotShadowBlur = _selectedDotShadowBlur;
                dotShadowColor = _selectedDotShadowColor;
                dotShadowOffset = _selectedDotShadowOffset;
                dotSize = _selectedDotSize > 0 ?: _dotSize;
                dotWidth = _selectedDotWidth > 0 ?: _dotWidth;
			}
			else
			{
				[_dotColor setFill];
                dotImage = [_delegate pageControl:self imageForDotAtIndex:i] ?: _dotImage;
                dotShape = [_delegate pageControl:self shapeForDotAtIndex:i] ?: _dotShape;
				dotColor = [_delegate pageControl:self colorForDotAtIndex:i] ?: _dotColor;
                if (!dotColor)
                {
                    //fall back to selected dot color with reduced alpha
                    dotColor = [_delegate pageControl:self selectedColorForDotAtIndex:i] ?: _selectedDotColor ?: [UIColor blackColor];
                    dotColor = [dotColor colorWithAlphaComponent:0.25];
                }
                dotShadowBlur = _dotShadowBlur;
                dotShadowColor = _dotShadowColor;
                dotShadowOffset = _dotShadowOffset;
                dotSize = _dotSize;
                dotWidth = _dotWidth;
			}
            
            CGContextSaveGState(context);
            CGFloat xoffset = (_dotWidth + _dotSpacing) * i + _dotSize / 2;
            
            CGContextTranslateCTM(context, _vertical? 0: xoffset, _vertical? offset: 0);
            
            if (dotShadowColor && ![dotShadowColor isEqual:[UIColor clearColor]])
            {
                CGContextSetShadowWithColor(context, dotShadowOffset, dotShadowBlur, dotShadowColor.CGColor);
            }
			if (dotImage)
			{
				[dotImage drawInRect:CGRectMake(-dotImage.size.width / 2, -dotImage.size.height / 2, dotImage.size.width, dotImage.size.height)];
			}
			else
			{
                [dotColor setFill];
                if (!dotShape || dotShape == FXPageControlDotShapeCircle)
                {
                    CGContextFillEllipseInRect(context, CGRectMake(-dotWidth / 2, -dotSize / 2, dotWidth, dotSize));
                }
                else if (dotShape == FXPageControlDotShapeSquare)
                {
                    CGContextFillRect(context, CGRectMake(-dotWidth / 2, -dotSize / 2, dotWidth, dotSize));
                }
                else if (dotShape == FXPageControlDotShapeTriangle)
                {
                    CGContextBeginPath(context);
                    CGContextMoveToPoint(context, 0, -dotSize / 2);
                    CGContextAddLineToPoint(context, dotSize / 2, dotSize / 2);
                    CGContextAddLineToPoint(context, -dotSize / 2, dotSize / 2);
                    CGContextAddLineToPoint(context, 0, -dotSize / 2);
                    CGContextFillPath(context);
                }
                else
                {
                    CGContextBeginPath(context);
                    CGContextAddPath(context, dotShape);
                    CGContextFillPath(context);
                }
			}
            
            offset += _dotWidth + _dotSpacing;

            CGContextRestoreGState(context);
            
		}
	}
}


- (CGFloat)_leftOffset
{
    CGRect rect = self.bounds;
    CGSize size = [self sizeForNumberOfPages:self.numberOfPages];
    CGFloat left = 0.0;
    
    if (_alignment == SFPageControlAlignmentRight) {
        
        left = CGRectGetMaxX(rect) - size.width;
    }
    else if (_alignment == SFPageControlAlignmentCenter){
        
        left = ceil(CGRectGetMidX(rect) - (size.width / 2.0));
    }
    
    return left;
}


- (NSInteger)clampedPageValue:(NSInteger)page
{
	if (_wrapEnabled)
    {
        return _numberOfPages? (page + _numberOfPages) % _numberOfPages: 0;
    }
    else
    {
        return MIN(MAX(0, page), _numberOfPages - 1);
    }
}

- (void)setDotImage:(UIImage *)dotImage
{
	if (_dotImage != dotImage)
	{
		_dotImage = dotImage;
		[self setNeedsDisplay];
	}
}

- (void)setDotShape:(CGPathRef)dotShape
{
	if (_dotShape != dotShape)
	{
        if (_dotShape > LAST_SHAPE) CGPathRelease(_dotShape);
        _dotShape = dotShape;
        if (_dotShape > LAST_SHAPE) CGPathRetain(_dotShape);
		[self setNeedsDisplay];
	}
}

- (void)setDotSize:(CGFloat)dotSize
{
    if (ABS(_dotSize - dotSize) > 0.001)
	{
		_dotSize = dotSize;
		[self setNeedsDisplay];
	}
}

- (void)setDotWidth:(CGFloat)dotWidth
{
    if (ABS(_dotWidth - dotWidth) > 0.001)
    {
        _dotWidth = dotWidth;
        [self setNeedsDisplay];
    }
}


- (void)setDotColor:(UIColor *)dotColor
{
	if (_dotColor != dotColor)
	{
		_dotColor = dotColor;
		[self setNeedsDisplay];
	}
}

- (void)setDotShadowColor:(UIColor *)dotColor
{
	if (_dotShadowColor != dotColor)
	{
		_dotShadowColor = dotColor;
		[self setNeedsDisplay];
	}
}

- (void)setDotShadowBlur:(CGFloat)dotShadowBlur
{
	if (ABS(_dotShadowBlur - dotShadowBlur) > 0.001)
	{
		_dotShadowBlur = dotShadowBlur;
		[self setNeedsDisplay];
	}
}

- (void)setDotShadowOffset:(CGSize)dotShadowOffset
{
	if (!CGSizeEqualToSize(_dotShadowOffset, dotShadowOffset))
	{
		_dotShadowOffset = dotShadowOffset;
		[self setNeedsDisplay];
	}
}

- (void)setSelectedDotImage:(UIImage *)dotImage
{
	if (_selectedDotImage != dotImage)
	{
		_selectedDotImage = dotImage;
		[self setNeedsDisplay];
	}
}

- (void)setSelectedDotColor:(UIColor *)dotColor
{
	if (_selectedDotColor != dotColor)
	{
		_selectedDotColor = dotColor;
		[self setNeedsDisplay];
	}
}

- (void)setSelectedDotShape:(CGPathRef)dotShape
{
	if (_selectedDotShape != dotShape)
	{
        if (_selectedDotShape > LAST_SHAPE) CGPathRelease(_selectedDotShape);
        _selectedDotShape = dotShape;
        if (_selectedDotShape > LAST_SHAPE) CGPathRetain(_selectedDotShape);
		[self setNeedsDisplay];
	}
}

- (void)setSelectedDotSize:(CGFloat)dotSize
{
    if (ABS(_selectedDotSize - dotSize) > 0.001)
	{
		_selectedDotSize = dotSize;
		[self setNeedsDisplay];
	}
}


- (void)setSelectedDotWidth:(CGFloat)dotWidth
{
    if (ABS(_selectedDotWidth - dotWidth) > 0.001)
    {
        _selectedDotWidth = dotWidth;
        [self setNeedsDisplay];
    }
}

- (void)setSelectedDotShadowColor:(UIColor *)dotColor
{
	if (_selectedDotShadowColor != dotColor)
	{
		_selectedDotShadowColor = dotColor;
		[self setNeedsDisplay];
	}
}

- (void)setSelectedDotShadowBlur:(CGFloat)dotShadowBlur
{
    if (ABS(_selectedDotShadowBlur - dotShadowBlur) > 0.001)
	{
		_selectedDotShadowBlur = dotShadowBlur;
		[self setNeedsDisplay];
	}
}

- (void)setSelectedDotShadowOffset:(CGSize)dotShadowOffset
{
	if (!CGSizeEqualToSize(_selectedDotShadowOffset, dotShadowOffset))
	{
		_selectedDotShadowOffset = dotShadowOffset;
		[self setNeedsDisplay];
	}
}

- (void)setDotSpacing:(CGFloat)dotSpacing
{
    if (ABS(_dotSpacing - dotSpacing) > 0.001)
	{
		_dotSpacing = dotSpacing;
		[self setNeedsDisplay];
	}
}

- (void)setDelegate:(id<FXPageControlDelegate>)delegate
{
	if (_delegate != delegate)
	{
		_delegate = delegate;
		[self setNeedsDisplay];
	}
}

- (void)setCurrentPage:(NSInteger)page
{
    _currentPage = [self clampedPageValue:page];
    [self setNeedsDisplay];
}

- (void)setNumberOfPages:(NSInteger)pages
{
	if (_numberOfPages != pages)
    {
        _numberOfPages = pages;
        if (_currentPage >= pages)
        {
            _currentPage = pages - 1;
        }
        [self setNeedsDisplay];
    }
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
	CGPoint point = [touch locationInView:self];
    BOOL forward = _vertical? (point.y > self.frame.size.height / 2): (point.x > self.frame.size.width / 2);
	_currentPage = [self clampedPageValue:_currentPage + (forward? 1: -1)];
    if (!_defersCurrentPageDisplay)
    {
        [self setNeedsDisplay];
    }
	[self sendActionsForControlEvents:UIControlEventValueChanged];
	[super endTrackingWithTouch:touch withEvent:event];
}

- (CGSize)sizeThatFits:(__unused CGSize)size
{
    CGSize dotSize = [self sizeForNumberOfPages:_numberOfPages];
    if (_selectedDotSize > 0)
    {
        CGFloat width = (_selectedDotSize - _dotSize);
        CGFloat height = MAX(36, MAX(_dotSize, _selectedDotSize));
        dotSize.width = _vertical? height: dotSize.width + width;
        dotSize.height = _vertical? dotSize.height + width: height;

    }
    if ((_dotShadowColor && ![_dotShadowColor isEqual:[UIColor clearColor]]) ||
        (_selectedDotShadowColor && ![_selectedDotShadowColor isEqual:[UIColor clearColor]]))
    {
        dotSize.width += MAX(_dotShadowOffset.width, _selectedDotShadowOffset.width) * 2;
        dotSize.height += MAX(_dotShadowOffset.height, _selectedDotShadowOffset.height) * 2;
        dotSize.width += MAX(_dotShadowBlur, _selectedDotShadowBlur) * 2;
        dotSize.height += MAX(_dotShadowBlur, _selectedDotShadowBlur) * 2;
    }
    return dotSize;
}

- (CGSize)intrinsicContentSize
{
    return [self sizeThatFits:self.bounds.size];
}

@end
