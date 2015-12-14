//
//  Settings.h
//  ContentEditor
//
//  Created by 毕鸣 on 14/12/2015.
//  Copyright © 2015 HOME. All rights reserved.
//

#ifndef Settings_h
#define Settings_h

#define MAX_IMAGE_COUNT 5 // The max number of images when editing event content
#define MAX_TEXT_COUNT 5 // The max number of textViews when editing event content.
#define TEXTVIEW_PLACEHOLDER @"请输入描述信息"

typedef NS_ENUM(NSUInteger, IMAGE_ACTION) {
    IMAGE_ACTION_NONE,
    IMAGE_ACTION_ADD,
    IMAGE_ACTION_EDIT
};
typedef NS_ENUM(NSInteger, ContentType){
    ContentTypeText,
    ContentTypeImage
};

#endif /* Settings_h */
