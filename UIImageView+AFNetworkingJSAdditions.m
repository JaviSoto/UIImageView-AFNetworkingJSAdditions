/* 
 Copyright 2012 Javier Soto (ios@javisoto.es)
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License. 
 */

#import "UIImageView+AFNetworkingJSAdditions.h"

#import "UIImageView+AFNetworking.h"

#import <objc/runtime.h>

#define kImageFadeInAnimationDuration 0.2
#define kDefaultImageDownloadTimeut 30.0

@interface UIImageView()
@property (nonatomic, copy) NSURL *imageURL;

+ (void)swizzleSelector:(SEL)orig ofClass:(Class)c withSelector:(SEL)newSelector;
@end

@implementation UIImageView (AFNetworkingJSAdditions)

static char imageURLKey;

- (NSURL *)imageURL
{
    return objc_getAssociatedObject(self, &imageURLKey);
}

- (void)setImageURL:(NSURL *)imageURL
{
    objc_setAssociatedObject(self, &imageURLKey, imageURL, OBJC_ASSOCIATION_COPY);
}

+ (void)load
{
    [self swizzleSelector:@selector(dealloc) ofClass:[UIImageView class] withSelector:@selector(JSImageViewAdditionsDealloc)];
    [self swizzleSelector:@selector(setImageWithURL:placeholderImage:) ofClass:[UIImageView class] withSelector:@selector(JSSetImageWithURL:placeholderImage:)];
    [self swizzleSelector:@selector(setImageWithURL:) ofClass:[UIImageView class] withSelector:@selector(setImageWithURL:)];
}

- (void)JSSetImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    [self setImageWithURL:url placeholderImage:placeholder fadeIn:NO];
}

- (void)setImageWithURL:(NSURL *)url
{
    [self setImageWithURL:url fadeIn:NO];
}

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest placeholderImage:(UIImage *)placeholderImage fadeIn:(BOOL)fadeIn success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    NSURL *newImageURL = urlRequest.URL;
    
    if (![self.imageURL isEqual:newImageURL]) // if it's a different URL
    {       
        if (urlRequest.URL)
        {
            self.imageURL = nil;
            
            [self setImageWithURLRequest:urlRequest placeholderImage:placeholderImage success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                
                self.imageURL = newImageURL;
                
				BOOL cachedImage = !request && !response;
				
                BOOL shouldFadeIn = fadeIn && !cachedImage;
                
                if (shouldFadeIn)
                {
                    self.alpha = 0.0f;
                    [UIView animateWithDuration:kImageFadeInAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
                        self.alpha = 1.0f;
                    } completion:NULL];
                }
                
                if (success)
                {
                    success(request, response, image);
                }
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                NSLog(@"Error loading image with URL: %@", urlRequest.URL);
                self.imageURL = nil;
                
                self.alpha = 1.0f;
                if (failure)
                {
                    failure(request, response, error);
                }
            }];
        }
        else
        {
            self.imageURL = nil;
            self.image = placeholderImage;
            
            if (failure)
            {
                failure(nil, nil, nil);
            }
        }
    }
    else
    {
        if (success)
        {
            success(nil, nil, self.image);
        }
    }
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage fadeIn:(BOOL)fadeIn success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure
{
    NSMutableURLRequest *imageDownloadRequest = nil;
    
    if (url)
    {
        imageDownloadRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:kDefaultImageDownloadTimeut];
        [imageDownloadRequest setHTTPShouldHandleCookies:NO];
        [imageDownloadRequest setHTTPShouldUsePipelining:YES];
    }
    
    [self setImageWithURLRequest:imageDownloadRequest placeholderImage:placeholderImage fadeIn:fadeIn success:success failure:failure];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage fadeIn:(BOOL)fadeIn finished:(void (^)(UIImage *image))finished
{
    [self setImageWithURL:url placeholderImage:placeholderImage fadeIn:fadeIn success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (finished)
        {
            finished(image);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        if (finished)
        {
            finished(nil);
        }
    }];
}

- (void)setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholderImage fadeIn:(BOOL)fadeIn
{    
    [self setImageWithURL:url placeholderImage:placeholderImage fadeIn:fadeIn success:NULL failure:NULL];   
}

- (void)setImageWithURL:(NSURL *)url fadeIn:(BOOL)fadeIn finished:(void (^)(UIImage *image))finished
{
    [self setImageWithURL:url placeholderImage:nil fadeIn:fadeIn finished:finished];
}

- (void)setImageWithURL:(NSURL *)url finished:(void (^)(UIImage *image))finished
{
    [self setImageWithURL:url placeholderImage:nil fadeIn:NO finished:finished];
}

- (void)setImageWithURL:(NSURL *)url fadeIn:(BOOL)fadeIn
{
    [self setImageWithURL:url placeholderImage:nil fadeIn:fadeIn finished:NULL];
}

- (void)JSImageViewAdditionsDealloc
{    
    [self JSImageViewAdditionsDealloc];
}

/* Swizzling */

+ (void)swizzleSelector:(SEL)orig ofClass:(Class)c withSelector:(SEL)newSelector;
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, newSelector);
    
    if (class_addMethod(c, orig, method_getImplementation(newMethod),
                        method_getTypeEncoding(newMethod)))
    {
        class_replaceMethod(c, newSelector, method_getImplementation(origMethod),
                            method_getTypeEncoding(origMethod));
    }
    else
    {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@end
