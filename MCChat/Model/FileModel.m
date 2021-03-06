//
//  FileModel.m
//  MCChat
//
//  Created by sww on 16/3/1.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import "FileModel.h"

@implementation FileModel
-(void)setFileType:(FileType)fileType{
    _fileType = fileType;
    
    switch (_fileType) {
        case Word:
        {
            self.logoImage = [UIImage imageNamed:@"word"];
        }
            
            break;
        case Excel:
        {
            self.logoImage = [UIImage imageNamed:@"excel"];
        }
            
            break;
        case PowerPoint:
        {
            self.logoImage = [UIImage imageNamed:@"powerPoint"];
        }
            
            break;
        case music:
        {
            self.logoImage = [UIImage imageNamed:@"music"];
        }
            
            break;
        case video:
        {
            self.logoImage = [UIImage imageNamed:@"MOV"];
        }
            
            break;
        case txt:
        {
            self.logoImage = [UIImage imageNamed:@"txt"];
        }
            
            break;
        case zip:
        {
            self.logoImage = [UIImage imageNamed:@"zip"];
            
        }
            break;
        case other:
        {
            self.logoImage = [UIImage imageNamed:@"other"];
            
        }
            
            break;
        default:
            break;
    }
    
    
    
    
}
- (instancetype)initWithName:(NSString *)name Detail:(NSString *)detail size:(NSString *)size FileType:(FileType )type Path:(NSString *)path{
    if (self = [super init]) {
        
        self.name = name;
        self.detail = detail;
        self.fileType = type;
        self.path = path;
        self.size = size;
        
    }
    
    return self;
    
}
@end
