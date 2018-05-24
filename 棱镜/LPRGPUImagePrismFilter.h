//
//  LPRGPUImagePrismFilter.h
//  T-SDK
//
//  Created by 李沛然 on 2018/5/24.
//  Copyright © 2018年 mai. All rights reserved.
//

#import "GPUImageFilter.h"
#define PRISM_NUMBER1 8  // 棱镜分屏数目
#define MIN_PRISM_NUMBER1 4 // 最少分屏总块数
#define MAX_PRISM_NUMBER1 100 // 最多分屏总块数

/* 此 Filter 可以直接对接 GPUImageView */
@interface LPRGPUImagePrismFilter : GPUImageFilter
{
    GLint brightnessUniform;
    GLfloat imageVertices1[MAX_PRISM_NUMBER1*12]; // MAX_SCREEN_NUMBER（最大数目）* 4 （每个顶点 4个数据：2个顶点数据，2个纹理数据） * 3（GL_TRANGLES 因为是棱镜，所以3个顶点）
    GLfloat imageBrightness[MAX_PRISM_NUMBER1];
}
@end
