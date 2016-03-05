//
//  FileModel.h
//  MCChat
//
//  Created by sww on 16/3/1.
//  Copyright © 2016年 shiwenwen. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM (NSInteger,FileType){
    Word,//doc,docx，pages
    Excel,//xls,xlsx，numbers
    PowerPoint,//ppt,pptx,keynote
    music,//mp3,wma,mac,aac,wav...
    video,//RMVB、WMV、ASF、AVI、3GP、MPG、MKV、MP4、DVD、OGM、MOV、MPEG2、MPEG4
    image,//GIF、JPEG、BMP、TIF、JPG、PCD、QTI、QTF、TIFF
    txt,//txt,plist,m,c,h,webarchive,html
    zip,//rar,zip,tar,cab,uue,jar,iso,z,7-zip,ace,lzh,arj,gzip,bz2
    pdf,//pdf
    other,
    folder//文件夹
};
@interface FileModel : NSObject
@property (nonatomic,strong)UIImage *logoImage;
@property (nonatomic,copy)NSString *name;
@property (nonatomic,copy)NSString *detail;
@property (nonatomic,assign)FileType fileType;
@property (nonatomic,copy)NSString *path;
@property (nonatomic,copy)NSString *size;
@property (nonatomic,assign)double realitySize;
- (instancetype)initWithName:(NSString *)name Detail:(NSString *)detail size:(NSString *)size FileType:(FileType )type Path:(NSString *)path;
@end
