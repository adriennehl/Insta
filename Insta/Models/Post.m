//
//  Post.m
//  Insta
//
//  Created by Adrienne Li on 7/7/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import "Post.h"
@implementation Post
    
@dynamic postID;
@dynamic userID;
@dynamic author;
@dynamic caption;
@dynamic image;
@dynamic likeCount;
@dynamic commentCount;
@dynamic aspectRatio;
@dynamic comments;

+ (nonnull NSString *)parseClassName {
    return @"Post";
}

+ (NSString *)dateToString: (NSDate *)createdAt {
    // format and set createdAtString
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // configure output format
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterNoStyle;
    //Convert Date to String
    NSString *createdAtString = [formatter stringFromDate:createdAt];
    return createdAtString;
}

+ (void) postUserImage: ( UIImage * _Nullable )image withCaption: ( NSString * _Nullable )caption withAspectRatio: (float) aspectRatio withCompletion: (PFBooleanResultBlock  _Nullable)completion {
    
    Post *newPost = [Post new];
    newPost.image = [self getPFFileFromImage:image];
    newPost.author = [PFUser currentUser];
    newPost.caption = caption;
    newPost.likeCount = @(0);
    newPost.commentCount = @(0);
    newPost.comments = [NSMutableArray array];
    newPost.aspectRatio = aspectRatio;
    
    [newPost saveInBackgroundWithBlock: completion];
}

+ (PFFileObject *)getPFFileFromImage: (UIImage * _Nullable)image {
 
    // check if image is not nil
    if (!image) {
        return nil;
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    // get image data and check if that is not nil
    if (!imageData) {
        return nil;
    }
    
    return [PFFileObject fileObjectWithName:@"image.png" data:imageData];
}

@end
