//
//  LockView.m
//  GestureLock
//
//  Created by 聂康  on 2017/7/13.
//  Copyright © 2017年 com.nk. All rights reserved.
//

#import "LockView.h"

#define btnWidth 100

@interface LockView ()

//选中按钮数组
@property (nonatomic, strong)NSMutableArray *selectBtnArray;

@property (nonatomic, assign)CGPoint  currentPoint ;


@end

@implementation LockView

- (NSMutableArray *)selectBtnArray {
    if (!_selectBtnArray) {
        _selectBtnArray = [NSMutableArray array];
    }
    return _selectBtnArray;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

//添加密码小圈圈
- (void)setup {
    
    self.backgroundColor = [UIColor clearColor];
    
    UIImage *normalImage = [self imageWithColor:[UIColor grayColor] selected:NO];
    UIImage *selectImage = [self imageWithColor:[UIColor blueColor] selected:YES];
    
    for (int i=0; i<9; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:normalImage forState:UIControlStateNormal];
        [btn setImage:selectImage forState:UIControlStateSelected];
        [self addSubview:btn];
    }
    
    // 添加拖动手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [self addGestureRecognizer:pan];
}

//拖动手势
- (void)pan:(UIPanGestureRecognizer *)panGes {
    
    CGPoint point = [panGes locationInView:self];
    
    _currentPoint = point;
    
    for (UIButton *btn in self.subviews) {
        
        CGFloat scale = 20;
        
        //触摸的有效范围 以按钮中心为中心 宽度为2*scale的正方形区域
        CGRect frame = CGRectMake(btn.center.x - scale, btn.center.y-scale, 2*scale, 2*scale);
        
        if (CGRectContainsPoint(frame, point)) {
            
            //选中
            btn.selected = YES;
            //保存到数组中
            [self.selectBtnArray addObject:btn];
        }
    }
    
    //当手势结束时还原密码图形状态
    if (panGes.state == UIGestureRecognizerStateEnded) {
        
        [self.selectBtnArray makeObjectsPerformSelector:@selector(setSelected:) withObject:nil];//注意后面的参数 传@NO没有作用 nil可以看做NO
        
        [self.selectBtnArray removeAllObjects];
    }
    
    //重新绘制视图
    [self setNeedsDisplay];

}

//设置自视图的frame
- (void)layoutSubviews {
    
    CGFloat width = self.bounds.size.width;
    
    CGFloat space = (width - 3 * btnWidth)/2.f;
    
    for (int i=0; i<self.subviews.count; i++) {
        
        UIButton *btn = self.subviews[i];
        
        btn.frame = CGRectMake((i%3)*(btnWidth + space), (i/3)*(btnWidth+space), btnWidth, btnWidth);
        
    }
}

// 用颜色生小圈圈成图片
- (UIImage *)imageWithColor:(UIColor *)color selected:(BOOL)selected{
    
    UIImage *image = nil;
    
    CGRect rect = CGRectMake(0, 0, 70, 70);
    
    CGFloat lineW = 2;
    
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //画圆
    CGContextAddEllipseInRect(ctx, CGRectMake(lineW, lineW, rect.size.width-2*lineW, rect.size.height-2*lineW));
    
    CGContextSetLineWidth(ctx, 2);
    
    [color setStroke];
    
    CGContextStrokePath(ctx);
    
    if (selected) {
        
        CGFloat innerW = 20;
        
        CGContextAddEllipseInRect(ctx, CGRectMake(rect.size.width/2-innerW/2,rect.size.height/2-innerW/2,innerW,innerW));
        
        [color setFill];
        
        CGContextFillPath(ctx);
    }
    

    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

//绘制
- (void)drawRect:(CGRect)rect {
    //如果没有选中的按钮，不同画线
    if (self.selectBtnArray.count == 0) {
        return;
    }
    
    //绘制
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSInteger count = self.selectBtnArray.count;
    
    for (NSInteger i=0; i<count; i++) {
        
        UIButton *btn = self.selectBtnArray[i];
        
        if (i==0) {
            //是起点
            [path moveToPoint:btn.center];
        }else{
            //不是起点
            [path addLineToPoint:btn.center];
        }
    }
    
    //与当前触摸点连接起来
    [path addLineToPoint:_currentPoint];
    
    [[UIColor redColor] set];
    
    path.lineWidth = 10;
    
    path.lineJoinStyle = kCGLineJoinRound;
    
    [path stroke];
}

@end
