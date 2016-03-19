//
//  YMCommentViewController.m
//  ImitateBaisi
//
//  Created by 杨蒙 on 16/3/11.
//  Copyright © 2016年 hrscy. All rights reserved.
//

#import "YMCommentViewController.h"
#import "YMTopicCell.h"
#import "YMTopic.h"
#import "MJRefresh.h"
#import "AFNetworking.h"
#import "YMComment.h"
#import "MJExtension.h"

@interface YMCommentViewController () <UITableViewDelegate, UITableViewDataSource>
/** 工具条底部间距*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomSpace;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/** 最热评论*/
@property (nonatomic, strong) NSArray *hotComments;

/** 最新评论*/
@property (nonatomic, strong) NSMutableArray *lastestComments;

@end

@implementation YMCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupBasic];
    
    [self setupHeader];
    
    [self setupRefresh];
}


-(void)setupRefresh {
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewComments)];
    [self.tableView.mj_header beginRefreshing];
    
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreComments)];
}

-(void)loadNewComments {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"a"] = @"dataList";
    params[@"c"] = @"comment";
    params[@"hot"] = @"1";
    params[@"data_id"] = self.topic.ID;
    [[AFHTTPSessionManager manager] GET:@"http://api.budejie.com/api/api_open.php" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //最热评论
//        self.hotComments =
        
        //最新评论
        self.lastestComments = [YMComment mj_objectArrayWithKeyValuesArray:responseObject[@"data"]];
        
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self.tableView.mj_header endRefreshing];
        
    }];
}

-(void)loadMoreComments {
    
}

-(void)setupHeader {
    UIView *header = [[UIView alloc] init];
    YMTopicCell *cell = [YMTopicCell cell];
    cell.topic = self.topic;;
    cell.height = self.topic.cellHeight;
    cell.width = SCREENW;
    [header addSubview:cell];
    header.height = self.topic.cellHeight + YMTopicCellMargin;
    self.tableView.tableHeaderView = header;
    self.tableView.backgroundColor = YMGlobalBg;
}

-(void)setupBasic {
    self.navigationItem.title = @"评论";
    self.navigationItem.rightBarButtonItem = [UIBarButtonItem itemWithImage:@"comment_nav_item_share_icon" highImage:@"comment_nav_item_share_icon_click" target:nil action:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

-(void)keyboardWillChangeFrame:(NSNotification *)notification {
    //键盘显示/隐藏完毕的frame
    CGRect frame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.bottomSpace.constant = SCREENH - frame.origin.y;
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //动画
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger hotCount = self.hotComments.count;
    NSInteger lastestCount = self.lastestComments.count;
    if (hotCount) return 2; //有最热评论+最新评论  2组
    if (lastestCount) return 1; //最新评论  1组
    return 0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        NSInteger hotCount = self.hotComments.count;
        return hotCount ? hotCount : self.lastestComments.count;
    }
    return self.lastestComments.count;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = YMGlobalBg;
    
    UILabel *label = [[UILabel alloc] init];
    label.x = YMTopicCellMargin;
    label.width = 200;
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    label.textColor = YMColor(67, 67, 67);
    if (section == 0) {
        label.text = self.hotComments.count ? @"最热评论" : @"最新评论";
    } else {
        label.text = @"评论";
    }
    [header addSubview:label];
    return header;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    YMComment *comment = [self commentInIndexPath:indexPath];
    cell.textLabel.text = comment.content;
    return cell;
}

/**
 *  返回第section组的所有评论
 */
-(NSArray *)commentInSection:(NSInteger)section {
    if (section == 0) {
        return self.hotComments.count ? self.hotComments : self.lastestComments;
    }
    return self.lastestComments;
}

-(YMComment *)commentInIndexPath:(NSIndexPath *)indexPath {
    return [self commentInSection:indexPath.section][indexPath.row];
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

-(NSMutableArray *)lastestComments{
    if (_lastestComments == nil) {
        _lastestComments = [[NSMutableArray alloc] init];
    }
    return _lastestComments;
}

@end
