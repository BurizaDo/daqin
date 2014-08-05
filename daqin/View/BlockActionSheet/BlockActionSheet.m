//
//  BlockActionSheet.m
//
//

#import "BlockActionSheet.h"
#import "BlockBackground.h"

#define kActionSheetBorder              10
#define kActionSheetTopMargin           15
#define kActionSheetButtonHeight        44

#define kActionSheetTitleFont           [UIFont systemFontOfSize:14]
#define kActionSheetTitleTextColor      [UIColor blackColor]
#define kActionSheetButtonFontNormal    [UIFont systemFontOfSize:20]
#define kActionSheetButtonFontBold      [UIFont boldSystemFontOfSize:20]
#define kActionSheetButtonTextColor     [UIColor blackColor]

#ifndef IOS_LESS_THAN_6
#define IOS_LESS_THAN_6 !([[[UIDevice currentDevice] systemVersion] compare:@"6.0" options:NSNumericSearch] != NSOrderedAscending)
#endif

typedef NS_ENUM(NSUInteger, BlockActionSheetButtonType)
{
    BlockActionSheetButtonTypeNormal = 0,
    BlockActionSheetButtonTypeCancel = 1,
    BlockActionSheetButtonTypeDestructive = 2
};

@interface BlockActionSheet ()
{
    NSMutableArray *_blocks;
    CGFloat _height;
    BlockActionSheet* _strongSelf;
    
    UIView *_firstSection;
    UIView *_secendSection;
    
    BOOL _whetherHasTitle;
}

@end

@implementation BlockActionSheet

#pragma mark - init

+ (id)sheetWithTitle:(NSString *)title
{
    return [[BlockActionSheet alloc] initWithTitle:title];
}

- (instancetype)init
{
    return [self initWithTitle:nil];
}

- (id)initWithTitle:(NSString *)title 
{
    if ((self = [super init]))
    {
        CGRect frame = [BlockBackground sharedInstance].bounds;
        
        _view = [[UIView alloc] initWithFrame:frame];
        _view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        _view.backgroundColor = [UIColor clearColor];
        _firstSection = [[UIView alloc] initWithFrame:CGRectZero];
        _firstSection.backgroundColor = [UIColor whiteColor];
        _firstSection.layer.cornerRadius = 4.0f;
        _secendSection = [[UIView alloc] initWithFrame:CGRectZero];
        _secendSection.backgroundColor = [UIColor whiteColor];
        _secendSection.layer.cornerRadius = 4.0f;
        [_view addSubview:_firstSection];
        [_view addSubview:_secendSection];
        
        _blocks = [[NSMutableArray alloc] init];
        _height = kActionSheetTopMargin;

        if (title)
        {
            CGSize size = [title sizeWithFont:kActionSheetTitleFont
                            constrainedToSize:CGSizeMake(frame.size.width-kActionSheetBorder*2, 1000)
                                lineBreakMode:NSLineBreakByWordWrapping];
            
            UILabel *labelView = [[UILabel alloc] initWithFrame:CGRectMake(kActionSheetBorder, _height, frame.size.width-kActionSheetBorder*4, rint(size.height))];
            labelView.font = kActionSheetTitleFont;
            labelView.numberOfLines = 0;
            labelView.lineBreakMode = NSLineBreakByWordWrapping;
            labelView.textColor = kActionSheetTitleTextColor;
            labelView.backgroundColor = [UIColor clearColor];
            labelView.textAlignment = NSTextAlignmentCenter;
            labelView.text = title;
            
            labelView.autoresizingMask = UIViewAutoresizingNone;

            [_firstSection addSubview:labelView];
            
            _height += rint(size.height) + kActionSheetBorder;
            
            _whetherHasTitle = YES;
        } else {
            _height = 0;
        }
    }
    
    return self;
}

- (NSUInteger)buttonCount
{
    return _blocks.count;
}

- (void)addButtonWithTitle:(NSString *)title type:(BlockActionSheetButtonType) type block:(void (^)())block atIndex:(NSInteger)index
{
    id idBlock =  block ? [block copy] : [NSNull null];
    
    if (index >= 0) {
        [_blocks insertObject:@[idBlock, @(type), title] atIndex:index];
        return;
    }
    [_blocks addObject:@[idBlock, @(type), title]];

}

- (void)setDestructiveButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title type: BlockActionSheetButtonTypeDestructive block:block atIndex:-1];
}

- (void)setCancelButtonWithTitle:(NSString *)title block:(void (^)())block
{
    [self addButtonWithTitle:title type:BlockActionSheetButtonTypeCancel block:block atIndex:-1];
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block 
{
    [self addButtonWithTitle:title type: BlockActionSheetButtonTypeNormal block:block atIndex:-1];
}

- (void)setDestructiveButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title type: BlockActionSheetButtonTypeDestructive  block:block atIndex:index];
}

- (void)setCancelButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block
{
    [self addButtonWithTitle:title type:BlockActionSheetButtonTypeCancel block:block atIndex:index];
}

- (void)addButtonWithTitle:(NSString *)title atIndex:(NSInteger)index block:(void (^)())block 
{
    [self addButtonWithTitle:title  type: BlockActionSheetButtonTypeNormal block:block atIndex:index];
}

#define kUnRemovableView            98765
#define kLineWidth                  0.5

- (UIView *)lineViewWithColor:(UIColor *)color
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingNone;
    view.backgroundColor = color;
    return view;
}

- (void)addLineToView:(UIView *)view
                  top:(BOOL)top
               bottom:(BOOL)bottom
                 left:(BOOL)left
                right:(BOOL)right
            withColor:(UIColor *)color
{
    CGRect frame = view.bounds;
    frame.size.height = kLineWidth;
    
    if (top) {
        UIView *headerLine = [self lineViewWithColor:color];
        headerLine.tag = kUnRemovableView;
        headerLine.frame = frame;
        [view addSubview:headerLine];
    }
    
    if (bottom) {
        UIView *lastLine = [self lineViewWithColor:color];
        lastLine.tag = kUnRemovableView;
        frame.origin.y = CGRectGetHeight(view.bounds) - kLineWidth;
        lastLine.frame = frame;
        [view addSubview:lastLine];
        lastLine.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin;
    }
    
    frame.origin.y = 0;
    frame.size.width = kLineWidth;
    frame.size.height = CGRectGetHeight(view.bounds);
    if (left) {
        UIView *leftLine = [self lineViewWithColor:color];
        leftLine.tag = kUnRemovableView;
        leftLine.frame = frame;
        [view addSubview:leftLine];
        leftLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    if (right) {
        UIView *leftLine = [self lineViewWithColor:color];
        leftLine.tag = kUnRemovableView;
        frame.origin.x = CGRectGetWidth(view.bounds) - kLineWidth;
        leftLine.frame = frame;
        [view addSubview:leftLine];
        leftLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
}


- (void)showInView:(UIView *)view
{
    for (int i = 0; i < [_blocks count] - 1; i++)
    {
        NSArray *block = _blocks[i];
        UIButton *button = [self makeButton:block withTag: i+1];
        button.frame = CGRectMake(0, _height, _view.bounds.size.width-kActionSheetBorder*2, kActionSheetButtonHeight);
        
        if (i == 0 && _whetherHasTitle) {
            [self addLineToView:button top:YES bottom:YES left:NO right:NO withColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
        } else{
             [self addLineToView:button top:NO bottom:YES left:NO right:NO withColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
        }

        [_firstSection addSubview:button];
        
        _height += kActionSheetButtonHeight;
    }
    
    CGRect frame = _view.frame;
    frame.origin.x = 0;
    frame.origin.y = 0;
    frame.size.width = [BlockBackground sharedInstance].bounds.size.width - 20;
    frame.size.height = _height;
    _firstSection.frame = frame;
    
    frame.origin.y = CGRectGetMaxY(frame) + kActionSheetBorder;
    frame.size.height = kActionSheetButtonHeight;
    _secendSection.frame = frame;
    UIButton *lastButton = [self makeButton:[_blocks lastObject] withTag:[_blocks count]];
    lastButton.frame = _secendSection.bounds;
    [_secendSection addSubview:lastButton];
    
    frame.origin.x = 10;
    frame.origin.y = CGRectGetHeight(_view.frame);
    frame.size.height = CGRectGetMaxY(_secendSection.frame);
    _view.frame = frame;
    
    [[BlockBackground sharedInstance] addToMainWindow:_view];
    
    __block CGPoint center = _view.center;
    center.y -= CGRectGetHeight(_view.frame) + kActionSheetBorder;
    
    [UIView animateWithDuration: 0.25
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations: ^{
                         [BlockBackground sharedInstance].backgroundView.alpha = 1.0f;
                         _view.center = center;
                     } completion: nil];
    
    _strongSelf = self;
}

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated 
{
    id obj = nil;
    if (buttonIndex >= 0 && buttonIndex < [_blocks count])
    {
        obj = [[_blocks objectAtIndex: buttonIndex] objectAtIndex:0];
    }
    
    if (animated)
    {
        __block CGPoint center = _view.center;
        [UIView animateWithDuration: 0.25
                              delay: 0.0
                            options: UIViewAnimationOptionCurveEaseOut
                         animations: ^{
                             center.y += _view.bounds.size.height;
                             _view.center = center;
                             [BlockBackground sharedInstance].backgroundView.alpha = 0.0f;
                         } completion: ^(BOOL finished) {
                             [[BlockBackground sharedInstance] removeView:_view];
                             _view = nil;
                             _strongSelf = nil;
                             if (![obj isEqual:[NSNull null]])
                             {
                                 ((void (^)())obj)();
                             }
                         }];
    }
    else
    {
        [[BlockBackground sharedInstance] removeView:_view];
        _view = nil;
        _strongSelf = nil;
        if (![obj isEqual:[NSNull null]])
        {
            ((void (^)())obj)();
        }
    }
}

#pragma mark - Action

- (void)buttonClicked:(id)sender 
{
    /* Run the button's block */
    int buttonIndex = [(UIButton *)sender tag] - 1;
    [self dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - private

- (UIButton *)makeButton:(NSArray *)block withTag:(NSUInteger)tag
{
    NSString *title = block[2];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = kActionSheetButtonFontNormal;
    if (IOS_LESS_THAN_6) {
#pragma clan diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        button.titleLabel.minimumFontSize = 10;
#pragma clan diagnostic pop
    }
    else {
        button.titleLabel.minimumScaleFactor = 0.1;
    }
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.backgroundColor = [UIColor clearColor];
    button.accessibilityLabel = title;
    button.tag = tag;
    button.autoresizingMask = UIViewAutoresizingNone;
    [button setTitleColor:kActionSheetButtonTextColor forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    BlockActionSheetButtonType type = [block[1] unsignedIntegerValue];
    
    switch (type) {
        case BlockActionSheetButtonTypeCancel: case BlockActionSheetButtonTypeNormal:
            if (type == BlockActionSheetButtonTypeCancel) {
                button.titleLabel.font = kActionSheetButtonFontBold;
            }
            
            [button setTitleColor:[UIColor colorWithRed:0.0f green:0x7A/255.0 blue:0xFF/255.0 alpha:1.0] forState:UIControlStateNormal];
            break;
            
        default://BlockActionSheetButtonTypeDestructive
            [button setTitleColor:[UIColor colorWithRed:0xFD/255.0 green:0x47/255.0 blue:0x2B/255.0 alpha:1.0] forState:UIControlStateNormal];
            break;
    }
    
    return button;
}

@end
