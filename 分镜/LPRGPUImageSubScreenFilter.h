//
//  LPRGPUImageSubScreenFilter.h
//  T-SDK
//
//  Created by 李沛然 on 2018/5/24.
//  Copyright © 2018年 mai. All rights reserved.
//

#import "GPUImageFilter.h"
/*
 注意：X_NUMBER * Y_NUMBER <= MAX_SCREEN_NUMBER 即总块数不超过MAX_SCREEN_NUMBER
 */
#define X_NUMBER2 5  // x坐标轴方向分屏数目
#define Y_NUMBER2 7  // y坐标轴方向分屏数目
#define MAX_SCREEN_NUMBER2 100 // 最多分屏总块数

@interface LPRGPUImageSubScreenFilter : GPUImageFilter
{
    GLint brightnessUniform;
    GLfloat imageVertices1[MAX_SCREEN_NUMBER2*24]; // MAX_SCREEN_NUMBER（最大数目）* 4 （每个顶点 4个数据：2个顶点数据，2个纹理数据） * 6（GL_TRANGLES 6个顶点）
    GLfloat imageBrightness[MAX_SCREEN_NUMBER2];
}
@end
