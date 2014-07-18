//
//  ViewController.m
//  ContactsPrefix
//
//  Created by 邱峰 on 4/6/14.
//  Copyright (c) 2014 TongjiUniversity. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>

@interface ViewController ()

@property (nonatomic, strong) NSArray* contact;

@property (weak, nonatomic) IBOutlet UITextField* prefixDeleteLabel;

@property (weak, nonatomic) IBOutlet UITextField* prefixLabel;

@property (nonatomic, strong) UIView* layerView;

@property (nonatomic, strong) UIActivityIndicatorView* activity;

@end

@implementation ViewController {
    NSString* prefix;
    BOOL isAdd;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self layerView];

    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView*)layerView
{
    if (_layerView == nil) {
        self.layerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.layerView.backgroundColor = [UIColor blackColor];
        self.layerView.alpha = 0.5;
        [self.navigationController.view addSubview:_layerView];
        self.layerView.hidden = YES;
    }
    return _layerView;
}

- (UIActivityIndicatorView*)activity
{
    if (_activity == nil) {
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity.frame = CGRectMake(self.view.frame.size.width / 2 - 22, self.view.frame.size.height / 2 - 22, 44, 44);
        [self.navigationController.view addSubview:_activity];
        _activity.hidden = YES;
    }
    return _activity;
}

- (void)readAllPeople
{

    //读取所有联系人

    //取得本地通信录名柄

    ABAddressBookRef addressBook = nil;

    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0) {
        addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool greanted, CFErrorRef error) {
            dispatch_semaphore_signal(sema);
        });

        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
    } else {
        addressBook = ABAddressBookCreateWithOptions(nil, nil);
    }
    //取得本地所有联系人记录

    if (addressBook == nil)
        return;
    CFArrayRef contacts = ABAddressBookCopyArrayOfAllPeople(addressBook);

    for (int i = 0; i < CFArrayGetCount(contacts); i++) {
        ABRecordRef person = CFArrayGetValueAtIndex(contacts, i);
        NSString* name = (__bridge NSString*)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        NSLog(@"%@", name);

        ABMutableMultiValueRef phoneNumbers = ABRecordCopyValue(person, kABPersonPhoneProperty);

        ABMultiValueIdentifier mi;

        ABMultiValueRef mv = ABMultiValueCreateMutable(kABMultiStringPropertyType);
        for (int j = 0; j < ABMultiValueGetCount(phoneNumbers); j++) {

            CFStringRef label = ABMultiValueCopyLabelAtIndex(phoneNumbers, j);
            NSString* value = (__bridge NSString*)(ABMultiValueCopyValueAtIndex(phoneNumbers, j));
            if (isAdd) {
                if (!([[value substringToIndex:prefix.length] isEqualToString:prefix]) && [value characterAtIndex:0] == '1') {
                    value = [NSString stringWithFormat:@"%@%@", prefix, value];
                }
            } else {
                NSLog(@"%@", [value substringToIndex:prefix.length]);
                if ([[value substringToIndex:prefix.length] isEqualToString:prefix]) {
                    value = [value substringFromIndex:prefix.length];
                }
            }

            NSLog(@"%@ %@ %@", [value substringToIndex:prefix.length], label, value);
            mi = ABMultiValueAddValueAndLabel(mv, (__bridge CFTypeRef)(value), label, &mi);
        }

        ABRecordSetValue(person, kABPersonPhoneProperty, mv, NULL);
    }
    ABAddressBookSave(addressBook, nil);
}

- (void)startDelete
{
    isAdd = NO;
    NSMutableString* str = [self.prefixDeleteLabel.text mutableCopy];
    if (str.length > 5) {
        [[[UIAlertView alloc] initWithTitle:@"输入错误" message:@"亲～～要对自己的通讯录负责哦～～" delegate:nil cancelButtonTitle:@"我错了T_T" otherButtonTitles:nil, nil] show];
        [self endFix];
        return;
    }
    for (int i = 0; i < str.length; i++) {
        if ([str characterAtIndex:i] < '0' || [str characterAtIndex:i] > '9') {
            [str deleteCharactersInRange:NSMakeRange(i, 1)];
            i--;
        }
    }

    prefix = [NSString stringWithFormat:@"+%@", str];
    [self readAllPeople];
    [self endFix];
}

- (IBAction) delete:(id)sender
{
    [self startFix];
    [self performSelector:@selector(startDelete) withObject:self afterDelay:0.1];
}

- (void)startAdd
{
    isAdd = YES;
    NSMutableString* str = [self.prefixLabel.text mutableCopy];
    if (str.length > 5) {
        [[[UIAlertView alloc] initWithTitle:@"输入错误" message:@"亲～～要对自己的通讯录负责哦～～" delegate:nil cancelButtonTitle:@"我错了T_T" otherButtonTitles:nil, nil] show];
        [self endFix];
        return;
    }
    for (int i = 0; i < str.length; i++) {
        if ([str characterAtIndex:i] < '0' || [str characterAtIndex:i] > '9') {
            [str deleteCharactersInRange:NSMakeRange(i, 1)];
            i--;
        }
    }
    prefix = [NSString stringWithFormat:@"+%@", str];
    NSLog(@"%@", prefix);
    [self readAllPeople];

    [self endFix];
}

- (IBAction)add:(id)sender
{
    [self startFix];

    [self performSelector:@selector(startAdd) withObject:self afterDelay:0.1];
}

- (void)startFix
{
    self.layerView.hidden = NO;
    self.activity.hidden = NO;
    [self.activity startAnimating];
}

- (void)endFix
{
    self.layerView.hidden = YES;
    self.activity.hidden = YES;
    [self.activity stopAnimating];
}

@end
