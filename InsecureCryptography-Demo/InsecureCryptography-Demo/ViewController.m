//
//  ViewController.m
//  InsecureCryptography-Demo
//
//  Created by Prateek Gianchandani on 1/12/14.
//  Copyright (c) 2014 HighAltitudeHacks.com. All rights reserved.
//

#import "ViewController.h"
#import "RNEncryptor.h"
#import "RNDecryptor.h"

@interface ViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIView *firstUserView;
@property (weak, nonatomic) IBOutlet UIView *returningUserView;
@property (weak, nonatomic) IBOutlet UITextField *returningUserTextField;
@property (weak, nonatomic) IBOutlet UILabel *returningUserLabel;
@property (weak, nonatomic) IBOutlet UILabel *loggedInLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self checkUserState];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *dataPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"/secret-data"];
    
    if(textField == self.passwordTextField){
    [textField resignFirstResponder];
    if(textField.text.length == 0){
        [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Please enter a password" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    NSData *data = [self.passwordTextField.text dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error;
    NSData *encryptedData = [RNEncryptor encryptData:data
                                        withSettings:kRNCryptorAES256Settings
                                            password:@"Secret-Key"
                                               error:&error];
    
    [encryptedData writeToFile:dataPath atomically:YES];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"loggedIn"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.firstUserView setHidden:YES];
    
}
    else if(textField == self.returningUserTextField){
        
        NSData *data = [self.returningUserTextField.text dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSData *encryptedData = [NSData dataWithContentsOfFile:dataPath];
        NSData *decryptedData = [RNDecryptor decryptData:encryptedData
                                            withPassword:@"Secret-Key"
                                                   error:&error];
        
     if([data isEqualToData:decryptedData]){
            [self.loggedInLabel setHidden:NO];
            [self.returningUserTextField setHidden:YES];
            [self.returningUserLabel setHidden:YES];
            
        }else{
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:@"Password is incorrect" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return NO;

        }
    }
    
    return NO;
}

-(void)checkUserState {
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"loggedIn"]){
        [self.firstUserView setHidden:YES];
    }
}

@end
