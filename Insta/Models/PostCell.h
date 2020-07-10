//
//  PostCell.h
//  Insta
//
//  Created by Adrienne Li on 7/7/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "PostCell.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN
@protocol PostCellDelegate;

@interface PostCell : UITableViewCell
@property (weak, nonatomic) IBOutlet PFImageView *postView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet PFImageView *profileView;
@property (strong, nonatomic) Post *post;
@property (strong, nonatomic) PFUser *user;
@property (nonatomic, weak) id<PostCellDelegate> delegate;

- (PostCell*)reloadPost:(PostCell *)cell post:(Post *) post;
@end

@protocol PostCellDelegate

- (void)postCell:(PostCell *) postCell didTap: (PFUser *)user;

@end

NS_ASSUME_NONNULL_END
