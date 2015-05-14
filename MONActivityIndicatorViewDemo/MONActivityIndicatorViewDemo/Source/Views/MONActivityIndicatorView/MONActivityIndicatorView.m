//
//  MONActivityIndicatorView.m
//
//  Created by Mounir Ybanez on 4/24/14.
//

#import <QuartzCore/QuartzCore.h>
#import "MONActivityIndicatorView.h"



@interface MONActivityIndicatorView ()



/** An indicator whether the activity indicator view is animating. */
@property (nonatomic) BOOL isAnimating;

@property (nonatomic, copy) void (^gracefulAnimationCompletionBlock)(void);

@property (nonatomic, assign) BOOL stopRequested;

@end



@implementation MONActivityIndicatorView



@synthesize numberOfCircles = _numberOfCircles;
@synthesize internalSpacing = _internalSpacing;
@synthesize radius = _radius;
@synthesize delay = _delay;
@synthesize duration = _duration;



#pragma mark - Intrinsic Content Size

- (CGSize)intrinsicContentSize {
    CGFloat width = (self.numberOfCircles * ((2 * self.radius) + self.internalSpacing)) - self.internalSpacing;
    CGFloat height = self.radius * 2;
    return CGSizeMake(width, height);
}



#pragma mark - Private Methods



- (void)refresh
{
    if (self.isAnimating)
    {
        [self removeCircles];
        [self addCircles];
    }
    [self invalidateIntrinsicContentSize];
}



/**
 Creates the circle view.
 @param radius The radius of the circle.
 @param color The background color of the circle.
 @param positionX The x-position of the circle in the contentView.
 @return The circle view.
 */
- (UIView *)createCircleWithRadius:(CGFloat)radius color:(UIColor *)color positionX:(CGFloat)x
{
    UIView *circle = [[UIView alloc] initWithFrame:CGRectMake(x, 0, radius * 2, radius * 2)];
    circle.backgroundColor = color;
    circle.layer.cornerRadius = radius;
    circle.translatesAutoresizingMaskIntoConstraints = NO;
    return circle;
}

/**
 Creates the animation of the circle.
 @param duration The duration of the animation.
 @param delay The delay of the animation
 @return The animation of the circle.
 */

- (CABasicAnimation *)createAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay reverse:(BOOL)reverse {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.delegate = self;
    if (! reverse) {
        anim.fromValue = [NSNumber numberWithFloat:0.0f];
        anim.toValue = [NSNumber numberWithFloat:1.0f];
    } else {
        anim.fromValue = [NSNumber numberWithFloat:1.0f];
        anim.toValue = [NSNumber numberWithFloat:0.0f];
    }
    anim.autoreverses = NO;
    anim.duration = duration;
    // can't use this one as YES or it will flicker
    anim.removedOnCompletion = NO;
    // also need this to not flicker on animation switching
    anim.fillMode = kCAFillModeForwards;
    anim.beginTime = CACurrentMediaTime()+delay;
    anim.repeatCount = 0;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return anim;
}

/// starts the reverse animation to the one that has just stopped
- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
{
    CALayer *layer = [anim valueForKey:@"circleLayer"];
    
    BOOL wasDecreasingInSize = [anim.toValue isEqualToNumber:@0];
    
    // if we were asked to stop animating and we have zoomed out, then remove the circle view
    if (self.stopRequested && wasDecreasingInSize) {
        UIView *circle = layer.delegate;
        [circle removeFromSuperview];
        // if we have removed all the circles - hide self
        if ([self.subviews count] == 0) {
            self.isAnimating = NO;
            self.hidden = YES;
            if (self.gracefulAnimationCompletionBlock) {
                self.gracefulAnimationCompletionBlock();
                self.gracefulAnimationCompletionBlock = nil;
            }
        }
    } else {
        CABasicAnimation *newAnimation = [self createAnimationWithDuration:self.duration delay:0 reverse:!wasDecreasingInSize];
        [newAnimation setValue:layer forKey:@"circleLayer"];
        [layer removeAllAnimations];
        [layer addAnimation:newAnimation forKey:@"scale"];
    }
}

- (void)addCircles {
    for (NSUInteger i = 0; i < self.numberOfCircles; i++) {
        UIColor *color = self.tintColor;
        if (self.delegate && [self.delegate respondsToSelector:@selector(activityIndicatorView:dotColorAtIndex:)]) {
            color = [self.delegate activityIndicatorView:self dotColorAtIndex:i];
        }
        UIView *circle = [self createCircleWithRadius:self.radius color:color positionX:(i * ((2 * self.radius) + self.internalSpacing))];
        [circle setTransform:CGAffineTransformMakeScale(0, 0)];
        CABasicAnimation *animation = [self createAnimationWithDuration:self.duration delay:(i * self.delay) reverse:NO];
        // save the layer into animation so that we could easily create a new animation for it
        [animation setValue:circle.layer forKey:@"circleLayer"];
        [circle.layer addAnimation:animation forKey:@"scale"];
        [self addSubview:circle];
    }
}

- (void)removeCircles {
    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [obj removeFromSuperview];
    }];
}



#pragma mark - Public Methods

- (void)startAnimating {
    if (self.stopRequested) {
        // remove circles in case if previous animation was still gracefully stopping
        [self removeCircles];
        self.isAnimating = NO;
    }
    
    if (!self.isAnimating) {
        
        // create the new animation
        [self addCircles];
        self.hidden = NO;
        self.isAnimating = YES;
        self.stopRequested = NO;
    }
}

- (void)stopAnimating
{
    [self stopAnimating:NO];
}

- (void)stopAnimatingGracefullyWithCompletion:(void(^)(void))completion
{
    if (self.isAnimating) {
        [self stopAnimating:YES];
        self.gracefulAnimationCompletionBlock = completion;
    }
}


/// method used only internally
- (void)stopAnimating:(BOOL)gracefully
{
    if (self.isAnimating) {
        if (! gracefully) {
            [self removeCircles];
            self.hidden = YES;
            self.isAnimating = NO;
        }
        self.stopRequested = YES;
    }
    
}

#pragma mark - *** Custom Setters and Getters ***

#pragma mark - Number of Circles

- (NSUInteger)numberOfCircles
{
    if (!_numberOfCircles) return 5;
    return _numberOfCircles;
}



- (void)setNumberOfCircles:(NSUInteger)numberOfCircles {
    _numberOfCircles = numberOfCircles;
    [self refresh];
}



#pragma mark - Radius

- (CGFloat)radius
{
    if (!_radius) return 10.f;
    return _radius;
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    [self refresh];
}



#pragma mark - Delay

- (CGFloat)delay
{
    if (!_delay) return 0.2f;
    return _delay;
}



- (void)setDelay:(CGFloat)delay
{
    _delay = delay;
    [self refresh];
}



#pragma mark - Duration

- (CGFloat)duration
{
    if (!_duration) return 0.8f;
    return _duration;
}



- (void)setDuration:(CGFloat)duration
{
    _duration = duration;
    [self refresh];
}


#pragma mark - Internal Spacing

- (CGFloat)internalSpacing
{
    if (!_internalSpacing) return 5;
    return _internalSpacing;
}

- (void)setInternalSpacing:(CGFloat)internalSpacing {
    _internalSpacing = internalSpacing;
    [self refresh];
}



#pragma mark - Tint Color

- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];
    [self refresh];
}



@end
