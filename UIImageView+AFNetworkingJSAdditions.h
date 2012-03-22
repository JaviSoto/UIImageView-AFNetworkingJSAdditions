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


@interface UIImageView (AFNetworkingJSAdditions)

@property (nonatomic, readonly) NSURL *imageURL;

- (void)setImageWithURLRequest:(NSURLRequest *)urlRequest
              placeholderImage:(UIImage *)placeholderImage
                        fadeIn:(BOOL)fadeIn
                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                 fadeIn:(BOOL)fadeIn
                success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image))success
                failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error))failure;

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                 fadeIn:(BOOL)fadeIn
               finished:(void (^)(UIImage *image))finished;

- (void)setImageWithURL:(NSURL *)url
                 fadeIn:(BOOL)fadeIn
               finished:(void (^)(UIImage *image))finished;

- (void)setImageWithURL:(NSURL *)url
               finished:(void (^)(UIImage *image))finished;

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                 fadeIn:(BOOL)fadeIn;

- (void)setImageWithURL:(NSURL *)url
                 fadeIn:(BOOL)fadeIn;

- (void)setImageWithURL:(NSURL *)url;

@end
