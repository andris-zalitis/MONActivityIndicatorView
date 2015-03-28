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
    anim.delegate = self;
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
        if (self.delegate && [self.delegate respondsToSelector:@selector(activityIndicatorView:circleBackgroundColorAtIndex:)]) {
            color = [self.delegate activityIndicatorView:self circleBackgroundColorAtIndex:i];
        }
        UIView *circle = [self createCircleWithRadius:self.radius
                                                color:color
                                            positionX:(i * ((2 * self.radius) + self.internalSpacing))];
        [circle setTransform:CGAffineTransformMakeScale(0, 0)];
        [circle.layer addAnimation:[self createAnimationWithDuration:self.duration delay:(i * self.delay)] forKey:@"scale"];
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
    if (!self.isAnimating) {
        [self addCircles];
        self.hidden = NO;
        self.isAnimating = YES;
    }
}

- (void)stopAnimating {
    if (self.isAnimating) {
        [self removeCircles];
        self.hidden = YES;
        self.isAnimating = NO;
    }
}



#pragma mark - Custom Setters and Getters

- (NSUInteger)numberOfCircles
{
    if (!_numberOfCircles) return 5;
    return _numberOfCircles;
}

- (void)setNumberOfCircles:(NSUInteger)numberOfCircles {
    _numberOfCircles = numberOfCircles;
    [self invalidateIntrinsicContentSize];
}



- (CGFloat)radius
{
    if (!_radius) return 10.f;
    return _radius;
}

- (void)setRadius:(CGFloat)radius {
    _radius = radius;
    [self invalidateIntrinsicContentSize];
}



- (CGFloat)delay
{
    if (!_delay) return 0.2f;
    return _delay;
}



- (CGFloat)duration
{
    if (!_duration) return 0.8f;
    return _duration;
}


- (CGFloat)internalSpacing
{
    if (!_internalSpacing) return 5;
    return _internalSpacing;
}

- (void)setInternalSpacing:(CGFloat)internalSpacing {
    _internalSpacing = internalSpacing;
    [self invalidateIntrinsicContentSize];
}



- (void)setTintColor:(UIColor *)tintColor
{
    [super setTintColor:tintColor];

    if (self.isAnimating)
    {
        [self removeCircles];
        [self addCircles];
    }
}

@end
