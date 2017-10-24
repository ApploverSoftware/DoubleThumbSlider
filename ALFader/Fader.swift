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
    // Thumbs corner radius
    var thumbRadius: CGFloat = 25 {
        didSet {
            configLeftThumb()
            configRightThumb()
        }
    }
    
    // Color of left thumb
    var leftThumbBackgroundColor = UIColor.orange {
        didSet {
            leftThumb.backgroundColor = leftThumbBackgroundColor
        }
    }
    
    // Color of right thumb
    var rightThumbBackgroundColor = UIColor.orange {
        didSet {
            rightThumb.backgroundColor = rightThumbBackgroundColor
        }
    }
    
    // Min value (most left)
    var minValue: CGFloat = 0 {
        didSet {
            faderRange = (minValue, maxValue)
        }
    }
    
    // Max value (most right)
    var maxValue: CGFloat = 24 {
        didSet {
            faderRange = (minValue, maxValue)
        }
    }
    
    // Init value for left thumb in depends of min - max
    var initLeftValue: CGFloat = 0 {
        didSet {
            let values = maxValue - minValue
            let rangeWithPadding = frame.width - thumbRadius * 2
            let startShift = thumbRadius + initLeftValue * (rangeWithPadding / values)
            leftThumbXPos = computeNewXValue(for: startShift) ?? leftThumbXPos
        }
    }
    
    // Init value for right thumb in depends of min - max
    var initRightValue: CGFloat = 0 {
        didSet {
            let values = maxValue - minValue
            let rangeWithPadding = frame.width - thumbRadius * 2
            let startShift = thumbRadius + initRightValue * (rangeWithPadding / values)
            rightThumbXPos = computeNewXValue(for: startShift) ?? rightThumbXPos
        }
    }
    
    // Height of fader
    var lineHeight: CGFloat = 10 {
        didSet {
            configBackgroundLine()
            configRightOutsideRange()
            configLeftOutsideRange()
            configInsideRange()
        }
    }
    
    // Color of view which represents whole fader
    var backgroundLineColor = UIColor(red: 0.84, green: 0.84, blue: 0.84, alpha: 1.00) {
        didSet {
            backgroundLine.backgroundColor = backgroundLineColor
        }
    }
    
    // Color of view which indicate selected user value
    var rangeLineColor = UIColor.orange {
        didSet {
            insideRangeView.backgroundColor = rangeLineColor
            leftOutsideRangeView.backgroundColor = rangeLineColor
            rightOutsideRangeView.backgroundColor = rangeLineColor
        }
    }
    
    // Overriden frame, need to refresh content when user
    // decided to set frame after he created an instance of object
    override var frame: CGRect {
        didSet {
            configBackgroundLine()
            configInsideRange()
            configLeftOutsideRange()
            configRightOutsideRange()
            configLeftThumb()
            configRightThumb()
            refreshRangeDrawing()
        }
    }
    
    // Background line
    private let backgroundLine = UIView()
    
    // Range line
    private let insideRangeView = UIView()
    private let leftOutsideRangeView = UIView()
    private let rightOutsideRangeView = UIView()
    
    private let leftThumb = UIView()
    fileprivate var leftThumbXPos: CGFloat = 0.0 {
        didSet {
            leftThumb.center.x = leftThumbXPos
            faderRange.leftXValue = newRangeValue(for: leftThumbXPos)
        }
    }
    
    private let rightThumb = UIView()
    fileprivate var rightThumbXPos: CGFloat = 0.0 {
        didSet {
            rightThumb.center.x = rightThumbXPos
            faderRange.rightXValue = newRangeValue(for: rightThumbXPos)
        }
    }
    
    weak var delegate: FaderDelegate? {
        didSet { // To notify init values
            delegate?.rangeDidChage(left: faderRange.leftXValue, right: faderRange.rightXValue)
        }
    }
    
    // Normalized to range from 0 to 1 for both values
    var faderRange: (leftXValue: CGFloat, rightXValue: CGFloat) {
        didSet {
            if faderRange.leftXValue > faderRange.rightXValue {
                rangeState = .outside
            } else {
                rangeState = .inside
            }
            refreshRangeDrawing()
            delegate?.rangeDidChage(left: faderRange.leftXValue, right: faderRange.rightXValue)
        }
    }
    
    private var rangeState: RangeState = .inside
    enum RangeState {
        case inside
        case outside
    }
    
    private var thumbHandledByPanGesture: HandledCircle = .none
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
        // Background line
        configBackgroundLine()
        addSubview(backgroundLine)
        
        // Inside range
        configInsideRange()
        addSubview(insideRangeView)
        
        // Left outside range
        configLeftOutsideRange()
        addSubview(leftOutsideRangeView)
        
        // Right outside range
        configRightOutsideRange()
        addSubview(rightOutsideRangeView)
        
        // Left circle
        configLeftThumb()
        addSubview(leftThumb)
        
        // Right circle
        configRightThumb()
        addSubview(rightThumb)
        
        // Adjust ranges to requirements
        refreshRangeDrawing()
    }
    
    private func configBackgroundLine() {
        backgroundLine.frame = CGRect(
            x: 0,
            y: (frame.height - lineHeight) / 2,
            width: frame.width,
            height: lineHeight)
        backgroundLine.backgroundColor = backgroundLineColor
        backgroundLine.layer.cornerRadius = lineHeight / 2
        backgroundLine.layer.borderWidth = 0.5
        backgroundLine.layer.borderColor = backgroundLineColor.darker(by: 10)?.cgColor
    }
    
    private func configInsideRange() {
        insideRangeView.frame = CGRect(
            x: leftThumb.center.x,
            y: (frame.height - lineHeight) / 2,
            width: rightThumb.center.x - leftThumb.center.x,
            height: lineHeight)
        insideRangeView.backgroundColor = rangeLineColor
        insideRangeView.layer.cornerRadius = lineHeight / 2
        insideRangeView.layer.borderWidth = 0.5
        insideRangeView.layer.borderColor = rangeLineColor.darker(by: 10)?.cgColor
    }
    
    private func configLeftOutsideRange() {
        leftOutsideRangeView.frame = CGRect(
            x: 0,
            y: (frame.height - lineHeight) / 2,
            width: rightThumb.center.x,
            height: lineHeight)
        leftOutsideRangeView.isHidden = true
        leftOutsideRangeView.backgroundColor = rangeLineColor
        leftOutsideRangeView.layer.cornerRadius = lineHeight / 2
        leftOutsideRangeView.layer.borderWidth = 0.5
        leftOutsideRangeView.layer.borderColor = rangeLineColor.darker(by: 10)?.cgColor
    }
    
    private func configRightOutsideRange() {
        rightOutsideRangeView.frame = CGRect(
            x: leftThumb.center.x,
            y: (frame.height - lineHeight) / 2,
            width: frame.width - leftThumb.center.x,
            height: lineHeight)
        rightOutsideRangeView.isHidden = true
        rightOutsideRangeView.backgroundColor = rangeLineColor
        rightOutsideRangeView.layer.cornerRadius = lineHeight / 2
        rightOutsideRangeView.layer.borderWidth = 0.5
        rightOutsideRangeView.layer.borderColor = rangeLineColor.darker(by: 10)?.cgColor
    }
    
    private func configLeftThumb() {
        leftThumb.frame = CGRect(
            x: 0,
            y: (frame.height - (thumbRadius * 2)) / 2,
            width: thumbRadius * 2,
            height: thumbRadius * 2)
        leftThumb.layer.cornerRadius = thumbRadius
        leftThumb.backgroundColor = leftThumbBackgroundColor
        leftThumb.layer.borderWidth = 0.5
        leftThumb.layer.borderColor = leftThumbBackgroundColor.darker(by: 10)?.cgColor
    }
    
    private func configRightThumb() {
        rightThumb.frame = CGRect(
            x: frame.width - thumbRadius * 2,
            y: (frame.height - (thumbRadius * 2)) / 2,
            width: thumbRadius * 2,
            height: thumbRadius * 2)
        rightThumb.layer.cornerRadius = thumbRadius
        rightThumb.backgroundColor = rightThumbBackgroundColor
        rightThumb.layer.borderWidth = 0.5
        rightThumb.layer.borderColor = rightThumbBackgroundColor.darker(by: 10)?.cgColor
    }
    
    private func refreshRangeDrawing() {
        if rangeState == .inside {
            insideRangeView.isHidden = false
            leftOutsideRangeView.isHidden = true
            rightOutsideRangeView.isHidden = true
            
            insideRangeView.frame.origin.x = leftThumb.center.x
            insideRangeView.frame.size.width = rightThumb.center.x - leftThumb.center.x
        } else {
            insideRangeView.isHidden = true
            leftOutsideRangeView.isHidden = false
            rightOutsideRangeView.isHidden = false
            
            leftOutsideRangeView.frame.origin.x = 0
            leftOutsideRangeView.frame.size.width = rightThumb.center.x
            rightOutsideRangeView.frame.origin.x = leftThumb.center.x
            rightOutsideRangeView.frame.size.width = frame.width - leftThumb.center.x
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
                offsetToCenterOfCircle = (locationInFader - leftThumb.center).x
                thumbHandledByPanGesture = .left
            } else if handledRightCircle(point: locationInFader) {
                offsetToCenterOfCircle = (locationInFader - rightThumb.center).x
                thumbHandledByPanGesture = .right
            } else {
                thumbHandledByPanGesture = .none
            }
        case .changed:
            let newFingerXPos = gesture.location(in: self).x
            
            if thumbHandledByPanGesture == .left {
                handleLeftCircleChange(for: newFingerXPos)
            } else if thumbHandledByPanGesture == .right {
                handleRightCircleChange(for: newFingerXPos)
            }
        case .ended, .cancelled:
            thumbHandledByPanGesture = .none
        default: break
        }
    }
    
    private func newRangeValue(for circleXPosition: CGFloat) -> CGFloat {
        let values = maxValue - minValue
        let rangeWithPadding = frame.width - thumbRadius * 2
        let startShift = minValue * (rangeWithPadding / values)
        let newValue = (startShift + (circleXPosition - thumbRadius)) / (rangeWithPadding / values)
        return newValue.rounded(FloatingPointRoundingRule.toNearestOrEven)
    }
    
    
    /// Set start values in depends of given range
    ///
    /// - Parameters:
    ///   - left: Left thumb position
    ///   - right: Right thumb position
    func startValues(left: CGFloat, right: CGFloat) {
        
    }
    
    private func handledLeftCircle(point: CGPoint) -> Bool {
        return leftThumb.frame.insetBy(dx: -20, dy: -20).contains(point)
    }
    
    private func handledRightCircle(point: CGPoint) -> Bool {
        return rightThumb.frame.insetBy(dx: -20, dy: -20).contains(point)
    }
}

// MARK: Function to compute new value for particular circle x pos
extension Fader {
    fileprivate func handleLeftCircleChange(for newFingerXPos: CGFloat) {
        leftThumbXPos = computeNewXValue(for: newFingerXPos) ?? leftThumbXPos
    }
    
    fileprivate func handleRightCircleChange(for newFingerXPos: CGFloat) {
        rightThumbXPos = computeNewXValue(for: newFingerXPos) ?? rightThumbXPos
    }
    
    fileprivate func computeNewXValue(for fingerXPos: CGFloat) -> CGFloat? {
        let newXPosition = fingerXPos - offsetToCenterOfCircle
        if newXPosition > thumbRadius && newXPosition < frame.width - thumbRadius {
            return newXPosition
        } else if newXPosition <= thumbRadius {
            return thumbRadius
        } else if newXPosition >= frame.width - thumbRadius {
            return frame.width - thumbRadius
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


