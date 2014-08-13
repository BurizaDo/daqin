//
//  BXImageMessage.m
//  Baixing
//
//  Created by minjie on 14-5-14.
//
//

#import "ImageMessage.h"

@implementation ImageMessage

- (id)init
{
    self = [super init];
    if (self) {
        self.type = MessageTypeImage;
    }
    return self;
}

- (void)setContent:(NSString*)content
{
    if (content) {
        NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
        if (data) {
            NSDictionary* dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            self.imageUrl = dic[@"url"];
            
            CGFloat imageWidth = 0;
            CGFloat imageHeight = 0;
            
            if (dic[@"width"]) {
                imageWidth = [dic[@"width"] floatValue];
            }
            
            if (dic[@"height"]) {
                imageHeight = [dic[@"height"] floatValue];
            }
            
            if (imageWidth > 0 && imageHeight > 0) {
                self.imageSize = CGSizeMake(imageWidth, imageHeight);
            }
            
        }
    }
}

- (NSData*) objectData
{
    if (self.image) {
        NSData *dataOfObject = [NSKeyedArchiver archivedDataWithRootObject:self.image];
        return dataOfObject;
    }
    else{
        return nil;
    }
}

- (void) loadObject
{
    if (self.object.length>0) {
        
        NSData *data = self.object;
        if (data) {
            self.image = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
}

- (NSDictionary*) contentDic
{
    
    NSDictionary* contentDic =  @{@"url":[self imageUrl],
                                  @"width":@((int)self.imageSize.width),
                                  @"height":@((int)self.imageSize.height)};
    return contentDic;
}

@end
