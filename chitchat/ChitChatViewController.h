//
//  ChitChatViewController.h
//  MaiDuo
//
//  Created by yuanwei on 13-5-8.
//  Copyright (c) 2013年 魏琮举. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSMessagesViewController.h"
@interface ChitChatViewController : JSMessagesViewController
@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableArray *timestamps;
@end
