//
//  EditContentTableViewController.m
//  Events
//
//  Created by 毕鸣 on 20/11/2015.
//  Copyright © 2015 LLZG. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CTAssetsPickerController/CTAssetsPickerController.h>
#import "EditContentTableViewController.h"
#import "PureLayout.h"
#import "Settings.h"
#import "MBProgressHUD.h"
//#import "UISwipeGestureRecognizerWithData.h"
//#import "ImageRecord.h"
//#import "ImageUploader.h"
//#import "UploadImageOperations.h"
#import "ContentRecord.h"
#import "ContentRecordText.h"
#import "ContentRecordImage.h"
#import "Settings.h"
#import "CLImageEditor.h"



@interface EditContentTableViewController ()<EditContentCellDelegate, UIImagePickerControllerDelegate ,UINavigationControllerDelegate, MGSwipeTableCellDelegate, CTAssetsPickerControllerDelegate, CLImageEditorDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addTextBtn;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addImageBtn;

@property (strong,nonatomic) NSMutableArray *contentsArray; // Save the ContentRecords
@property (nonatomic, assign) NSUInteger imageViewCount;
@property (nonatomic, assign) NSUInteger textViewCount;
@property (strong, nonatomic) NSMutableArray *selectedImages; // Images for this selection.
@property (strong, nonatomic) NSIndexPath *indexPath; // indexPath for the cell that is updating content.
@property (weak, nonatomic) UITextView *currentTextView;
@property (strong, nonatomic) MBProgressHUD *progressHud;
@property (nonatomic, strong) PHImageRequestOptions *phImageRequestOptions;

@property (nonatomic, assign) IMAGE_ACTION imageAction;

@end

@implementation EditContentTableViewController


- (NSMutableArray *)contentsArray {
    if (!_contentsArray) {
        _contentsArray = [[NSMutableArray alloc]initWithCapacity:MAX_TEXT_COUNT + MAX_IMAGE_COUNT];
    }
    
    return _contentsArray;
}


- (NSMutableArray *)selectedImages {
    if (!_selectedImages) {
        _selectedImages = [[NSMutableArray alloc]initWithCapacity:MAX_IMAGE_COUNT];
    }
    return _selectedImages;
}

- (PHImageRequestOptions *)phImageRequestOptions {
    if (!_phImageRequestOptions) {
        _phImageRequestOptions = [[PHImageRequestOptions alloc] init];
        _phImageRequestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
        _phImageRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    return _phImageRequestOptions;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.tableView setEditing:NO animated:YES];
    
    [self.navigationController setToolbarHidden:NO];
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 40;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [self.tableView registerClass:[EditContentTextCell class] forCellReuseIdentifier:@"textCell"];
    [self.tableView registerClass:[EditContentImageCell class] forCellReuseIdentifier:@"imageCell"];
    
    //[self addTextContent:nil];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.tableView addGestureRecognizer:tapGesture];
    
    //[self addDoneToolBarToKeyboard:self.currentTextView];
    self.editMode = EditModeUpdate;
    if (self.editMode == EditModeUpdate /*&& self.eventDic*/) {
        //NSString *contentString = self.eventDic[@"content"];
        NSString *contentString = @"[{\"type\":\"html\", \"value\":\"Draft forget\"},{\"type\":\"imgs\", \"value\":[{\"url\":\"http://image.llzg.cn/ufiles/2016/01/28/an/2016-01-28_1453965096610.jpg\"}]},{\"type\":\"imgs\", \"value\":[{\"url\":\"http://image.llzg.cn/ufiles/2016/01/28/an/2016-01-28_1453965098677.jpg\"}]},{\"type\":\"imgs\", \"value\":[{\"url\":\"http://image.llzg.cn/ufiles/2016/01/28/an/2016-01-28_1453965100468.jpg\"}]},{\"type\":\"imgs\", \"value\":[{\"url\":\"http://image.llzg.cn/ufiles/2016/01/28/an/2016-01-28_1453965102268.jpg\"}]},{\"type\":\"imgs\", \"value\":[{\"url\":\"http://image.llzg.cn/ufiles/2016/01/28/an/2016-01-28_1453965103308.jpg\"}]}]";
        NSData *data = [contentString dataUsingEncoding:NSUTF8StringEncoding];
        NSError *jsonError;
        NSArray *contents = (NSArray *)[NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        if (!jsonError && contents.count > 0) {
            NSLog(@"contents:%@", contents);
            for (NSDictionary *content in contents) {
                if ([content[@"type"] isEqualToString:@"html"]) {
                    
                    [self addTextContent:self editMode:EditModeUpdate withContent:content[@"value"]];
                }else if ([content[@"type"] isEqualToString:@"imgs"]) {
                    NSArray *images = content[@"value"];
                    for (NSDictionary *urlDic in images) {
                        NSString *urlString = urlDic[@"url"];
                        [self addImageRecord:nil imagePath:urlString];
                    }
                }
            }
        } else {
            NSLog(@"json error:%@", jsonError);
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.navigationController setHidesBarsOnSwipe:NO];
    [self.navigationController setToolbarHidden:NO animated:YES];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    NSLog(@"Setting Editing Mode to %d", editing);
    [super setEditing:editing animated:NO];
    
    [self.tableView setEditing:editing animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)addText:(id)sender {
    [self addTextContent:nil editMode:EditModeCreate withContent:nil];
    
}

- (void)addTextContent:(id)sender editMode:(EditMode)mode withContent:(NSString *)content {
    
    if (self.textViewCount >= MAX_TEXT_COUNT) {
        NSString *message = [NSString stringWithFormat:@"最多添加%d个文字编辑区", MAX_TEXT_COUNT];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else {
        ContentRecordText *textRecord = [[ContentRecordText alloc]initWithType:ContentTypeText];
        
        [self.contentsArray addObject:textRecord];
        
        self.textViewCount++;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.contentsArray.count - 1 inSection:0];
        textRecord.indexPath = indexPath;
        
        if (mode == EditModeCreate) {
            [self.tableView beginUpdates];
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
            NSInteger row = indexPath.row;
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:row-1 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            [self.tableView endUpdates];
            
            [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            EditContentTextCell *textCell = (EditContentTextCell *)[self.tableView cellForRowAtIndexPath:indexPath];
            [textCell.textView becomeFirstResponder];
        }else if (mode == EditModeUpdate) {
            textRecord.text = content;
            textRecord.updated = YES;
        }
    }
}


- (IBAction)addImageContent:(id)sender {
    
    if (self.imageViewCount >= MAX_IMAGE_COUNT) {
        
        NSString *message = [NSString stringWithFormat:@"最多添加%d个图片编辑区", MAX_IMAGE_COUNT];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else {
        
        if (self.currentTextView) {
            [self.currentTextView endEditing:YES];
        }
        
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.allowsEditing = NO;
        imagePicker.delegate = self;
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                
                [self presentViewController:imagePicker animated:YES completion:^{
                    self.imageAction = IMAGE_ACTION_ADD;
                }];
            }];
            [alert addAction:cameraAction];
        }
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"选择图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                // request authorization status
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        // init picker
                        CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
                        
                        // set delegate
                        picker.delegate = self;
                        
                        // Optionally present picker as a form sheet on iPad
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
                            picker.modalPresentationStyle = UIModalPresentationFormSheet;
                        
                        // present picker
                        [self presentViewController:picker animated:YES completion:nil];
                    });
                }];
                
            }];
            [alert addAction:libraryAction];
        }
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

#pragma mark - CTAssetsPickerControllerDelegate

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(PHAsset *)asset {
    NSInteger max = (MAX_IMAGE_COUNT - self.imageViewCount);
    
    // show alert gracefully
    if (picker.selectedAssets.count >= max)
    {
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:nil
                                            message:[NSString stringWithFormat:@"本次最多添加 %ld 张图片，您选择的数量已达到上限", (long)max]
                                     preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *action =
        [UIAlertAction actionWithTitle:@"确定"
                                 style:UIAlertActionStyleDefault
                               handler:nil];
        
        [alert addAction:action];
        
        [picker presentViewController:alert animated:YES completion:nil];
    }
    
    // limit selection to max
    return (picker.selectedAssets.count < max);
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets {
    [picker dismissViewControllerAnimated:YES completion:^{
        NSLog(@"Get %lu Assets", assets.count);
        [self.tableView beginUpdates];
        for (int i = 0; i < assets.count; i++) {
            PHAsset *asset = [assets objectAtIndex:i];
            PHImageManager *manager = [PHImageManager defaultManager];
            CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
            
            [manager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFit options:self.phImageRequestOptions resultHandler:^(UIImage * image, NSDictionary * _Nullable info) {
                
                ContentRecordImage *imageRecord = [self addImageRecord:image imagePath:nil];
                
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:imageRecord.indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                
                //[self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }];
        }
        [self.tableView endUpdates];
        [self.addImageBtn setEnabled:YES];
    }];
}

- (ContentRecordImage *)addImageRecord:(UIImage *)image imagePath:(NSString *)imagePath{
    ContentRecordImage *imageRecord = [[ContentRecordImage alloc]initWithType:ContentTypeImage];
    if (image) {
        imageRecord.image = image;
        imageRecord.uploaded = NO; // Set need to upload when a new image is set.
    }
    if (imagePath) {
        imageRecord.imagePath = imagePath;
    }
    
    imageRecord.updated = YES;
    
    [self.contentsArray addObject:imageRecord];
    
    self.imageViewCount++;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.contentsArray.count - 1 inSection:0];
    imageRecord.indexPath = indexPath;
    
    return imageRecord;
}

- (void)assetsPickerControllerDidCancel:(CTAssetsPickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{
        [self.addImageBtn setEnabled:YES];
    }];
}

#pragma mark - ImagePickerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if ([info objectForKey:UIImagePickerControllerOriginalImage]) {
        UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
        if (self.imageAction == IMAGE_ACTION_ADD) {
            ContentRecordImage *imageRecord = [[ContentRecordImage alloc]initWithType:ContentTypeImage];
            imageRecord.image = image;
            imageRecord.updated = YES;
            imageRecord.uploaded = NO;
            
            [self.contentsArray addObject:imageRecord];
            
            self.imageViewCount++;
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.contentsArray.count - 1 inSection:0];
            [self dismissViewControllerAnimated:YES completion:^{
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationBottom];
            }];
            
        }else if (self.imageAction == IMAGE_ACTION_EDIT) {
            ContentRecordImage *imageRecord = [self.contentsArray objectAtIndex:self.indexPath.row];
            imageRecord.image = image;
            imageRecord.updated = YES;
            imageRecord.uploaded = NO;
            
            [self dismissViewControllerAnimated:YES completion:^{
                
                //[self.tableView beginUpdates];
                [self.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                
                //[self.tableView endUpdates];
                //[self.tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            }];
        }
        self.imageAction = IMAGE_ACTION_NONE;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:^{
        self.imageAction = IMAGE_ACTION_NONE;
    }];
}


/**
 *  Upload Images, set the url to a new array:contentsArrayWithImagePath; Submit content after completion.
 */
/*- (IBAction)uploadImages {
    
    //self.contentsArrayWithImagePath = [NSMutableArray arrayWithArray:self.contentsArray];
    
    self.progressHud.mode = MBProgressHUDModeDeterminateHorizontalBar;
    self.progressHud.labelText = @"准备上传图片";
    NSMutableArray *records = [[NSMutableArray alloc]initWithCapacity:MAX_IMAGE_COUNT];
    
    NSUInteger counter = 0;
    for (int i = 0; i < self.contentsArray.count; i++) {
        ContentRecord *contentRecord = self.contentsArray[i];
        if (contentRecord.type == ContentTypeImage) {
            ContentRecordImage *contentRecordImage = (ContentRecordImage *)contentRecord;
            if (contentRecordImage.updated && !contentRecordImage.uploaded && contentRecordImage.image) {
                UIImage *image = contentRecordImage.image;
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                contentRecordImage.indexPath = indexPath;
                
                ImageRecord *record = [[ImageRecord alloc] init];
                record.image = image;
                [records addObject:record];
                
                // Init uploader with userInfo. i is the index of the dic in the content array. Use this param to update the content after upload image.
                ImageUploader *uploader = [[ImageUploader alloc]initWithRecord:record atIndex:[NSNumber numberWithInteger:counter] delegate:self userInfo:contentRecordImage.indexPath];
                if (counter > 0) {
                    [uploader addDependency:[self.uploadImageOperations.uploadQueue.operations lastObject]];
                }
                [self.uploadImageOperations.uploadsInProgress setObject:uploader forKey:[NSString stringWithFormat:@"%lu", counter]];
                [self.uploadImageOperations.uploadQueue addOperation:uploader];
                counter++;
            }
        }
    }
    if (counter == 0) {
        [self submitContents];
    }
}*/

#pragma mark ImageUploaderDelegate

/*- (void)imageUploaderDidGetProgress:(float)progress forUploader:(ImageUploader *)uploader {
    if (progress) {
        self.progressHud.labelText = [NSString stringWithFormat:@"正在上传第%ld张图片", [uploader.index integerValue] + 1];
        self.progressHud.progress = progress;
    }
}

- (void)imageUploaderDidFinish:(ImageUploader *)uploader {
    if ([uploader.record hasURL]) {
        NSString *imagePath = uploader.record.URL.absoluteString;
        //NSUInteger m = [(NSNumber *)uploader.info integerValue];
        NSIndexPath *indexPath = uploader.info;
        ContentRecordImage *imageRecord = [self.contentsArray objectAtIndex:indexPath.row];
        imageRecord.imagePath = imagePath;
        imageRecord.uploaded = YES;
        
        int n = uploader.index.intValue;
        [self.uploadImageOperations.uploadsInProgress removeObjectForKey:[NSString stringWithFormat:@"%d", n]];
        
        NSLog(@"upload Image success, index:%@\nRow:%lu\nURL String:%@", uploader.index, imageRecord.indexPath.row ,imagePath);
    }
    if (self.uploadImageOperations.uploadQueue.operationCount == 0) {
        self.progressHud.labelText = @"上传完成";
        //NSLog(@"After upload, content array:%@", self.contentsArrayWithImagePath);
        [self submitContents];
    }
}*/


- (IBAction)submitBtnPressed:(id)sender {
    if (self.currentTextView) {
        [self.currentTextView endEditing:YES];
    }
    
    NSMutableArray *messages = [[NSMutableArray alloc]initWithCapacity:10];
    if (self.contentsArray.count == 0) {
        NSString *message = @"请填写活动介绍";
        [messages addObject:message];
    }
    NSUInteger counter = 0;
    for (int i = 0; i < self.contentsArray.count; i++) {
        ContentRecord *record = [self.contentsArray objectAtIndex:i];
        if (record.updated) {
            counter++;
        }
    }
    if (counter == 0) {
        NSString *message = @"您还没有输入任何内容";
        [messages addObject:message];
    }
    
    if (messages.count > 0) {
        NSString *message = @"";
        for (int i = 0; i < messages.count; i++) {
            message = [message stringByAppendingString:messages[i]];
            if (i != messages.count - 1) {
                message = [message stringByAppendingString:@"\n"];
            }
        }
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:confirm];
        [self presentViewController:alert animated:YES completion:nil];
    }else {
        
        for (int i = 0; i < self.contentsArray.count; i++) {
            ContentRecord *record = [self.contentsArray objectAtIndex:i];
            if (!record.updated) {
                [self deleteRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        //[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        
        self.progressHud = [[MBProgressHUD alloc]initWithView:self.tableView.window];
        [self.tableView.window addSubview:self.progressHud];
        self.progressHud.dimBackground = YES;
        [self.progressHud show:YES];
        
        if (self.imageViewCount > 0) {
#warning Upload Images
//            [self uploadImages];
        }else {
            [self submitContents];
        }
    }
}


- (void)submitContents{
    if (!self.progressHud) {
        self.progressHud = [MBProgressHUD showHUDAddedTo:self.tableView animated:YES];
    }
    NSString *contentString = nil;
    
    for (int i = 0; i < self.contentsArray.count; i++) {
        if (i == 0) {
            contentString = @"[";
        }
        
        ContentRecord *record = [self.contentsArray objectAtIndex:i];
        if (record.contentString) {
            contentString = [contentString stringByAppendingString:record.contentString];
        }
        
        if (i < self.contentsArray.count - 1) {
            contentString = [contentString stringByAppendingString:@","];
        }else {
            contentString = [contentString stringByAppendingString:@"]"];
        }
    }
    if (contentString) {
        NSLog(@"Content String:%@", contentString);
        self.eventDic[@"content"] = contentString;
    }
    
    [self.progressHud setLabelText:@"正在发布，请稍候"];
#warning Submit to Server
    /*[[EventStore sharedStore]submitEvent:self.eventDic completionHandler:^(NSDictionary *eventInfo, BOOL isSuccess, NSError *error) {
        if (isSuccess) {
            self.progressHud.customView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"MBPCheckMark"]];
            self.progressHud.mode = MBProgressHUDModeCustomView;
            [self.progressHud setLabelText:@"发布成功"];
            [self.progressHud hide:YES afterDelay:1.0];
            self.progressHud.completionBlock = ^{
                if (self.editMode == EditModeUpdate) {
                    // Update Event details
                    [self.delegate_event eventUpdated:nil];
                }else {
                    // Update Event list
                    [self.delegate_event eventCreated:nil];
                }
                
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            };
            
        }else {
            [self.progressHud hide:YES afterDelay:0.0];
            NSLog(@"create event error:%@", error);
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"提交活动信息失败" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"返回" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                
            }];
            UIAlertAction *quit = [UIAlertAction actionWithTitle:@"放弃编辑" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            }];
            [alert addAction:action];
            [alert addAction:quit];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];*/
}


#pragma mark - Table View Delegate

/*- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }*/

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView willBeginEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Will delete");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger n = self.contentsArray.count;
    //NSLog(@"rows count:%ld", n);
    
    return n;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ContentRecord *record = [self.contentsArray objectAtIndex:indexPath.row];
    if (record.type == ContentTypeText) {
        EditContentTextCell *textCell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
        if (!textCell) {
            textCell = [[EditContentTextCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textCell"];
        }
        
        [textCell setRecord:record];
        [self addDoneToolBarToKeyboard:textCell.textView];
        
        textCell.contentCellDelegate = self;
        textCell.delegate = self;
        
        [textCell setNeedsUpdateConstraints];
        [textCell updateFocusIfNeeded];
        
        return textCell;
    }else if (record.type == ContentTypeImage) {
        EditContentImageCell *imageCell = [tableView dequeueReusableCellWithIdentifier:@"imageCell" forIndexPath:indexPath];
        if (!imageCell) {
            imageCell = [[EditContentImageCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"imageCell"];
        }
        
        [imageCell setRecord:record];
        
        imageCell.contentCellDelegate = self;
        imageCell.delegate = self;
        
        [imageCell setNeedsUpdateConstraints];
        [imageCell updateConstraintsIfNeeded];
        
        return imageCell;
    }else {
        //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        return nil;
    }
}


/*- (void)leftSwipeForCell:(UISwipeGestureRecognizerWithData *)swipeGesture {
 NSLog(@"left swipe");
 if ([swipeGesture.userData isKindOfClass:[EditContentTextCell class]]) {
 EditContentTextCell *textCell = swipeGesture.userData;
 NSIndexPath *indexPath = [self.tableView indexPathForCell:textCell];
 
 //[self tableView:self.tableView willBeginEditingRowAtIndexPath:indexPath];
 [self tableView:self.tableView commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
 }
 }*/


// Override to support conditional editing of the table view.
/*- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }*/



/*// Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 NSLog(@"deleting cell from row %ld", indexPath.row);
 [self deleteRowAtIndexPath:indexPath];
 //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 NSLog(@"Inserting cell to row %ld", indexPath.row);
 }
 }*/



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    
    NSLog(@"Moving Row From %ld, to %ld\n contents array:%@", fromIndexPath.row, toIndexPath.row, self.contentsArray);
    // Update the indexPath property of record.
    
    [self.contentsArray exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    
    [self.tableView beginUpdates];
    [self.tableView reloadRowsAtIndexPaths:@[fromIndexPath, toIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.tableView endUpdates];
    NSLog(@"Move complete: contents array:%@", self.contentsArray);
}


/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - EditContentCellDelegate

- (void)didUpdateContent:(EditContentTableViewCell *)cell {
    
}

- (void)selectImageForCell:(EditContentTableViewCell *)cell {
    if (self.currentTextView) {
        [self.currentTextView endEditing:YES];
    }
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    NSLog(@"Updating cell in row %ld", indexPath.row);
    self.indexPath = indexPath;
    self.imageAction = IMAGE_ACTION_EDIT;
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.allowsEditing = NO;
    imagePicker.delegate = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];
        [alert addAction:cameraAction];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertAction *libraryAction = [UIAlertAction actionWithTitle:@"选择图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            /*ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc]initImagePicker];
             //elcPicker.maximumImagesCount = (EDIT_EVENT_MAX_IMAGE_COUNT - self.imageViewCount + 1); //Set the maximum number of images
             elcPicker.maximumImagesCount = 1;
             elcPicker.returnsOriginalImage = YES; //Only return the fullScreenImage, not the fullResolutionImage
             elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
             elcPicker.onOrder = YES; //For multiple image selection, display and return order of selected images
             elcPicker.mediaTypes = @[(NSString *)kUTTypeImage, (NSString *)kUTTypeMovie]; //Supports image and movie types
             
             elcPicker.imagePickerDelegate = self;*/
            
            
            [self presentViewController:imagePicker animated:YES completion:nil];
        }];
        [alert addAction:libraryAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)textViewDidBeginEditingForCell:(EditContentTableViewCell *)cell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.indexPath = indexPath;
    
    EditContentTextCell *textCell = (EditContentTextCell *)cell;
    self.currentTextView = textCell.textView;
    [self.currentTextView becomeFirstResponder];
    [self.currentTextView setBackgroundColor:[UIColor yellowColor]];
    self.currentTextView.layer.borderWidth = 1.0;
    self.currentTextView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.currentTextView.layer.cornerRadius = 8;
    if ([self.currentTextView.text isEqualToString:TEXTVIEW_PLACEHOLDER]) {
        self.currentTextView.text = @"";
    }
    
    NSLog(@"Editing textView at:%@", indexPath);
}

- (void)textViewDidEndEditingForCell:(EditContentTableViewCell *)cell {
    
    [self.currentTextView resignFirstResponder];
    self.currentTextView.backgroundColor = [UIColor whiteColor];
    self.currentTextView.layer.borderWidth = 0.25;
    //    textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.currentTextView.layer.cornerRadius = 8;
    if ([self.currentTextView.text isEqualToString:@""]) {
        self.currentTextView.text = TEXTVIEW_PLACEHOLDER;
    }else {
        ContentRecordText *textRecord = [self.contentsArray objectAtIndex:self.indexPath.row];
        textRecord.text = self.currentTextView.text;
        textRecord.updated = YES;
    }
}

#pragma mark -MGSwipeTableCellDelegate

- (NSArray *)swipeTableCell:(MGSwipeTableCell *)cell swipeButtonsForDirection:(MGSwipeDirection)direction swipeSettings:(MGSwipeSettings *)swipeSettings expansionSettings:(MGSwipeExpansionSettings *)expansionSettings {
    swipeSettings.transition = MGSwipeTransitionRotate3D;
    if (direction == MGSwipeDirectionRightToLeft) {
        if ([cell isKindOfClass:[EditContentTextCell class]]) {
            EditContentTextCell *textCell = (EditContentTextCell *)cell;
            [textCell.textView endEditing:YES];
        }
        
        cell.rightButtons = nil;
        
        expansionSettings.fillOnTrigger = YES;
        expansionSettings.threshold = 1.1;
        CGFloat padding = 15;
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        NSLog(@"Swiping row:%ld", indexPath.row);
        
        MGSwipeButton *delete = [MGSwipeButton buttonWithTitle:@"删除" backgroundColor:[UIColor redColor] callback:^BOOL(MGSwipeTableCell *sender) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            [self deleteRowAtIndexPath:indexPath];
            return NO;
        }];
        
        MGSwipeButton *moveUp = [MGSwipeButton buttonWithTitle:@"上移" backgroundColor:[UIColor grayColor] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            
            //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:0];
            [self moveRowFromIndexPath:indexPath toIndexPath:newIndexPath];
            
            return NO;
        }];
        
        MGSwipeButton *moveDown = [MGSwipeButton buttonWithTitle:@"下移" backgroundColor:[UIColor lightGrayColor] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0];
            [self moveRowFromIndexPath:indexPath toIndexPath:newIndexPath];
            
            return NO;
        }];
        
        MGSwipeButton *editImage = [MGSwipeButton buttonWithTitle:@"编辑" backgroundColor:[UIColor darkGrayColor] padding:padding callback:^BOOL(MGSwipeTableCell *sender) {
            //EditContentImageCell *imageCell = (EditContentImageCell *)sender;
            ContentRecordImage *imageRecord = [self.contentsArray objectAtIndex:indexPath.row];
            CLImageEditor *editor = [[CLImageEditor alloc]initWithImage:imageRecord.image];
            editor.delegate = self;
            self.indexPath = indexPath;
            [self presentViewController:editor animated:YES completion:nil];
            
            return YES;
        }];
        
        NSMutableArray *buttons = [[NSMutableArray alloc]initWithCapacity:3];
        [buttons addObject:delete];
        
        if (indexPath.row > 0) {
            NSLog(@"indexPath:%ld, adding move up btn", indexPath.row);
            [buttons addObject:moveUp];
        }
        
        if (indexPath.row < self.contentsArray.count - 1) {
            NSLog(@"indexPath:%ld, adding move down btn", indexPath.row);
            [buttons addObject:moveDown];
        }
        
        if ([cell isKindOfClass:[EditContentImageCell class]]) {
            [buttons addObject:editImage];
        }
        
        return buttons;
    }
    return nil;
}

#pragma mark- CLImageEditor delegate

- (void)imageEditor:(CLImageEditor *)editor didFinishEdittingWithImage:(UIImage *)image
{
    //_imageView.image = image;
    //EditContentImageCell *imageCell = (EditContentImageCell *)[self.tableView cellForRowAtIndexPath:self.indexPath];
    ContentRecordImage *imageRecord = [self.contentsArray objectAtIndex:self.indexPath.row];
    imageRecord.image = image;
    imageRecord.uploaded = NO;
    
    [editor dismissViewControllerAnimated:YES completion:^{
        //[self.tableView beginUpdates];
        //[self.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView reloadData];
        //[self.tableView endUpdates];
    }];
}

#pragma mark -


- (void)deleteRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"Before delete, content count:%ld", self.contentsArray.count);
    [self.contentsArray removeObjectAtIndex:indexPath.row];
    
    EditContentTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell.record.type == ContentTypeText) {
        self.textViewCount--;
    }else if(cell.record.type == ContentTypeImage) {
        self.imageViewCount--;
    }
    
    NSLog(@"After delete, content count:%ld", self.contentsArray.count);
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
}

- (void)moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath{
    NSLog(@"table view editing:%d", self.tableView.editing);
    
    [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    
    [self tableView:self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    
    
}


-(void)addDoneToolBarToKeyboard:(UITextView *)textView
{
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    doneToolbar.barStyle = UIBarStyleDefault;
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"完成" style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)],
                         nil];
    [doneToolbar sizeToFit];
    textView.inputAccessoryView = doneToolbar;
}



- (void)dismissKeyboard {
    [self.currentTextView endEditing:YES];
    [self.currentTextView resignFirstResponder];
}



/*- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info {
 
 for (int i = 0; i < info.count; i++) {
 NSDictionary *dict = info[i];
 if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypePhoto){
 if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
 UIImage* image=[dict objectForKey:UIImagePickerControllerOriginalImage];
 [self.selectedImages addObject:image];
 
 //NSDictionary *imageContent = [[NSDictionary alloc]initWithObjectsAndKeys:image, @"content", @"image", @"type", nil];
 ContentRecordImage *imageRecord = [self.contentsArray objectAtIndex:self.indexPath.row];
 imageRecord.image = image;
 imageRecord.updated = YES;
 
 //[self.contentsArray replaceObjectAtIndex:self.indexPath.row withObject:imageContent];
 //NSLog(@"Replace ImageCell Info:%@", imageContent);
 
 } else {
 NSLog(@"UIImagePickerControllerReferenceURL = %@", dict);
 }
 } else if ([dict objectForKey:UIImagePickerControllerMediaType] == ALAssetTypeVideo){
 if ([dict objectForKey:UIImagePickerControllerOriginalImage]){
 
 
 } else {
 }
 } else {
 NSLog(@"Uknown asset type");
 }
 }
 
 [self dismissViewControllerAnimated:YES completion:^{
 
 [self.tableView beginUpdates];
 [self.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
 
 
 [self.tableView endUpdates];
 [self.tableView scrollToRowAtIndexPath:self.indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
 }];
 }
 
 - (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker {
 [self dismissViewControllerAnimated:YES completion:^{
 
 }];
 }*/

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
