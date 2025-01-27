//
//  TYAPAddDeviceViewController.m
//  TuyaSmartHomeKit_Example
//
//  Created by 盖剑秋 on 2018/11/12.
//  Copyright © 2018 xuchengcheng. All rights reserved.
//

#import "TYAPAddDeviceViewController.h"
#import "TYSmartHomeManager.h"
#import <Reachability/Reachability.h>
#import "TYAddDeviceUtils.h"

/**
 
 @remark 2.4G WIFI environment is essential.
 @remark If your Xcode version is above 10.0, turn on 'Access WIFI Information' of your project before running on device.
 
 doc link
 
 en:https://tuyainc.github.io/tuyasmart_home_ios_sdk_doc/en/resource/Activator.html#network-configuration
 zh-hans:https://tuyainc.github.io/tuyasmart_home_ios_sdk_doc/zh-hans/resource/Activator.html#%E8%AE%BE%E5%A4%87%E9%85%8D%E7%BD%91
 
 */

static NSString *currentToken = @"";
const NSInteger timeLeft0 = 100;
static NSInteger timeout0 = timeLeft0;

@interface TYAPAddDeviceViewController () <TuyaSmartActivatorDelegate>

@property (nonatomic, strong) UITextField *ssidField;
@property (nonatomic, strong) UITextField *passwordField;
@property (nonatomic, strong) UITextView *console;

@end

@implementation TYAPAddDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)initView {
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.topBarView.leftItem = self.leftBackItem;
    self.centerTitleItem.title = @"Add device AP";
    self.topBarView.centerItem = self.centerTitleItem;
    
    CGFloat currentY = self.topBarView.height;
    currentY += 10;
    
    //first line.
    CGFloat labelWidth = 75;
    CGFloat textFieldWidth = APP_SCREEN_WIDTH - labelWidth - 30;
    CGFloat labelHeight = 44;
    
    UILabel *ssidKeyLabel = [sharedAddDeviceUtils() keyLabel];
    ssidKeyLabel.text = @"ssid:";
    ssidKeyLabel.frame = CGRectMake(10, currentY, labelWidth, labelHeight);
    [self.view addSubview:ssidKeyLabel];
    
    self.ssidField = [sharedAddDeviceUtils() textField];
    self.ssidField.placeholder = @"Input your wifi ssid";
    self.ssidField.frame = CGRectMake(labelWidth + 20, currentY, textFieldWidth, labelHeight);
    [self.view addSubview:self.ssidField];
    currentY += labelHeight;
    NSString *ssid = [TuyaSmartActivator currentWifiSSID];
    if (ssid.length) {
        self.ssidField.text = ssid;
    }
    //second line.
    currentY += 10;
    UILabel *passwordKeyLabel = [sharedAddDeviceUtils() keyLabel];
    passwordKeyLabel.text = @"password:";
    passwordKeyLabel.frame = CGRectMake(10, currentY, labelWidth, labelHeight);
    [self.view addSubview:passwordKeyLabel];
    
    self.passwordField = [sharedAddDeviceUtils() textField];
    self.passwordField.placeholder = @"password of wifi";
    self.passwordField.frame = CGRectMake(labelWidth + 20, currentY, textFieldWidth, labelHeight);
    [self.view addSubview:self.passwordField];
    currentY += labelHeight;
    
    //third line.
    currentY += 10;
    UIButton *EZModeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    EZModeButton.layer.cornerRadius = 5;
    EZModeButton.frame = CGRectMake(10, currentY, APP_SCREEN_WIDTH - 20, labelHeight);
    [EZModeButton setTitle:@"Add device in AP mode" forState:UIControlStateNormal];
    EZModeButton.backgroundColor = UIColor.orangeColor;
    [EZModeButton addTarget:self action:@selector(addDeviceWithAPMode) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:EZModeButton];
    currentY += labelHeight;
    
    //forth line.
    currentY += 10;
    UILabel *titleLabel = [sharedAddDeviceUtils() keyLabel];
    titleLabel.text = @"console:";
    titleLabel.frame = CGRectMake(10, currentY, labelWidth, labelHeight);
    [self.view addSubview:titleLabel];
    currentY += labelHeight;
    
    //fifth line.
    self.console = [UITextView new];
    self.console.frame = CGRectMake(10, currentY, APP_SCREEN_WIDTH - 20, 220);
    self.console.layer.borderColor = UIColor.blackColor.CGColor;
    self.console.layer.borderWidth = 1;
    [self.view addSubview:self.console];
    self.console.editable = NO;
    self.console.layoutManager.allowsNonContiguousLayout = NO;
    self.console.backgroundColor = HEXCOLOR(0xededed);
    currentY += self.console.height;
    
    //final line
    currentY += 10;
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.layer.cornerRadius = 5;
    cancelButton.frame = CGRectMake(10, currentY, APP_SCREEN_WIDTH - 20, labelHeight);
    [cancelButton setTitle:@"Stop config wiFi" forState:UIControlStateNormal];
    cancelButton.backgroundColor = UIColor.orangeColor;
    [cancelButton addTarget:self action:@selector(stopConfigWiFi) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    currentY += labelHeight;
}

- (void)addDeviceWithAPMode {
    
    [self.view endEditing:YES];
    
    if (!self.ssidField.text.length) {
        [sharedAddDeviceUtils() alertMessage:@"ssid can't be nil"];
        return;
    }
    //If already in AP mode progress, do nothing.
    if (timeout0 < timeLeft0) {
        [self appendConsoleLog:@"Activitor is still in progress, please wait..."];
        return;
    }
    //Get token from server with current homeId before commit activit progress.
    __block NSString *info = [NSString stringWithFormat:@"%@: start add device in APMode",NSStringFromSelector(_cmd)];
    [self appendConsoleLog:info];
    info = [NSString stringWithFormat:@"%@: start get token",NSStringFromSelector(_cmd)];
    [self appendConsoleLog:info];
    WEAKSELF_AT
    long long homeId = [TYSmartHomeManager sharedInstance].currentHome.homeModel.homeId;
    [[TuyaSmartActivator sharedInstance] getTokenWithHomeId:homeId success:^(NSString *token) {
        
        info = [NSString stringWithFormat:@"%@: token fetched, token is %@",NSStringFromSelector(_cmd),token];
        [weakSelf_AT appendConsoleLog:info];
        
        NSURL *url = [TPUtils wifiSettingUrl];
        if (TP_SYSTEM_VERSION < 10.0) {
            [[UIApplication sharedApplication] openURL:url];
        } else {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success) {
                ;
            }];
        }
        currentToken = token;
    } failure:^(NSError *error) {
        
        info = [NSString stringWithFormat:@"%@: token fetch failed, error message is %@",NSStringFromSelector(_cmd),error.localizedDescription];
        [weakSelf_AT appendConsoleLog:info];
    }];
}

- (void)appendConsoleLog:(NSString *)logString {
    
    if (!logString) {
        logString = [NSString stringWithFormat:@"%@ : param error",NSStringFromSelector(_cmd)];
    }
    NSString *result = self.console.text?:@"";
    result = [[result stringByAppendingString:logString] stringByAppendingString:@"\n"];
    self.console.text = result;
    [self.console scrollRangeToVisible:NSMakeRange(result.length, 1)];
}

- (void)reachabilityChanged:(NSNotification *)notification {
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    
    /**
     *  设备ssid目前有4种情况: 1.TuyaSmart-xxxx 2.SmartLife-xxx 3.prefix-xxxx 4.prefix-TLinkAP-xxxx
     */
    NSString *ssid = [TuyaSmartActivator currentWifiSSID];
    [self appendConsoleLog:[NSString stringWithFormat:@"WIFI changed: %@",ssid]];
    
    if (timeout0 < timeLeft0) {
        [self appendConsoleLog:[NSString stringWithFormat:@"Wifi...."]];
        return;
    }

    if ([ssid hasPrefix:@"SmartLife"]
        || [ssid hasPrefix:@"TuyaSmart"]
        || [ssid rangeOfString:@"TLinkAP" options:NSCaseInsensitiveSearch].length > 0) {
        [self commitAPModeActionWithToken:currentToken];
    }
}

- (void)countDown {
    timeout0 --;
    
    if (timeout0) {
        [self performSelector:@selector(countDown) withObject:nil afterDelay:1];
        [self appendConsoleLog:[NSString stringWithFormat:@"%@: %@ seconds left before timeout.",NSStringFromSelector(_cmd),@(timeout0)]];
    } else {
        timeout0 = timeLeft0;
    }
}

- (void)stopConfigWiFi {
    [[TuyaSmartActivator sharedInstance] stopConfigWiFi];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(countDown) object:nil];
    timeout0 = timeLeft0;
    [self hideProgressView];
    [self appendConsoleLog:@"Activator action canceled"];
}

- (void)commitAPModeActionWithToken:(NSString *)token {
    [TuyaSmartActivator sharedInstance].delegate = self;
    [[TuyaSmartActivator sharedInstance] startConfigWiFi:TYActivatorModeAP ssid:self.ssidField.text password:self.passwordField.text token:token timeout:timeout0];
    
    [self countDown];
}

#pragma mark - TuyaSmartActivatorDelegate

- (void)activator:(TuyaSmartActivator *)activator didReceiveDevice:(TuyaSmartDeviceModel *)deviceModel error:(NSError *)error {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(countDown) object:nil];
    timeout0 = timeLeft0;
    [self hideProgressView];
    
    NSString *info = [NSString stringWithFormat:@"%@: Finished!", NSStringFromSelector(_cmd)];
    [self appendConsoleLog:info];
    if (error) {
        info = [NSString stringWithFormat:@"%@: Error-%@!", NSStringFromSelector(_cmd), error.localizedDescription];
        [self appendConsoleLog:info];
    } else {
        info = [NSString stringWithFormat:@"%@: Success-You've added device %@ successfully!", NSStringFromSelector(_cmd), deviceModel.name];
        [self appendConsoleLog:info];
    }
}


@end
