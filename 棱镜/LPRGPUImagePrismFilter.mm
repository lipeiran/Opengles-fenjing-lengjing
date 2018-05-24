//
//  LPRGPUImagePrismFilter.m
//  T-SDK
//
//  Created by 李沛然 on 2018/5/24.
//  Copyright © 2018年 mai. All rights reserved.
//

#import "LPRGPUImagePrismFilter.h"
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>
#import "GPUImageContext.h"
#import "GPUImageFilter.h"
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/ES2/glext.h>

#include "Glm/glm.hpp"
#include "Glm/ext.hpp"

NSString *const kGPUImageVertexShaderString11 = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 uniform lowp mat4 model;
 uniform lowp mat4 view;
 uniform lowp mat4 projection;
 
 void main()
 {
     gl_Position = projection*view*model*position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );
//projection*view*model*

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

NSString *const kGPUImagePassthroughFragmentShaderString11 = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform lowp float brightness;
 
 void main()
 {
     lowp vec4 textureColor  = texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = vec4((textureColor.rgb + vec3(brightness)),textureColor.w);
 }
 );

#else

NSString *const kGPUImagePassthroughFragmentShaderString11 = SHADER_STRING
(
 varying vec2 textureCoordinate;
 
 uniform sampler2D inputImageTexture;
 uniform  float brightness;
 
 void main()
 {
     vec4 textureColor  = texture2D(inputImageTexture, textureCoordinate);
     gl_FragColor = vec4((textureColor.rgb + vec3(brightness)),textureColor.w);
 }
 );
#endif

GLuint CreateBufferObject1(GLenum objType,int objSize,void*data,GLenum usage)
{
    GLuint bufferObject;
    glGenBuffers(1, &bufferObject);
    glBindBuffer(objType, bufferObject);
    glBufferData(objType, objSize, data, usage);
    glBindBuffer(objType, 0);
    return bufferObject;
}

GLuint prism_vbo1;
GLint lprViewLocation1,lprProjectionLocation1,lprModelLocation1;
CGFloat fov1 = 45.0f;
float rotateF1 = 0.0f;
glm::vec3 cameraPos1   = glm::vec3(0.0f, 0.0f,  8.0f);
glm::vec3 cameraFront1 = glm::vec3(0.0f, 0.0f, -1.0f);
glm::vec3 cameraUp1    = glm::vec3(0.0f, 1.0f,  0.0f);

#define ScreenWidth1 [UIScreen mainScreen].bounds.size.width
#define ScreenHeight1 [UIScreen mainScreen].bounds.size.height

@interface LPRGPUImagePrismFilter ()
{
    glm::vec3 triglePositions[MAX_PRISM_NUMBER1];
}

@end

@implementation LPRGPUImagePrismFilter

- (id)init
{
    if (!([self initWithVertexShaderFromString:kGPUImageVertexShaderString11 fragmentShaderFromString:kGPUImagePassthroughFragmentShaderString11]))
    {
        return nil;
    }
    
    self->brightnessUniform = [filterProgram uniformIndex:@"brightness"];
    [self commonInit];
    return self;
}

- (void)commonInit
{
    NSLog(@"开始===============================================");
    
    static const GLfloat noRotationTextureCoordinates[] = {
        1.0f, 1.0f,
        0.5f, 0.0f,
        0.0f, 1.0f,
    };
    float tmpXYRatio = ScreenWidth1/ScreenHeight1;
    float ratioF = 2;
    for (int xi = 0; xi < PRISM_NUMBER1; ++xi)
    {
        float angle = 360.0f/PRISM_NUMBER1*xi*M_PI/180;
        NSLog(@"angle is:%f",angle);
        CGFloat tmpBrightness = ((arc4random() % 201)/100.0-1.0)*0.5;
        NSLog(@"第 %d 块---亮度值为 %.1f",xi+1,tmpBrightness);
        self->imageBrightness[xi] = tmpBrightness;
        
        self->triglePositions[xi] = glm::vec3(-ratioF*0.5*sin(angle),  -ratioF*0.5*cos(angle),  0.0f);
        NSLog(@"第 %d 块---坐标x:%f,y:%f))))%f,%f==%f",xi+1,-ratioF*0.5*sin(angle),-ratioF*0.5*cos(angle),sin(angle),cos(angle),angle);
    }
    
    // postions 时针小顶点
    self->imageVertices1[0*12+0] = ratioF*0.5*tmpXYRatio;
    self->imageVertices1[0*12+1] = -ratioF*0.5;
    // textureCoord 时针小顶点
    self->imageVertices1[0*12+2] = noRotationTextureCoordinates[0];
    self->imageVertices1[0*12+3] = noRotationTextureCoordinates[1];
    NSLog(@"时针小顶点：%.2f,%.2f,%.2f,%.2f,\n",0.0,0.0,0.0,0.0);
    
    // postions 圆心
    self->imageVertices1[0*12+4] = 0;
    self->imageVertices1[0*12+5] = ratioF*0.5;
    // textureCoord 圆心
    self->imageVertices1[0*12+6] = noRotationTextureCoordinates[2];
    self->imageVertices1[0*12+7] = noRotationTextureCoordinates[3];
    NSLog(@"圆心：%.2f,%.2f,%.2f,%.2f,\n",0.0,0.0,0.0,0.0);
    
    // postions 时针大顶点
    self->imageVertices1[0*12+8] = -ratioF*0.5*tmpXYRatio;
    self->imageVertices1[0*12+9] = -ratioF*0.5;
    // textureCoord 时针大顶点
    self->imageVertices1[0*12+10] = noRotationTextureCoordinates[4];
    self->imageVertices1[0*12+11] = noRotationTextureCoordinates[5];
    NSLog(@"时针大顶点：%.2f,%.2f,%.2f,%.2f,\n",0.0,0.0,0.0,0.0);
    
    NSLog(@"\n\n\n\n\n\n\n\n\n\n\n\n");
    NSLog(@"结束===============================================");
    prism_vbo1 = CreateBufferObject1(GL_ARRAY_BUFFER, sizeof(self->imageVertices1), self->imageVertices1, GL_STATIC_DRAW);
}


#pragma mark -
#pragma mark Rendering

- (void)newFrameReadyAtTime:(CMTime)frameTime atIndex:(NSInteger)textureIndex;
{
    [self renderToTextureWithVertices:NULL textureCoordinates:NULL];
    
    [self informTargetsAboutNewFrameAtTime:frameTime];
}

- (CGSize)outputFrameSize;
{
    return [self sizeOfFBO];
}

- (void)setInputSize:(CGSize)newSize atIndex:(NSInteger)textureIndex;
{
    if (self.preventRendering)
    {
        return;
    }
    
    inputTextureSize = newSize;
}

- (void)setInputRotation:(GPUImageRotationMode)newInputRotation atIndex:(NSInteger)textureIndex;
{
    inputRotation = kGPUImageNoRotation;
}

- (void)renderToTextureWithVertices:(const GLfloat *)vertices textureCoordinates:(const GLfloat *)textureCoordinates;
{
    // we need a normal color texture for this filter
    NSAssert(self.outputTextureOptions.internalFormat == GL_RGBA, @"The output texture format for this filter must be GL_RGBA.");
    NSAssert(self.outputTextureOptions.type == GL_UNSIGNED_BYTE, @"The type of the output texture of this filter must be GL_UNSIGNED_BYTE.");
    
    if (self.preventRendering)
    {
        [firstInputFramebuffer unlock];
        return;
    }
    
    [GPUImageContext useImageProcessingContext];
    
    outputFramebuffer = [[GPUImageContext sharedFramebufferCache] fetchFramebufferForSize:[self sizeOfFBO] textureOptions:self.outputTextureOptions onlyTexture:NO];
    [outputFramebuffer activateFramebuffer];
    if (usingNextFrameForImageCapture)
    {
        [outputFramebuffer lock];
    }
    [GPUImageContext setActiveShaderProgram:filterProgram];
    
    /*
     glClearColor(0.0, 0.0, 0.0, 1.0);
     glClear(GL_COLOR_BUFFER_BIT);
     
     glBlendEquation(GL_FUNC_ADD);
     glBlendFunc(GL_ONE, GL_ONE);
     glEnable(GL_BLEND);
     
     glVertexAttribPointer(filterPositionAttribute, 4, GL_UNSIGNED_BYTE, 0, ((unsigned int)_downsamplingFactor - 1) * 4, vertexSamplingCoordinates);
     glDrawArrays(GL_POINTS, 0, inputTextureSize.width * inputTextureSize.height / (CGFloat)_downsamplingFactor);
     */
    
    glClearColor(self->backgroundColorRed, self->backgroundColorGreen, self->backgroundColorBlue, self->backgroundColorAlpha);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, [firstInputFramebuffer texture]);
    glUniform1i(filterInputTextureUniform, 2);
    
    
    glBindBuffer(GL_ARRAY_BUFFER, prism_vbo1);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, sizeof(float)*4, (void*)(sizeof(float)*0));
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, sizeof(float)*4, (void*)(sizeof(float)*2));
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glm::mat4 viewT;
    viewT = glm::lookAt(cameraPos1, cameraPos1+cameraFront1, cameraUp1);
    lprViewLocation1 = [filterProgram uniformIndex:@"view"];
    glUniformMatrix4fv(lprViewLocation1, 1, GL_FALSE, glm::value_ptr(viewT));
    
    glm::mat4 projectionT;
    projectionT = glm::perspective((float)fov1, (float)ScreenWidth1 / (float)ScreenHeight1, 0.1f, 100.0f);
    lprProjectionLocation1 = [filterProgram uniformIndex:@"projection"];
    glUniformMatrix4fv(lprProjectionLocation1, 1, GL_FALSE, glm::value_ptr(projectionT));
    
    rotateF1 += 0.02f;
    for (int i = 0; i < PRISM_NUMBER1; ++i)
    {
        lprModelLocation1 = [filterProgram uniformIndex:@"model"];
        glm::mat4 model;
        model = glm::translate(model, self->triglePositions[i]);
        float angle = -360.0f/PRISM_NUMBER1*i;
        model = glm::rotate(model, (float)angle+rotateF1*40, glm::vec3(0.0f, 0.0f, 1.0f));
        glUniformMatrix4fv(lprModelLocation1, 1, GL_FALSE, glm::value_ptr(model));
        
        glUniform1f(self->brightnessUniform, self->imageBrightness[i]);
        
        glDrawArrays(GL_TRIANGLES, 0, 3);
    }
    
    [firstInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}
@end
