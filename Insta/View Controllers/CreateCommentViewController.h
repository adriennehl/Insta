//
//  CreateCommentViewController.h
//  Insta
//
//  Created by Adrienne Li on 7/10/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

NS_ASSUME_NONNULL_BEGIN

@interface CreateCommentViewController : UIViewController
@property (nonatomic, strong) Post *post;
@end

NS_ASSUME_NONNULL_END
