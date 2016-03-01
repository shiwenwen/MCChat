//
//  FileModel.h
//  MCChat
//
//  Created by sww on 16/3/1.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM (NSInteger,FileType){
    Word,//doc,docx
    Excel,//xls,xlsx
    PowerPoint,//ppt,pptx
    music,//mp3,wma,mac,aac,wav...
    video,//RMVB、WMV、ASF、AVI、3GP、MPG、MKV、MP4、DVD、OGM、MOV、MPEG2、MPEG4
    image,//GIF、JPEG、BMP、TIF、JPG、PCD、QTI、QTF、TIFF
    txt,
    other
};
@interface FileModel : NSObject
@property (nonatomic,strong)UIImage *logoImage;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *detail;
@property (nonatomic,assign)FileType fileType;
@property (nonatomic,copy)NSString *path;


- (instancetype)initWithName:(NSString *)name Detail:(NSString *)detail FileType:(FileType )type Path:(NSString *)path;
@end
