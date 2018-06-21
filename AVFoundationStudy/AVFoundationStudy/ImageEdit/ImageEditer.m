//
//  ImageEditer.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/19.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "ImageEditer.h"

NSString * const kScrawl = @"scrawl"; // 涂鸦
NSString * const kEmoji = @"emoji"; // 表情
NSString * const kText = @"text";   // 文本
NSString * const kMosaic = @"mosaic"; // 马赛克
NSString * const kCrop = @"crop"; // 裁剪


////////////////////////////////////////////////////////////////////
#pragma mark - IEToolbarItem

@interface IEToolbarItem : NSObject

@property (nonatomic, copy, readonly) NSString *identifier;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, copy) NSString *title;

+ (instancetype)itemWithIdentifier:(NSString *)identifier;
- (instancetype)initWithIdentifier:(NSString *)identifier;

@end

@implementation IEToolbarItem

+ (instancetype)itemWithIdentifier:(NSString *)identifier {
    return [[self alloc] initWithIdentifier:identifier];
}

- (instancetype)initWithIdentifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        _identifier = [identifier copy];
    }
    return self;
}

@end

////////////////////////////////////////////////////////////////////
#pragma mark - IEHeaderToolbar

@interface IEHeaderToolbar : UIView

@property (nonatomic, copy) void(^cancelBlock)(void);
@property (nonatomic, copy) void(^doneBlock)(void);

@end


@implementation IEHeaderToolbar {
    UIButton *_cancelBtn;
    UIButton *_doneBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _cancelBtn = [UIButton new];
        _cancelBtn.backgroundColor = [UIColor clearColor];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancelBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelBtn];
        [_cancelBtn sizeToFit];
        
        
        _doneBtn = [UIButton new];
        _doneBtn.backgroundColor = [UIColor clearColor];
        [_doneBtn setTitle:@"确定" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(doneBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_doneBtn];
        [_doneBtn sizeToFit];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat centerX = _cancelBtn.bounds.size.width / 2.0 + 10;
    _cancelBtn.center = CGPointMake(centerX, self.bounds.size.height/2.0);
    centerX = self.bounds.size.width - _doneBtn.bounds.size.width/2.0 - 10;
    _doneBtn.center = CGPointMake(centerX, self.bounds.size.height/2.0);
}

#pragma mark button action

- (void)cancelBtnAction:(UIButton *)button {
    !_cancelBlock ?: _cancelBlock();
}

- (void)doneBtnAction:(UIButton *)button {
    !_doneBlock ?: _doneBlock();
}

@end

////////////////////////////////////////////////////////////////////
#pragma mark - IEFooterToolbar

@interface IEFooterToolbar : UIView

@property (nonatomic, strong) NSArray<IEToolbarItem *> *items;

@property (nonatomic, copy) void(^didSelectItemBlock)(IEToolbarItem *item);

@end

@implementation IEFooterToolbar {
    NSMutableArray<UIView *> *_itemViews;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _itemViews = [NSMutableArray new];
    }
    return self;
}

- (void)setItems:(NSArray<IEToolbarItem *> *)items {
    _items = [items copy];
    [_itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_itemViews removeAllObjects];
    __block CGFloat lastBtnRight = 0;
    [_items enumerateObjectsUsingBlock:^(IEToolbarItem * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [UIButton new];
        btn.tag = 0xff + idx;
        [self addSubview:btn];
        [btn addTarget:self action:@selector(buttonHandle:) forControlEvents:UIControlEventTouchUpInside];
        if (item.image) {
            [btn setImage:item.image forState:UIControlStateNormal];
            [btn setImage:item.selectedImage forState:UIControlStateSelected];
            btn.bounds = CGRectMake(0, 0, 30, 30);
        } else {
            [btn setTitle:item.title forState:UIControlStateNormal];
            [btn sizeToFit];
        }
        CGFloat centerX = lastBtnRight + 20 + btn.bounds.size.width/2.0;
        btn.center = CGPointMake(centerX, self.bounds.size.height/2.0);
        lastBtnRight = CGRectGetMaxX(btn.frame);
    }];
}

- (void)buttonHandle:(UIButton *)button {
    if (button.tag-0xff < _items.count) {
        !_didSelectItemBlock ?: _didSelectItemBlock(_items[button.tag-0xff]);
    }
}

@end


////////////////////////////////////////////////////////////////////
#pragma mark - ImageEditer

#import "IEScrawlView.h"
#import "IEMosaicView.h"
#import "IEMosaicTool.h"
#import "IEMosaicToolbar.h"
#import "IETextToolView.h"
#import "IETextElementView.h"

@interface ImageEditer()<UIScrollViewDelegate, IEElementViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) IEHeaderToolbar *headerToolbar;
@property (nonatomic, strong) IEFooterToolbar *footerToolbar;

// 涂鸦
@property (nonatomic, strong) IEScrawlView *scrawlView;
@property (nonatomic, strong) IEScrawlMaskView *scrawlMaskView;

// 马赛克
@property (nonatomic, strong) IEMosaicView *mosaicView;
@property (nonatomic, strong) IEMosaicToolbar *mosaicToolbar;

// 文本
@property (nonatomic, strong) IETextToolView *textToolView;
// 文本数组
@property (nonatomic, strong) NSMutableArray<IETextElementView *> *textElementArr;

@end

@implementation ImageEditer


+ (instancetype)imageEditerWithImage:(UIImage *)image {
    return [[self alloc] initWithImage:image];
}

- (instancetype)initWithImage:(UIImage *)image {
    NSAssert(image, @"image is nil");
    self = [self initWithFrame:[UIScreen mainScreen].bounds];
    self.backgroundColor = [UIColor blackColor];
    if (self) {
        _image = image;

        CGSize size = image.size;
        size.width = [UIScreen mainScreen].bounds.size.width;
        size.height = image.size.height * (size.width / image.size.width);
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:_scrollView];
        _scrollView.delegate = self;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.minimumZoomScale = 0.5;
        _scrollView.maximumZoomScale = 3;
        CGSize contentSize = _scrollView.bounds.size;
        if (size.height > self.bounds.size.height) {
            contentSize.height = size.height;
        }
        _scrollView.contentSize = contentSize;
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        _imageView.center = CGPointMake(contentSize.width/2.0, contentSize.height/2.0);
        _imageView.image = image;
        [_scrollView addSubview:_imageView];
        _imageView.userInteractionEnabled = YES;
        
        _headerToolbar = [[IEHeaderToolbar alloc] initWithFrame:CGRectMake(0, 20, self.bounds.size.width, 40.0)];
        [self addSubview:_headerToolbar];
        __weak typeof(self) weakSelf = self;
        _headerToolbar.cancelBlock = ^{
            [weakSelf cancelHandle];
        };
        _headerToolbar.doneBlock = ^{
            [weakSelf doneHandle];
        };
        
        CGFloat Y = self.bounds.size.height - 50;
        _footerToolbar = [[IEFooterToolbar alloc] initWithFrame:CGRectMake(0, Y, self.bounds.size.width, 40)];
        [self addSubview:_footerToolbar];
        _footerToolbar.items = [self createItems];
        _footerToolbar.didSelectItemBlock = ^(IEToolbarItem *item) {
            [weakSelf didSelectItemHandle:item];
        };
        
        [self setupToolViews];
        
        _textElementArr = [NSMutableArray new];
    }
    
    return self;
}

- (void)setupToolViews {
    CGFloat footerViewY = CGRectGetMinY(_footerToolbar.frame);
    const CGFloat height = 40;
    __weak typeof(self) weakSelf = self;
    CGRect toolbarFrame = CGRectMake(0, footerViewY-height, self.bounds.size.width, height);
    // 马赛克
    _mosaicView = [[IEMosaicView alloc] initWithFrame:_imageView.bounds];
    [_imageView addSubview:_mosaicView];
    _mosaicView.mosaicImage = [IEMosaicTool createMosaicImageFromSourceImage:_image level:0];
    _mosaicView.userInteractionEnabled = NO;
    
    _mosaicToolbar = [[IEMosaicToolbar alloc] initWithFrame:toolbarFrame];
    [self addSubview:_mosaicToolbar];
    _mosaicToolbar.hidden = YES;
    _mosaicToolbar.recoverBlock = ^{
        [weakSelf.mosaicView recoverHandle];
    };
    
    // 涂鸦
    _scrawlMaskView = [[IEScrawlMaskView alloc] initWithFrame:_imageView.bounds];
    [_imageView addSubview:_scrawlMaskView];
    _scrawlMaskView.userInteractionEnabled = NO;

    _scrawlView = [[IEScrawlView alloc] initWithFrame:toolbarFrame];
    [self addSubview:_scrawlView];
    _scrawlView.hidden = YES;
    _scrawlView.colorUpdateBlock = ^(UIColor *color) {
        weakSelf.scrawlMaskView.scrawlColor = color;
    };
    _scrawlView.recoverBlock = ^{
        [weakSelf.scrawlMaskView recoverHandle];
    };
    
    // 文本
    _textToolView = [[IETextToolView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height, self.bounds.size.width, self.bounds.size.height)];
    [self addSubview:_textToolView];
    _textToolView.cancelBlock = ^{
        [weakSelf dismissTextToolView];
    };
    _textToolView.doneBlock = ^(NSString *text) {
        [weakSelf dismissTextToolView];
        [weakSelf textToolViewDidDoneText:text];
    };
}


- (NSArray<IEToolbarItem *> *)createItems {
    IEToolbarItem *scrawl = [IEToolbarItem itemWithIdentifier:kScrawl];
    scrawl.title = scrawl.identifier;
    
    IEToolbarItem *emoji = [IEToolbarItem itemWithIdentifier:kEmoji];
    emoji.title = emoji.identifier;
    
    IEToolbarItem *text = [IEToolbarItem itemWithIdentifier:kText];
    text.title = text.identifier;
    
    IEToolbarItem *mosaic = [IEToolbarItem itemWithIdentifier:kMosaic];
    mosaic.title = mosaic.identifier;
    
    IEToolbarItem *corp = [IEToolbarItem itemWithIdentifier:kCrop];
    corp.title = corp.identifier;
    return @[scrawl, emoji, text, mosaic, corp];
}

- (void)show {
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)cancelHandle {
    [self removeFromSuperview];
}

- (void)doneHandle {
    
}


- (void)didSelectItemHandle:(IEToolbarItem *)item {
    
    self.scrollView.scrollEnabled = NO;
    if ([item.identifier isEqualToString:kScrawl]) {
        self.mosaicView.userInteractionEnabled = NO;
        self.scrawlMaskView.userInteractionEnabled = YES;
        
        self.scrawlView.hidden = NO;
        self.scrawlMaskView.scrawlColor = self.scrawlView.currentColor;
    } else if ([item.identifier isEqualToString:kMosaic]) {
        self.scrawlMaskView.userInteractionEnabled = NO;
        self.mosaicView.userInteractionEnabled = YES;
        self.mosaicToolbar.hidden = NO;
    } else if ([item.identifier isEqualToString:kText]) {
        [self showTextToolView];
    }
}

- (void)showTextToolView {
    [self.textToolView.textView becomeFirstResponder];
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.textToolView.frame;
        frame.origin.y = 0;
        self.textToolView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissTextToolView {
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = self.textToolView.frame;
        frame.origin.y = frame.size.height;
        self.textToolView.frame = frame;
    } completion:^(BOOL finished) {
        [self.textToolView.textView resignFirstResponder];
    }];
}

#pragma mark - textToolView
- (void)textToolViewDidDoneText:(NSString *)text {
    IETextElementView *textElementView = [[IETextElementView alloc] init];
    textElementView.delegete = self;
    textElementView.text = text;
    textElementView.textColor = _textToolView.textView.textColor;
    [_imageView addSubview:textElementView];
    textElementView.center = [_imageView convertPoint:self.center fromView:self];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

#pragma mark - IEElementViewDelegate

- (void)elementViewBeginMove:(IEElementView *)elementView {
    
}

- (void)elementViewMoveing:(IEElementView *)elementView {
    NSLog(@"center = %@", NSStringFromCGPoint(elementView.center));
}

- (void)elementViewEndMove:(IEElementView *)elementView {
    
}



@end
