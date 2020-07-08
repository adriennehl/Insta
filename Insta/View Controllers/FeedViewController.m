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

@interface FeedViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *postsTableView;
@property (strong, nonatomic) NSArray *posts;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation FeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.postsTableView.delegate = self;
    self.postsTableView.dataSource = self;
    
    // fetch tweets
    [self fetchPosts];
    
    // create an instance of UIRefreshControl
       self.refreshControl = [[UIRefreshControl alloc] init];
    // call fetchPosts on refresh
    [self.refreshControl addTarget:self action:@selector(fetchPosts) forControlEvents:UIControlEventValueChanged];
    // add refresh to table view
    [self.postsTableView insertSubview:self.refreshControl atIndex:0];
}

- (void)viewDidAppear:(BOOL)animated {
    [self fetchPosts];
}

// fetch posts method
- (void) fetchPosts {
    // construct query
    PFQuery *query = [PFQuery queryWithClassName:@"Post"];
    query.limit = 20;
    [query includeKey:@"author"];
    [query orderByDescending:@"createdAt"];

    // fetch data asynchronously
    [query findObjectsInBackgroundWithBlock:^(NSArray *posts, NSError *error) {
        if (posts != nil) {
            self.posts = posts;
            [self.postsTableView reloadData];
        } else {
            NSLog(@"%@", error.localizedDescription);
        }
        [self.refreshControl endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.posts.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   PostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostCell"];
    Post *post = self.posts[indexPath.row];
    
    cell = [cell reloadPost:cell post:post];
    
    return cell;
    
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
         Post *post = self.posts[indexPath.row];
         
         // set PostDetailViewController post
         PostDetailViewController *detailsViewController = [segue destinationViewController];
         detailsViewController.post = post;
     }
 }

@end
