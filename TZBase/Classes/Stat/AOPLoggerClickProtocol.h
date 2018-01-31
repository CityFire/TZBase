//
//  AOPLoggerClickProtocol.h
//  TZGame
//
//  Created by wjc on 2017/12/20.
//  Copyright © 2017年 wjc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AOPLoggerClickProtocol <NSObject>

@optional
- (void)alcp_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event;
- (void)alcp_customIgnore_sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event;
- (void)alcp_collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath from:(id)sender;
- (void)alcp_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath from:(id)sender;
- (void)alcp_tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController from:(id)sender;
- (void)alcp_tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item from:(id)sender;
- (void)alcp_alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex from:(id)sender;
- (void)alcp_actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex from:(id)sender;
- (void)alcp_alertControllerAction:(UIAlertAction *)action from:(id)sender;

@end
