//
//  WeiboFaceView.m
//  WeiBoS
//
//  Created by mac on 15/10/19.
//  Copyright © 2015年 sww. All rights reserved.
//

#import "WeiboFaceView.h"

//每一个绘制单元的大小
#define item_width (KScreenWidth / 7)
#define item_height (KScreenWidth / 7)

//绘制表情的大小
#define face_width (item_width - 20)
#define face_height (item_height - 20)



@implementation WeiboFaceView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _loadFaceData];
        //创建放大镜视图
        
        _magnifierView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 64, 92)];
        _magnifierView.image = [UIImage imageNamed:@"emoticon_keyboard_magnifier"];
        
        _magnifierView.hidden = YES;
        [self addSubview:_magnifierView];
        
        _largeFaceImageView = [[UIImageView alloc]initWithFrame:CGRectMake( (_magnifierView.width - item_width + 10 ) / 2, 10, item_width - 10, item_height - 10)];
        [_magnifierView addSubview:_largeFaceImageView];
    }
    return self;
}

- (void)_loadFaceData{
    
    NSString *path = [[NSBundle mainBundle]pathForResource:@"emoticons" ofType:@"plist"];
    
    NSArray *emoticons = [NSArray arrayWithContentsOfFile:path];
    
    //表情重新分组
    /*
     104 个表情 每一页4行 每行7个 共28个 共104 / 28 = 4 页 最后一页20个
     构造二维数组
      */
    
    
    //分组方法一
    //一维大数组
    _items = [NSMutableArray array];
    
    //小数组
    NSMutableArray *item2D = [NSMutableArray array];
    
    [_items addObject:item2D];
    for (int i = 0; i < emoticons.count; i ++) {
        
        if (item2D.count == 28) {
            //每存满28个创建一个新的数组 加到大数组中
            item2D = [NSMutableArray array];
            
            [_items addObject:item2D];
        }
        
        [item2D addObject:emoticons[i]];
    }
    

   
    /*
    //分组方法二
    NSInteger emoticonsOfOnePage = 28;
    
    NSInteger pages = emoticons.count / emoticonsOfOnePage;

    if (emoticons.count % emoticonsOfOnePage != 0) {
        pages += 1;
    }
    
    for (int i = 0; i < pages ; i ++) {
        
        //根据pages，判断是第几页
        NSRange range = NSMakeRange(i * emoticonsOfOnePage, emoticonsOfOnePage);
        
        //最后一页，要单独判断
        if (i == pages - 1) {
            range = NSMakeRange(i * emoticonsOfOnePage, emoticons.count - emoticonsOfOnePage * (pages - 1));
        
        }
        
        NSArray *items2D = [emoticons subarrayWithRange:range];
    }
    

    */
    
      //faceView的frame，取决于表情的个数
    
    CGRect frame = self.frame;
    frame.size.width = KScreenWidth * _items.count;
    frame.size.height = item_height * 4;
    self.frame = frame;
    
    
}




- (void)drawRect:(CGRect)rect {

    //获取context
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //1.image
    //2.确定坐标
    //3.绘制
    //[[UIImage imageNamed:@"menu"] drawAtPoint:<#(CGPoint)#>];
    
    // 28 = 7 X 4
    int column = 0; //列（7）
    int row = 0; //行（4）
    
    for (int i = 0; i < _items.count; i ++) {
        NSArray *item2D = _items[i];
        
        for (int j = 0; j < item2D.count; j ++) {
            
            UIImage *image = [UIImage imageNamed:item2D[j][@"png"]];
            
            CGFloat x = item_width * column + (item_width - face_width) / 2 + KScreenWidth * i;
            CGFloat y = item_height * row + (item_height - face_height) /2;
            
            column ++;
            if (column % 7 == 0) {
                column = 0;
                
                row ++;
                
            }
            if (row == 4) {
                row = 0;
            }
         
            [image drawInRect:CGRectMake(x, y, face_width, face_height)];
        }
        
    }
    
    
}
- (void)touchFace:(CGPoint )point{
    
    int page = point.x / KScreenWidth;
    
    int column =( point.x - page * KScreenWidth ) / item_width;
    
    int row = point.y / item_height;
    
    CGFloat x = column * item_width + item_width / 2 + page * KScreenWidth;
    
    CGFloat y = row * item_width + item_width / 2;
    
    _magnifierView.center = CGPointMake(x, 0);
    _magnifierView.bottom = y;
    
    NSArray *item2D = _items[page];
    NSInteger index = row * 7 + column;
    
    if (index >= item2D.count) {
        
        _magnifierView.hidden = YES;
        return ;
    }
    
    NSDictionary *faceDic = item2D[index];
    
    _largeFaceImageView.image = [UIImage imageNamed:faceDic[@"png"]];
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        scrollView.scrollEnabled = NO;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    _magnifierView.hidden = NO;
    
    
    
    [self touchFace:point];
    
    
    
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    _magnifierView.hidden = NO;
    
    
    
    [self touchFace:point];
    
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    
    if ([self.superview isKindOfClass:[UIScrollView class]]) {
        
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        scrollView.scrollEnabled = YES;
    }
    _magnifierView.hidden = YES;
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    int page = point.x / KScreenWidth;
    
    int column =( point.x - page * KScreenWidth ) / item_width;
    
    int row = point.y / item_height;
    
    CGFloat x = column * item_width + item_width / 2 + page * KScreenWidth;
    
    CGFloat y = row * item_width + item_width / 2;
    
    _magnifierView.center = CGPointMake(x, 0);
    _magnifierView.bottom = y;
    
    NSArray *item2D = _items[page];
    NSInteger index = row * 7 + column;
    
    if (index >= item2D.count) {
        
        _magnifierView.hidden = YES;
        return ;
    }
    
    NSDictionary *faceDic = item2D[index];
    
    [self.delegate choseFace:[NSString stringWithFormat:@"%@",faceDic[@"chs"]]];
        

    
}



@end
