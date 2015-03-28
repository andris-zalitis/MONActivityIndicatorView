# MONActivityIndicatorView

MONActivityIndicatorView is an awesome custom activity indicator view for iOS.

![MONActivityIndicatorView] (https://raw.github.com/mownier/MONActivityIndicatorView/master/MONActivityIndicatorView-Screenshot.gif)

## Installation

### Manual Install
* Copy and add the files `MONActivityIndicatorView.h` and `MONActivityIndicatorView.m` to your project.
* Add the **QuartzCore** framework to your project.
* Then do, `import MONActivityIndicatorView.h`

### From CocoaPods
* Add `pod 'MONActivityIndicatorView'` to your Podfile.
* Then `pod install` in the terminal.

## Usage

### Initialization
``` objective-c
- (void)viewDidLoad {
  [super viewDidLoad];

  MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
  [self.view addSubview:indicatorView];
}
```

### Toggling Indicator
``` objective-c
[indicatorView startAnimating];
[indicatorView stopAnimating];
```


## Customization



### Custom Properties
MONActivityIndicator is totally customizable:

``` objective-c
- (void)viewDidLoad {
  [super viewDidLoad];
  
  MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
  indicatorView.numberOfCircles = 3;
  indicatorView.radius = 20;
  indicatorView.internalSpacing = 3;
  indicatorView.duration = 0.5;
  indicatorView.delay = 0.5
  ...
  [indicatorView startAnimating];
}
```

### Custom Dot Color
There are several ways to set the color of the dots in this component.

**Option 1**

MONActivityIndicatorView conforms to UIAppearance, so you can do this:

``` objective-c
[[MONActivityIndicatorView appearance] setTintColor:[UIColor redColor]];
```

or this:

``` objective-c
MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
indicatorView.tintColor = [UIColor redColor];
```


**Option 2**

MONActivityIndicatorView supports IBInspectable, so you can set the tintColor in Interface Builder/Storyboard.


**Option 3**

MONActivityIndicatorViewDelegate provides the method `activityIndicatorView:dotColorAtIndex:`, which you can implement in your delegate.

``` objective-c
@interface ViewController : UIViewController <MONActivityIndicatorViewDelegate>
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  MONActivityIndicatorView *indicatorView = [[MONActivityIndicatorView alloc] init];
  indicatorView.delegate = self;
  ...
  [indicatorView startAnimating];
}

- (UIColor *)activityIndicatorView:(MONActivityIndicatorView *)activityIndicatorView dotColorAtIndex:(NSUInteger)index {
  return [UIColor redColor];
}

@end
```



