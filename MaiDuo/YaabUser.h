//
//  YaabUser.h
//  Yaab
//
//  Created by 魏琮举 on 13-4-26.
//
//

#import <Foundation/Foundation.h>
#import <RHAddressBook/AddressBook.h>

@interface YaabUser : NSObject
{
}

@property (nonatomic, strong) NSMutableArray *group;
@property (nonatomic, strong) NSMutableArray *names;
@property (nonatomic, strong) NSMutableArray *description;
+(YaabUser *)default;

@end
