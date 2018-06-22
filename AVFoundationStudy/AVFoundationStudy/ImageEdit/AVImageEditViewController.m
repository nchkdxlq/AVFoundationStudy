//
//  AVImageEditViewController.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/6/19.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "AVImageEditViewController.h"
#import "ImageEditer.h"


@interface AVImageEditViewController ()

@property (nonatomic, strong) ImageEditer *editer;

@end

@implementation AVImageEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImage *image = [UIImage imageNamed:@"world_cup_right.jpg"];

    _editer = [ImageEditer imageEditerWithImage:image];

    [_editer show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
