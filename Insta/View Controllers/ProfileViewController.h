//
//  ProfileViewController.h
//  Insta
//
//  Created by Adrienne Li on 7/8/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import <UIKit/UIKit.h>
@import Parse;

NS_ASSUME_NONNULL_BEGIN

@interface ProfileViewController : UIViewController
@property (strong, nonatomic) PFUser *user;
@property (strong, nonatomic) NSArray *posts;
@end

NS_ASSUME_NONNULL_END
