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
#import "Post.h"

@interface ProfileViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *postCollectionView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet PFImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bioLabel;
@property (strong, nonatomic) NSArray *userPosts;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;

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
        self.profileImageView.file = self.user[@"profileImage"];
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

// resize image
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

// implement delegate method to take a picture
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    // get the image captured by UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    CGSize size = CGSizeMake(300, 300);
    UIImage *resizedImage = [self resizeImage:originalImage withSize:size];
    
    // set image
    [self.profileImageView setImage:resizedImage];
    
    // Dismiss UIImagePickerController and return to original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)saveProfilePhoto {
    PFFileObject *profileImage = [Post getPFFileFromImage:self.profileImageView.image];
    self.user[@"profileImage"] = profileImage;
    [self.user saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error!= nil) {
            NSLog(@"Error saving file");
        }
        else {
            NSLog(@"Profile saved successfully!");
            self.navigationItem.rightBarButtonItem = nil;
        }
    }];
}
- (IBAction)handleTap:(id)sender {
    NSLog(@"Tapped!");
    // only show image picker for currentUser
    if ([self.user.username isEqualToString:[PFUser currentUser].username]) {
        // instantiate UIImagePickerController
        UIImagePickerController *imagePickerVC = [UIImagePickerController new];
        imagePickerVC.delegate = self;
        imagePickerVC.allowsEditing = YES;
        // check that camera is supported on device
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
        }
        else {
            NSLog(@"Camera 🚫 available so we will use photo library instead");
            imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
        [self presentViewController:imagePickerVC animated:YES completion:nil];
        UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(saveProfilePhoto)];
        self.navigationItem.rightBarButtonItem = saveButton;
    }
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
