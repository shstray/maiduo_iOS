//
//  MDHTTPAPI.m
//  MaiDuo
//
//  Created by 魏琮举 on 13-5-10.
//  Copyright (c) 2013年 魏琮举. All rights reserved.
//

#import "MDHTTPAPI.h"
#import "AFMDClient.h"
#import <AFNetworking/AFNetworking.h>

@implementation MDHTTPAPI
-(id) init
{
    self = [super init];
    if (self) {
        url = @"https://himaiduo.com/api/";
    }
    
    return self;
}

-(id) initWithUser:(MDUser *)user
{
    self = [self init];
    if (self) {
        self.user = user;
    }
    
    return self;
}

-(void)activitiesSuccess:(void (^)(NSArray *))success
                 failure:(void (^)(NSError *error))failure
{
    void (^blockSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
        NSLog(@"Activity fetch data success.");
        success([MDActivity activitiesWithJSON:JSON]);
    };
    
    void (^blockFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        if (nil != failure)
            failure(error);
    };
    
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           self.user.accessToken, @"access_token", nil];
    
    [[AFMDClient sharedClient] getPath:@"activity/"
                            parameters:query
                               success:blockSuccess
                               failure:blockFailure];
}

-(void)createActivity:(MDActivity *)activity
              success:(void (^)(MDActivity *))success
              failure:(void (^)(NSError *error))failure
{
    void (^blockSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
        success([MDActivity activityWithJSON: JSON]);
    };
    
    void (^blockFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self printError:error];
        if (nil != failure)
            failure(error);
    };
    
    NSMutableDictionary *dictionaryActivity = [activity valueDictionary];
    [dictionaryActivity setValue:self.user.accessToken forKey:@"access_token"];
    
    [[AFMDClient sharedClient] postPath:@"activity/"
                             parameters:dictionaryActivity
                                success:blockSuccess
                                failure:blockFailure];
}

-(void)sendMessage:(MDMessage *)message
           success:(void (^)(MDMessage *))success
           failure:(void (^)(NSError *error))failure
{
    void (^blockSuccess)(AFHTTPRequestOperation *, id) = ^(AFHTTPRequestOperation *operation, id JSON) {
        success([MDMessage messageWithJSON:JSON]);
    };
    
    void (^blockFailure)(AFHTTPRequestOperation *, NSError *) = ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self printError:error];
        if (nil != failure)
            failure(error);
    };
    
    NSMutableDictionary *dictionaryMessage = [message valueDictionary];
    [dictionaryMessage setValue:self.user.accessToken forKey:@"access_token"];
    
    [[AFMDClient sharedClient] postPath:@"activity/"
                             parameters:dictionaryMessage
                                success:blockSuccess
                                failure:blockFailure];
}

-(void)messagesWithActivity:(MDActivity *)activity
                    success:(void (^)(NSArray *))success
                    failure:(void (^)(NSError *error))failure
{
    
}

-(void)sendChat:(MDChat *)chat
        success:(void (^)(MDChat *))success
        failure:(void (^)(NSError *))failure
{
    NSDictionary *chatDictionary;
    chatDictionary = [chat dictionaryForAPIWithAccessToken:self.user.accessToken];
    [[AFMDClient sharedClient] postPath:@"chat/"
                             parameters:chatDictionary
                                success:^(AFHTTPRequestOperation *operation,
                                          id JSON)
    {
        success([MDChat chatWithJSON:JSON]);
    }
                                failure:^(AFHTTPRequestOperation *operation,
                                          NSError *error)
    {
        [self printError:error];
        if (nil != failure)
            failure(error);
    }];
}

+(void)registerUser:(MDUser *)user
            success:(void (^)(MDUser *user, MDHTTPAPI *api))success
            failure:(void (^)(NSError *error))failure
{
    static NSString *url = @"https://himaiduo.com/api/";
    AFHTTPClient *client = [[AFHTTPClient alloc]
                            initWithBaseURL:[NSURL URLWithString:url]];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          user.username, @"username",
                          user.password, @"password",
                          nil];
    NSMutableURLRequest *request = [client requestWithMethod:@"POST"
                                                        path:@"user/"
                                                  parameters:data];
    
    void (^blockSuccess)(NSURLRequest *, NSHTTPURLResponse *, id) =
    ^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [MDHTTPAPI login:user success:^(MDUser *user, MDHTTPAPI *api) {
            success(user, api);
        } failure:^(NSError *error) {
            failure(error);
        }];
    };
    void (^blockFailure)(NSURLRequest *, NSHTTPURLResponse *, NSError *, id) =
    ^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error,
      id JSON) {
        if (400 == [response statusCode]) {
            [MDHTTPAPI login:user success:^(MDUser *user, MDHTTPAPI *api) {
                success(user, api);
            } failure:^(NSError *error2) {
                failure(error2);
            }];
            return;
        }
        if (nil != failure)
            failure(error);
    };
    
    AFJSONRequestOperation *operation;
    operation = [AFJSONRequestOperation
                 JSONRequestOperationWithRequest:request
                 success:blockSuccess
                 failure:blockFailure];
    [operation start];
}

+(void)login:(MDUser *)user
    success:(void (^)(MDUser *user, MDHTTPAPI *api))success
    failure:(void (^)(NSError *error))failure
{
    
    NSDictionary *dicParams = [NSDictionary dictionaryWithObjectsAndKeys:
                          user.username, @"username",
                          user.password, @"password",
                          @"password", @"grant_type",
                          @"", @"scope",
                          @"104c03b3103e4d5e96d042330f6dd0c8", @"client_id",
                          user.deviceToken, @"device_token",
                          nil];
    [[AFMDClient sharedClient] postPath:@"authentication/" parameters:dicParams success:^(AFHTTPRequestOperation *operation, id JSON) {
        user.accessToken = [NSString stringWithFormat:@"%@",
                             [JSON objectForKey:@"access_token"]];
        user.refreshToken = [NSString stringWithFormat:@"%@",
                              [JSON objectForKey:@"refresh_token"]];
        MDHTTPAPI *api = [[MDHTTPAPI alloc] initWithUser:user];
        success(user, api);
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (nil != failure)
            failure(error);
    }];
}

+(MDHTTPAPI *)MDHTTPAPIWithToken:(MDUser *)user
{
    return [[MDHTTPAPI alloc] initWithUser:user];
}

-(void)printError:(NSError *)error
{
    [error.userInfo
     enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
         NSLog(@"key:%@\nvalue:%@\n", key, obj);
     }];
}
@end
