//
//  KeyframeAnimation.swift
//  Morph
//
//  Created by Alvin on 09/01/2017.
//  Copyright © 2017 Alvin. All rights reserved.
//

import UIKit

open class KeyframeAnimation: CAKeyframeAnimation {
    
    // MARK: Attributes
    
    /// The layer that apply the animation.
    public weak var layer: CALayer?
    
    /// The attribute that specify what kind of animation should be applied.
    public let attribute:Attribute
    
    /// The value that animation begin with.
    public var fromValue: AnyObject!
    
    /// The value that animation end up.
    public var toValue: AnyObject!
    
    /// The function block that effect apply with. Default is linear.
    public var functionBlock = keyframeAnimationFunctionLinear
    
    // MARK: Lifecycle
    
    override init() {
        attribute = .none
        
        super.init()
    }
    
    public init(attribute: Attribute) {
        self.attribute = attribute
        
        super.init()
        
        keyPath = attribute.keyPath
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @discardableResult open func from(_ value: AnimationChainable) -> KeyframeAnimation {
        fromValue = preprocessFromValue(value: value.boxValue())
        
        return self
    }
    
    @discardableResult open func to(_ value: AnimationChainable) -> KeyframeAnimation {
        toValue = preprocessToValue(value: value.boxValue())
        
        return self
    }
    
    @discardableResult open func by(_ values: [Any]) -> KeyframeAnimation {
        self.values = values
        
        return self
    }
    
    @discardableResult open func during(_ values: [NSNumber]) -> KeyframeAnimation {
        keyTimes = values
        
        return self
    }
    
    @discardableResult open func delay(_ timeInterval: TimeInterval) -> KeyframeAnimation {
        beginTime = CACurrentMediaTime() + timeInterval
        
        return self
    }
    
    @discardableResult open func animate(_ timeInterval: TimeInterval) -> KeyframeAnimation {
        duration = timeInterval
        
        return self
    }
    
    open func calculate() {
        createValueArray()
    }

}

// MARK: - Utilities

fileprivate let FPS: Double = 60

fileprivate extension KeyframeAnimation {
    
    fileprivate func preprocessFromValue(value: AnyObject) -> AnyObject {
        
        guard value.isKind(of: NSNumber.self), let f = value.doubleValue else {
            return value
        }
        
        var value = value
        
        if (attribute == .rotateX || attribute == .rotateY || attribute == .rotateZ) {
            
            value = NSNumber(value: (f / 180 * M_PI))
            
        } else if (attribute == .scale || attribute == .scaleX || attribute == .scaleY), fabs(f) < DBL_EPSILON {
            
            value = NSNumber(value: DBL_EPSILON)
            
        }
        
        return value
    }
    
    fileprivate func preprocessToValue(value: AnyObject) -> AnyObject {
        
        guard value.isKind(of: NSNumber.self), let f = value.doubleValue else {
            return value
        }
        
        var value = value
        
        if (attribute == .rotateX || attribute == .rotateY || attribute == .rotateZ) {
            
            value = NSNumber(value: (f / 180 * M_PI))
            
        } else if (attribute == .scale || attribute == .scaleX || attribute == .scaleY), fabs(f) < DBL_EPSILON {
            
            value = NSNumber(value: DBL_EPSILON)
            
        } else if attribute == .xOffset {
            
            let newX = Double(self.layer?.position.x ?? 0) + f
            value = NSNumber(value: newX)
        
        } else if attribute == .yOffset {
            
            let newY = Double(self.layer?.position.y ?? 0) + f
            value = NSNumber(value: newY)
            
        } else if attribute == .widthOffset {
            
            let newWidth = Double(self.layer?.bounds.size.width ?? 0) + f
            value = NSNumber(value: newWidth)
            
        } else if attribute == .heightOffset {
            
            let newHeight = Double(self.layer?.bounds.size.height ?? 0) + f
            value = NSNumber(value: newHeight)
            
        } else if attribute == .bezierPath, let bezierPath = value as? UIBezierPath {
            
            path = bezierPath.cgPath
            
        }
        
        return value
    }
    
    fileprivate func createValueArray() {
        if let fromValue: AnyObject = self.fromValue, let toValue: AnyObject = self.toValue {
            if valueIsKind(of: NSNumber.self) {
                
                values = valueArray(for: CGFloat(fromValue.doubleValue), endValue: CGFloat(toValue.doubleValue))
                
            } else if valueIsKind(of: UIColor.self) {
                
                let fromColor = fromValue.cgColor
                let toColor = toValue.cgColor
                
                if let fromComponents = fromColor?.components, let toComponents = toColor?.components {
                    
                    let redValues = valueArray(for: fromComponents[0], endValue: toComponents[0])
                    let greenValues = valueArray(for: fromComponents[1], endValue: toComponents[1])
                    let blueValues = valueArray(for: fromComponents[2], endValue: toComponents[2])
                    let alphaValues = valueArray(for: fromComponents[3], endValue: toComponents[3])
                    
                    values = colorArray(from: redValues, greenValues: greenValues, blueValues: blueValues, alphaValues: alphaValues)
                    
                }
                
            } else if valueIsKind(of: NSValue.self) {
                
                let valueType: NSString = NSString(cString: fromValue.objCType, encoding: 1)!
                
                if valueType.contains("CGRect"), let fromRect = fromValue.cgRectValue, let toRect = toValue.cgRectValue {
                    
                    let xValues = valueArray(for: fromRect.origin.x, endValue: toRect.origin.x)
                    let yValues = valueArray(for: fromRect.origin.y, endValue: toRect.origin.y)
                    let widths = valueArray(for: fromRect.size.width, endValue: toRect.size.width)
                    let heights = valueArray(for: fromRect.size.height, endValue: toRect.size.height)
                    
                    values = rectArray(from: xValues, yValues: yValues, widths: widths, heights: heights)
                    
                } else if valueType.contains("CGPoint"), let fromPoint = fromValue.cgPointValue, let toPoint = toValue.cgPointValue {
                    
                    let xValues = valueArray(for: fromPoint.x, endValue: toPoint.x)
                    let yValues = valueArray(for: fromPoint.y, endValue: toPoint.y)
                    
                    path = path(from: xValues, yValues: yValues)
                    
                } else if valueType.contains("CGSize"), let fromSize = fromValue.cgSizeValue, let toSize = toValue.cgSizeValue {
                    
                    let widths = valueArray(for: fromSize.width, endValue: toSize.width)
                    let heights = valueArray(for: fromSize.height, endValue: toSize.height)
                    
                    path = path(from: widths, yValues: heights)
                    
                } else if valueType.contains("CATransform3D"), let fromTransform = fromValue.caTransform3DValue, let toTransform = toValue.caTransform3DValue {
                    
                    let m11 = valueArray(for: fromTransform.m11, endValue: toTransform.m11)
                    let m12 = valueArray(for: fromTransform.m12, endValue: toTransform.m12)
                    let m13 = valueArray(for: fromTransform.m13, endValue: toTransform.m13)
                    let m14 = valueArray(for: fromTransform.m14, endValue: toTransform.m14)
                    
                    let m21 = valueArray(for: fromTransform.m21, endValue: toTransform.m21)
                    let m22 = valueArray(for: fromTransform.m22, endValue: toTransform.m22)
                    let m23 = valueArray(for: fromTransform.m23, endValue: toTransform.m23)
                    let m24 = valueArray(for: fromTransform.m24, endValue: toTransform.m24)
                    
                    let m31 = valueArray(for: fromTransform.m31, endValue: toTransform.m31)
                    let m32 = valueArray(for: fromTransform.m32, endValue: toTransform.m32)
                    let m33 = valueArray(for: fromTransform.m33, endValue: toTransform.m33)
                    let m34 = valueArray(for: fromTransform.m34, endValue: toTransform.m34)
                    
                    let m41 = valueArray(for: fromTransform.m41, endValue: toTransform.m41)
                    let m42 = valueArray(for: fromTransform.m42, endValue: toTransform.m42)
                    let m43 = valueArray(for: fromTransform.m43, endValue: toTransform.m43)
                    let m44 = valueArray(for: fromTransform.m44, endValue: toTransform.m44)
                    
                    values = transformArray(from: m11, m12: m12, m13: m13, m14: m14,
                                            m21: m21, m22: m22, m23: m23, m24: m24,
                                            m31: m31, m32: m32, m33: m33, m34: m34,
                                            m41: m41, m42: m42, m43: m43, m44: m44)
                    
                }
                
            }
            
            timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        }
    }
    
    fileprivate func valueIsKind(of klass: AnyClass) -> Bool {
        return self.fromValue!.isKind(of: klass) && self.toValue!.isKind(of: klass)
    }
    
    fileprivate func rectArray(from xValues: [NSNumber], yValues: [NSNumber], widths: [NSNumber], heights: [NSNumber]) -> [CGRect] {
        
        assert(xValues.count == yValues.count && xValues.count == widths.count && xValues.count == heights.count)
        
        let countOfRects = xValues.count
        var values = [CGRect]()
        
        for i in 1..<countOfRects {
            let value = CGRect(x: CGFloat(xValues[i].doubleValue),
                               y: CGFloat(yValues[i].doubleValue),
                               width: CGFloat(widths[i].doubleValue),
                               height: CGFloat(heights[i].doubleValue))
            values.append(value)
        }
        
        return values
    }
    
    fileprivate func path(from xValues: [NSNumber], yValues: [NSNumber]) -> CGPath {
        
        assert(xValues.count > 0)
        
        let countOfPoints = xValues.count
        let path = CGMutablePath()
        var value = CGPoint(x: CGFloat(xValues[0].doubleValue),
                            y: CGFloat(yValues[0].doubleValue))
        path.move(to: value)
        
        for i in 1..<countOfPoints {
            value = CGPoint(x: CGFloat(xValues[i].doubleValue),
                            y: CGFloat(yValues[i].doubleValue))
            path.addLine(to: value)
        }
        
        return path
    }
    
    fileprivate func colorArray(from redValues: [NSNumber], greenValues: [NSNumber], blueValues: [NSNumber], alphaValues: [NSNumber]) -> [CGColor] {
        
        assert(redValues.count > 0)
        
        let countOfColors = redValues.count
        var values = [CGColor]()
        
        for i in 1..<countOfColors {
            let value = UIColor(red: CGFloat(redValues[i].doubleValue),
                                green: CGFloat(greenValues[i].doubleValue),
                                blue: CGFloat(blueValues[i].doubleValue),
                                alpha: CGFloat(alphaValues[i].doubleValue))
            values.append(value.cgColor)
        }
        
        return values
    }
    
    fileprivate func valueArray(for startValue: CGFloat, endValue: CGFloat) -> [NSNumber] {
        let startValue = Double(startValue)
        let endValue = Double(endValue)
        
        let steps = Int(ceil(FPS * duration) + 2)
        var values = [NSNumber]()
        
        let increment = 1 / Double(steps - 1)
        var progress: Double = 0
        var v: Double = 0
        var value: Double = 0
        
        for _ in 0..<steps {
            v = functionBlock(duration * progress * 1000, 0, 1, duration * 1000)
            value = startValue + v * (endValue - startValue)
            values.append(NSNumber(value: value))
            progress += increment
        }
        
        return values
    }
    
    fileprivate func transformArray(from m11: [NSNumber], m12: [NSNumber], m13: [NSNumber], m14: [NSNumber],
                                    m21: [NSNumber], m22: [NSNumber], m23: [NSNumber], m24: [NSNumber],
                                    m31: [NSNumber], m32: [NSNumber], m33: [NSNumber], m34: [NSNumber],
                                    m41: [NSNumber], m42: [NSNumber], m43: [NSNumber], m44: [NSNumber]) -> [NSValue] {
        let numberOfTransform = m11.count
        var values = [NSValue]()
        
        for i in 1..<numberOfTransform {
            var value = CATransform3DIdentity
            value.m11 = CGFloat(m11[i].doubleValue)
            value.m12 = CGFloat(m12[i].doubleValue)
            value.m13 = CGFloat(m13[i].doubleValue)
            value.m14 = CGFloat(m14[i].doubleValue)
            
            value.m21 = CGFloat(m21[i].doubleValue)
            value.m22 = CGFloat(m22[i].doubleValue)
            value.m23 = CGFloat(m23[i].doubleValue)
            value.m24 = CGFloat(m24[i].doubleValue)
            
            value.m31 = CGFloat(m31[i].doubleValue)
            value.m32 = CGFloat(m32[i].doubleValue)
            value.m33 = CGFloat(m33[i].doubleValue)
            value.m34 = CGFloat(m34[i].doubleValue)
            
            value.m41 = CGFloat(m41[i].doubleValue)
            value.m42 = CGFloat(m42[i].doubleValue)
            value.m43 = CGFloat(m43[i].doubleValue)
            value.m44 = CGFloat(m44[i].doubleValue)
            
            values.append(NSValue(caTransform3D: value))
        }
        
        return values
    }
    
}
