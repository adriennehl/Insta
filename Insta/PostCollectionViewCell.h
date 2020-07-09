//
//  PostCollectionViewCell.h
//  Insta
//
//  Created by Adrienne Li on 7/8/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface PostCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet PFImageView *postView;
- (PostCollectionViewCell *)setCell:(Post *)post;
@property (strong, nonatomic) Post *post;
@end

NS_ASSUME_NONNULL_END
