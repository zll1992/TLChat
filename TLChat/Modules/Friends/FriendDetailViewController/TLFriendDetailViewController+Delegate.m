//
//  TLFriendDetailViewController+Delegate.m
//  TLChat
//
//  Created by 李伯坤 on 16/3/17.
//  Copyright © 2016年 李伯坤. All rights reserved.
//

#import "TLFriendDetailViewController+Delegate.h"
#import "TLLaunchManager.h"
#import "TLChatViewController.h"
#import <MWPhotoBrowser/MWPhotoBrowser.h>
#import "TLUser+ChatModel.h"
#import "TLFriendDetailAlbumCell.h"
#import "NSFileManager+TLChat.h"

@implementation TLFriendDetailViewController (Delegate)

#pragma mark - Private Methods -
- (void)registerCellClass
{
    [self.tableView registerClass:[TLFriendDetailUserCell class] forCellReuseIdentifier:@"TLFriendDetailUserCell"];
    [self.tableView registerClass:[TLFriendDetailAlbumCell class] forCellReuseIdentifier:@"TLFriendDetailAlbumCell"];
}

#pragma mark - Delegate -
//MARK: UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLInfo *info = [self.data[indexPath.section] objectAtIndex:indexPath.row];
    if (info.type == TLInfoTypeOther) {
        if (indexPath.section == 0) {
            TLFriendDetailUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TLFriendDetailUserCell"];
            [cell setDelegate:self];
            [cell setInfo:info];
            [cell setTopLineStyle:TLCellLineStyleFill];
            [cell setBottomLineStyle:TLCellLineStyleFill];
            return cell;
        }
        else {
            TLFriendDetailAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TLFriendDetailAlbumCell"];
            [cell setInfo:info];
            return cell;
        }
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

//MARK: UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TLInfo *info = [self.data[indexPath.section] objectAtIndex:indexPath.row];
    if (info.type == TLInfoTypeOther) {
        if (indexPath.section == 0) {
            return HEIGHT_USER_CELL;
        }
        return HEIGHT_ALBUM_CELL;
    }
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


//MARK: TLInfoButtonCellDelegate
- (void)infoButtonCellClicked:(TLInfo *)info
{
    if ([info.title isEqualToString:@"发消息"]) {
        TLChatViewController *chatVC = [[TLChatViewController alloc] init];
        if ([self.navigationController findViewController:@"TLChatViewController"]) {
            if ([[chatVC.partner chat_userID] isEqualToString:self.user.userID]) {
                [self.navigationController popToViewControllerWithClassName:@"TLChatViewController" animated:YES];
                return;
            }
            else {
                [chatVC setPartner:self.user];
            }
        }
        else {
            [chatVC setPartner:self.user];
        }
        if ([TLLaunchManager sharedInstance].tabBarController.selectedIndex != 0) {
            [self.navigationController popToRootViewControllerAnimated:NO];
            UINavigationController *navC = [TLLaunchManager sharedInstance].tabBarController.childViewControllers[0];
            [[TLLaunchManager sharedInstance].tabBarController setSelectedIndex:0];
            [chatVC setHidesBottomBarWhenPushed:YES];
            [navC pushViewController:chatVC animated:YES];
        }
        else {
            PushVC(chatVC);
        }
    }
    else {
        [super infoButtonCellClicked:info];
    }
}

//MARK: TLFriendDetailUserCellDelegate
- (void)friendDetailUserCellDidClickAvatar:(TLInfo *)info
{
    NSURL *url;
    if (self.user.avatarPath) {
        NSString *imagePath = [NSFileManager pathUserAvatar:self.user.avatarPath];
        url = [NSURL fileURLWithPath:imagePath];
    }
    else {
        url = TLURL(self.user.avatarURL);
    }

    MWPhoto *photo = [MWPhoto photoWithURL:url];
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithPhotos:@[photo]];
    UINavigationController *broserNavC = [[UINavigationController alloc] initWithRootViewController:browser];
    [self presentViewController:broserNavC animated:NO completion:nil];
}

@end
