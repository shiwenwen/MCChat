

#import "UITool.h"



#pragma mark - <1.Image>
@implementation ImageTool

+ (UIImage *)createImageWithColor:(UIColor *)color size:(CGSize)size;
{
    CGRect rect = CGRectZero;
    rect.size = size;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage*)resizeImageToSize:(CGSize)size image:(UIImage*)image
{
    UIGraphicsBeginImageContext(size);
    //获取上下文内容
    CGContextRef ctx= UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, 0.0, size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);
    //重绘image
    CGContextDrawImage(ctx,CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
    //根据指定的size大小得到新的image
    UIImage* scaled= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaled;
}

+ (UIImage *)imageFromView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.frame.size); //currentView 当前的view
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //从全屏中截取指定的范围
    CGImageRef imageRef = viewImage.CGImage;
    UIImage * sendImage = [[UIImage alloc] initWithCGImage:imageRef];
    return sendImage;
}

/**返回指定视图中指定范围生成的image图片*/
+ (UIImage *)imageFromView:(UIView *)view inRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(view.frame.size); //currentView 当前的view
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //从全屏中截取指定的范围
    CGImageRef imageRef = viewImage.CGImage;
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage * image = [[UIImage alloc] initWithCGImage:imageRefRect];
    CGImageRelease(imageRefRect);
    return image;
}

+ (void)writeImageToSavedPhotosAlbum:(UIImage *)image
{
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
}

@end


#pragma mark - <2.Color>
@implementation ColorTool

+ (UIColor *)createColorWithR:(NSInteger)red G:(NSInteger)green B:(NSInteger)blue
{
    return [UIColor colorWithRed:(double)red/255.0f green:(double)green/255.0f blue:(double)blue/255.0f alpha:1.0f];
}

+ (UIColor *)createColorWithR:(NSInteger)red G:(NSInteger)green B:(NSInteger)blue alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:(double)red/255.0f green:(double)green/255.0f blue:(double)blue/255.0f alpha:alpha];
}

@end


#pragma mark - <3.DeviceAttribute>
@implementation DeviceAttributeTool

//获取屏幕宽度
+(CGFloat)currentScreenWidth
{
    return [UIScreen mainScreen].bounds.size.width;
}

//获取屏幕高度
+(CGFloat)currentScreenHeight
{
    return [UIScreen mainScreen].bounds.size.height;
}

//获取屏幕大小
+(CGSize)currentScreenSize{
    return [UIScreen mainScreen].bounds.size;
}
//获取操作系统版本号
+(NSString *)currentVersion{
    return [UIDevice currentDevice].systemVersion;
}
//获取设备型号
+(NSString *)currentModel{
    return [UIDevice currentDevice].model;
}

@end

#pragma mark - <4.TableView>
@implementation TableViewTool
+ (UITableView *)createTableViewWithFrame:(CGRect)frame viewController:(UIViewController<UITableViewDataSource, UITableViewDelegate> *)vc
{
    vc.automaticallyAdjustsScrollViewInsets = NO;
    return [TableViewTool createTableViewWithFrame:frame superView:vc.view delegate:vc];
}


+ (UITableView *)createTableViewWithFrame:(CGRect)frame superView:(UIView *)view delegateViewController:(UIViewController<UITableViewDataSource, UITableViewDelegate> *)delegate;
{
    delegate.automaticallyAdjustsScrollViewInsets = NO;
    return [TableViewTool createTableViewWithFrame:frame superView:delegate.view delegate:delegate];
}

+ (UITableView *)createTableViewWithFrame:(CGRect)frame superView:(UIView *)view delegate:(id<UITableViewDataSource, UITableViewDelegate>)delegate
{
    UITableView * tv = [[UITableView  alloc]initWithFrame:frame style:UITableViewStylePlain];
    tv.delegate = delegate;
    tv.dataSource = delegate;
//    tv.separatorStyle = UITableViewCellSeparatorStyleNone;
    [view addSubview:tv];
    return tv;
}

@end

#pragma mark - <5.GestureRecognizerTool>
@implementation GestureRecognizerTool
+ (void)addGestureInView:(UIView *)view target:(id)target action:(SEL)action
{
    [self addSingleGestureInView:view target:target action:action];
}

+ (UITapGestureRecognizer *)addSingleGestureInView:(UIView *)view target:(id)target action:(SEL)action
{
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:target action:action];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [view addGestureRecognizer:tapGesture];
    return tapGesture;
}

@end

#pragma mark - <6.ButtonTool>
@implementation ButtonTool

+ (UIButton *)createButtonWithImageName:(NSString *)imageName addTarget:(id)target action:(SEL)action
{
    UIButton * btn = [[UIButton alloc] init];
    [btn setImage:[UIImage imageNamed:imageName] forState:(UIControlStateNormal)];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}
+ (UIButton *)createButtonWithBGImageName:(NSString *)bgImageName addTarget:(id)target action:(SEL)action
{
    UIButton * btn = [[UIButton alloc] init];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateNormal];
    return btn;
}

+ (UIButton *)createButtonWithBGImageName:(NSString *)bgImageName addTarget:(id)target action:(SEL)action title:(NSString *)title titleColor:(UIColor *)titleColor
{
    return [self createButtonWithBGImageName:bgImageName addTarget:target action:action title:title titleColor:titleColor isSizeToFit:YES];
}

+ (UIButton *)createButtonWithBGImageName:(NSString *)bgImageName addTarget:(id)target action:(SEL)action title:(NSString *)title titleColor:(UIColor *)titleColor isSizeToFit:(BOOL)isSizeToFit
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateNormal];
    [btn setTitle:title forState:UIControlStateNormal];
    if (titleColor) {
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
    }else {
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    if (isSizeToFit) {
        [btn sizeToFit];
    }
    return btn;
}

+ (UIButton *)createButtonWithBGImageName:(NSString *)bgImageName addTarget:(id)target action:(SEL)action title:(NSString *)title titleColor:(UIColor *)titleColor superView:(UIView *)superView
{
    UIButton * btn = [self createButtonWithBGImageName:bgImageName addTarget:target action:action title:title titleColor:titleColor];
    [superView addSubview:btn];
    return btn;
}

+ (UIButton *)createButtonWithTitle:(NSString *)title titleColor:(UIColor *)titleColor titleFont:(UIFont *)font addTarget:(id)target action:(SEL)action
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = font;
    if (titleColor) {
        [btn setTitleColor:titleColor forState:UIControlStateNormal];
    }else {
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    [btn sizeToFit];
    return btn;
}

+ (void)addTarget:(id)target action:(SEL)action onButton:(UIButton *)btn
{
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

+ (UIButton *)createButtonWithBGNormalImageName:(NSString *)bgImageName hightImageName:(NSString *)hightImageName addTarget:(id)target action:(SEL)action isSizeToFit:(BOOL)isSizeToFit
{
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setBackgroundImage:[UIImage imageNamed:bgImageName] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:hightImageName] forState:UIControlStateHighlighted];
    if (isSizeToFit) {
        [btn sizeToFit];
    }
    return btn;
}

+ (void)setTitle:(NSString *)title color:(UIColor *)color font:(NSInteger)fontSize onButton:(UIButton *)btn
{
    [btn setTitle:title forState:(UIControlStateNormal)];
    [btn setTitleColor:color forState:(UIControlStateNormal)];
    // 设置字体为冬青黑简
    btn.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W3" size:fontSize];
}

/*
 改变按钮
 */
//设置按钮圆角
+ (void)setBtnCorner:(UIButton *)btn
{
    
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 5.0;
//    btn.layer.borderWidth = 0.5;
    //btn.layer.borderColor = [[UIColor lightGrayColor] CGColor];
}

@end
#pragma mark - <7.LabelTool>
@implementation LabelTool

+ (UILabel *)createLableWithFrame:(CGRect)frame textColor:(UIColor *)textColor textFontOfSize:(CGFloat)size;
{
    UILabel * lab = [[UILabel alloc]initWithFrame:frame];
    if (textColor) {
        lab.textColor = textColor;
    }else {
        lab.textColor = [UIColor blackColor];
    }
    lab.backgroundColor = [UIColor clearColor];
    lab.font = [UIFont systemFontOfSize:size];
    return lab;
}

+ (UILabel *)createLableWithFrame:(CGRect)frame textColor:(UIColor *)textColor font:(UIFont *)font
{
    UILabel * lab = [[UILabel alloc]initWithFrame:frame];
    if (textColor) {
        lab.textColor = textColor;
    }else {
        lab.textColor = [UIColor blackColor];
    }
    lab.backgroundColor = [UIColor clearColor];
    lab.font = font;
    
    return lab;
}

+ (UILabel *)createLableWithTextColor:(UIColor *)textColor textFontOfSize:(CGFloat)size
{
    UILabel * lab = [[UILabel alloc]init];
    if (textColor) {
        lab.textColor = textColor;
    }else {
        lab.textColor = [UIColor blackColor];
    }
    lab.backgroundColor = [UIColor clearColor];
    lab.font = [UIFont systemFontOfSize:size];
    return lab;
}

+ (UILabel *)createLableWithTextColor:(UIColor *)textColor font:(UIFont *)font
{
    UILabel * lab = [[UILabel alloc]init];
    if (textColor) {
        lab.textColor = textColor;
    }else {
        lab.textColor = [UIColor blackColor];
    }
    lab.backgroundColor = [UIColor clearColor];
    lab.font = font;
    
    return lab;
}

@end

#pragma mark - <8.LayoutConstraintTool>

@implementation LayoutConstraintTool

+ (NSArray *)constraintsWithVisualFormat:(NSString *)format views:(NSDictionary *)views
{
    return [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:views];
}

@end

#pragma mark - <9.ScrollViewTool>

@implementation ScrollViewTool

+ (UIScrollView *)createScrollView
{
    UIScrollView * sv = [[UIScrollView alloc]init];
    sv.showsHorizontalScrollIndicator = NO;
    sv.showsVerticalScrollIndicator = NO;
    return sv;
}


@end


@implementation UITool

//是否包含emoji表情
+ (BOOL)stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}

//  设置千分位格式显示
+ (NSString *) stringFromNumber:(NSNumber *)number {
    NSString *str;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc]init];
    formatter.numberStyle =kCFNumberFormatterCurrencyStyle;
//    [formatter setPositiveFormat:@"*,***,***.00"];
//    formatter.currencyCode = @"";
    formatter.currencySymbol = @"";
    str = [formatter stringFromNumber:number];
    return str;
}

/*****
 * 区分ios7计算字符串高度
 *
 * str   字符串
 * font  字体
 * size  区域
 * mode  折行方式
 */
+(CGSize)sizeOfStr:(NSString *)str andFont:(UIFont *)font andMaxSize:(CGSize)size andLineBreakMode:(NSLineBreakMode)mode
{
    CGSize s;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        NSDictionary * dic = @{NSFontAttributeName:font};
        dic = dic;
        NSMutableDictionary * mdic = [NSMutableDictionary dictionary];
        [mdic setObject:[UIColor redColor] forKey:NSForegroundColorAttributeName];
        [mdic setObject:font forKey:NSFontAttributeName];
        NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc]init];
        [para setLineSpacing:5];//调整行间距
        [mdic setObject:para forKey:NSParagraphStyleAttributeName];
        
        s = [str boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                           attributes:mdic context:nil].size;
    }
    
    return s;
}
/**
 *  设置label行间距
 *
 *  @param label       label
 *  @param lineSpacing 行间距
 *  @param color       字体颜色
 */
+(void)label:(UILabel *)label andLineSpacing:(CGFloat )lineSpacing andColor:(UIColor *)color{
    
    if (label.text.length > 0) {
      
        
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]initWithString:label.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineSpacing = lineSpacing;
        [attriStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, label.text.length)];
        
        if (color) {
            [attriStr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, label.text.length)];
        }
        
        label.attributedText = attriStr;
        
    }
  
    
}

/**
 *  金钱字符串
 *
 *  @param money       金额
 *  @param moneyColor  金额颜色
 *  @param moneyFont   金额字体
 *  @param headerStr   金额前的字符（不包含￥）
 *  @param headerColor 金额前的字符的颜色
 *  @param headerFont  金额前的字符的字体
 *  @param addStr      金额后的字符
 *  @param addStrColor 金额后的字符的颜色
 *  @param addStrFont  金额后的字符的字体
 *
 *  @return 金钱属性字符串
 */
+(nonnull NSAttributedString *)money:(nonnull NSString *)money moneyColor:(nonnull UIColor *)moneyColor moneyFont:(nonnull UIFont *)moneyFont headerStr:(nullable NSString *)headerStr headerColor:(nullable UIColor *)headerColor headerFont:(nullable UIFont *)headerFont addStr:(nullable NSString *)addStr addStrColor:(nullable UIColor *)addStrColor addStrFont:(nullable UIFont *)addStrFont{
    
    NSMutableString *str;
    str = [NSMutableString stringWithFormat:@"￥%@",[self moneyChange:money]];
    if (headerStr) {
        str = [NSMutableString stringWithFormat:@"%@￥%@",headerStr,[self moneyChange:money]];
    }
    if (addStr) {
         str = [NSMutableString stringWithFormat:@"%@￥%@%@",headerStr,[self moneyChange:money],addStr];
    }
    
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:str];
    
    //金额
    NSString *moneyStr = [NSString stringWithFormat:@"￥%@",[self moneyChange:money]];
    
    NSRange moneyRange = [str rangeOfString:moneyStr];
    
    
    [attr addAttribute:NSFontAttributeName value:moneyFont range:moneyRange];
    [attr addAttribute:NSForegroundColorAttributeName value:moneyColor range:moneyRange];
    //金额前
    if (headerStr) {
        NSRange headerRange =  [str rangeOfString:headerStr];
        
        if (headerFont) {
            [attr addAttribute:NSFontAttributeName value:headerFont range:headerRange];
        }
        if (headerColor) {
            [attr addAttribute:NSForegroundColorAttributeName value:headerColor range:headerRange];
        }
        
        
    }
    //金额后
    if (addStr) {
        NSRange addRange = [str rangeOfString:addStr];
        
        if (addStrFont) {
            
            [attr addAttribute:NSFontAttributeName value:addStrFont range:addRange];
        }
        if (addStrColor) {
            [attr addAttribute:NSForegroundColorAttributeName value:addStrColor range:addRange];
        }
        
    }
   
    
    
    
    return attr;
}

//货币格式转换
/**
 *  货币格式转换
 *
 *  @param moneyStr 金额
 *
 *  @return 转换后的金额
 */

+ (NSString *)moneyChange:(NSString *)moneyStr{
    
    float money = [moneyStr floatValue];
    
    if (money < 1000) {
        
        return [NSString stringWithFormat:@"%.2f",money];
    }else if (money >= 1000 && money < 1000000 ){
        
        NSMutableString *string = [NSMutableString stringWithFormat:@"%.2f",money];
        [string insertString:@"," atIndex:string.length - 6];
        return string;
    }else if (money >= 1000000 && money < 1000000000){
        
        NSMutableString *string = [NSMutableString stringWithFormat:@"%.2f",money];
        [string insertString:@"," atIndex:string.length - 9];
        [string insertString:@"," atIndex:string.length - 6];
        return string;
        
        
    }
    
    return [NSString stringWithFormat:@"%.2f",money];
    
}

/*****
 * 存入用户信息
 *
 * dict 用户信息
 */
+ (BOOL)insertUserInfoToPlist:(nonnull NSDictionary *)dict
{
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [path objectAtIndex:0];
    NSString * fileName = [NSString stringWithFormat:@"userinfo.plist"];
    NSString * filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    return [dict writeToFile:filePath atomically:YES];
}

/*****
 * 读取userinfo
 */
+ (nonnull NSDictionary *)getUserInfo
{
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [path objectAtIndex:0];
    NSString * fileName = [NSString stringWithFormat:@"userinfo.plist"];
    NSString * filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:filePath]];
    
    return dict;
}


 +(BOOL)updateUserInfoWithItem:(nonnull NSString *)key value:(nonnull NSString *)value
 {
 NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:[self getUserInfo]];
 [dict setObject:value forKey:key];
 
 return [self insertUserInfoToPlist:dict];
 }


/*****
 * 清空userinfo
 */
+ (void)clearUserInfo
{
    NSArray * path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [path objectAtIndex:0];
    NSString * fileName = [NSString stringWithFormat:@"userinfo.plist"];
    NSString * filePath = [documentDirectory stringByAppendingPathComponent:fileName];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] initWithDictionary:[NSDictionary dictionaryWithContentsOfFile:filePath]];
    [dict removeAllObjects];
    [dict writeToFile:filePath atomically:YES];
}


@end
