//
//  oss_ios_demo.m
//  oss_ios_demo
//
//  Created by mr.scorpion on 3/16/16.
//  Copyright (c) 2016 mr.scorpion. All rights reserved.
//

#import "AliyunOSSDemo.h"
#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>

NSString * const AccessKey = @"GGSjqzjHLZ09t9aU";
NSString * const SecretKey = @"EhJbZuYeQUQ0yDav3Gh97rROtzfh1n";
NSString * const EndPoint = @"这里去掉了，填自己公司的"; // IMG
NSString * const bucketName = @"这里去掉了，填自己公司的"; // IMG
//NSString * const EndPoint = @"这里去掉了，填自己公司的"; // VIDEO
//NSString * const bucketName = @"这里去掉了，填自己公司的"; // VIDEO
NSString * const multipartUploadKey = @"multipartUploadObject";

OSSClient * client;
static dispatch_queue_t queue4demo;

@implementation AliyunOSSDemo

- (void)runDemo {
    [OSSLog enableLog];
//    [self initLocalFile];
//    [self initOSSClient];


    /*************** 以下每个方法调用代表一个功能的演示，取消注释即可运行 ***************/

    // 罗列Bucket中的Object
//     [self listObjectsInBucket];

    // 异步上传文件
//     [self uploadObjectAsync];

    // 同步上传文件
//     [self uploadObjectSync];

    // 异步下载文件
    // [self downloadObjectAsync];

    // 同步下载文件
    // [self downloadObjectSync];

    // 复制文件
//    [self copyObjectAsync];

    // 签名Obejct的URL以授权第三方访问
    // [self signAccessObjectURL];

    // 分块上传的完整流程
    // [self multipartUpload];

    // 只获取Object的Meta信息
    // [self headObject];

    // 罗列已经上传的分块
    // [self listParts];

    // 自行管理UploadId的分块上传
    // [self resumableUpload];

#pragma mark - 成功上传
    /************* MY TEST *************/
    [self myTest];

/************* 旧版本风格接口，不再建议使用 *************/

    // [self oldPutObjectStyle];

    // [self oldGetObjectStyle];

    // [self oldResumableUploadStyle];
}

/*******/
- (void)myTest
{
    // 1.初始化OSSClient
    NSString *endpoint = EndPoint; //@"http://oss-cn-hangzhou.aliyuncs.com";
    // 明文设置secret的方式建议只在测试时使用，更多鉴权模式参考后面链接给出的官网完整文档的`访问控制`章节
    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKey secretKey:SecretKey];
    client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    /*// 2.上传文件
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = bucketName;
    put.objectKey = @"images2";
    // test Data
    put.uploadingData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"1.png" ofType:nil]]; // [NSData dataWithContentsOfURL:[NSURL fileURLWithPath:[[self getDocumentDirectory] stringByAppendingPathComponent:@"file1m"]]]; // 直接上传NSData
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    OSSTask * putTask = [client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"upload object success!");
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
    // 可以等待任务完成
    // [putTask waitUntilFinished];*/
    
    // 3.获取所有路径
    // 罗列Bucket中的Object
//    [self listObjectsInBucket];
}

/******/


// get local file dir which is readwrite able
- (NSString *)getDocumentDirectory {
    NSString * path = NSHomeDirectory();
    NSLog(@"NSHomeDirectory:%@",path);
    NSString * userName = NSUserName();
    NSString * rootPath = NSHomeDirectoryForUser(userName);
    NSLog(@"NSHomeDirectoryForUser:%@",rootPath);
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

// create some random file for demo cases
- (void)initLocalFile {
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * mainDir = [self getDocumentDirectory];

    NSArray * fileNameArray = @[@"file1k", @"file10k", @"file100k", @"file1m", @"file10m", @"fileDirA/", @"fileDirB/"];
    NSArray * fileSizeArray = @[@1024, @10240, @102400, @1024000, @10240000, @1024, @1024];

    NSMutableData * basePart = [NSMutableData dataWithCapacity:1024];
    for (int i = 0; i < 1024/4; i++) {
        u_int32_t randomBit = arc4random();
        [basePart appendBytes:(void*)&randomBit length:4];
    }

    for (int i = 0; i < [fileNameArray count]; i++) {
        NSString * name = [fileNameArray objectAtIndex:i];
        long size = [[fileSizeArray objectAtIndex:i] longValue];
        NSString * newFilePath = [mainDir stringByAppendingPathComponent:name];
        if ([fm fileExistsAtPath:newFilePath]) {
            [fm removeItemAtPath:newFilePath error:nil];
        }
        [fm createFileAtPath:newFilePath contents:nil attributes:nil];
        NSFileHandle * f = [NSFileHandle fileHandleForWritingAtPath:newFilePath];
        for (int k = 0; k < size/1024; k++) {
            [f writeData:basePart];
        }
        [f closeFile];
    }
    NSLog(@"main bundle: %@", mainDir);
}

- (void)initOSSClient {

    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKey
                                                                                                            secretKey:SecretKey];

    // 自实现签名，可以用本地签名也可以远程加签
    id<OSSCredentialProvider> credential1 = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
        NSString *signature = [OSSUtil calBase64Sha1WithData:contentToSign withSecret:SecretKey];
        if (signature != nil) {
            *error = nil;
        } else {
            // construct error object
            *error = [NSError errorWithDomain:@"Some Error" code:OSSClientErrorCodeSignFailed userInfo:nil];
            return nil;
        }
        return [NSString stringWithFormat:@"OSS %@:%@", AccessKey, signature];
    }];

    // Federation鉴权，建议通过访问远程业务服务器获取签名
    // 假设访问业务服务器的获取token服务时，返回的数据格式如下：
//{"accessKeyId":"STS.iA645eTOXEqP3cg3VeHf",
//"accessKeySecret":"rV3VQrpFQ4BsyHSAvi5NVLpPIVffDJv4LojUBZCf",
//"expiration":"2016-11-03T09:52:59Z[;",
//"federatedUser":"335450541622398178:alice-001",
//"requestId":"C0E01B94-332E-4582-87F9-B857C807EE52",
//"securityToken":"CAES7QIIARKAAZPlqaN9ILiQZPS+JDkS/GSZN45RLx4YS/p3OgaUC+oJl3XSlbJ7StKpQp1Q3KtZVCeAKAYY6HYSFOa6rU0bltFXAPyW+jvlijGKLezJs0AcIvP5a4ki6yHWovkbPYNnFSOhOmCGMmXKIkhrRSHMGYJRj8AIUvICAbDhzryeNHvUGhhTVFMuaUE2NDVlVE9YRXFQM2NnM1ZlSGYiEjMzNTQ1MDU0MTUyMjM5ODE3OCoJYWxpY2UtMDAxMOG/g7v6KToGUnNhTUQ1QloKATEaVQoFQWxsb3cSHwoMQWN0aW9uRXF1YWxzEgZBY3Rpb24aBwoFb3NzOioSKwoOUmVzb3VyY2VFcXVhbHMSCFJlc291cmNlGg8KDWFjczpvc3M6KjoqOipKEDEwNzI2MDc4NDc4NjM4ODhSAFoPQXNzdW1lZFJvbGVVc2VyYABqEjMzNTQ1MDU0MTUyMjM5ODE3OHIHeHljLTAwMQ=="}
    id<OSSCredentialProvider> credential2 = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken * {
//        NSURL * url = [NSURL URLWithString:@"http://localhost:8080/distribute-token.json"];
//        NSURLRequest * request = [NSURLRequest requestWithURL:url];
//        OSSTaskCompletionSource * tcs = [OSSTaskCompletionSource taskCompletionSource];
//        NSURLSession * session = [NSURLSession sharedSession];
//        NSURLSessionTask * sessionTask = [session dataTaskWithRequest:request
//                                                    completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//                                                        if (error) {
//                                                            [tcs setError:error];
//                                                            return;
//                                                        }
//                                                        [tcs setResult:data];
//                                                    }];
//        [sessionTask resume];
//        [tcs.task waitUntilFinished];
//        if (tcs.task.error) {
//            NSLog(@"get token error: %@", tcs.task.error);
//            return nil;
//        } else {
        
//        NSString *json = @"{\"accessKeyId\":\"STS.iA645eTOXEqP3cg3VeHf\",\n\"accessKeySecret\":\"rV3VQrpFQ4BsyHSAvi5NVLpPIVffDJv4LojUBZCf\",\n\"expiration\":\"2016-11-03T09:52:59Z[;\",\n\"federatedUser\":\"335450541622398178:alice-001\",\n\"requestId\":\"C0E01B94-332E-4582-87F9-B857C807EE52\",\n\"securityToken\":\"CAES7QIIARKAAZPlqaN9ILiQZPS+JDkS/GSZN45RLx4YS/p3OgaUC+oJl3XSlbJ7StKpQp1Q3KtZVCeAKAYY6HYSFOa6rU0bltFXAPyW+jvlijGKLezJs0AcIvP5a4ki6yHWovkbPYNnFSOhOmCGMmXKIkhrRSHMGYJRj8AIUvICAbDhzryeNHvUGhhTVFMuaUE2NDVlVE9YRXFQM2NnM1ZlSGYiEjMzNTQ1MDU0MTUyMjM5ODE3OCoJYWxpY2UtMDAxMOG/g7v6KToGUnNhTUQ1QloKATEaVQoFQWxsb3cSHwoMQWN0aW9uRXF1YWxzEgZBY3Rpb24aBwoFb3NzOioSKwoOUmVzb3VyY2VFcXVhbHMSCFJlc291cmNlGg8KDWFjczpvc3M6KjoqOipKEDEwNzI2MDc4NDc4NjM4ODhSAFoPQXNzdW1lZFJvbGVVc2VyYABqEjMzNTQ1MDU0MTUyMjM5ODE3OHIHeHljLTAwMQ==\"}";
        
////            NSDictionary * object = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
//                                                                    options:kNilOptions
//                                                                      error:nil];
            OSSFederationToken * token = [OSSFederationToken new];
        token.tAccessKey = AccessKey;//@"STS.iA645eTOXEqP3cg3VeHf";//[object objectForKey:@"accessKeyId"];
        token.tSecretKey = SecretKey;//@"rV3VQrpFQ4BsyHSAvi5NVLpPIVffDJv4LojUBZCf";//[object objectForKey:@"accessKeySecret"];
            token.tToken = @"CAES7QIIARKAAZPlqaN9ILiQZPS+JDkS/GSZN45RLx4YS/p3OgaUC+oJl3XSlbJ7StKpQp1Q3KtZVCeAKAYY6HYSFOa6rU0bltFXAPyW+jvlijGKLezJs0AcIvP5a4ki6yHWovkbPYNnFSOhOmCGMmXKIkhrRSHMGYJRj8AIUvICAbDhzryeNHvUGhhTVFMuaUE2NDVlVE9YRXFQM2NnM1ZlSGYiEjMzNTQ1MDU0MTUyMjM5ODE3OCoJYWxpY2UtMDAxMOG/g7v6KToGUnNhTUQ1QloKATEaVQoFQWxsb3cSHwoMQWN0aW9uRXF1YWxzEgZBY3Rpb24aBwoFb3NzOioSKwoOUmVzb3VyY2VFcXVhbHMSCFJlc291cmNlGg8KDWFjczpvc3M6KjoqOipKEDEwNzI2MDc4NDc4NjM4ODhSAFoPQXNzdW1lZFJvbGVVc2VyYABqEjMzNTQ1MDU0MTUyMjM5ODE3OHIHeHljLTAwMQ==";//[object objectForKey:@"securityToken"];
            token.expirationTimeInGMTFormat = @"2016-11-03T09:52:59Z";//[object objectForKey:@"expiration"];
            NSLog(@"get token: %@", token);
            return token;
//        }
    }];


    OSSClientConfiguration * conf = [OSSClientConfiguration new];
    conf.maxRetryCount = 2;
    conf.timeoutIntervalForRequest = 30;
    conf.timeoutIntervalForResource = 24 * 60 * 60;

    client = [[OSSClient alloc] initWithEndpoint:EndPoint credentialProvider:credential2 clientConfiguration:conf];
}

#pragma mark work with normal interface

- (void)createBucket {
    OSSCreateBucketRequest * create = [OSSCreateBucketRequest new];
    create.bucketName = bucketName;
    create.xOssACL = @"public-read";
    create.location = @"oss-cn-hangzhou";

    OSSTask * createTask = [client createBucket:create];

    [createTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"create bucket success!");
        } else {
            NSLog(@"create bucket failed, error: %@", task.error);
        }
        return nil;
    }];
}

- (void)deleteBucket {
    OSSDeleteBucketRequest * delete = [OSSDeleteBucketRequest new];
    delete.bucketName = bucketName;

    OSSTask * deleteTask = [client deleteBucket:delete];

    [deleteTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"delete bucket success!");
        } else {
            NSLog(@"delete bucket failed, error: %@", task.error);
        }
        return nil;
    }];
}

- (void)listObjectsInBucket {
    OSSGetBucketRequest * getBucket = [OSSGetBucketRequest new];
    getBucket.bucketName = bucketName; //@"android-test";
//    getBucket.delimiter = @"";
//    getBucket.prefix = @"iOS_";

    OSSTask * getBucketTask = [client getBucket:getBucket];
    [getBucketTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            OSSGetBucketResult * result = task.result;
            NSLog(@"get bucket success!");
            for (NSDictionary * objectInfo in result.contents) {
                NSLog(@"list object: %@", objectInfo);
            }
        } else {
            NSLog(@"get bucket failed, error: %@", task.error);
        }
        return nil;
    }];
}

// 异步上传
- (void)uploadObjectAsync {
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];

    // required fields
    put.bucketName = bucketName; //@"android-test";
    put.objectKey =  @"image1";//@"file1m";
    NSString * docDir = [self getDocumentDirectory];
    put.uploadingFileURL = [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent:@"image1"]];

    // optional fields
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    // 设置文件类型
    put.contentType = @"image/png"; // @"";
//    put.contentMd5 = @"";
    // 指定该Object被下载时的内容编码格式
    put.contentEncoding = @"utf-8"; //@"";
    // 指定该Object被下载时的名称
    put.contentDisposition = @"attachment;filename=oss_download.jpg"; //@"";

    OSSTask * putTask = [client putObject:put];

    [putTask continueWithBlock:^id(OSSTask *task) {
        NSLog(@"objectKey: %@", put.objectKey);
        if (!task.error) {
            NSLog(@"upload object success!");
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];
}

// 同步上传
- (void)uploadObjectSync {
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];

    // required fields
    put.bucketName = @"iOS-test";
    put.objectKey = @"image1";
    NSString * docDir = [[NSBundle mainBundle] pathForResource:@"1.png" ofType:nil]; // [self getDocumentDirectory];
    put.uploadingFileURL = [NSURL fileURLWithPath:docDir];

    // optional fields
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    put.contentType = @"image/png";
//    put.contentMd5 = @"";
    put.contentEncoding = @"utf-8";
    put.contentDisposition = @"attachment;filename=oss_download.jpg";

    OSSTask * putTask = [client putObject:put];

    [putTask waitUntilFinished]; // 阻塞直到上传完成

    if (!putTask.error) {
        NSLog(@"upload object success!");
    } else {
        NSLog(@"upload object failed, error: %@" , putTask.error);
    }
}

// 追加上传

- (void)appendObject {
    OSSAppendObjectRequest * append = [OSSAppendObjectRequest new];

    // 必填字段
    append.bucketName = @"android-test";
    append.objectKey = @"file1m";
    append.appendPosition = 0; // 指定从何处进行追加
    NSString * docDir = [self getDocumentDirectory];
    append.uploadingFileURL = [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent:@"file1m"]];

    // 可选字段
    append.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    // append.contentType = @"";
    // append.contentMd5 = @"";
    // append.contentEncoding = @"";
    // append.contentDisposition = @"";

    OSSTask * appendTask = [client appendObject:append];

    [appendTask continueWithBlock:^id(OSSTask *task) {
        NSLog(@"objectKey: %@", append.objectKey);
        if (!task.error) {
            NSLog(@"append object success!");
            OSSAppendObjectResult * result = task.result;
            NSString * etag = result.eTag;
            long nextPosition = result.xOssNextAppendPosition;
        } else {
            NSLog(@"append object failed, error: %@" , task.error);
        }
        return nil;
    }];
}

// 异步下载
- (void)downloadObjectAsync {
    OSSGetObjectRequest * request = [OSSGetObjectRequest new];
    // required
    request.bucketName = @"android-test";
    request.objectKey = @"file1m";

    //optional
    request.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"%lld, %lld, %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    };
    // NSString * docDir = [self getDocumentDirectory];
    // request.downloadToFileURL = [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent:@"downloadfile"]];

    OSSTask * getTask = [client getObject:request];

    [getTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"download object success!");
            OSSGetObjectResult * getResult = task.result;
            NSLog(@"download dota length: %lu", [getResult.downloadedData length]);
        } else {
            NSLog(@"download object failed, error: %@" ,task.error);
        }
        return nil;
    }];
}

// 同步下载
- (void)downloadObjectSync {
    OSSGetObjectRequest * request = [OSSGetObjectRequest new];
    // required
    request.bucketName = @"android-test";
    request.objectKey = @"file1m";

    //optional
    request.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
        NSLog(@"%lld, %lld, %lld", bytesWritten, totalBytesWritten, totalBytesExpectedToWrite);
    };
    // NSString * docDir = [self getDocumentDirectory];
    // request.downloadToFileURL = [NSURL fileURLWithPath:[docDir stringByAppendingPathComponent:@"downloadfile"]];

    OSSTask * getTask = [client getObject:request];

    [getTask waitUntilFinished];

    if (!getTask.error) {
        OSSGetObjectResult * result = getTask.result;
        NSLog(@"download data length: %lu", [result.downloadedData length]);
    } else {
        NSLog(@"download data error: %@", getTask.error);
    }
}

// 获取meta
- (void)headObject {
    OSSHeadObjectRequest * head = [OSSHeadObjectRequest new];
    head.bucketName = @"android-test";
    head.objectKey = @"file1m";

    OSSTask * headTask = [client headObject:head];

    [headTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            OSSHeadObjectResult * headResult = task.result;
            NSLog(@"all response header: %@", headResult.httpResponseHeaderFields);

            // some object properties include the 'x-oss-meta-*'s
            NSLog(@"head object result: %@", headResult.objectMeta);
        } else {
            NSLog(@"head object error: %@", task.error);
        }
        return nil;
    }];
}

// 删除Object
- (void)deleteObject {
    OSSDeleteObjectRequest * delete = [OSSDeleteObjectRequest new];
    delete.bucketName = @"android-test";
    delete.objectKey = @"file1m";

    OSSTask * deleteTask = [client deleteObject:delete];

    [deleteTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"delete success !");
        } else {
            NSLog(@"delete erorr, error: %@", task.error);
        }
        return nil;
    }];
}

// 复制Object
- (void)copyObjectAsync {
    OSSCopyObjectRequest * copy = [OSSCopyObjectRequest new];
    copy.bucketName = @"android-test"; // 复制到哪个bucket
    copy.objectKey = @"file_copy_to"; // 复制为哪个object
    copy.sourceCopyFrom = [NSString stringWithFormat:@"/%@/%@", @"android-test", @"file1m"]; // 从哪里复制

    OSSTask * copyTask = [client copyObject:copy];

    [copyTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"copy success!");
        } else {
            NSLog(@"copy error, error: %@", task.error);
        }
        return nil;
    }];
}

// 签名URL授予第三方访问
- (void)signAccessObjectURL {
    NSString * constrainURL = nil;
    NSString * publicURL = nil;

    // sign constrain url
    OSSTask * task = [client presignConstrainURLWithBucketName:@"<bucket name>"
                                                 withObjectKey:@"<object key>"
                                        withExpirationInterval:60 * 30];
    if (!task.error) {
        constrainURL = task.result;
    } else {
        NSLog(@"error: %@", task.error);
    }

    // sign public url
    task = [client presignPublicURLWithBucketName:@"<bucket name>"
                                    withObjectKey:@"<object key>"];
    if (!task.error) {
        publicURL = task.result;
    } else {
        NSLog(@"sign url error: %@", task.error);
    }
}

// 分块上传
- (void)multipartUpload {

    __block NSString * uploadId = nil;
    __block NSMutableArray * partInfos = [NSMutableArray new];

    NSString * uploadToBucket = @"android-test";
    NSString * uploadObjectkey = @"file3m";

    OSSInitMultipartUploadRequest * init = [OSSInitMultipartUploadRequest new];
    init.bucketName = uploadToBucket;
    init.objectKey = uploadObjectkey;
    init.contentType = @"application/octet-stream";
    init.objectMeta = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"value1", @"x-oss-meta-name1", nil];

    OSSTask * initTask = [client multipartUploadInit:init];

    [initTask waitUntilFinished];

    if (!initTask.error) {
        OSSInitMultipartUploadResult * result = initTask.result;
        uploadId = result.uploadId;
        NSLog(@"init multipart upload success: %@", result.uploadId);
    } else {
        NSLog(@"multipart upload failed, error: %@", initTask.error);
        return;
    }

    for (int i = 1; i <= 3; i++) {
        OSSUploadPartRequest * uploadPart = [OSSUploadPartRequest new];
        uploadPart.bucketName = uploadToBucket;
        uploadPart.objectkey = uploadObjectkey;
        uploadPart.uploadId = uploadId;
        uploadPart.partNumber = i; // part number start from 1

        NSString * docDir = [self getDocumentDirectory];
        uploadPart.uploadPartFileURL = [NSURL URLWithString:[docDir stringByAppendingPathComponent:@"file1m"]];

        OSSTask * uploadPartTask = [client uploadPart:uploadPart];

        [uploadPartTask waitUntilFinished];

        if (!uploadPartTask.error) {
            OSSUploadPartResult * result = uploadPartTask.result;
            uint64_t fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:uploadPart.uploadPartFileURL.absoluteString error:nil] fileSize];
            [partInfos addObject:[OSSPartInfo partInfoWithPartNum:i eTag:result.eTag size:fileSize]];
        } else {
            NSLog(@"upload part error: %@", uploadPartTask.error);
            return;
        }
    }

    OSSCompleteMultipartUploadRequest * complete = [OSSCompleteMultipartUploadRequest new];
    complete.bucketName = uploadToBucket;
    complete.objectKey = uploadObjectkey;
    complete.uploadId = uploadId;
    complete.partInfos = partInfos;

    OSSTask * completeTask = [client completeMultipartUpload:complete];

    [completeTask waitUntilFinished];

    if (!completeTask.error) {
        NSLog(@"multipart upload success!");
    } else {
        NSLog(@"multipart upload failed, error: %@", completeTask.error);
        return;
    }
}

// 罗列分块
- (void)listParts {
    OSSListPartsRequest * listParts = [OSSListPartsRequest new];
    listParts.bucketName = @"android-test";
    listParts.objectKey = @"file3m";
    listParts.uploadId = @"265B84D863B64C80BA552959B8B207F0";

    OSSTask * listPartTask = [client listParts:listParts];

    [listPartTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"list part result success!");
            OSSListPartsResult * listPartResult = task.result;
            for (NSDictionary * partInfo in listPartResult.parts) {
                NSLog(@"each part: %@", partInfo);
            }
        } else {
            NSLog(@"list part result error: %@", task.error);
        }
        return nil;
    }];
}

// 断点续传
- (void)resumableUpload {
    __block NSString * recordKey;

    NSString * docDir = [self getDocumentDirectory];
    NSString * filePath = [docDir stringByAppendingPathComponent:@"file1m"];
    NSString * bucketName = @"android-test";
    NSString * objectKey = @"uploadKey";


    [[[[[[OSSTask taskWithResult:nil] continueWithBlock:^id(OSSTask *task) {
        // 为该文件构造一个唯一的记录键
        NSURL * fileURL = [NSURL fileURLWithPath:filePath];
        NSDate * lastModified;
        NSError * error;
        [fileURL getResourceValue:&lastModified forKey:NSURLContentModificationDateKey error:&error];
        if (error) {
            return [OSSTask taskWithError:error];
        }
        recordKey = [NSString stringWithFormat:@"%@-%@-%@-%@", bucketName, objectKey, [OSSUtil getRelativePath:filePath], lastModified];
        // 通过记录键查看本地是否保存有未完成的UploadId
        NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
        return [OSSTask taskWithResult:[userDefault objectForKey:recordKey]];
    }] continueWithSuccessBlock:^id(OSSTask *task) {
        if (!task.result) {
            // 如果本地尚无记录，调用初始化UploadId接口获取
            OSSInitMultipartUploadRequest * initMultipart = [OSSInitMultipartUploadRequest new];
            initMultipart.bucketName = bucketName;
            initMultipart.objectKey = objectKey;
            initMultipart.contentType = @"application/octet-stream";
            return [client multipartUploadInit:initMultipart];
        }
        OSSLogVerbose(@"An resumable task for uploadid: %@", task.result);
        return task;
    }] continueWithSuccessBlock:^id(OSSTask *task) {
        NSString * uploadId = nil;

        if (task.error) {
            return task;
        }

        if ([task.result isKindOfClass:[OSSInitMultipartUploadResult class]]) {
            uploadId = ((OSSInitMultipartUploadResult *)task.result).uploadId;
        } else {
            uploadId = task.result;
        }

        if (!uploadId) {
            return [OSSTask taskWithError:[NSError errorWithDomain:OSSClientErrorDomain
                                                             code:OSSClientErrorCodeNilUploadid
                                                         userInfo:@{OSSErrorMessageTOKEN: @"Can't get an upload id"}]];
        }
        // 将“记录键：UploadId”持久化到本地存储
        NSUserDefaults * userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:uploadId forKey:recordKey];
        [userDefault synchronize];
        return [OSSTask taskWithResult:uploadId];
    }] continueWithSuccessBlock:^id(OSSTask *task) {
        // 持有UploadId上传文件
        OSSResumableUploadRequest * resumableUpload = [OSSResumableUploadRequest new];
        resumableUpload.bucketName = bucketName;
        resumableUpload.objectKey = objectKey;
        resumableUpload.uploadId = task.result;
        resumableUpload.uploadingFileURL = [NSURL fileURLWithPath:filePath];
        resumableUpload.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            NSLog(@"%lld %lld %lld", bytesSent, totalBytesSent, totalBytesExpectedToSend);
        };
        return [client resumableUpload:resumableUpload];
    }] continueWithBlock:^id(OSSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:OSSClientErrorDomain] && task.error.code == OSSClientErrorCodeCannotResumeUpload) {
                // 如果续传失败且无法恢复，需要删除本地记录的UploadId，然后重启任务
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:recordKey];
            }
        } else {
            NSLog(@"upload completed!");
            // 上传成功，删除本地保存的UploadId
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:recordKey];
        }
        return nil;
    }];
}

#pragma mark work with compatible interface

- (void)oldGetObjectStyle {
    OSSTaskHandler * tk = [client downloadToDataFromBucket:@"android-test"
                                                 objectKey:@"file1m"
                                               onCompleted:^(NSData * data, NSError * error) {
                                                   if (error) {
                                                       NSLog(@"download object failed, erorr: %@", error);
                                                   } else {
                                                       NSLog(@"download object success, data length: %ld", [data length]);
                                                   }
                                               } onProgress:^(float progress) {
                                                   NSLog(@"progress: %f", progress);
                                               }];

    // [tk cancel];
}

- (void)oldPutObjectStyle {

    NSString * doctDir = [self getDocumentDirectory];
    NSString * filePath = [doctDir stringByAppendingPathComponent:@"file10m"];

    NSDictionary * objectMeta = @{@"x-oss-meta-name1": @"value1"};

    OSSTaskHandler * tk = [client uploadFile:filePath
                             withContentType:@"application/octet-stream"
                              withObjectMeta:objectMeta
                                toBucketName:@"android-test"
                                 toObjectKey:@"file10m"
                                 onCompleted:^(BOOL isSuccess, NSError * error) {
                                       if (error) {
                                           NSLog(@"upload object failed, erorr: %@", error);
                                       } else {
                                           NSLog(@"upload object success!");
                                       }
                                 } onProgress:^(float progress) {
                                     NSLog(@"progress: %f", progress);
                                 }];

}

- (void)oldResumableUploadStyle {

    NSString * doctDir = [self getDocumentDirectory];
    NSString * filePath = [doctDir stringByAppendingPathComponent:@"file10m"];

    OSSTaskHandler * tk = [client resumableUploadFile:filePath
                                      withContentType:@"application/octet-stream"
                                       withObjectMeta:nil
                                         toBucketName:@"android-test"
                                          toObjectKey:@"file10m"
                                          onCompleted:^(BOOL isSuccess, NSError * error) {
                                              if (error) {
                                                  NSLog(@"resumable upload object failed, erorr: %@", error);
                                              } else {
                                                  NSLog(@"resumable upload object success!");
                                              }
                                          } onProgress:^(float progress) {
                                              NSLog(@"progress: %f", progress);
                                          }];
    [tk cancel];
}

@end
