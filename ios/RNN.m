
#import "RNN.h"
#import "RNNEventEmitter.h"

#import "RCTBridge.h"
#import "RNNSplashScreen.h"

@interface RNN()
@property RNNEventEmitter* eventEmitter;
@property (readwrite) RCTBridge* bridge;
@property (readwrite) BOOL isReadyToReceiveCommands;
@end

@implementation RNN

+(instancetype)instance
{
	static RNN *sharedInstance = nil;
	static dispatch_once_t onceToken = 0;
	dispatch_once(&onceToken,^{
		if (sharedInstance == nil)
		{
			sharedInstance = [[RNN alloc] init];
		}
	});
	
	return sharedInstance;
}

-(void)bootstrap:(NSURL *)jsCodeLocation launchOptions:(NSDictionary *)launchOptions
{
	self.eventEmitter = [RNNEventEmitter new];
	
	UIApplication.sharedApplication.delegate.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	UIApplication.sharedApplication.delegate.window.backgroundColor = [UIColor whiteColor];
	
	[RNNSplashScreen show];
	
	[self registerForJsEvents];
	// this will load the JS bundle
	self.bridge = [[RCTBridge alloc] initWithBundleURL:jsCodeLocation moduleProvider:nil launchOptions:launchOptions];
}

-(void)registerForJsEvents
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onJavaScriptLoaded) name:RCTJavaScriptDidLoadNotification object:self.bridge];
	
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onJavaScriptDevReload) name:RCTReloadNotification object:self.bridge];
#pragma GCC diagnostic pop
}

-(void)onJavaScriptLoaded
{
	self.isReadyToReceiveCommands = true;
	[self.eventEmitter sendOnAppLaunched];
}

-(void)onJavaScriptDevReload
{
	UIApplication.sharedApplication.delegate.window.rootViewController = nil;
}

@end
