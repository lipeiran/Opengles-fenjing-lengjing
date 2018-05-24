//
//  LPRGPUImageSubScreenFilter.m
//  T-SDK
//
//  Created by 李沛然 on 2018/5/24.
//  Copyright © 2018年 mai. All rights reserved.
//

#import "LPRGPUImageSubScreenFilter.h"
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>
#import "GPUImageContext.h"
#import "GPUImageFilter.h"
#import <AVFoundation/AVFoundation.h>
#import <OpenGLES/ES2/glext.h>

#include "Glm/glm.hpp"
#include "Glm/ext.hpp"

NSString *const kGPUImageVertexShaderString12 = SHADER_STRING
(
 attribute vec4 position;
 attribute vec4 inputTextureCoordinate;
 
 varying vec2 textureCoordinate;
 
 void main()
 {
     gl_Position = position;
     textureCoordinate = inputTextureCoordinate.xy;
 }
 );
//projection*view*model*

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE

NSString *const kGPUImagePassthroughFragmentShaderString12 = SHADER_STRING
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

NSString *const kGPUImagePassthroughFragmentShaderString12 = SHADER_STRING
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

GLuint CreateBufferObject2(GLenum objType,int objSize,void*data,GLenum usage)
{
    GLuint bufferObject;
    glGenBuffers(1, &bufferObject);
    glBindBuffer(objType, bufferObject);
    glBufferData(objType, objSize, data, usage);
    glBindBuffer(objType, 0);
    return bufferObject;
}

GLuint vbo2;

#define ScreenWidth2 [UIScreen mainScreen].bounds.size.width
#define ScreenHeight2 [UIScreen mainScreen].bounds.size.height

@interface LPRGPUImageSubScreenFilter ()
{
    NSInteger _numberX;
    NSInteger _numberY;
}

@end

@implementation LPRGPUImageSubScreenFilter

- (id)init
{
    if (!([self initWithVertexShaderFromString:kGPUImageVertexShaderString12 fragmentShaderFromString:kGPUImagePassthroughFragmentShaderString12]))
    {
        return nil;
    }
    
    self->brightnessUniform = [filterProgram uniformIndex:@"brightness"];
    [self commonInit];
    return self;
}

- (void)commonInit
{
    self->_numberX = X_NUMBER2;
    self->_numberY = Y_NUMBER2;
    
    GLfloat unitX = 2.0/self->_numberX;
    GLfloat unitY = 2.0/self->_numberY;
    
    NSLog(@"开始===============================================");
    
    static const GLfloat tmpTextCoordArray[] = {
        0.0f, 0.0f,
        1.0f, 0.0f,
        0.0f, 1.0f,
        1.0f, 1.0f,
    };
    /*
     0.0f, 1.0f,
     1.0f, 1.0f,
     0.0f, 0.0f,
     1.0f, 0.0f,
     */
    
    for (int yi = 0; yi < self->_numberY; ++yi)
    {
        for (int xi = 0; xi < self->_numberX; ++xi)
        {
            CGFloat tmpBrightness = ((arc4random() % 201)/100.0-1.0)*0.5;
            NSLog(@"第 %ld 块---亮度值为 %.1f",yi*self->_numberX+xi+1,tmpBrightness);
            self->imageBrightness[yi*_numberX+xi] = tmpBrightness;
            
            // postions 左下
            self->imageVertices1[(yi*self->_numberX+xi)*24+0] = unitX*xi-1;
            self->imageVertices1[(yi*self->_numberX+xi)*24+1] = -unitY*(yi+1)+1;
            // textureCoord 左下
            self->imageVertices1[(yi*self->_numberX+xi)*24+2] = tmpTextCoordArray[0];
            self->imageVertices1[(yi*self->_numberX+xi)*24+3] = tmpTextCoordArray[1];
            NSLog(@"左下：%.2f,%.2f,%.2f,%.2f,\n",unitX*xi-1,-unitY*(yi+1)+1,tmpTextCoordArray[0],tmpTextCoordArray[1]);
            // postions 右下
            self->imageVertices1[(yi*self->_numberX+xi)*24+4] = unitX*(xi+1)-1;
            self->imageVertices1[(yi*self->_numberX+xi)*24+5] = -unitY*(yi+1)+1;
            // textureCoord 右下
            self->imageVertices1[(yi*self->_numberX+xi)*24+6] = tmpTextCoordArray[2];
            self->imageVertices1[(yi*self->_numberX+xi)*24+7] = tmpTextCoordArray[3];
            NSLog(@"右下：%.2f,%.2f,%.2f,%.2f,\n",unitX*(xi+1)-1,-unitY*(yi+1)+1,tmpTextCoordArray[2],tmpTextCoordArray[3]);
            // postions 左上
            self->imageVertices1[(yi*self->_numberX+xi)*24+8] = unitX*xi-1;
            self->imageVertices1[(yi*self->_numberX+xi)*24+9] = -unitY*yi+1;
            // textureCoord 左上
            self->imageVertices1[(yi*self->_numberX+xi)*24+10] = tmpTextCoordArray[4];
            self->imageVertices1[(yi*self->_numberX+xi)*24+11] = tmpTextCoordArray[5];
            NSLog(@"左上：%.2f,%.2f,%.2f,%.2f,\n",unitX*xi-1,-unitY*yi+1,tmpTextCoordArray[4],tmpTextCoordArray[5]);
            
            // postions 左上
            self->imageVertices1[(yi*self->_numberX+xi)*24+12] = unitX*xi-1;
            self->imageVertices1[(yi*self->_numberX+xi)*24+13] = -unitY*yi+1;
            // textureCoord 左上
            self->imageVertices1[(yi*self->_numberX+xi)*24+14] = tmpTextCoordArray[4];
            self->imageVertices1[(yi*self->_numberX+xi)*24+15] = tmpTextCoordArray[5];
            NSLog(@"左上：%.2f,%.2f,%.2f,%.2f,\n",unitX*xi-1,-unitY*yi+1,tmpTextCoordArray[4],tmpTextCoordArray[5]);
            // postions 右下
            self->imageVertices1[(yi*self->_numberX+xi)*24+16] = unitX*(xi+1)-1;
            self->imageVertices1[(yi*self->_numberX+xi)*24+17] = -unitY*(yi+1)+1;
            // textureCoord 右下
            self->imageVertices1[(yi*self->_numberX+xi)*24+18] = tmpTextCoordArray[2];
            self->imageVertices1[(yi*self->_numberX+xi)*24+19] = tmpTextCoordArray[3];
            NSLog(@"右下：%.2f,%.2f,%.2f,%.2f,\n",unitX*(xi+1)-1,-unitY*(yi+1)+1,tmpTextCoordArray[2],tmpTextCoordArray[3]);
            // postions 右上
            self->imageVertices1[(yi*self->_numberX+xi)*24+20] = unitX*(xi+1)-1;
            self->imageVertices1[(yi*self->_numberX+xi)*24+21] = -unitY*yi+1;
            // textureCoord 右上
            self->imageVertices1[(yi*self->_numberX+xi)*24+22] = tmpTextCoordArray[6];
            self->imageVertices1[(yi*self->_numberX+xi)*24+23] = tmpTextCoordArray[7];
            NSLog(@"右上：%.2f,%.2f,%.2f,%.2f,\n",unitX*(xi+1)-1,-unitY*yi+1,tmpTextCoordArray[6],tmpTextCoordArray[7]);
            NSLog(@"\n\n\n\n\n\n\n\n\n\n\n\n");
        }
    }
    NSLog(@"结束===============================================");
    vbo2 = CreateBufferObject2(GL_ARRAY_BUFFER, sizeof(self->imageVertices1), self->imageVertices1, GL_STATIC_DRAW);
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
    
    glBindBuffer(GL_ARRAY_BUFFER, vbo2);
    
    glVertexAttribPointer(filterPositionAttribute, 2, GL_FLOAT, 0, sizeof(float)*4, (void*)(sizeof(float)*0));
    glVertexAttribPointer(filterTextureCoordinateAttribute, 2, GL_FLOAT, 0, sizeof(float)*4, (void*)(sizeof(float)*2));
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    for (int i = 0; i < MAX_SCREEN_NUMBER2; ++i)
    {
        glUniform1f(self->brightnessUniform, self->imageBrightness[i]);
        glDrawArrays(GL_TRIANGLES, i*6, 6);
    }
    
    [firstInputFramebuffer unlock];
    if (usingNextFrameForImageCapture)
    {
        dispatch_semaphore_signal(imageCaptureSemaphore);
    }
}
@end
