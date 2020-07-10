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
    self.layoutMargins = UIEdgeInsetsZero;
    self.preservesSuperviewLayoutMargins = false;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (PostCell *)reloadPost:(PostCell *)cell post:(Post *) post {
    _post = post;
    self.postView.file = post[@"image"];
    [self.postView loadInBackground];
    self.captionLabel.text = post[@"caption"];
    self.user = post[@"author"];
    self.usernameLabel.text = self.user[@"username"];
    return self;
}

@end
