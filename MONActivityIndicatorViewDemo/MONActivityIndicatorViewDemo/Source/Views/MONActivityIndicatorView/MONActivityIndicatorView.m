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
    // if stop has been requested we must not recreate circles, gotta allow the animations to stop
    if (self.isAnimating && !self.stopRequested) {
        [self removeCircles];
        [self addCircles];
        [self invalidateIntrinsicContentSize];
    }
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

- (CABasicAnimation *)createAnimationWithDuration:(CGFloat)duration delay:(CGFloat)delay {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    anim.fromValue = [NSNumber numberWithFloat:0.0f];
    anim.toValue = [NSNumber numberWithFloat:1.0f];
    anim.autoreverses = YES;
    anim.duration = duration;
    anim.removedOnCompletion = NO;
    anim.beginTime = CACurrentMediaTime()+delay;
    anim.repeatCount = INFINITY;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return anim;
}

- (void)addCircles {
    for (NSUInteger i = 0; i < self.numberOfCircles; i++) {
        UIColor *color = self.tintColor;
        if (self.delegate && [self.delegate respondsToSelector:@selector(activityIndicatorView:dotColorAtIndex:)]) {
            color = [self.delegate activityIndicatorView:self dotColorAtIndex:i];
        }
        UIView *circle = [self createCircleWithRadius:self.radius color:color positionX:(i * ((2 * self.radius) + self.internalSpacing))];
        [circle setTransform:CGAffineTransformMakeScale(0, 0)];
        CABasicAnimation *animation = [self createAnimationWithDuration:self.duration delay:(i * self.delay)];
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
        self.stopRequested = YES;
        if (! gracefully) {
            [self removeCircles];
            self.hidden = YES;
            self.isAnimating = NO;
        } else {
            [self addGracefulEndingAnimations];
        }
    }
    
}

- (void)addGracefulEndingAnimations
{
    for (UIView *circle in self.subviews) {
        CALayer *layer = circle.layer;
        CALayer *presentationLayer = layer.presentationLayer;
        NSValue *scaleValue = [presentationLayer valueForKeyPath:@"transform.scale"];
        
        CABasicAnimation *endingAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        endingAnimation.fromValue = scaleValue;
        endingAnimation.toValue = @0;
        endingAnimation.delegate = self;
        
        endingAnimation.duration = self.duration;
        endingAnimation.removedOnCompletion = NO;
        endingAnimation.beginTime = CACurrentMediaTime();
        endingAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [endingAnimation setValue:circle forKey:@"circleView"];
        [circle.layer addAnimation:endingAnimation forKey:@"scale"];
    }
}

- (void)animationDidStop:(CABasicAnimation *)anim finished:(BOOL)flag
{
    UIView *circle = [anim valueForKey:@"circleView"];
    
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
