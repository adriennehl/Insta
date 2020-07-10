//
//  PostCell.m
//  Insta
//
//  Created by Adrienne Li on 7/7/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import "PostCell.h"

@implementation PostCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
    // configure tap gesture recognizer
    UITapGestureRecognizer *profileViewTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    UITapGestureRecognizer *usernameTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUserProfile:)];
    [self.profileView addGestureRecognizer:profileViewTapGestureRecognizer];
    [self.profileView setUserInteractionEnabled:YES];
    [self.usernameLabel addGestureRecognizer:usernameTapGestureRecognizer];
    [self.usernameLabel setUserInteractionEnabled:YES];
}

// when tap gesture recognizer recognizes a tap
- (void) didTapUserProfile:(UITapGestureRecognizer *)sender{
    // call did tap method on delegate when tapped
    [self.delegate postCell:self didTap:self.user];
}

- (PostCell *)reloadPost:(PostCell *)cell post:(Post *) post {
    _post = post;
    self.postView.file = post[@"image"];
    [self.postView loadInBackground];
    self.captionLabel.text = post[@"caption"];
    self.user = post[@"author"];
    self.usernameLabel.text = self.user[@"username"];
    self.profileView.file = self.user[@"profileImage"];
    [self.profileView loadInBackground];
    return self;
}

@end
