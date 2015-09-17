//
//  BXMessageViewController.m
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

#import "MessageViewController.h"
#import "Message.h"
#import "MessageCell.h"
#import "JSMessageInputView.h"
#import "BlockActionSheet.h"
#import "InputToolBar.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "UIImage+Resize.h"

#import "MessageProvider.h"
#import "ChatSession.h"
#import "ChatPeer.h"
#import "ChatUser.h"
#import "Util.h"
#import "Store.h"

#import "AudioPlayer.h"
#import "AudioRecorder.h"
#import "VoiceMessage.h"
#import "amrFileCodec.h"
#import "VolumeView.h"
#import <Foundation/NSTimer.h>
#import "EventDefinition.h"
#import "Uploader.h"
#import "TextDisplayViewController.h"
#import "AFHTTPRequestOperation.h"
#import "GlobalDataManager.h"
#import "User.h"
#import "ViewUtil.h"

#define kStatusBarHeight    20.0f
#define kNaviBarHeight      44.0f
#define kInputViewHeight    45.0f
#define kVolumeWidth        120.0f
#define kVolumeHeight       100.0f


@interface MessageViewController ()<UITableViewDataSource,UITableViewDelegate,
            UITextViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,
            AudioRecordDelegate, AudioPlayerDelegate, InputToolBarDelegate>

@property (nonatomic, weak) UITableView             *messageTableView;
@property (nonatomic, weak) InputToolBar            *messageInputView;
//@property (nonatomic, weak) JSMessageInputView      *messageInputView;

@property (nonatomic, assign) BOOL                  isUserScrolling;
@property (nonatomic, assign) CGFloat               previousTextViewContentHeight;

@property (nonatomic, assign) BOOL                  isShowingKeyBorad;

@property (nonatomic, weak) Message               *longPressMessage;

@property (nonatomic, strong) ChatPeer            *chatPeer;

@property (nonatomic, strong) VolumenView*            volumeView;
@property (nonatomic, strong) NSTimer*              timer;
@end

@implementation MessageViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"聊天";
        self.hidesBottomBarWhenPushed = YES;
        
        _isUserScrolling = NO;
        _isShowingKeyBorad = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNewMessage:) name:kNotificationNewMessage object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessageSent:) name:kNotificationMessageSent object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessageSentFail:) name:kNotificationMessageSentFail object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleMessageSentAgain:) name:kNotificationMessageSentAgain object:nil];
        
        
        [ChatSession sharedInstance].isChattingPeerId = @"";
        
        self.navigationItem.leftBarButtonItem = [ViewUtil createBackItem:self action:@selector(backAction)];
        
    }
    return self;
}

- (void)backAction{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void) dealloc
{
    [ChatSession sharedInstance].isChattingPeerId = @"";
}

- (void)initData
{
    self.messages = [NSMutableArray array];
    User* currentUser = [GlobalDataManager sharedInstance].user;
    [ChatSession sharedInstance].selfUser = [[ChatUser alloc] initWithPeerId:currentUser.userId displayName:currentUser.name iconUrl:currentUser.avatar];
    NSString* myPeerId = [ChatSession sharedInstance].selfUser.peerId;
    NSString* receiveId = self.receiverChatUser.peerId;
    if (receiveId) {
        NSArray* messages = [MessageProvider getAllMessagesWithFromId:myPeerId toId:receiveId];
        self.messages = [NSMutableArray arrayWithArray:messages];
    }
    
    [self updateShowTimeFlag];
    
}

- (void)loadView
{
    [super loadView];
    
    CGRect rect = self.view.frame;
    CGFloat inputY;
    if (VERSION_GREATER_7) {
        rect.size.height -= (kNaviBarHeight);
        inputY = self.view.frame.size.height - kNaviBarHeight;
    }
    else{
        rect.origin.y = 0.0f;
        rect.size.height -= (kNaviBarHeight);
        inputY = self.view.frame.size.height - kNaviBarHeight;
    }
    
    UITableView *messageTableView = [[UITableView alloc] initWithFrame:rect];
    messageTableView.dataSource = self;
    messageTableView.delegate = self;
    messageTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:messageTableView];
    self.messageTableView = messageTableView;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 1;
    [self.messageTableView addGestureRecognizer:tapGesture];
    
    // set up the input view
    // set up the input view
    CGRect inputFrame = CGRectMake(0, inputY, self.view.bounds.size.width, kInputViewHeight);
    InputToolBar* inputView = [[InputToolBar alloc] initWithFrame:inputFrame superView:self.view];
    [self.view addSubview:inputView];
    self.messageInputView = inputView;
    messageTableView.backgroundColor = [UIColor colorWithRed:0xef/255.0 green:0xef/255.0 blue:0xef/255.0 alpha:1];
    [self setTableViewInsetsWithBottomValue:kInputViewHeight];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [self setRightBarItemTitle:@"更多" select:@selector(topMoreButtonClicked:)];
    
    [self scrollToBottomAnimated:NO];
    
    self.messageInputView.delegate = self;
    
//    [self.messageInputView.moreButton addTarget: self
//                                         action:@selector(moreButtonClicked:)
//                               forControlEvents:UIControlEventTouchUpInside];
//
//    [self.messageInputView.audioButton addTarget: self
//                                         action:@selector(audioButtonClicked:)
//                               forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.messageInputView.speakButton addTarget:self
//                                          action:@selector(speakButtonDown:)
//                                forControlEvents:UIControlEventTouchDown];
//    
//    [self.messageInputView.speakButton addTarget:self
//                                          action:@selector(speakButtonUp:)
//                                forControlEvents:UIControlEventTouchUpInside];

    
    NSString* myPeerId = (NSString*)[[EGOCache globalCache] objectForKey:@"userToken"];
//    NSString* myPeerId = [ChatSession sharedInstance].selfUser.peerId;
    NSString* receiveId = self.receiverChatUser.peerId;
    [ChatSession sharedInstance].isChattingPeerId = receiveId;
    [MessageProvider markAllMessageReadWithFromId:myPeerId toId:receiveId];
    [MessageProvider saveChatUser:_receiverChatUser];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifcationMessageChange object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadSessionFromDB object:nil];
        
    if (receiveId) {
        NSArray* messages = [MessageProvider getAllMessagesWithFromId:myPeerId toId:receiveId];
        self.messages = [NSMutableArray arrayWithArray:messages];
        [self updateShowTimeFlag];
        [self.messageTableView reloadData];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillShowKeyboardNotification:)
												 name:UIKeyboardWillShowNotification
                                               object:nil];
    
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleWillHideKeyboardNotification:)
												 name:UIKeyboardWillHideNotification
                                               object:nil];
    
//    [self.messageInputView.textView addObserver:self
//                                     forKeyPath:@"contentSize"
//                                        options:NSKeyValueObservingOptionNew
//                                        context:nil];
    [self.messageInputView registerTextViewObserver];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString* receiveId = self.receiverChatUser.peerId;
    [ChatSession sharedInstance].isChattingPeerId = receiveId;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [ChatSession sharedInstance].isChattingPeerId = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self setEditing:NO animated:YES];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
//    [self.messageInputView.textView removeObserver:self forKeyPath:@"contentSize"];
    [self.messageInputView unregisterTextViewObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - uitextview delegate methods

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToBottomAnimated:YES];
    
    if (!self.previousTextViewContentHeight)
		self.previousTextViewContentHeight = textView.contentSize.height;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [self didSendText:self.messageInputView.textView.text fromSender:MessageFromMine];
        return NO;
    }
    return  YES;
}

#pragma mark - button actions
- (void)moreButtonClicked:(UIButton *)sender
{
    BlockActionSheet *actionSheet = [[BlockActionSheet alloc] init];
    [actionSheet addButtonWithTitle:@"拍照" block:^{
        [self takePhoto];
    }];
    [actionSheet addButtonWithTitle:@"选择照片" block:^{
        [self choosePhoto];
    }];
    [actionSheet setDestructiveButtonWithTitle:@"取消" block:nil];
    [actionSheet showInView:self.view];
    [self.view endEditing:YES];
}



-(void) onStatusChanged:(RecorderStatus)status{
    
}

-(void) onPlayingFinished{
    
}

-(void) onRecordingFinished:(NSString*)filePath duration:(int)duration{
    if(!filePath) return;
    [self didSendVoice:filePath duration:duration fromSender:MessageFromMine];
}


- (void)speakButtonDown:(UIButton*)sender{
    if(!self.volumeView){
        
        self.volumeView = [[VolumenView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - kVolumeWidth) / 2,
                           (self.view.frame.size.height - kVolumeHeight) / 2,
                           kVolumeWidth,
                           kVolumeHeight)];
        [self.view addSubview:self.volumeView];
    }
    self.volumeView.hidden = NO;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(volumeTimer) userInfo:nil repeats:YES];
//    [[AudioRecorder sharedInstance] startRecording:self];
}

- (void)volumeTimer{
//    float power = [[AudioRecorder sharedInstance] getPower];
//    NSLog(@"power:%f", power);
//    [self.volumeView updatePower:power];
}

- (void)speakButtonUp:(UIButton*)sender{
//    [[AudioRecorder sharedInstance] finishRecording];
//    self.volumeView.hidden = YES;
//    if(_timer){
//        [_timer invalidate];
//        _timer = nil;
//    }
}

- (void)endEditing {
    [self.messageInputView endEditing];
    [self setTableViewInsetsWithBottomValue:self.view.bounds.size.height - self.messageInputView.frame.origin.y];
    [self.view endEditing:YES];
}


- (void)audioButtonClicked:(UIButton*)sender{
    [self.view endEditing:YES];
}

- (void)takePhoto
{
    [self choosePhotoFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (void)choosePhoto
{
    [self choosePhotoFromSource:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

- (void)choosePhotoFromSource:(UIImagePickerControllerSourceType)source
{
    UIImagePickerController *pickerController = [[UIImagePickerController alloc] init];
    pickerController.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:source] ) {
        pickerController.sourceType = source;
        [self.navigationController presentViewController:pickerController animated:YES completion:nil];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissModalViewControllerAnimated:YES];
}


#pragma mark - message sender methods
- (void)didSendText:(NSString *)text fromSender:(MessageFrom)sender
{
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (text.length<=0) {
        return;
    }
    
    Message* message = [Message createTextMessage:text from:MessageFromMine];
    ChatSession* chatSession = [ChatSession sharedInstance];
    message.fromId = chatSession.selfUser.peerId;
    message.toId = chatSession.receiverUser.peerId;
    message.guid = [Util GUID];

    [MessageProvider addMessage:message];
    
    [self.messages addObject: message];

    [ChatSession sendMessage:message.contentToSend];
    
    [self finishSend];
}

- (void)didSendImage:(UIImage *)image fromSender:(MessageFrom)sender
{
    // save to Library/Cache get file path
    NSString *imagePath = [Store getImagePath];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:imagePath atomically:YES];
    
    // upload the image
    NSString* guid = [Util GUID];
    [Uploader uploadImage:image onSuccess:^(NSString * returnUrl) {
        NSString* fullUrl = returnUrl;

        Message* message = [Message createImageMessageWithImage:image
                                                          imageSize:CGSizeZero
                                                           imageUrl:fullUrl
                                                               from:MessageFromMine];
        message.fromId = [ChatSession sharedInstance].selfUser.peerId;
        message.toId = [ChatSession sharedInstance].receiverUser.peerId;
        message.guid = guid;
        
        [MessageProvider addMessage:message];
        [ChatSession sendMessage:message.contentToSend];
        
    } onFailure:^(NSString * error ) {
        
    } onProgress:^(CGFloat percent, long long sent) {
        
    }];
    Message* message = [Message createImageMessageWithImage:image
                                                      imageSize:CGSizeZero
                                                       imageUrl:nil
                                                           from:MessageFromMine];
    message.fromId = [ChatSession sharedInstance].selfUser.peerId;
    message.toId = [ChatSession sharedInstance].receiverUser.peerId;
    message.guid = guid;
    
    [self.messages addObject:message];
    
    [self finishSend];
    
}

- (void)didSendVoice:(NSString *)localPath duration:(int)duration fromSender:(MessageFrom)sender
{
    NSString* guid = [Util GUID];
    [Uploader uploadFile:localPath onSuccess:^(NSString * returnUrl) {
         // 上传成功
         Message* message = [Message createVoiceMessage:returnUrl
                                                  localPath:localPath
                                                   duration:duration from:MessageFromMine];
         message.fromId = [ChatSession sharedInstance].selfUser.peerId;
         message.toId = [ChatSession sharedInstance].receiverUser.peerId;
         message.guid = guid;
         
         [MessageProvider addMessage:message];
         [ChatSession sendMessage:message.contentToSend];
     } onFailure:^(NSString * error) {
         // 上传失败
     } onProgress:^(CGFloat percent, long long sent) {
         
     }];
    
    Message* message = [Message createVoiceMessage:nil
                                             localPath:localPath
                                              duration:duration from:MessageFromMine];
    message.fromId = [ChatSession sharedInstance].selfUser.peerId;
    message.toId = [ChatSession sharedInstance].receiverUser.peerId;
    message.guid = guid;
    
    [self.messages addObject:message];
    
    [self finishSend];
}


- (void)finishSend
{
    int count = [self.messages count];
    if (count >= 2) {
        Message* lastMessage = [self.messages objectAtIndex:count-2];
        Message* curMessage = [self.messages objectAtIndex:count-1];
        NSTimeInterval lastTime = [lastMessage.time timeIntervalSinceNow];
        NSTimeInterval currentTime = [curMessage.time timeIntervalSinceNow];
        
        if (currentTime-lastTime>60*3) {
            curMessage.showTime = YES;
        }
    }
    else if(count == 1){
        Message* curMessage = [self.messages objectAtIndex:count-1];
        curMessage.showTime = YES;
    }
    
    [self.messageInputView.textView setText:nil];
    [self.messageTableView reloadData];
    [self scrollToBottomAnimated:YES];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationShouldReloadSession object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationReloadSessionFromDB object:nil];
}

#pragma mark - InputToolBarDelegate

- (void) onInputing {
    [self setTableViewInsetsWithBottomValue:self.view.bounds.size.height - self.messageInputView.frame.origin.y];
    [self scrollToBottomAnimated:YES];
}

- (void) onSendTextMessage:(NSString*)txt {
    [self didSendText:txt fromSender:MessageFromMine];
}

#pragma mark - Layout message input view

- (void) inputLayoutResized:(CGFloat)changeInHeight {
    [self setTableViewInsetsWithBottomValue:self.messageTableView.contentInset.bottom + changeInHeight];
    [self scrollToBottomAnimated:NO];
}


//- (void)layoutAndAnimateMessageInputTextView:(UITextView *)textView
//{
//    CGFloat maxHeight = [JSMessageInputView maxHeight];
//    
//    BOOL isShrinking = textView.contentSize.height < self.previousTextViewContentHeight;
//    CGFloat changeInHeight = textView.contentSize.height - self.previousTextViewContentHeight;
//    
//    if (!isShrinking && (self.previousTextViewContentHeight == maxHeight || textView.text.length == 0)) {
//        
//        changeInHeight = 0;
//        
//    } else {
//        /**
//         *  不知道为啥拿到的textView的contentSize.height的值不对, 有想法的同学过来解决下???
//         */
//        if (abs(changeInHeight) == 24) {
//            return;
//        } else {
//            changeInHeight = MIN(changeInHeight, maxHeight - self.previousTextViewContentHeight);
//        }
//    }
//    
//    if (changeInHeight != 0.0f) {
//        [UIView animateWithDuration:0.25f
//                         animations:^
//        {
//             [self setTableViewInsetsWithBottomValue:self.messageTableView.contentInset.bottom + changeInHeight];
//             
//             [self scrollToBottomAnimated:NO];
//             
//             if (isShrinking) {
//                 // if shrinking the view, animate text view frame BEFORE input view frame
//                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
//             }
//             
//             CGRect inputViewFrame = self.messageInputView.frame;
//             self.messageInputView.frame = CGRectMake(0.0f,
//                                                      inputViewFrame.origin.y - changeInHeight,
//                                                      inputViewFrame.size.width,
//                                                      inputViewFrame.size.height + changeInHeight);
//             if (!isShrinking) {
//                 // growing the view, animate the text view frame AFTER input view frame
//                 [self.messageInputView adjustTextViewHeightBy:changeInHeight];
//             }
//         } completion:^(BOOL finished) {
//         }];
//    
//        self.previousTextViewContentHeight = MIN(textView.contentSize.height, maxHeight);
//    }
//    
//    // Once we reached the max height, we have to consider the bottom offset for the text view.
//    // To make visible the last line, again we have to set the content offset.
//    if (self.previousTextViewContentHeight == maxHeight) {
//        double delayInSeconds = 0.01;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
//        {
//           CGPoint bottomOffset = CGPointMake(0.0f, textView.contentSize.height - textView.bounds.size.height);
//           [textView setContentOffset:bottomOffset animated:YES];
//        });
//    }
//}

#pragma mark - gesture recogonizer handler

- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}


#pragma mark - uiimagepickercontroller delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    CGFloat maxLength = 640;
    image = [image bx_imageResizetoMaxLength:maxLength];
    [image bx_imageResizetoMaxLength:maxLength];
    
    [self didSendImage:image fromSender:MessageFromMine];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollView delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.isUserScrolling = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.isUserScrolling = NO;
}

#pragma mark - tableview datasource & delegate methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message* message = [self.messages objectAtIndex:indexPath.row];
    NSString* cellIdentifier = [NSString stringWithFormat:@"BXMessageCell%d",message.type];
    
    MessageCell *messageCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!messageCell) {
        messageCell = [MessageCell createMessageCellMessage:message reuseIdentifier:cellIdentifier target:self];
        [messageCell setBackgroundColor:tableView.backgroundColor];
    }
    
    messageCell.indexPath = indexPath;
    
    if (message.from == MessageFromOther) {
        message.avatarUrl = [ChatSession sharedInstance].receiverUser.iconUrl;
    }
    else{
        message.avatarUrl = [ChatSession sharedInstance].selfUser.iconUrl;
    }
    
    [messageCell configCellWithMessage:message];
    
    return messageCell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0.0;
    
    Message* message = [self.messages objectAtIndex:indexPath.row];
    height = [MessageCell cellHeightWithMessage:message];
    
    return height;
}

#pragma mark - Keyboard notifications

- (void)handleWillShowKeyboardNotification:(NSNotification *)notification
{
    [_messageInputView handleWillShowKeyboardNotification:notification];
    self.isShowingKeyBorad = YES;
    [self keyboardWillShowOrHide:notification];
}

- (void)handleWillHideKeyboardNotification:(NSNotification *)notification
{
    [_messageInputView handleWillHideKeyboardNotification:notification];
    self.isShowingKeyBorad = NO;
    [self keyboardWillShowOrHide:notification];
}

- (void)keyboardWillShowOrHide:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
	UIViewAnimationCurve curve = [notification.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSInteger animationCurveOption = (curve << 16);
    
    [UIView animateWithDuration:duration
                          delay:0.0
                        options:animationCurveOption
                     animations:^
     {
         CGFloat keyboardY = [self.view convertRect:keyboardRect fromView:nil].origin.y;
         
         CGRect inputViewFrame = self.messageInputView.frame;
         CGFloat inputViewFrameY = keyboardY - inputViewFrame.size.height;
         
         self.messageInputView.frame = CGRectMake(inputViewFrame.origin.x,
                                                  inputViewFrameY,
                                                  inputViewFrame.size.width,
                                                  inputViewFrame.size.height);
         
         [self setTableViewInsetsWithBottomValue:self.view.frame.size.height - self.messageInputView.frame.origin.y];
     } completion:^(BOOL finished) {
         if (self.isShowingKeyBorad) {
             [self scrollToBottomAnimated:YES];
         }
     }];
}

//#pragma mark - Key-value observing
//
//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context
//{
//    if (object == self.messageInputView.textView && [keyPath isEqualToString:@"contentSize"]) {
//        [self layoutAndAnimateMessageInputTextView:object];
//    }
//}

#pragma mark - private method

- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = [self tableViewInsetsWithBottomValue:bottom];
    self.messageTableView.contentInset = insets;
    self.messageTableView.scrollIndicatorInsets = insets;
}

- (UIEdgeInsets)tableViewInsetsWithBottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        insets.top = self.topLayoutGuide.length;
    }
    
    insets.bottom = bottom;
    
    return insets;
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
	if (![self shouldAllowScroll])
        return;
	
    NSInteger rows = [self.messageTableView numberOfRowsInSection:0];
    
    if (rows > 0) {
        [self.messageTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rows - 1 inSection:0]
                                     atScrollPosition:UITableViewScrollPositionBottom
                                             animated:animated];
    }
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath
			  atScrollPosition:(UITableViewScrollPosition)position
					  animated:(BOOL)animated
{
	if (![self shouldAllowScroll])
        return;
	
	[self.messageTableView scrollToRowAtIndexPath:indexPath
                                 atScrollPosition:position
                                         animated:animated];
}

- (BOOL)shouldAllowScroll
{
    if (self.isUserScrolling) {
        return NO;
    }
    
    return YES;
}


#pragma mark - 手势事件回调

- (void)handleSingleHitGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
    
    UIView* view = gestureRecognizer.view;
    int index = view.tag;
    Message* message = [self.messages objectAtIndex:index];

    if (message.type == MessageTypeImage) {

        NSMutableArray* imageMessages = [NSMutableArray array];
        int totalCount = 0;
        int curIndex = 0;
        for (int i = 0; i < [self.messages count]; i++) {
            Message* msg = [self.messages objectAtIndex:i];
            if (msg.type == MessageTypeImage) {
                if (msg == message) {
                    curIndex = totalCount;
                }
                totalCount++;
                [imageMessages addObject:msg];
            }
        }
        
        NSMutableArray *photoes = [NSMutableArray arrayWithCapacity:totalCount];
        for (int i = 0; i < totalCount; i ++) {
            Message* msg = [imageMessages objectAtIndex:i];
            MJPhoto *photo = [[MJPhoto alloc] init];
            if (msg.imageValue) {
                photo.image = msg.imageValue;
            }
            else if(msg.imageUrl){
                photo.url = [NSURL URLWithString:msg.imageUrl];
            }
            
            [photoes addObject:photo];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.currentPhotoIndex = curIndex;
        browser.photos = photoes;
        [browser show];
        
    }
}

- (void)handleDoubleHitGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    int index = view.tag;
    
    Message* message = [self.messages objectAtIndex:index];
    
    TextDisplayViewController *displayTextViewController = [[TextDisplayViewController alloc] init];
    displayTextViewController.message = message;
    [self.navigationController pushViewController:displayTextViewController animated:NO];
}

- (NSString*)convertToPlayFile:(NSString*)path{
    NSString* ret = path;
    if([path rangeOfString:@".amr"].location != NSNotFound){
        NSString* wavPath = [[path substringToIndex:[path rangeOfString:@"." options:NSBackwardsSearch].location] stringByAppendingString:@".wav"];
        BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:wavPath];
        if(!fileExists){
//            DecodeAMRFileToWAVEFile(path.UTF8String, wavPath.UTF8String);
        }
        ret = wavPath;
    }
    return ret;
}

- (void)handleHitGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    int index = view.tag;
    
    Message* message = [self.messages objectAtIndex:index];
//    if([message isMemberOfClass:[VoiceMessage class]]){
//        if(((VoiceMessage*)message).localPath){
//            [[AudioPlayer sharedInstance] play:[self convertToPlayFile:((VoiceMessage*)message).localPath] listener:self];
//        }else if(((VoiceMessage*)message).voiceUrl){
//            NSString* voiceUrl = ((VoiceMessage*)message).voiceUrl;
//            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:voiceUrl]];
//            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//            
//            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//            NSString *path = [[paths objectAtIndex:0] stringByAppendingString:@"/Sounds/"];
//            
//            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
//
//            int index = ([voiceUrl rangeOfString:@"/" options:NSBackwardsSearch].location);
//            NSString* fileName = [voiceUrl substringFromIndex:(index + 1)];
//            path = [path stringByAppendingString:fileName];
//            
//            operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
//            
//            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//                NSString* wavPath = [NSString stringWithString:path];
////                wavPath = [[wavPath substringToIndex:[wavPath rangeOfString:@"." options:NSBackwardsSearch].location] stringByAppendingString:@".wav"];
//                wavPath = [wavPath stringByAppendingString:@".wav"];
////                DecodeAMRFileToWAVEFile([path UTF8String], [wavPath UTF8String]);
//                ((VoiceMessage*)message).localPath = wavPath;
//                [MessageProvider updateMessageObject:message];
//                [[AudioPlayer sharedInstance] play:wavPath listener:self];
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            }];
//            
//            [operation start];
//        }
//    }
}

- (void)handleLongPressGesture:(UITapGestureRecognizer *)gestureRecognizer
{
    UIView* view = gestureRecognizer.view;
    int index = view.tag;
    Message* message = [self.messages objectAtIndex:index];
    self.longPressMessage = message;
    
    if (message.type == MessageTypeText) {
        if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {

        }
        else if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
            
            UIMenuItem *copy = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyed:)];
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:[NSArray arrayWithObjects:copy, nil]];
            CGRect targetRect = view.bounds;
            
            [menu setTargetRect:CGRectInset(targetRect, 0.0f, 4.0f) inView:view];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}

#pragma mark - Menu Actions

- (void)copyed:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:[self.longPressMessage textValue]];
    [self resignFirstResponder];
}


- (void) handleNewMessage:(NSNotification*)aNotification
{
    NSString* receiveId = [aNotification object];
    self.receiverChatUser.peerId = receiveId;
    [self initData];
    [self.messageTableView reloadData];
    
    [self scrollToBottomAnimated:YES];
}

- (void) handleMessageSent:(NSNotification*)aNotification
{
    NSString* guid = [aNotification object];
    
    for (Message* message in self.messages) {
        if ([message.guid isEqualToString:guid]) {
            message.state = MessageStateSendOK;
            [MessageProvider updateMessageObject:message];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageTableView reloadData];
    });
}

- (void) handleMessageSentFail:(NSNotification*)aNotification
{
    NSString* guid = [aNotification object];
    
    for (Message* message in self.messages) {
        if ([message.guid isEqualToString:guid]) {
            message.state = MessageStateSendFail;
            [MessageProvider updateMessageObject:message];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.messageTableView reloadData];
    });
}

- (void) handleMessageSentAgain:(NSNotification*)aNotification
{
    NSIndexPath* indexPath = [aNotification object];
    
    Message* message = [self.messages objectAtIndex:indexPath.row];
    message.state = MessageStateSending;
    message.time = [NSDate date];
    [MessageProvider updateMessageObject:message];
    
    [ChatSession sendMessage:message.contentToSend];
    
    [self finishSend];
}

- (void)updateShowTimeFlag
{
    for (int i = 1; i < [self.messages count]; i++) {
        Message* lastMessage = [self.messages objectAtIndex:i-1];
        if (i == 1) {
            lastMessage.showTime = YES;
        }
        Message* curMessage = [self.messages objectAtIndex:i];
        NSTimeInterval lastTime = [lastMessage.time timeIntervalSinceNow];
        NSTimeInterval currentTime = [curMessage.time timeIntervalSinceNow];
        
        if (currentTime-lastTime>60*3) {
            curMessage.showTime = YES;
        }
    }
}

@end
