//
//  PostDetailViewController.m
//  Insta
//
//  Created by Adrienne Li on 7/7/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import "PostDetailViewController.h"
#import "CommentCell.h"
#import "CreateCommentViewController.h"

@import Parse;

@interface PostDetailViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet PFImageView *postView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (strong, nonatomic) PFUser *user;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *likeLabel;
@property (weak, nonatomic) IBOutlet UITableView *commentsTableView;

@end

@implementation PostDetailViewController

- (void)viewDidLoad {
    self.commentsTableView.delegate = self;
    self.commentsTableView.dataSource = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [self loadDetails];
    [self.commentsTableView reloadData];
}

- (void) loadDetails {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postView.file = self.post[@"image"];
    [self.postView loadInBackground];
    
    self.likeLabel.text = [NSString stringWithFormat:@"%@", self.post[@"likeCount"]];
    self.captionLabel.text = self.post[@"caption"];
    self.user = self.post[@"author"];
    self.usernameLabel.text = self.user[@"username"];
    self.timestampLabel.text = [Post dateToString:self.post.createdAt];

    if ([PFUser.currentUser[@"likedPosts"] containsObject:self.post.objectId]) {
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
    }
    else {
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
    }
}

- (IBAction)onLike:(id)sender {
    NSNumber *likes = self.post[@"likeCount"];
    if ([PFUser.currentUser[@"likedPosts"] containsObject:self.post.objectId]) {
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon"] forState:UIControlStateNormal];
        [PFUser.currentUser[@"likedPosts"] removeObject:self.post.objectId];
        self.post[@"likeCount"] =  [NSNumber numberWithInt:[likes intValue]-1];
    }
    else {
        [self.likeButton setImage:[UIImage imageNamed:@"favor-icon-red"] forState:UIControlStateNormal];
        [PFUser.currentUser[@"likedPosts"] addObject:self.post.objectId];
        self.post[@"likeCount"] =  [NSNumber numberWithInt:[likes intValue]+1];
    }
    [PFUser.currentUser saveInBackground];
    [self.post saveInBackground];
    [self loadDetails];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *comment = self.post.comments[indexPath.row];
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    cell.commentLabel.text = comment;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.post.comments.count;
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    CreateCommentViewController *destinationViewController = [segue destinationViewController];
    destinationViewController.post = self.post;
}


@end
