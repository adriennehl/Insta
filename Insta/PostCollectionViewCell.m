//
//  PostCollectionViewCell.m
//  Insta
//
//  Created by Adrienne Li on 7/8/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import "PostCollectionViewCell.h"
#import "Post.h"

@implementation PostCollectionViewCell
- (PostCollectionViewCell *)setCell:(Post *)post {
    self.post = post;
    self.postView.file = self.post[@"image"];
    return self;
}
@end
