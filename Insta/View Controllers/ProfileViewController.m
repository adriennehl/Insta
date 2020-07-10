//
//  ProfileViewController.m
//  Insta
//
//  Created by Adrienne Li on 7/8/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import "ProfileViewController.h"
#import "PostCollectionViewCell.h"
#import "PostDetailViewController.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *postCollectionView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) NSArray *userPosts;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.postCollectionView.delegate = self;
    self.postCollectionView.dataSource = self;
    self.postCollectionView.alwaysBounceVertical = YES;
    
    // call fetchPosts on refresh
    [self.refreshControl addTarget:self.postCollectionView action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    // add refresh to collection view
    [self.postCollectionView insertSubview:self.refreshControl atIndex:0];
    
    // if no user has been set, set to current user
    if (self.user == nil) {
        self.user = [PFUser currentUser];
    }
    
    [self fetchPosts];
    [self setUserData];
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout*) self.postCollectionView.collectionViewLayout;
    
    layout.minimumInteritemSpacing = 5;
    layout.minimumLineSpacing = 5;
    
    CGFloat postersPerLine = 3;
    CGFloat itemWidth = (self.postCollectionView.frame.size.width - layout.minimumInteritemSpacing * (postersPerLine - 1)) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (void)setUserData {
    self.title = self.user[@"username"];
    if(self.user[@"name"]){
        self.nameLabel.text = self.user[@"name"];
    }
    if(self.user[@"biography"]){
        self.bioLabel.text = self.user[@"biography"];
    }
    if(self.user[@"profileImage"]){
        self.profileImageView.file = self.user[@"image"];
    }
}

// fetch user posts method
- (void) fetchPosts {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"author" equalTo:self.user];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.userPosts = posts;
            [self.postCollectionView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PostCollectionViewCell *postCell= [collectionView dequeueReusableCellWithReuseIdentifier:@"PostCollectionCell" forIndexPath:indexPath];
    Post *post = self.userPosts[indexPath.row];
    postCell = [postCell setCell:post];
    return postCell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.userPosts.count;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([sender isKindOfClass:[PostCollectionViewCell class]]) {
           PostCollectionViewCell *tappedCell = sender;
           // get indexPath of tapped cell
           NSIndexPath *indexPath = [self.postCollectionView indexPathForCell:tappedCell];
           // get post of tapped cell
           Post *post = self.userPosts[indexPath.row];
           
           // set PostDetailViewController post
           PostDetailViewController *detailsViewController = [segue destinationViewController];
           detailsViewController.post = post;
       }
}

@end
