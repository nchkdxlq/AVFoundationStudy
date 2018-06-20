//
//  IEMosaicToolbar.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/20.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "IEMosaicToolbar.h"

@implementation IEMosaicToolbar {
    UIButton *_recoverBtn;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        _recoverBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        [self addSubview:_recoverBtn];
        _recoverBtn.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0);
        [_recoverBtn addTarget:self
                        action:@selector(recoverBtnClickHandle:)
              forControlEvents:UIControlEventTouchUpInside];
        
        _recoverBtn.backgroundColor = [UIColor redColor];
    }
    
    return self;
}


- (void)recoverBtnClickHandle:(UIButton *)button {
    !_recoverBlock ?: _recoverBlock();
}

@end
