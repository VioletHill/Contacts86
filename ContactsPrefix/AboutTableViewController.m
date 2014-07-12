//
//  AboutTableViewController.m
//  ContactsPrefix
//
//  Created by 邱峰 on 7/12/14.
//  Copyright (c) 2014 TongjiUniversity. All rights reserved.
//

#import "AboutTableViewController.h"
#import "AppInfo.h"
#import "UIDevice+DeviceInfo.h"
#import <MessageUI/MessageUI.h>

@interface AboutTableViewController () <MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>

@end

@implementation AboutTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.row == 0) {
        [self sharedWithMessage];
    } else if (indexPath.row == 1) {
        [self evaluate];
    } else if (indexPath.row == 2) {
        [self sendEmail];
    }
}

- (void)evaluate
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[AppInfo appDownloadAddress]]];
}

- (void)sendEmail
{
    MFMailComposeViewController* mail = [[MFMailComposeViewController alloc] init];
    mail.mailComposeDelegate = self;

    if ([MFMailComposeViewController canSendMail]) {
        //设置收件人
        [mail setToRecipients:@[ @"yijianjia86@gmail.com" ]];

        //设置抄送人
        //[mail setCcRecipients:ccAddress];
        //设置邮件内容
        [mail setMessageBody:[NSString stringWithFormat:@"%@\n请在分割线下面写下您的建议，或者遇到的问题:\n\n-------------------------------------------\n\n", [UIDevice deviceInfo]] isHTML:NO];

        //设置邮件主题
        [mail setSubject:@"一键加86建议"];

        [self presentViewController:mail animated:YES completion:nil];
    } else {
        [self sendEmailFail:@"您的设备不支持邮件发送，检查是否设置了邮件账户。如果一切正常，建议您更新设备"];
    }
}

- (void)sendEmailFail:(NSString*)errorMessage
{
    if (errorMessage == nil) {
        errorMessage = @"对不起，邮件发送失败，检查网络或者您的设备是否正常";
    }
    UIAlertView* view = [[UIAlertView alloc] initWithTitle:@"发送失败" message:errorMessage delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [view show];
}

- (void)sharedWithMessage
{
    MFMessageComposeViewController* message = [[MFMessageComposeViewController alloc] init];
    message.messageComposeDelegate = self;
    if ([MFMessageComposeViewController canSendText]) {
        message.body = [NSString stringWithFormat:@"hi~~我发现了关于通讯录的一个很棒的app,叫做\"%@\",地址在%@,快去下载吧～～", [AppInfo appName], [AppInfo appDownloadAddress]];
        [self presentViewController:message animated:YES completion:nil];
    } else {
        [self sendEmailFail:@"您的设备不支持信息发送，检查是否设置了iCloud账户。如果一切正常，建议您更新设备"];
    }
}

- (void)messageComposeViewController:(MFMessageComposeViewController*)controller didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
