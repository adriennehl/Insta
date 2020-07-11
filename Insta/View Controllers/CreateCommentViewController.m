//
//  CreateCommentViewController.m
//  Insta
//
//  Created by Adrienne Li on 7/10/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import "CreateCommentViewController.h"

@interface CreateCommentViewController ()
@property (weak, nonatomic) IBOutlet UITextField *commentField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation CreateCommentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)onSave:(id)sender {
    if ([self.commentField.text isEqualToString:@""]){
        NSLog(@"Comment field can't be empty");
    }
    else {
        NSMutableArray *comments = [[NSMutableArray alloc] initWithArray:self.post.comments];
        [comments addObject:self.commentField.text];
        NSNumber *commentCount = self.post.commentCount;
        self.post[@"commentCount"] =  [NSNumber numberWithInt:[commentCount intValue]+1];
        self.post[@"comments"] = comments;
        [self.post saveInBackground];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
