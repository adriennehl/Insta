//
//  PostDetailViewController.h
//  Insta
//
//  Created by Adrienne Li on 7/7/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface PostDetailViewController : UIViewController
@property (strong, nonatomic) Post *post;
@end

NS_ASSUME_NONNULL_END
