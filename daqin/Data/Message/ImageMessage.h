//
//  BXImageMessage.h
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

#import "Message.h"

@interface ImageMessage : Message

@property(nonatomic,copy) UIImage* image;
@property(nonatomic,copy) NSString* imageUrl;
//@property(nonatomic,copy) NSString* imagePath;
@property(nonatomic,assign) CGSize imageSize;

@end
