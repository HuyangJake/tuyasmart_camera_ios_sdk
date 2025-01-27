//
//  TuyaSmartCamera.h
//  TuyaSmartCamera_Example
//
//  Created by 傅浪 on 2019/4/11.
//  Copyright © 2019 fulang@tuya.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TuyaSmartCameraKit/TuyaSmartCameraKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NSArray<NSNumber *> TYNumberArray;
typedef NSArray<NSDictionary *> TYDictArray;

typedef void(^IPCVoidBlock)(void);
typedef void(^IPCErrorBlock)(NSError *error);

@class TuyaSmartCamera;
@protocol TuyaSmartCameraObserver <NSObject>

@optional

- (void)cameraDidDisconnected:(TuyaSmartCamera *)camera;

- (void)cameraPlaybackDidFinished:(TuyaSmartCamera *)camera;

- (void)camera:(TuyaSmartCamera *)camera didReceiveFirstFrame:(UIImage *)image;

- (void)camera:(TuyaSmartCamera *)camera didReceiveDefinitionState:(BOOL)isHd;

- (void)camera:(TuyaSmartCamera *)camera didReceiveMuteState:(BOOL)isMuted;

- (void)camera:(TuyaSmartCamera *)camera didReceiveVideoFrame:(CMSampleBufferRef)sampleBuffer frameInfo:(TuyaSmartVideoFrameInfo)frameInfo;

@end

@interface TuyaSmartCamera : NSObject

@property (nonatomic, strong, readonly) TuyaSmartDevice *device;

@property (nonatomic, strong, readonly) id<TuyaSmartCameraType> camera;

@property (nonatomic, strong, readonly) UIView<TuyaSmartVideoViewType> *videoView;

@property (nonatomic, assign, readonly) CGSize videoFrameSize;

@property (nonatomic, strong, readonly) TuyaSmartCameraDPManager *dpManager;

@property (nonatomic, assign) TuyaSmartCameraPlayMode playMode;

@property (nonatomic, assign, readonly) TuyaSmartCameraTalkbackMode talkbackMode;

@property (nonatomic, assign, readonly) NSInteger videoNum;

@property (nonatomic, assign, readonly)                 BOOL isSupportInstantTalkback;

@property (nonatomic, assign, readonly) BOOL isSupportSound;

@property (nonatomic, assign, readonly) BOOL isSupportTalk;

@property (nonatomic, assign, getter=isConnecting)      BOOL connecting;

@property (nonatomic, assign, getter=isConnected)       BOOL connected;

@property (nonatomic, assign, getter=isPreviewing)      BOOL previewing;

@property (nonatomic, assign, getter=isPlaybacking)     BOOL playbacking;

@property (nonatomic, assign, getter=isPlaybackPuased)  BOOL playbackPaused;

@property (nonatomic, assign, getter=isMuted)           BOOL muted;

@property (nonatomic, assign, getter=isTalking)         BOOL talking;

@property (nonatomic, assign, getter=isRecording)       BOOL recording;

@property (nonatomic, assign, getter=isHD)              BOOL HD;

@property (nonatomic, strong, readonly) TYDictArray *timeSlicesInCurrentDay;

@property (nonatomic, strong, readonly) NSArray<id<TuyaSmartCameraObserver>> *observers;

- (instancetype)initWithDeviceId:(NSString *)devId;

- (void)addObserver:(id<TuyaSmartCameraObserver>)observer;

- (void)removeObserver:(id<TuyaSmartCameraObserver>)observer;

- (void)connect:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

- (void)disConnect;

- (void)startPreview:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

- (void)stopPreview;

- (void)startPlaybackWithPlayTime:(NSInteger)playTime playbackSlice:(NSDictionary *)timeSlice success:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

- (void)pausePlayback:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

- (void)resumePlayback:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

- (void)stopPlayback;

- (void)playbackDaysInYear:(NSInteger)year month:(NSInteger)month complete:(void(^)(TYNumberArray * result))complete;

- (void)recordTimeSliceWithPlaybackDate:(TuyaSmartPlaybackDate *)date complete:(void(^)(TYDictArray *result))complete;

- (void)enableMute:(BOOL)isMute success:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

- (void)enableHD:(BOOL)isHD success:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

- (void)startTalk:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

- (void)stopTalk;

- (UIImage *)snapShoot:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

- (void)startRecord:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

- (void)stopRecord:(IPCVoidBlock)success failure:(IPCErrorBlock)failure;

@end

