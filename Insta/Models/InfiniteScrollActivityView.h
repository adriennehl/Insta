//
//  InfiniteScrollActivityView.h
//  Insta
//
//  Created by Adrienne Li on 7/9/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface InfiniteScrollActivityView : UIView

@property (class, nonatomic, readonly) CGFloat defaultHeight;

- (void)startAnimating;
- (void)stopAnimating;

@end
NS_ASSUME_NONNULL_END
