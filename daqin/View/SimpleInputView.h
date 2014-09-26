//
//  SimpleInputView.h
//  daqin
//
//  Created by BurizaDo on 9/24/14.
//  Copyright (c) 2014 BurizaDo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol InputDelegate
-(void)onSendMessage:(NSString*)text;
@end

@interface SimpleInputView : UIView
@property(nonatomic, strong)UITextView* textView;
@property(nonatomic, assign)id<InputDelegate>messageDelegate;
@end
