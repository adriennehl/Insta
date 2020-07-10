//
//  CreatePostViewController.m
//  Insta
//
//  Created by Adrienne Li on 7/6/20.
//  Copyright © 2020 ahli. All rights reserved.
//

#import "CreatePostViewController.h"
#import "Post.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface CreatePostViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *captionField;
@property (weak, nonatomic) IBOutlet UIImageView *photoView;
@property (nonatomic) float aspectRatio;
@end

@implementation CreatePostViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

// implement delegate method to take a picture
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    // get the image captured by UIImagePickerController
    UIImage *originalImage = info[UIImagePickerControllerOriginalImage];
    self.aspectRatio = originalImage.size.height/originalImage.size.width;
    CGSize size = CGSizeMake(300, 300*self.aspectRatio);
    UIImage *resizedImage = [self resizeImage:originalImage withSize:size];
    
    // set image
    [self.photoView setImage:resizedImage];
    
    // Dismiss UIImagePickerController and return to original view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

// resize image
- (UIImage *)resizeImage:(UIImage *)image withSize:(CGSize)size {
    UIImageView *resizeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    
    resizeImageView.contentMode = UIViewContentModeScaleAspectFill;
    resizeImageView.image = image;
    
    UIGraphicsBeginImageContext(size);
    [resizeImageView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (IBAction)handleTap:(UITapGestureRecognizer *)sender {
    NSLog(@"Tapped!");
    // instantiate UIImagePickerController
    UIImagePickerController *imagePickerVC = [UIImagePickerController new];
    imagePickerVC.delegate = self;
    imagePickerVC.allowsEditing = YES;
    // check that camera is supported on device
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        NSLog(@"Camera 🚫 available so we will use photo library instead");
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    [self presentViewController:imagePickerVC animated:YES completion:nil];
}

- (IBAction)onSave:(id)sender {
    // show progress HUD
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [Post postUserImage:self.photoView.image withCaption:self.captionField.text withAspectRatio:self.aspectRatio withCompletion:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            NSLog(@"Posted successfully!");
            
            // close tab
            [self dismissViewControllerAnimated:true completion:nil];
        }
        else {
            UIAlertController *postAlert = [self createAlert:error.localizedDescription title:@"Error Posting"];
            
            // show the alert controller
            [self presentViewController: postAlert animated:YES completion:^{
                // optional code for what happens after the alert controller has finished presenting
            }];
        }
        // hide progress HUD
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    }];
}

- (IBAction)onClose:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}

// given an error description and title, return an alert with cancel and ok buttons
- (UIAlertController *) createAlert: (NSString *) errorDescription title: (NSString *) title {
    
    
    // create a cancel action
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
        // handle cancel response here. Doing nothing will dismiss the view.
    }];
    
    // create an OK action
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        // handle response here.
    }];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: title
                                                                   message:errorDescription
                                                            preferredStyle:(UIAlertControllerStyleAlert)];
    
    // add the cancel action to the alertController
    [alert addAction:cancelAction];
    
    // add the OK action to the alert controller
    [alert addAction:okAction];
    
    return alert;
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
