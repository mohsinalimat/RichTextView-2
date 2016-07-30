//
//  ViewController.m
//  InputimageExample
//
//  Created by zorro on 15/3/6.
//  Copyright (c) 2015年 tutuge. All rights reserved.
//

#import "RichTextViewController.h"



#import "ImageTextAttachment.h"
#import "NSAttributedString+RichText.h"
#import "PictureModel.h"
#import "NSAttributedString+html.h"

//Image default max size
#define IMAGE_MAX_SIZE ([UIScreen mainScreen].bounds.size.width-10)

#define ImageTag (@"[UIImageView]")
#define DefaultFont (16)
#define MaxLength (2000)

@interface RichTextViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;


//设置
@property (nonatomic,assign) NSRange newRange;
@property (nonatomic,strong) NSString * newstr;
@property (nonatomic,assign) BOOL isBold;          //是否加粗
@property (nonatomic,strong) UIColor * fontColor;  //字体颜色
@property (nonatomic,assign) CGFloat  font;        //字体大小
@property (nonatomic,assign) NSUInteger location;  //纪录变化的起始位置
@property (nonatomic,strong) NSMutableAttributedString * locationStr;

@property (nonatomic,assign) CGFloat lineSapce;    //行间距
@property (nonatomic,assign) BOOL isDelete;        //是否是回删



@end

@implementation RichTextViewController
+(instancetype)ViewController
{
    RichTextViewController * ctrl=[[UIStoryboard storyboardWithName:@"RichText" bundle:nil]instantiateViewControllerWithIdentifier:@"RichTextViewController"];
    
    return ctrl;
}

-(void)CommomInit
{
    self.textView.delegate=self;
    //显示链接，电话
    self.textView.dataDetectorTypes = UIDataDetectorTypeAll;
    self.font=DefaultFont;
    self.fontColor=[UIColor blackColor];
    self.location=0;
    self.isBold=NO;
    self.lineSapce=5;
    [self setInitLocation];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //Init text font
    
    [self resetTextStyle];

    //Add keyboard notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onKeyboardNotification:) name:UIKeyboardWillShowNotification object:nil];
    
    
    UIBarButtonItem * backItem=[[UIBarButtonItem alloc]initWithTitle:@"back" style:UIBarButtonItemStylePlain target:self action:@selector(backClick)];
    
    self.navigationItem.leftBarButtonItem=backItem;
}

//返回保存数据
-(void)backClick
{
    [self finishClick:nil];
    
    [self.navigationController popViewControllerAnimated:YES];
}




- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)resetTextStyle {
    //After changing text selection, should reset style.
    [self CommomInit];
    NSRange wholeRange = NSMakeRange(0, _textView.textStorage.length);
    
    
    [_textView.textStorage removeAttribute:NSFontAttributeName range:wholeRange];
    [_textView.textStorage removeAttribute:NSForegroundColorAttributeName range:wholeRange];
    
    //字体颜色
    [_textView.textStorage addAttribute:NSForegroundColorAttributeName value:self.fontColor range:wholeRange];
    
    //字体加粗
    if (self.isBold) {
        [_textView.textStorage addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:self.font] range:wholeRange];
    }
    //字体大小
    else
    {
        
        [_textView.textStorage addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:self.font] range:wholeRange];
    }
    
    
    
}
-(void)setInitLocation
{
    
    
    self.locationStr=nil;
    self.locationStr=[[NSMutableAttributedString alloc]initWithAttributedString:self.textView.attributedText];
   
    
}
-(void)setStyle
{
    
    
    //把最新的内容进行替换
    [self setInitLocation];
    
    
    if (self.isDelete) {
        return;
    }
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = self.lineSapce;// 字体的行间距
    NSDictionary *attributes=nil;
    if (self.isBold) {
        attributes = @{
                       NSFontAttributeName:[UIFont boldSystemFontOfSize:self.font],
                       NSForegroundColorAttributeName:self.fontColor,
                       NSParagraphStyleAttributeName:paragraphStyle
                       };
        
    }
    else
    {
        attributes = @{
                       NSFontAttributeName:[UIFont systemFontOfSize:self.font],
                       NSForegroundColorAttributeName:self.fontColor,
                       NSParagraphStyleAttributeName:paragraphStyle
                       };
        
    }
    
    NSAttributedString * replaceStr=[[NSAttributedString alloc] initWithString:self.newstr attributes:attributes];
    [self.locationStr replaceCharactersInRange:self.newRange withAttributedString:replaceStr];
   
    _textView.attributedText =self.locationStr;
    
    //这里需要把光标的位置重新设定
    self.textView.selectedRange=NSMakeRange(self.newRange.location+self.newRange.length, 0);
   
}
#pragma mark textViewDelegate
/**
 *  点击图片触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange
{
    NSLog(@"%@", textAttachment);
    return NO;
}

/**
 *  点击链接，触发代理事件
 */
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange
{
    [[UIApplication sharedApplication] openURL:URL];
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    //    textview 改变字体的行间距
    
    
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
   
    if (range.length == 1)     // 回删
    {
       
        return YES;
    }
    else
    {
        
        // 超过长度限制
        if ([textView.text length] >= MaxLength+3)
        {
            
            return NO;
        }
    }

    
    return YES;
}
//- (void)textViewDidChangeSelection:(UITextView *)textView;
//{
//    NSLog(@"焦点改变");
//}
-(void)textViewDidChange:(UITextView *)textView
{
    NSInteger len=textView.attributedText.length-self.locationStr.length;

    
    if (len>0) {
       
        self.isDelete=NO;
        self.newRange=NSMakeRange(self.textView.selectedRange.location-len, len);
        self.newstr=[textView.text substringWithRange:self.newRange];
 
    }
    else
    {
        self.isDelete=YES;

    }
   
    
    bool isChinese;//判断当前输入法是否是中文
    
    NSArray *currentar = [UITextInputMode activeInputModes];
    UITextInputMode *textInputMode = [currentar firstObject];
    
    if ([[textInputMode primaryLanguage] isEqualToString: @"en-US"]) {
        isChinese = false;
    }
    else
    {
        isChinese = true;
    }
   
    NSString *str = [[ self.textView text] stringByReplacingOccurrencesOfString:@"?" withString:@""];
    if (isChinese) { //中文输入法下
        
        
        
        UITextRange *selectedRange = [ self.textView markedTextRange];
        
        
        //获取高亮部分
        UITextPosition *position = [ self.textView positionFromPosition:selectedRange.start offset:0];
      
       
        
        // 没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
//            NSLog(@"汉字");
//              NSLog(@"str=%@; 本次长度=%lu",str,(unsigned long)[str length]);
           
            [self setStyle];
            if ( str.length>=MaxLength) {
                NSString *strNew = [NSString stringWithString:str];
                [ self.textView setText:[strNew substringToIndex:MaxLength]];
            }
        }
        else
        {
//            NSLog(@"没有转化--%@",str);
            if ([str length]>=MaxLength+10) {
                NSString *strNew = [NSString stringWithString:str];
                [ self.textView setText:[strNew substringToIndex:MaxLength+10]];
            }
            
        }
    }else{
//        NSLog(@"英文");
      
        [self setStyle];
        if ([str length]>=MaxLength) {
            NSString *strNew = [NSString stringWithString:str];
            [ self.textView setText:[strNew substringToIndex:MaxLength]];
        }
    }
    
    
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    
    
}
#pragma mark - Action
//完成
- (IBAction)finishClick:(UIButton *)sender {

    //注意这下面的三种 数据
//    NSLog(@"textStorage。getPlainString--%@",[_textView.textStorage getPlainString]);
//    NSLog(@"attributedText。getPlainString--%@",[_textView.attributedText getPlainString]);
//    NSLog(@"attributedText--%@",self.textView.attributedText);
    if (self.feedbackHtml) {
        if ([self.RTDelegate respondsToSelector:@selector(uploadImageArray:withCompletion:)]) {
            //实现上传图片的代理，用url替换图片标识
            
            __weak typeof(self) weakself=self;
            
            [self.RTDelegate uploadImageArray:[_textView.attributedText getImgaeArray] withCompletion:^NSString *(NSArray *urlArray) {
                 return  [weakself replacetagWithImageArray:urlArray];
            }];
        }
    }
    else
    {

        //这个是返回数组，每个数组装有不同设置的字符串
        if (self.finished!=nil) {
            self.finished([_textView.attributedText getArrayWithAttributed]);
            
        }
 
    }
    
}
//颜色设置
- (IBAction)colorClick:(UIButton *)sender {
    
    sender.selected=!sender.selected;
    if (sender.selected) {
        self.fontColor=[UIColor redColor];
        
    }
    else
    {
        
        self.fontColor=[UIColor blackColor];
    }
    
    [sender setTintColor:self.fontColor];
    
    
    //设置字的设置
    [self setInitLocation];
    

    
    
    
}
//加粗
- (IBAction)boldClick:(UIButton *)sender {
    
    sender.selected=!sender.selected;
    self.isBold=sender.selected;
    if (self.isBold) {
        sender.titleLabel.font=[UIFont systemFontOfSize:12];
        
        
    }
    else
    {
        
        sender.titleLabel.font=[UIFont boldSystemFontOfSize:12];
    }
    
    //设置字的设置
    [self setInitLocation];
}
//字体设置
- (IBAction)fontClick:(UIButton *)sender {
    
    sender.selected=!sender.selected;
    if (sender.selected) {
        self.font=25.f;
        [sender setTitle:[NSString stringWithFormat:@"字体 %.f",self.font] forState:UIControlStateSelected];
    }
    else
    {
        self.font=DefaultFont;
        [sender setTitle:[NSString stringWithFormat:@"字体 %.f",self.font] forState:UIControlStateNormal];
    }
    
    //设置字的设置
    [self setInitLocation];
}
//选择图片
- (IBAction)imageClick:(UIButton *)sender {
    [self.view endEditing:YES];
    

    
    
    __weak typeof(self) weakSelf=self;
    UIAlertController * alertVC=[UIAlertController alertControllerWithTitle:@"选择照片" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf selectedImage];
    }]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];

    [self presentViewController:alertVC animated:YES completion:nil];
    
    
}
-(void)selectedImage
{
    
    NSUInteger sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    
    imagePickerController.delegate = self;
    
    imagePickerController.allowsEditing = YES;
    
    imagePickerController.sourceType = sourceType;
    
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}


#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [self appenReturn];
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    //    // 保存图片至本地，方法见下文
    //    NSLog(@"img = %@",image);
    image = [self compressImage:image toMaxFileSize:0.2];
    
    
    ImageTextAttachment *imageTextAttachment = [ImageTextAttachment new];
    
    image=[imageTextAttachment scaleImage:image withSize:CGSizeMake(IMAGE_MAX_SIZE, IMAGE_MAX_SIZE/2)];
    //Set tag and image
    imageTextAttachment.imageTag = ImageTag;
    imageTextAttachment.image =image;
    
    //Set image size
    imageTextAttachment.imageSize = CGSizeMake(IMAGE_MAX_SIZE, IMAGE_MAX_SIZE/2);
    
    //Insert image image
    [_textView.textStorage insertAttributedString:[NSAttributedString attributedStringWithAttachment:imageTextAttachment]
                                          atIndex:_textView.selectedRange.location];
    
    //Move selection location
    _textView.selectedRange = NSMakeRange(_textView.selectedRange.location + 1, _textView.selectedRange.length);
    
    
    //设置字的设置
    [self setInitLocation];
    
    [self appenReturn];
    
}

- (UIImage *)compressImage:(UIImage *)image toMaxFileSize:(NSInteger)maxFileSize {
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    while ([imageData length] > maxFileSize && compression > maxCompression) {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
    UIImage *compressedImage = [UIImage imageWithData:imageData];
    return compressedImage;
}

-(void)appenReturn
{
    NSAttributedString * returnStr=[[NSAttributedString alloc]initWithString:@"\n"];
    NSMutableAttributedString * att=[[NSMutableAttributedString alloc]initWithAttributedString:_textView.attributedText];
    [att appendAttributedString:returnStr];
    
    _textView.attributedText=att;
}
#pragma mark - Keyboard notification

- (void)onKeyboardNotification:(NSNotification *)notification {
    //Reset constraint constant by keyboard height
    if ([notification.name isEqualToString:UIKeyboardWillShowNotification]) {
        CGRect keyboardFrame = ((NSValue *) notification.userInfo[UIKeyboardFrameEndUserInfoKey]).CGRectValue;
        _bottomConstraint.constant = keyboardFrame.size.height;
    } else if ([notification.name isEqualToString:UIKeyboardWillHideNotification]) {
        _bottomConstraint.constant = -40;
    }
    
    //Animate change
    [UIView animateWithDuration:0.8f animations:^{
        [self.view layoutIfNeeded];
    }];
}




//这里就开始上传图片，拼接图片地址
-(NSString *)replacetagWithImageArray:(NSArray *)picArr
{

//    NSMutableAttributedString * contentStr=[[NSMutableAttributedString alloc]initWithAttributedString:_textView.attributedText];
//    NSInteger count=0;
//    [contentStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, contentStr.length)
//                     options:0
//                  usingBlock:^(id value, NSRange range, BOOL *stop) {
//                      if (value && [value isKindOfClass:[ImageTextAttachment class]]) {
//                  
//                          if (count<picArr.count) {
//                              PictureModel *picture=[picArr objectAtIndex:count];
//                              NSString * imgTag=[NSString stringWithFormat:@"<img src=\"%@\" w=\"%lu\" h=\"%lu\"/>",picture.imageurl,(unsigned long)picture.width,(unsigned long)picture.height];
////                              imgTag = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)imgTag, nil, nil, kCFStringEncodingUTF8));
//                              
////                             imgTag = [imgTag stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//                              [contentStr replaceCharactersInRange:range withString:imgTag];
//                          }
//                          else
//                          {
//                              *stop=YES;
//                          }
//                          
//                      }
//                  }];
//
//    
//    return [contentStr toHtmlString];
    
    
    NSMutableAttributedString * contentStr=[[NSMutableAttributedString alloc]initWithAttributedString:_textView.attributedText];

    [contentStr enumerateAttribute:NSAttachmentAttributeName inRange:NSMakeRange(0, contentStr.length)
                           options:0
                        usingBlock:^(id value, NSRange range, BOOL *stop) {
                            if (value && [value isKindOfClass:[ImageTextAttachment class]]) {

                                [contentStr replaceCharactersInRange:range withString:ImageTag];

                            }
                        }];
    

    NSMutableString * mutableStr=[[NSMutableString alloc]initWithString:[contentStr toHtmlString]];
    
    //这里是把字符串分割成数组，
    NSArray * strArr=[mutableStr  componentsSeparatedByString:ImageTag];


    NSString * newContent=@"";
    for (int i=0; i<strArr.count; i++) {
        PictureModel * picture=nil;
        NSString * imgTag=@"";
        if (i<picArr.count) {
            picture=[picArr objectAtIndex:i];
            imgTag=[NSString stringWithFormat:@"<img src=\"%@\" w=\"%lu\" h=\"%lu\"/>",picture.imageurl,(unsigned long)picture.width,(unsigned long)picture.height];
        }

        
        
        //因为cutstr 可能是null
        NSString * cutStr=[strArr objectAtIndex:i];
        newContent=[NSString stringWithFormat:@"%@%@%@",newContent,cutStr,imgTag];
        
    }
    
    return newContent;

}
@end
