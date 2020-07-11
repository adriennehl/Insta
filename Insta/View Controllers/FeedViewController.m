//
//  FeedViewController.m
//  Insta
//
//  Created by Adrienne Li on 7/6/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import "FeedViewController.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "PostDetailViewController.h"
#import "CreatePostViewController.h"
#import "SceneDelegate.h"
#import "PostCell.h"
#import "Post.h"
#import "ProfileViewController.h"
#import "InfiniteScrollActivityView.h"

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, PostCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *postsTableView;
@property (strong, nonatomic) NSMutableArray *posts;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (nonatomic) BOOL isMoreDataLoading;
@property (strong, nonatomic) InfiniteScrollActivityView* loadingMoreView;
@property (strong, nonatomic) NSString *HeaderViewIdentifier;
@property (strong, nonatomic) NSString *FooterViewIdentifier;

@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postsTableView.delegate = self;
    self.postsTableView.dataSource = self;
    
    // create an instance of UIRefreshControl
       self.refreshControl = [[UIRefreshControl alloc] init];
    // call fetchPosts on refresh
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    // add refresh to table view
    [self.postsTableView insertSubview:self.refreshControl atIndex:0];
    
    // set up activity indicator
    [self setUpIndicator];
    //set up table view header and footer view
    self.HeaderViewIdentifier = @"TableViewHeaderView";
    self.FooterViewIdentifier = @"TableViewFooterView";
    [self.postsTableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:self.HeaderViewIdentifier];
     [self.postsTableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:self.FooterViewIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [self fetchPosts];
}

// fetch posts method
- (void) fetchPosts {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    query.limit = 20;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            // save posts and reload table
            self.posts = (NSMutableArray *)posts;
            [self.postsTableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

// fetch next posts method
- (void) fetchNextPosts {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];
    query.limit = 20;
    query.skip = self.posts.count;

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            // add posts to array and reload table
            [self.posts addObjectsFromArray:posts];
            [self.postsTableView reloadData];
            // update loading flag
            self.isMoreDataLoading = false;
            [self removedContentInset];
            // Stop the loading indicator
            [self.loadingMoreView stopAnimating];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
    }];
}

- (void)postCell:(PostCell *)postCell didTap:(PFUser *)user{
    [self performSegueWithIdentifier:@"profileSegue" sender:user];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.posts.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    Post *post = self.posts[indexPath.section];
    
    cell = [cell reloadPost:cell post:post];
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = self.posts[indexPath.section];
    float width = self.postsTableView.frame.size.width;
    float aspectRatio = 1;
    if (post.aspectRatio) {
        aspectRatio = post.aspectRatio;
    }
    
    return width * aspectRatio + 20;
}

// set header text
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:self.HeaderViewIdentifier];
    header.textLabel.text = self.posts[section][@"author"][@"username"];
    header.textLabel.textColor = UIColor.blackColor;
    return header;
}

// set footer text
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = [tableView dequeueReusableHeaderFooterViewWithIdentifier:self.FooterViewIdentifier];
    Post *post = self.posts[section];
    footer.textLabel.text = [Post dateToString:post.createdAt];
    footer.tintColor = UIColor.whiteColor;
    // set separator inset
    return footer;
}

// set header height
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

//set footer height
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 30;
}

// handle scrolling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!self.isMoreDataLoading){
        // Calculate the position of one screen length before the bottom of the results
        int scrollViewContentHeight = self.postsTableView.contentSize.height;
        int scrollOffsetThreshold = scrollViewContentHeight - self.postsTableView.bounds.size.height;
        
        // When the user has scrolled past the threshold, start requesting
        if(scrollView.contentOffset.y > scrollOffsetThreshold && self.postsTableView.isDragging) {
            self.isMoreDataLoading = true;
            [self addContentInset];
            
            // Update position of loadingMoreView, and start loading indicator
                       CGRect frame = CGRectMake(0, self.postsTableView.contentSize.height, self.postsTableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
            self.loadingMoreView.frame = frame;
            [self.loadingMoreView startAnimating];
            
            // load data
            [self fetchNextPosts];
        }
    }
}

// user can logout
- (IBAction)onLogout:(id)sender {
    SceneDelegate *sceneDelegate = (SceneDelegate *)self.view.window.windowScene.delegate;
    // create storyboard
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // create new instance of view controller in storyboard
    LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
    // set root view controller
    sceneDelegate.window.rootViewController = loginViewController;
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        // PFUser.current() will now be nil
    }];
}

// Set up Infinite Scroll loading indicator
- (void)setUpIndicator {
    // create subview with frame
    CGRect frame = CGRectMake(0, self.postsTableView.contentSize.height, self.postsTableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight);
    self.loadingMoreView = [[InfiniteScrollActivityView alloc] initWithFrame:frame];
    self.loadingMoreView.hidden = true;
    [self.postsTableView addSubview:self.loadingMoreView];
}

- (void)addContentInset {
    // add insets to show loading indicator at bottom
    UIEdgeInsets insets = self.postsTableView.contentInset;
    insets.bottom += InfiniteScrollActivityView.defaultHeight;
    self.postsTableView.contentInset = insets;
}

- (void)removedContentInset {
    // remove inset when not loading
    UIEdgeInsets insets = self.postsTableView.contentInset;
    insets.bottom -= InfiniteScrollActivityView.defaultHeight;
    self.postsTableView.contentInset = insets;
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     
     if([sender isKindOfClass:[PostCell class]]) {
         PostCell *tappedCell = sender;
         // get indexPath of tapped cell
         NSIndexPath *indexPath = [self.postsTableView indexPathForCell:tappedCell];
         // get post of tapped cell
         Post *post = self.posts[indexPath.section];
         
         // set PostDetailViewController post
         PostDetailViewController *detailsViewController = [segue destinationViewController];
         detailsViewController.post = post;
     }
     else if ([segue.identifier isEqualToString:@"profileSegue"]){
         ProfileViewController *profileViewController = [segue destinationViewController];
         profileViewController.user = sender;
     }
 }

@end
