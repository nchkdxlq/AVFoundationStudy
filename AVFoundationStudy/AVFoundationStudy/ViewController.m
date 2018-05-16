//
//  ViewController.m
//  AVFoundationStudy
//
//  Created by nchkdxlq on 2018/5/16.
//  Copyright © 2018年 luoquan. All rights reserved.
//

#import "ViewController.h"
#import "AVCameraViewController.h"


static NSString * const kRowTitleKey = @"title";
static NSString * const kRowVCClassKey = @"vcClass";

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *dataSource;

@end

@implementation ViewController


- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

- (NSMutableArray<NSDictionary *> *)dataSource {
    if (!_dataSource) {
        _dataSource = [NSMutableArray new];
    }
    return _dataSource;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"AVFoundation";
    
    [self.view addSubview:self.tableView];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self setupDataSourece];
}


- (void)setupDataSourece {
    
    [self.dataSource addObject:@{kRowTitleKey:@"Carera Recorder",
                                 kRowVCClassKey:AVCameraViewController.class}];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *reuseIdentifier = @"reuseIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    cell.textLabel.text = [self titleForIndexPath:indexPath];
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    Class vcClass = [self vcClassForIndexPath:indexPath];
    if (vcClass) {
        UIViewController *vc = [vcClass new];
        vc.title = [self titleForIndexPath:indexPath];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.count) {
        return (NSString *)self.dataSource[indexPath.row][kRowTitleKey];
    }
    return nil;
}

- (Class)vcClassForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataSource.count) {
        return (Class)self.dataSource[indexPath.row][kRowVCClassKey];
    }
    return nil;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
