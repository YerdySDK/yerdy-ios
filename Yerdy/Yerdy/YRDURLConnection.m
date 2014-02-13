//
//  YRDURLConnection.m
//  Yerdy
//
//  Created by Darren Clark on 2014-02-10.
//  Copyright (c) 2014 Yerdy. All rights reserved.
//

#import "YRDURLConnection.h"
#import "YRDConstants.h"
#import "YRDLog.h"
#import "YRDResponseHandler.h"


@interface YRDURLConnection () <NSURLConnectionDataDelegate>
{
	NSURLConnection *_connection;
	NSURLResponse *_response;
	NSMutableData *_responseBody;
	NSError *_error;
	
	YRDRequest *_request;
	YRDURLConnectionCompletionHandler _completionHandler;
}
@end


@implementation YRDURLConnection

+ (NSOperationQueue *)delegateOperationQueue
{
	static NSOperationQueue *queue = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		queue = [[NSOperationQueue alloc] init];
		queue.name = @"com.yerdy.YRDURLConnection";
	});
	return queue;
}

+ (NSMutableSet *)openConnections
{
	static NSMutableSet *set = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		set = [[NSMutableSet alloc] init];
	});
	return set;
}

+ (instancetype)sendRequest:(YRDRequest *)request
		  completionHandler:(YRDURLConnectionCompletionHandler)completionHandler
{
	YRDURLConnection *conn = [[self alloc] initWithRequest:request completionHandler:completionHandler];
	[conn send];
	return conn;
}

- (id)initWithRequest:(YRDRequest *)request completionHandler:(YRDURLConnectionCompletionHandler)completionHandler
{
	self = [super init];
	if (!self)
		return nil;
	
	NSAssert(request != nil, @"'request' must not be nil");
	
	_request = request;
	_completionHandler = completionHandler;
	
	return self;
}

- (void)send
{
	NSAssert(_connection == nil, @"Attempting to send multiple requests using the same YDURLConnection");
	
	// When assertions are disabled, we should still exit early
	if (_connection != nil)
		return;
	
	NSMutableSet *openConnections = [[self class] openConnections];
	@synchronized (openConnections) {
		[openConnections addObject:self];
	}
	
	YRDDebug(@"Sending request: %@", _request.URL);
	
	NSURLRequest *request = _request.urlRequest;
	
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
	[_connection setDelegateQueue:[[self class] delegateOperationQueue]];
	[_connection start];
}

- (void)finishRequestWithResponse:(id)response error:(NSError *)error
{
	if (response) {
		YRDDebug(@"Request successful: %@", _request.URL);
	} else {
		YRDDebug(@"Request failed: %@: %@", _request.URL, error);
	}
	
	if (_completionHandler) {
		dispatch_async(dispatch_get_main_queue(), ^{
			_completionHandler(response, error);
		});
	}
	
	NSMutableSet *openConnections = [[self class] openConnections];
	@synchronized (openConnections) {
		[openConnections removeObject:self];
	}
}

- (void)didFinishLoading
{
	YRDURLConnectionCompletionHandler handler = _completionHandler;
	if (handler == nil) handler = ^(id response, NSError *error) {};
	
	if (_error != nil) {
		[self finishRequestWithResponse:nil error:_error];
		return;
	}
	
	if ([_response isKindOfClass:[NSHTTPURLResponse class]]) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)_response;
		if (httpResponse.statusCode >= 400) {
			NSDictionary *userInfo = @{
				NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:httpResponse.statusCode]
			};
			NSError *error = [NSError errorWithDomain:YRDErrorDomain code:httpResponse.statusCode userInfo:userInfo];
			[self finishRequestWithResponse:nil error:error];
			return;
		}
	}
	
	NSError *processingError;
	id response = [_request.responseHandler processResponse:_response
													   data:_responseBody
													  error:&processingError];
	if (processingError) response = nil;
	
	[self finishRequestWithResponse:response error:processingError];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	_response = response;
	
	// attempt to create correctly sized NSMutableData
	long long expectedLength = response.expectedContentLength;
	if (expectedLength > 0 && expectedLength < NSIntegerMax)
		_responseBody = [[NSMutableData alloc] initWithCapacity:(NSUInteger)expectedLength];
	else
		_responseBody = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[_responseBody appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[self didFinishLoading];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	_error = error;
	[self didFinishLoading];
}

@end
