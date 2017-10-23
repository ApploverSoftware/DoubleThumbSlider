//
//  Fader.swift
//  ALFader
//
//  Created by Mac on 23.10.2017.
//  Copyright © 2017 Mac. All rights reserved.
//

import UIKit

protocol FaderDelegate {
    func rangeDidChage(left: CGFloat, right: CGFloat)
}

final class Fader: UIView {
    let circleRadius: CGFloat = 40
    let leftCircleBackgroundColor = UIColor.orange
    let rightCircleBackgroundColor = UIColor.orange
    
    let lineHeight: CGFloat = 10
    let backgroundLineColor = UIColor.gray
    let rangeLineColor = UIColor.orange
    
    // Background line
    private let backgroundLine = UIView()
    
    // Range line
    private let insideRangeView = UIView()
    private let leftOutsideRangeView = UIView()
    private let rightOutsideRangeView = UIView()
    
    var delegate: FaderDelegate?
    
    private let leftCircle = UIView()
    private var leftCircleXPos: CGFloat = 0.0 {
        didSet {
            leftCircle.center.x = leftCircleXPos
            selectedRange.leftXValue = newRangeValue(for: leftCircleXPos)
            refreshRangeDrawing()
        }
    }
    
    private let rightCircle = UIView()
    private var rightCircleXPos: CGFloat = 0.0 {
        didSet {
            rightCircle.center.x = rightCircleXPos
            selectedRange.rightXValue = newRangeValue(for: rightCircleXPos)
            refreshRangeDrawing()
        }
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
    
    fileprivate func newRangeValue(for circleXPosition: CGFloat) -> CGFloat {
        return (circleXPosition - circleRadius) / (frame.width - circleRadius * 2)
    }
    
    // Normalized value to range in both from 0 to 1
    var selectedRange: (leftXValue: CGFloat, rightXValue: CGFloat) = (0, 1) {
        didSet {
            if selectedRange.leftXValue > selectedRange.rightXValue {
                rangeState = .outside
            } else {
                rangeState = .inside
            }
            
            delegate?.rangeDidChage(left: selectedRange.leftXValue, right: selectedRange.rightXValue)
            debugPrint(selectedRange, "New range value")
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
        super.init(frame: frame)
        configFader()
        configPanGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configFader()
        configPanGesture()
    }
    
    private func configFader() {
        // Background line
        backgroundLine.frame = CGRect(
            x: 0,
            y: (frame.height - lineHeight) / 2,
            width: frame.width,
            height: lineHeight)
        backgroundLine.backgroundColor = backgroundLineColor
        backgroundLine.layer.cornerRadius = lineHeight / 2
        addSubview(backgroundLine)
        
        // Inside range
        insideRangeView.frame = CGRect(
            x: leftCircle.center.x,
            y: (frame.height - lineHeight) / 2,
            width: rightCircle.center.x - leftCircle.center.x,
            height: lineHeight)
        insideRangeView.backgroundColor = rangeLineColor
        insideRangeView.layer.cornerRadius = lineHeight / 2
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
        addSubview(rightOutsideRangeView)
        
        // Left circle
        leftCircle.frame = CGRect(
            x: 0,
            y: (frame.height - (circleRadius * 2)) / 2,
            width: circleRadius * 2,
            height: circleRadius * 2)
        leftCircle.layer.cornerRadius = circleRadius
        leftCircle.backgroundColor = leftCircleBackgroundColor
        addSubview(leftCircle)
        
        // Right circle
        rightCircle.frame = CGRect(
            x: frame.width - circleRadius * 2,
            y: (frame.height - (circleRadius * 2)) / 2,
            width: circleRadius * 2,
            height: circleRadius * 2)
        rightCircle.layer.cornerRadius = circleRadius
        rightCircle.backgroundColor = rightCircleBackgroundColor
        addSubview(rightCircle)
        
        refreshRangeDrawing()
    }
    
    private func configPanGesture() {
        let action = #selector(handlePanGesture(_:))
        let panGesture = UIPanGestureRecognizer(target: self, action: action)
        addGestureRecognizer(panGesture)
    }
    
    private var offsetToCenterOfCircle: CGFloat = 0.0
    
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

extension CGPoint {
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
