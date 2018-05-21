//
//  ScreenHangulClockView.m
//  ScreenHangulClock
//
//  Created by visu4l on 2015. 9. 11..
//  Copyright (c) 2015년 visu4l. All rights reserved.
//

#import "ScreenHangulClockView.h"
//#import "word.h"

@interface NSString (ConvertToArray)
-(NSArray *)convertToArray;
@end

@implementation NSString (ConvertToArray)

-(NSArray *)convertToArray
{
    NSMutableArray *arr = [[NSMutableArray alloc]init];
    for (int i=0; i < self.length; i++) {
        NSString *tmp_str = [self substringWithRange:NSMakeRange(i, 1)];
        [arr addObject:[tmp_str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return arr;
}
@end

@implementation ScreenHangulClockView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        [self setAnimationTimeInterval:1];
    }
    
    //화면 크기
    NSSize size = [self bounds].size;
    screen_width = size.width;
    screen_height = size.height;
    
    //글자 크기는 화면 높이에 1/6
    font_size = screen_height / 6;
    
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
}

- (void)stopAnimation
{
    [super stopAnimation];
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    NSArray *hour_word = [NSArray arrayWithObjects:@"", @"한", @"두", @"세", @"네", @"다섯", @"여섯", @"일곱", @"여덟", @"아홉", @"열", nil];
    NSArray *min_word = [NSArray arrayWithObjects:@"", @"일", @"이", @"삼", @"사", @"오", @"육", @"칠", @"팔", @"구", @"십", nil];
    
    //현재 시간
    NSDate *date = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    [df setDateFormat:@"h"];
    NSString *t_h = [df stringFromDate:date];
    [df setDateFormat:@"m"];
    NSString *t_m = [df stringFromDate:date];
    [df setDateFormat:@"a"]; //pm/am
    NSString *t_a = [df stringFromDate:date];
    
    [df setDateFormat:@"s"];
    NSString *t_s = [df stringFromDate:date];
    
    
    NSMutableString *result_hour = [NSMutableString stringWithCapacity:10];
    NSMutableString *result_min_ten = [NSMutableString stringWithCapacity:5];
    NSMutableString *result_min = [NSMutableString stringWithCapacity:5];
    
    int hour = [t_h intValue];
    int minute = [t_m intValue];
    
    if(hour == 0 && minute == 0){
        [result_min_ten appendString:@"자"];
        [result_min appendString:@"정"];
    }else if(hour == 12 && minute == 0){
        [result_min appendString:@"정오"];
    }else{
        // 오전/오후
        [result_hour appendString:@"오"];
        [result_hour appendString:[t_a substringFromIndex:1]];
        
        // 시
        [result_hour appendString:@"시"];
        if(hour >= 10){
            [result_hour appendString:hour_word[10]];
        }
        [result_hour appendString:hour_word[hour % 10]];
        
        // 분
        if(minute != 0){
            [result_min appendString:@"분"];
        }
        if(minute >= 20){
            [result_min_ten appendString:min_word[minute/10]];
        }
        if(minute >= 10){
            [result_min_ten appendString:min_word[10]];
        }
        [result_min appendString:min_word[minute % 10]];
    }
    
    // 문자열을 배열로 변경 후 출력
    [self writeText:[result_hour convertToArray]       start:0 rows:3 ];
    [self writeText:[result_min_ten convertToArray]    start:3 rows:1 ];
    [self writeText:[result_min convertToArray]        start:4 rows:2 ];
    
    // 마지막줄 "초" 출력
    NSColor *gray = [NSColor colorWithCalibratedRed:(CGFloat)0x20/0xff green:(CGFloat)0x20/0xff blue:(CGFloat)0x20/0xff alpha:1.0];
    [self draw:t_s width:(screen_width - font_size) height:screen_height - (font_size * (6)) font_size:font_size color:gray];
    
    // 연-월-일-요일 출력
    [df setDateFormat:@"yyyy"];
    [self draw:[df stringFromDate:date] width:0 height:screen_height-font_size font_size:font_size color:[NSColor darkGrayColor]];
    
    [df setDateFormat:@"MM-dd"];
    [self draw:[df stringFromDate:date] width:0 height:screen_height-font_size*2 font_size:font_size color:[NSColor darkGrayColor]];
    
    [df setDateFormat:@"E"];
    [self draw:[NSString stringWithFormat:@"%@요일", [df stringFromDate:date]] width:0 height:screen_height-font_size*3 font_size:font_size color:[NSColor darkGrayColor]];
    
}

- (void)writeText:(NSArray *)check_list start:(int)start rows:(int)rows{
    /*! 
     @brief 한글 시계를 라인별로 출력한다.
     @pram check_list 강조할 글자 배열
     @param start 출력 시작할 라인
     @param rows 출력될 라인수
     */
    NSMutableString *line_str = [NSMutableString stringWithString:@"오전후열한두세일곱다여섯네여덟아홉시자이삼사오십정오일이삼사육칠팔구분 "];
    NSArray *line = [line_str convertToArray];
    
    const int screen_width_pos = screen_width - (font_size * 6);
    NSColor *white = [NSColor whiteColor];
    NSColor *gray = [NSColor colorWithCalibratedRed:(CGFloat)0x20 / 0xff
                                              green:(CGFloat)0x20 / 0xff
                                               blue:(CGFloat)0x20 / 0xff
                                              alpha:1.0];
    int row_end = start + rows;
    int row = start;
    for(; row < row_end ; row++){
        int height = screen_height - (font_size * (row+1));
        int col = 0;
        for(;col < 6; col++){
            NSString *word = [line objectAtIndex:(row*6)+col];
            NSColor* color = gray;
            if([check_list containsObject:word]){ // 강조될 글자
                color = white;
            }
            
            if([word isEqual:@"여"] && row == 1 && [check_list containsObject:@"덟"]){
                color = gray;
            }
            
            if([word isEqual:@"여"] && row == 2 && [check_list containsObject:@"섯"]){
                color = gray;
            }
            
            [self draw:word width:(screen_width_pos + (font_size * (col))) height:height font_size:font_size color:color];
        }
    }
}

- (void)draw:(NSString *)word width:(int)width height:(int)height font_size:(int)font_size color:(NSColor*)color{
    /*!
     @brief 글자를 화면에 출력한다.
     @param word        출력 대상 글자
     @param width       글자 출력 위치
     @param height      글자 출력 위치
     @param font_size   글자 크기
     @param color       글자 색자
     */
    //특정 위치(width, height)에 obj를 font_size 크기에 color색으로 출력
    printf("visu4l hell");
    NSLog(@"visu4l hell");
    
    [word drawAtPoint:NSMakePoint(width, height) withAttributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:[NSFont fontWithName:@"YiSunShin Regular" size:font_size]}];
}

- (void)animateOneFrame
{
    [self setNeedsDisplay:YES];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

- (NSWindow*)configureSheet
{
    return nil;
}

@end
