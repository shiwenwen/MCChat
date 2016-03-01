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
            self.logoImage = [UIImage imageNamed:@""];
        }
            
            break;
        case Excel:
        {
            self.logoImage = [UIImage imageNamed:@""];
        }
            
            break;
        case PowerPoint:
        {
            self.logoImage = [UIImage imageNamed:@""];
        }
            
            break;
        case music:
        {
            self.logoImage = [UIImage imageNamed:@""];
        }
            
            break;
        case video:
        {
            self.logoImage = [UIImage imageNamed:@""];
        }
            
            break;
        case txt:
        {
            self.logoImage = [UIImage imageNamed:@""];
        }
            
            break;
        case other:
        {
            self.logoImage = [UIImage imageNamed:@""];
            
        }
            
            break;
        default:
            break;
    }
    
    
    
    
}
- (instancetype)initWithName:(NSString *)name Detail:(NSString *)detail FileType:(FileType )type Path:(NSString *)path{
    if (self = [super init]) {
        
        self.name = name;
        self.detail = detail;
        self.fileType = type;
        self.path = path;
        
        
    }
    
    return self;
    
}
@end
