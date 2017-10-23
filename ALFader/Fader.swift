//
//  Fader.swift
//  ALFader
//
//  Created by Mac on 23.10.2017.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

protocol FaderDelegate: class {
    func rangeDidChage(left: CGFloat, right: CGFloat)
}

final class Fader: UIView {
    let circleRadius: CGFloat = 25
    let leftCircleBackgroundColor = UIColor.orange
    let rightCircleBackgroundColor = UIColor.orange
    
    var minValue: CGFloat = 0 {
        didSet {
            faderRange = (minValue, maxValue)
        }
    }
    
    var maxValue: CGFloat = 24 {
        didSet {
            faderRange = (minValue, maxValue)
        }
    }
    
    var lineHeight: CGFloat = 10
    var backgroundLineColor = UIColor(red: 0.84, green: 0.84, blue: 0.84, alpha: 1.00) {
        didSet {
            backgroundLine.backgroundColor = backgroundLineColor
        }
    }
    
    var rangeLineColor = UIColor.orange {
        didSet {
            insideRangeView.backgroundColor = rangeLineColor
            leftOutsideRangeView.backgroundColor = rangeLineColor
            rightOutsideRangeView.backgroundColor = rangeLineColor
        }
    }
    
    override var frame: CGRect {
        didSet {
            configFader()
        }
    }
    
    // Background line
    private let backgroundLine = UIView()
    
    // Range line
    private let insideRangeView = UIView()
    private let leftOutsideRangeView = UIView()
    private let rightOutsideRangeView = UIView()
    
    weak var delegate: FaderDelegate? {
        didSet { // To notify init values
            delegate?.rangeDidChage(left: faderRange.leftXValue, right: faderRange.rightXValue)
        }
    }
    
    private let leftCircle = UIView()
    fileprivate var leftCircleXPos: CGFloat = 0.0 {
        didSet {
            leftCircle.center.x = leftCircleXPos
            faderRange.leftXValue = newRangeValue(for: leftCircleXPos)
            refreshRangeDrawing()
        }
    }
    
    private let rightCircle = UIView()
    fileprivate var rightCircleXPos: CGFloat = 0.0 {
        didSet {
            rightCircle.center.x = rightCircleXPos
            faderRange.rightXValue = newRangeValue(for: rightCircleXPos)
            refreshRangeDrawing()
        }
    }
    
    private func newRangeValue(for circleXPosition: CGFloat) -> CGFloat {
        let values = maxValue - minValue
        let rangeWithPadding = frame.width - circleRadius * 2
        let startShift = minValue * (rangeWithPadding / values)
        let newValue = (startShift + (circleXPosition - circleRadius)) / (rangeWithPadding / values)
        return newValue.rounded(FloatingPointRoundingRule.toNearestOrEven)
    }
    
    // Normalized to range from 0 to 1 for both values
    var faderRange: (leftXValue: CGFloat, rightXValue: CGFloat) {
        didSet {
            if faderRange.leftXValue > faderRange.rightXValue {
                rangeState = .outside
            } else {
                rangeState = .inside
            }
            
            delegate?.rangeDidChage(left: faderRange.leftXValue, right: faderRange.rightXValue)
        }
    }
    
    private var rangeState: RangeState = .inside
    enum RangeState {
        case inside
        case outside
    }
    
    private var circleHandledByPanGesture: HandledCircle = .none
    enum HandledCircle {
        case left
        case right
        case none
    }
    
    override init(frame: CGRect) {
        faderRange = (minValue, maxValue)
        super.init(frame: frame)
        configFader()
        configPanGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        faderRange = (minValue, maxValue)
        super.init(coder: aDecoder)
        configFader()
        configPanGesture()
    }
    
    private func configFader() {
        subviews.forEach { $0.removeFromSuperview() }
        
        // Background line
        backgroundLine.frame = CGRect(
            x: 0,
            y: (frame.height - lineHeight) / 2,
            width: frame.width,
            height: lineHeight)
        backgroundLine.backgroundColor = backgroundLineColor
        backgroundLine.layer.cornerRadius = lineHeight / 2
        backgroundLine.layer.borderWidth = 0.5
        backgroundLine.layer.borderColor = backgroundLineColor.darker(by: 10)?.cgColor
        addSubview(backgroundLine)
        
        // Inside range
        insideRangeView.frame = CGRect(
            x: leftCircle.center.x,
            y: (frame.height - lineHeight) / 2,
            width: rightCircle.center.x - leftCircle.center.x,
            height: lineHeight)
        insideRangeView.backgroundColor = rangeLineColor
        insideRangeView.layer.cornerRadius = lineHeight / 2
        insideRangeView.layer.borderWidth = 0.5
        insideRangeView.layer.borderColor = rangeLineColor.darker(by: 10)?.cgColor
        addSubview(insideRangeView)
        
        // Left outside range
        leftOutsideRangeView.frame = CGRect(
            x: 0,
            y: (frame.height - lineHeight) / 2,
            width: rightCircle.center.x,
            height: lineHeight)
        leftOutsideRangeView.isHidden = true
        leftOutsideRangeView.backgroundColor = rangeLineColor
        leftOutsideRangeView.layer.cornerRadius = lineHeight / 2
        leftOutsideRangeView.layer.borderWidth = 0.5
        leftOutsideRangeView.layer.borderColor = rangeLineColor.darker(by: 10)?.cgColor
        addSubview(leftOutsideRangeView)
        
        // Right outside range
        rightOutsideRangeView.frame = CGRect(
            x: leftCircle.center.x,
            y: (frame.height - lineHeight) / 2,
            width: frame.width - leftCircle.center.x,
            height: lineHeight)
        rightOutsideRangeView.isHidden = true
        rightOutsideRangeView.backgroundColor = rangeLineColor
        rightOutsideRangeView.layer.cornerRadius = lineHeight / 2
        rightOutsideRangeView.layer.borderWidth = 0.5
        rightOutsideRangeView.layer.borderColor = rangeLineColor.darker(by: 10)?.cgColor
        addSubview(rightOutsideRangeView)
        
        // Left circle
        leftCircle.frame = CGRect(
            x: 0,
            y: (frame.height - (circleRadius * 2)) / 2,
            width: circleRadius * 2,
            height: circleRadius * 2)
        leftCircle.layer.cornerRadius = circleRadius
        leftCircle.backgroundColor = leftCircleBackgroundColor
        leftCircle.layer.borderWidth = 0.5
        leftCircle.layer.borderColor = leftCircleBackgroundColor.darker(by: 10)?.cgColor
        addSubview(leftCircle)
        
        // Right circle
        rightCircle.frame = CGRect(
            x: frame.width - circleRadius * 2,
            y: (frame.height - (circleRadius * 2)) / 2,
            width: circleRadius * 2,
            height: circleRadius * 2)
        rightCircle.layer.cornerRadius = circleRadius
        rightCircle.backgroundColor = rightCircleBackgroundColor
        rightCircle.layer.borderWidth = 0.5
        rightCircle.layer.borderColor = rightCircleBackgroundColor.darker(by: 10)?.cgColor
        addSubview(rightCircle)
        
        refreshRangeDrawing()
    }
    
    private func refreshRangeDrawing() {
        if rangeState == .inside {
            insideRangeView.isHidden = false
            leftOutsideRangeView.isHidden = true
            rightOutsideRangeView.isHidden = true
            
            insideRangeView.frame.origin.x = leftCircle.center.x
            insideRangeView.frame.size.width = rightCircle.center.x - leftCircle.center.x
        } else {
            insideRangeView.isHidden = true
            leftOutsideRangeView.isHidden = false
            rightOutsideRangeView.isHidden = false
            
            leftOutsideRangeView.frame.size.width = rightCircle.center.x
            rightOutsideRangeView.frame.origin.x = leftCircle.center.x
            rightOutsideRangeView.frame.size.width = frame.width - leftCircle.center.x
        }
    }
    
    private func configPanGesture() {
        let action = #selector(handlePanGesture(_:))
        let panGesture = UIPanGestureRecognizer(target: self, action: action)
        addGestureRecognizer(panGesture)
    }
    
    fileprivate var offsetToCenterOfCircle: CGFloat = 0.0
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let state = gesture.state
        
        switch state {
        case .began:
            let locationInFader = gesture.location(in: self)
            
            if handledLeftCircle(point: locationInFader) {
                offsetToCenterOfCircle = (locationInFader - leftCircle.center).x
                circleHandledByPanGesture = .left
            } else if handledRightCircle(point: locationInFader) {
                offsetToCenterOfCircle = (locationInFader - rightCircle.center).x
                circleHandledByPanGesture = .right
            } else {
                circleHandledByPanGesture = .none
            }
        case .changed:
            let newFingerXPos = gesture.location(in: self).x
            
            if circleHandledByPanGesture == .left {
                handleLeftCircleChange(for: newFingerXPos)
            } else if circleHandledByPanGesture == .right {
                handleRightCircleChange(for: newFingerXPos)
            }
        case .ended, .cancelled:
            circleHandledByPanGesture = .none
        default: break
        }
    }
    
    private func handledLeftCircle(point: CGPoint) -> Bool {
        return leftCircle.frame.contains(point)
    }
    
    private func handledRightCircle(point: CGPoint) -> Bool {
        return rightCircle.frame.contains(point)
    }
}

// MARK: Function to compute new value for particular circle x pos
extension Fader {
    fileprivate func handleLeftCircleChange(for newFingerXPos: CGFloat) {
        leftCircleXPos = computeNewXValue(for: newFingerXPos) ?? leftCircleXPos
    }
    
    fileprivate func handleRightCircleChange(for newFingerXPos: CGFloat) {
        rightCircleXPos = computeNewXValue(for: newFingerXPos) ?? rightCircleXPos
    }
    
    private func computeNewXValue(for fingerXPos: CGFloat) -> CGFloat? {
        let newXPosition = fingerXPos - offsetToCenterOfCircle
        if newXPosition > circleRadius && newXPosition < frame.width - circleRadius {
            return newXPosition
        } else if newXPosition < circleRadius {
            return circleRadius
        } else if newXPosition > frame.width - circleRadius {
            return frame.width - circleRadius
        } else {
            return nil
        }
    }
}

private extension UIColor {
    func lighter(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: abs(percentage) )
    }
    
    func darker(by percentage:CGFloat=30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage) )
    }
    
    func adjust(by percentage:CGFloat=30.0) -> UIColor? {
        var r:CGFloat=0, g:CGFloat=0, b:CGFloat=0, a:CGFloat=0;
        if(self.getRed(&r, green: &g, blue: &b, alpha: &a)){
            return UIColor(red: min(r + percentage/100, 1.0),
                           green: min(g + percentage/100, 1.0),
                           blue: min(b + percentage/100, 1.0),
                           alpha: a)
        }else{
            return nil
        }
    }
}

private extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}

