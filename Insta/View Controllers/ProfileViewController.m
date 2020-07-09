//
//  ProfileViewController.m
//  Insta
//
//  Created by Adrienne Li on 7/8/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import "ProfileViewController.h"
#import "PostCollectionViewCell.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *postCollectionView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.postCollectionView.delegate = self;
    self.postCollectionView.dataSource = self;
    
    // call fetchPosts on refresh
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    // add refresh to collection view
    [self.postCollectionView insertSubview:self.refreshControl atIndex:0];
    
    // if no user has been set, set to current user
    if (self.user == nil) {
        self.user = [PFUser currentUser];
    }
    self.title = self.user[@"username"];
}

- (void)viewDidAppear:(BOOL)animated {
    [self fetchPosts];
}

// fetch user posts method
- (void) fetchPosts {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    query.limit = 20;
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"author" equalTo:self.user];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.posts = posts;
            [self.postCollectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCollectionViewCell *postCell= [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCollectionCell" forIndexPath:indexPath];
    Post *post = self.posts[indexPath.row];
    postCell = [postCell setCell:post];
    return postCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.posts.count;
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
