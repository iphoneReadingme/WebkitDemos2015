//
//  CATransform3DPerspect.h
//  IOS_3D_UI
//
//  Created by adam.worldmatrix@gmail.com on 9/25/12.
//  Copyright (c) 2012 WorldMatrix. All rights reserved.
//

#ifndef IOS_3D_UI_CATransform3DPerspect_h
#define IOS_3D_UI_CATransform3DPerspect_h


// https://books.google.com/books?id=wCfWkc_E3GkC&pg=PA35&hl=zh-CN&source=gbs_toc_r&cad=3#v=onepage&q&f=false
///< 3D 向量
typedef struct
{
	CGFloat x;     ///< x
	CGFloat y;     ///< y
	CGFloat z;     ///< z
}Vector3;


/**
 *  构造CALayer的透视投影矩阵
 *  center : 相机相对于CALayer的平面位置
 *  disZ   : 相机与z=0投影平面的距离
 */

CATransform3D CATransform3DMakePerspective(CGPoint center, float disZ);
CATransform3D CATransform3DPerspect(CATransform3D t, CGPoint center, float disZ);

#endif



/*
 
 // 2015-06-27
 
 CATransform3DPerspect.h
 CATransform3DPerspect.m
IOS 3D UI --- CALayer的transform扩展

http://www.cocoachina.com/bbs/read.php?tid=117061&page=1
 
*/

