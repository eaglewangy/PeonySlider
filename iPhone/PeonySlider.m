//
//  Created by Charlie Mezak on 9/16/10.
//  Copyright 2010 Natural Guides, LLC. All rights reserved.
//

#import "PeonySlider.h"
#import <QuartzCore/QuartzCore.h>

#define SLIDER_HEIGHT 30
#define MIN_MAX_DISRANCE 45

@interface PeonySlider ()

- (void)calculateMinMax;
- (void)setupSliders;

@end

@implementation PeonySlider

@synthesize min, max, minimumRangeLength;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, SLIDER_HEIGHT)]))
    {
		self.clipsToBounds = NO;
		
        // default values
		min = 0.0;
		max = 1.0;
		minimumRangeLength = 0.0;
        popupViewPrefix = @"";
				
		backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, SLIDER_HEIGHT)];
		backgroundImageView.contentMode = UIViewContentModeScaleToFill;
		[self addSubview:backgroundImageView];
		
		trackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 0, frame.size.width - 10, SLIDER_HEIGHT)];
		trackImageView.contentMode = UIViewContentModeScaleToFill;
		
		inRangeTrackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(min*frame.size.width, 0, (max-min) * frame.size.width, SLIDER_HEIGHT)];
		inRangeTrackImageView.contentMode = UIViewContentModeScaleToFill;

		[self addSubview:trackImageView];
		[self addSubview:inRangeTrackImageView];
		
		[self setupSliders];
				
		[self updateTrackImageViews];
        
        [self constructSlider];
	}
    return self;
}

- (void)setupSliders
{
	minSlider = [[UIImageView alloc] initWithFrame:CGRectMake(min*self.frame.size.width, (SLIDER_HEIGHT - self.frame.size.height)/2.0, self.frame.size.height, self.frame.size.height)];
	minSlider.backgroundColor = [UIColor whiteColor];
	minSlider.contentMode = UIViewContentModeScaleToFill;
	
	maxSlider = [[UIImageView alloc] initWithFrame:CGRectMake(max*(self.frame.size.width - self.frame.size.height), (SLIDER_HEIGHT - self.frame.size.height)/2.0, self.frame.size.height, self.frame.size.height)];
	maxSlider.backgroundColor = [UIColor whiteColor];
	maxSlider.contentMode = UIViewContentModeScaleToFill;
	
	[self addSubview:minSlider];
	[self addSubview:maxSlider];
}

- (void)setMinThumbImage:(UIImage *)image
{
	minSlider.backgroundColor = [UIColor clearColor];
	minSlider.image = image;	
}

- (void)setMaxThumbImage:(UIImage *)image
{
	maxSlider.backgroundColor = [UIColor clearColor];
	maxSlider.image = image;	
}

- (void)setInRangeTrackImage:(UIImage *)image
{
	trackImageView.frame = CGRectMake(inRangeTrackImageView.frame.origin.x,trackImageView.frame.origin.y, inRangeTrackImageView.frame.size.width, trackImageView.frame.size.height);
	inRangeTrackImageView.image = [image stretchableImageWithLeftCapWidth:image.size.width/2.0-2 topCapHeight:image.size.height-2];
	
}

- (void)setTrackImage:(UIImage *)image
{
	trackImageView.frame = CGRectMake(5, MAX((self.frame.size.height-image.size.height)/2.0,0), self.frame.size.width-10, MIN(self.frame.size.height,image.size.height));
	trackImageView.image = image;
	inRangeTrackImageView.frame = CGRectMake(inRangeTrackImageView.frame.origin.x,trackImageView.frame.origin.y,inRangeTrackImageView.frame.size.width,trackImageView.frame.size.height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesBegan:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	
	if (CGRectContainsPoint(minSlider.frame, [touch locationInView:self]))
    { //if touch is beginning on min slider
		trackingSlider = minSlider;
        [self positionAndUpdatePopupView];
        [self fadePopupViewInAndOut:YES];
	}
    else if (CGRectContainsPoint(maxSlider.frame, [touch locationInView:self]))
    { //if touch is beginning on max slider
		trackingSlider = maxSlider;
        [self positionAndUpdatePopupView];
        [self fadePopupViewInAndOut:YES];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	[super touchesMoved:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	
	float deltaX = [touch locationInView:self].x - [touch previousLocationInView:self].x;
	
	if (trackingSlider == minSlider)
    {
		float newX = MAX(0, MIN(
                                minSlider.frame.origin.x + deltaX,
							    self.frame.size.width - self.frame.size.height * 2.0 - minimumRangeLength*(self.frame.size.width - self.frame.size.height * 2.0))
                        );
        
        //NSLog(@"%f, %f", newX, maxSlider.frame.origin.x);
        //use to limit minSlider not affect maxSlider
		if ((maxSlider.frame.origin.x - newX) < MIN_MAX_DISRANCE)
        {
            return;
        }
    
		minSlider.frame = CGRectMake(newX, minSlider.frame.origin.y, minSlider.frame.size.width, minSlider.frame.size.height);
		
		maxSlider.frame = CGRectMake(
									 MAX(
										 maxSlider.frame.origin.x,
										 minSlider.frame.origin.x + self.frame.size.height + minimumRangeLength * (self.frame.size.width - self.frame.size.height * 2.0)
										 ), 
									 maxSlider.frame.origin.y, 
									 self.frame.size.height, 
									 self.frame.size.height);
		
	}
    else if (trackingSlider == maxSlider)
    {
		float newX = MAX(
						 self.frame.size.height + minimumRangeLength * (self.frame.size.width - self.frame.size.height * 2.0),
						 MIN(maxSlider.frame.origin.x+deltaX, self.frame.size.width - self.frame.size.height)
                        );
		
        //NSLog(@"%f, %f", newX, maxSlider.frame.origin.x);
        //use to limit maxSlider not affect minSlider
		if ((newX - minSlider.frame.origin.x) < MIN_MAX_DISRANCE)
        {
            return;
        }
        
		maxSlider.frame = CGRectMake(newX, maxSlider.frame.origin.y, maxSlider.frame.size.width, maxSlider.frame.size.height);
		minSlider.frame = CGRectMake(
									 MIN(
										 minSlider.frame.origin.x,
										 maxSlider.frame.origin.x-self.frame.size.height-minimumRangeLength*(self.frame.size.width-2.0*self.frame.size.height)
										 ), 
									 minSlider.frame.origin.y, 
									 self.frame.size.height, 
									 self.frame.size.height);
	}
	
	[self calculateMinMax];
	[self updateTrackImageViews];
}

- (void)updateTrackImageViews
{
	inRangeTrackImageView.frame = CGRectMake(minSlider.frame.origin.x + 0.5 * self.frame.size.height,
											 inRangeTrackImageView.frame.origin.y,
											 maxSlider.frame.origin.x - minSlider.frame.origin.x,
											 inRangeTrackImageView.frame.size.height);
}

- (void)setMin:(CGFloat)newMin
{
	min = MIN(1.0, MAX(0, newMin)); //value must be between 0 and 1
	[self updateThumbViews];
	[self updateTrackImageViews];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)setMax:(CGFloat)newMax
{
	max = MIN(1.0, MAX(0, newMax)); //value must be between 0 and 1
	[self updateThumbViews];
	[self updateTrackImageViews];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)calculateMinMax
{
	float newMax = MIN(1, (maxSlider.frame.origin.x - self.frame.size.height)/(self.frame.size.width - (2 * self.frame.size.height)));
	float newMin = MAX(0, minSlider.frame.origin.x/(self.frame.size.width - 2.0 * self.frame.size.height));
	
	if (newMin != min || newMax != max)
    {
		min = newMin;
		max = newMax;
		[self sendActionsForControlEvents:UIControlEventValueChanged];
	}

}

- (void)setMinimumRangeLength:(CGFloat)length
{
	minimumRangeLength = MIN(1.0, MAX(length, 0.0)); //length must be between 0 and 1
	[self updateThumbViews];
	[self updateTrackImageViews];
}

- (void)updateThumbViews
{
	maxSlider.frame = CGRectMake(max*(self.frame.size.width - 2 * self.frame.size.height) + self.frame.size.height, 
								 (SLIDER_HEIGHT - self.frame.size.height)/2.0, 
								 self.frame.size.height, 
								 self.frame.size.height);
	
	minSlider.frame = CGRectMake(MIN(
									 min * (self.frame.size.width - 2 * self.frame.size.height),
									 maxSlider.frame.origin.x - self.frame.size.height - (minimumRangeLength * (self.frame.size.width - self.frame.size.height * 2.0))
									 ), 
								 (SLIDER_HEIGHT - self.frame.size.height)/2.0, 
								 self.frame.size.height, 
								 self.frame.size.height);
	
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
	[super touchesEnded:touches withEvent:event];
	[self sendActionsForControlEvents:UIControlEventTouchUpInside];
	trackingSlider = nil; //we are no longer tracking either slider
}

/*/
#pragma mark - UIControl touch event tracking
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    // Fade in and update the popup view
    CGPoint touchPoint = [touch locationInView:self];
    
    // Check if the knob is touched. If so, show the popup view
    if(CGRectContainsPoint(CGRectInset(self.thumbRect, -12.0, -12.0), touchPoint)) {
        [self positionAndUpdatePopupView];
        [self fadePopupViewInAndOut:YES];
    }
    
    return [super beginTrackingWithTouch:touch withEvent:event];
}
 */

-(BOOL)continueTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event
{
    // Update the popup view as slider knob is being moved
    [self positionAndUpdatePopupView];
    return [super continueTrackingWithTouch:touch withEvent:event];
}

-(void)cancelTrackingWithEvent:(UIEvent*)event {
    [super cancelTrackingWithEvent:event];
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent*)event
{
    // Fade out the popup view
    //[self fadePopupViewInAndOut:NO];
    [super endTrackingWithTouch:touch withEvent:event];
}


#pragma mark - Helper methods
-(void)constructSlider
{
    int popupViewWidth = 60;
    _minPopview = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, popupViewWidth, 30)];
    _minPopview.backgroundColor = [UIColor clearColor];
    _minPopview.alpha = 1.0;
    [self addSubview:_minPopview];
    
    _maxPopview = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, popupViewWidth, 30)];
    _maxPopview.backgroundColor = [UIColor clearColor];
    _maxPopview.alpha = 1.0;
    [self addSubview:_maxPopview];
    
    [self positionAndUpdatePopupView:TRUE];
}

-(void)fadePopupViewInAndOut:(BOOL)aFadeIn
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    if (aFadeIn)
    {
        _minPopview.alpha = 1.0;
        _maxPopview.alpha = 1.0;
    }
    else
    {
        _minPopview.alpha = 0.0;
        _maxPopview.alpha = 0.0;
    }
    [UIView commitAnimations];
}

-(void)positionAndUpdatePopupView:(BOOL)updateBoth
{
    if (updateBoth)
    {
        [self updateLeftPopupViewPosition];
        [self updateRightPopupViewPosition];
    }
    else
    {
        [self positionAndUpdatePopupView];
    }
}

-(void)positionAndUpdatePopupView
{
    if (trackingSlider == minSlider)
    {
        [self updateLeftPopupViewPosition];
    }
    else if (trackingSlider == maxSlider)
    {
        [self updateRightPopupViewPosition];
    }
}

-(void)updateLeftPopupViewPosition
{
    CGRect minRect = minSlider.frame;
    CGRect minPopupRect = CGRectOffset(minRect, 0, -floor(minRect.size.height));
    _minPopview.frame = CGRectInset(minPopupRect, -10, -10);
    NSString *number = [[NSNumber numberWithInt:(int)(min * scale)] stringValue];
    NSString *value = [popupViewPrefix stringByAppendingString:number];
    _minPopview.text = value;
}

-(void)updateRightPopupViewPosition
{
    CGRect maxRect = maxSlider.frame;
    CGRect maxPopupRect = CGRectOffset(maxRect, 0, -floor(maxRect.size.height));
    _maxPopview.frame = CGRectInset(maxPopupRect, -10, -10);
    NSString *number = [[NSNumber numberWithFloat:(int)(max * scale)] stringValue];
    NSString *value = [popupViewPrefix stringByAppendingString:number];
    _maxPopview.text = value;
}

-(void)setScaleFactor:(int)scaleFactor
{
    scale = scaleFactor;
    [self positionAndUpdatePopupView:TRUE];
}

- (void)setPopupViewPrefix:(NSString*)prefix
{
    popupViewPrefix = prefix;
    [self positionAndUpdatePopupView:TRUE];
}

@end
