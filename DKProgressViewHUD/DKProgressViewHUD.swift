//
//  DKProgressViewHUD.swift
//  DKProgressViewHUD
//
//  Created by lee on 2017/6/6.
//  Copyright © 2017年 lee. All rights reserved.
//

import UIKit
import CoreGraphics
import QuartzCore

public let DKProgressMaxOffset = 10000.0
let DKDefaultPadding:CGFloat = 4.0
let DKDefaultLabelFontSize:CGFloat = 16.0
let DKDefaultDetailsLabelFontSize:CGFloat = 12.0

public enum DKProgressHUDMode {
    /// UIActivityIndicatorView.
    case indeterminate
    /// A round, pie-chart like, progress view.
    case determinate
    /// Horizontal progress bar.
    case determinateHorizontalBar
    /// Ring-shaped progress view.
    case annularDeterminate
    /// Shows a custom view.
    case customView
    /// Shows only labels.
    case text
}

public enum DKProgressHUDAnimation {
    /// Opacity animation
    case fade
    /// Opacity + scale animation (zoom in when appearing zoom out when disappearing)
    case zoom
    /// Opacity + scale animation (zoom out style)
    case zoomOut
    /// Opacity + scale animation (zoom in style)
    case zoomIn
}

public enum DKProgressHUDBackgroundStyle {
    /// Solid color background
    case solidColor
    /// UIVisualEffectView or UIToolbar.layer background view
    case blur
}

public typealias DKProgressHUDCompletionBlock = () -> Void

public protocol DKProgressHUDDelegate:NSObjectProtocol{
    /**
     * Called after the HUD was fully hidden from the screen.
     */
    func hudWasHidden(_ hud:DKProgressViewHUD) ->Void
}

public class DKBackgroundView: UIView {
    /**
     * The background style.
     * Defaults to MBProgressHUDBackgroundStyleBlur on iOS 7 or later and MBProgressHUDBackgroundStyleSolidColor otherwise.
     * @note Due to iOS 7 not supporting UIVisualEffectView, the blur effect differs slightly between iOS 7 and later versions.
     */
    private var _style = DKProgressHUDBackgroundStyle.blur
    
    public var style:DKProgressHUDBackgroundStyle{
        get{ return _style }
        set(newValue){
            _style = newValue
            updateForBackgroundStyle()
        }
    }
    /**
     * The background color or the blur tint color.
     * @note Due to iOS 7 not supporting UIVisualEffectView, the blur effect differs slightly between iOS 7 and later versions.
     */
    private var _color = UIColor.clear
    
    private var effectView:UIVisualEffectView?
    
    public var color:UIColor{
        get{
            return _color
        }set(newValue){
            _color = newValue
            updateViewsForColor(color: newValue)
        }
    }
    
    //MARK - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.style = .solidColor
        self.color = UIColor.init(white: 0.8, alpha: 0.6)
        self.clipsToBounds = true
        self.updateForBackgroundStyle()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateForBackgroundStyle() -> Void {
        if style == .blur {
            if self.effectView == nil {
                let effect = UIBlurEffect(style: .light)
                self.effectView = UIVisualEffectView(effect: effect)
                self.addSubview(self.effectView!)
                self.effectView?.frame = self.bounds;
                self.effectView?.autoresizingMask = [.flexibleHeight,.flexibleWidth]
                self.backgroundColor = self.color
                self.layer.allowsGroupOpacity = false;
            }
        }else{
            self.effectView?.removeFromSuperview()
            self.effectView = nil;
            self.backgroundColor = self.color;
        }
        
    }
    
    private func updateViewsForColor(color:UIColor) -> Void {
        if style == .blur {
            self.backgroundColor = self.color;
        }else{
            self.backgroundColor = self.color;
        }
    }
    
}

public class DKRoundProgressView: UIView {
    /**
     * Progress (0.0 to 1.0)
     */
    private var _progress: Float = 0.0
    @objc public var progress: Float{
        get{
            return _progress
        }set(newValue){
            _progress = newValue
            setNeedsDisplay()
        }
    }
    /**
     * Indicator progress color.
     * Defaults to white [UIColor whiteColor].
     */
    private var _progressTintColor = UIColor.white
    public var progressTintColor: UIColor {
        get{
            return _progressTintColor
        }set(newValue){
            _progressTintColor = newValue
            setNeedsDisplay()
        }
    }
    
    /**
     * Indicator background (non-progress) color.
     * Only applicable on iOS versions older than iOS 7.
     * Defaults to translucent white (alpha 0.1).
     */
    private var _backgroundTintColor = UIColor(white: 1.0, alpha: 0.1)
    public var backgroundTintColor: UIColor {
        get{
            return _backgroundTintColor
        }set(newValue){
            _backgroundTintColor = newValue
            setNeedsDisplay()
        }
    }
    
    /*
     * Display mode - NO = round or YES = annular. Defaults to round.
     */
    public var annular = false
    
    //MARK - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func `init`() -> DKRoundProgressView {
//        return DKRoundProgressView(frame: CGRect(x: 0.0, y: 0.0, width: 37.0, height: 37.0))
//    }
    
    
    //MARK - Layout
    
    override public var intrinsicContentSize: CGSize{
        get{
            return CGSize(width: 37.0, height: 37.0)
        }
    }
    
    //MARK - Drawing
    override public func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        if annular {
            let lineWidth: CGFloat = 2.0
            let processBackgroundPath = UIBezierPath()
            processBackgroundPath.lineWidth = lineWidth
            processBackgroundPath.lineCapStyle = .butt
            let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            let radius = (self.bounds.size.width - lineWidth)/2
            let startAngle = -(CGFloat(Double.pi / 2))
            var endAngle = (2 * CGFloat(Double.pi)) + startAngle
            processBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            backgroundTintColor.set()
            processBackgroundPath.stroke()
            // Draw progress
            let processPath = UIBezierPath()
            processPath.lineCapStyle = .square
            processPath.lineWidth = lineWidth;
            endAngle = (CGFloat(self.progress) * 2 * CGFloat(Double.pi)) + startAngle;
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            progressTintColor.set()
            processPath.stroke()
        }else{
            // Draw background
            let lineWidth: CGFloat = 2.0
            let allRect = self.bounds
            let circleRect = allRect.insetBy(dx: lineWidth/2.0, dy: lineWidth/2.0)
            let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
            progressTintColor.setStroke()
            backgroundTintColor.setFill()
            context?.setLineWidth(lineWidth)
            context?.strokeEllipse(in: circleRect)
            // 90 degrees
            let startAngle = -(CGFloat(Double.pi) / 2.0)
            let processPath = UIBezierPath()
            processPath.lineCapStyle = .butt
            processPath.lineWidth = lineWidth * 2
            // Draw progress
            let radius = (self.bounds.width / 2.0) - (processPath.lineWidth / 2.0)
            let endAngle = (CGFloat(self.progress) * 2.0 * CGFloat(Double.pi)) + startAngle
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            // Ensure that we don't get color overlaping when _progressTintColor alpha < 1.f.
            context?.setBlendMode(CGBlendMode.copy)
            progressTintColor.set()
            processPath.stroke()
            
        }
    }
}
    
public class DKBarProgressView: UIView {
    
    /**
     * Progress (0.0 to 1.0)
     */
    private var _progress:Float = 0.0
    @objc public var progress: Float{
        get{
            return _progress
        }set(newValue){
            _progress = newValue
            setNeedsDisplay()
        }
    }
    
    /**
     * Bar border line color.
     * Defaults to white [UIColor whiteColor].
     */
    public var lineColor = UIColor.white
    
    /**
     * Bar background color.
     * Defaults to clear [UIColor clearColor];
     */
    private var _progressRemainingColor = UIColor.clear
    public var progressRemainingColor: UIColor {
        get{
            return _progressRemainingColor
        }set(newValue){
            _progressRemainingColor = newValue
            setNeedsDisplay()
        }
    }
    
    /**
     * Bar progress color.
     * Defaults to white [UIColor whiteColor].
     */
    private var _progressColor = UIColor.white
    public var progressColor: UIColor{
        get{
            return _progressColor
        }set(newValue){
            _progressColor = newValue
            setNeedsDisplay()
        }
    }
    
    //MARK - Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK - Layout
    
    override public var intrinsicContentSize: CGSize{
        get{
            return CGSize(width: 120.0, height: 10.0)
        }
    }
    
    //MARK - Drawing
    
    override public func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2)
        context?.setStrokeColor(lineColor.cgColor)
        context?.setFillColor(progressRemainingColor.cgColor)
        
        // Draw background
        var radius: CGFloat = (rect.size.height / 2) - 2
        context?.move(to: CGPoint(x: 2, y: rect.size.height/2))
        context?.addArc(tangent1End: CGPoint(x:2,y:2), tangent2End: CGPoint(x:radius + 2,y:2), radius: radius)
        context?.addLine(to: CGPoint(x: rect.size.width - radius - 2, y: 2))
        context?.addArc(tangent1End: CGPoint(x: rect.size.width - 2, y: 2), tangent2End: CGPoint(x: rect.size.width - 2, y: rect.size.height / 2), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: rect.size.width - 2, y: rect.size.height - 2), tangent2End: CGPoint(x: rect.size.width - radius - 2, y: rect.size.height - 2), radius: radius)
        context?.addLine(to: CGPoint(x: radius + 2, y: rect.size.height - 2))
        context?.addArc(tangent1End: CGPoint(x: 2, y: rect.size.height - 2), tangent2End: CGPoint(x: 2, y: rect.size.height/2), radius: radius)
        context?.fillPath()
        
        // Draw border
        context?.move(to: CGPoint(x: 2, y: rect.size.height/2))
        context?.addArc(tangent1End: CGPoint(x: 2, y: 2), tangent2End: CGPoint(x: radius + 2, y: 2), radius: radius)
        context?.addLine(to: CGPoint(x: rect.size.width - radius - 2, y: 2))
        context?.addArc(tangent1End: CGPoint(x: rect.size.width - 2, y: 2), tangent2End: CGPoint(x: rect.size.width - 2, y: rect.size.height / 2), radius: radius)
        context?.addArc(tangent1End: CGPoint(x: rect.size.width - 2, y: rect.size.height - 2), tangent2End: CGPoint(x: rect.size.width - radius - 2, y: rect.size.height - 2), radius: radius)
        context?.addLine(to: CGPoint(x: radius + 2, y: rect.size.height - 2))
        context?.addArc(tangent1End: CGPoint(x: 2, y: rect.size.height - 2), tangent2End: CGPoint(x: 2, y: rect.size.height/2), radius: radius)
        context?.strokePath()
        context?.setFillColor(progressColor.cgColor)
        radius = radius-2
        let amount = CGFloat(self.progress) * rect.size.width
        // Progress in the middle area
        if (amount >= radius + 4 && amount <= (rect.size.width - radius - 4)) {
            context?.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius + 4, y: 4), radius: radius)
            context?.addLine(to: CGPoint(x: amount, y: 4))
            context?.addLine(to: CGPoint(x: amount, y: radius + 4))
            
            context?.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: rect.size.height - 4), tangent2End: CGPoint(x: radius + 4, y: rect.size.height - 4), radius: radius)
            context?.addLine(to: CGPoint(x: amount, y: rect.size.height - 4))
            context?.addLine(to: CGPoint(x: amount, y: radius + 4))
            
            context?.fillPath()
        }
        // Progress in the right arc
        else if (amount > radius + 4) {
            let x = amount - (rect.size.width - radius - 4)
            context?.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius + 4, y: 4), radius: radius)
            context?.addLine(to: CGPoint(x: rect.size.width - radius - 4, y: 4))
            var angle: CGFloat = -acos(x/radius)
            if (angle.isNaN) {angle = 0}
            context?.addArc(center: CGPoint(x: rect.size.width - radius - 4, y: rect.size.height/2), radius: radius, startAngle: CGFloat(Double.pi), endAngle: angle, clockwise: false)
            context?.addLine(to: CGPoint(x: amount, y: rect.size.height/2))
            
            context?.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: rect.size.height - 4), tangent2End: CGPoint(x: radius + 4, y: rect.size.height - 4), radius: radius)
            context?.addLine(to: CGPoint(x: rect.size.width - radius - 4, y: rect.size.height - 4))
            
            angle = acos(x/radius)
            if (angle.isNaN){ angle = 0 }
            context?.addArc(center: CGPoint(x: rect.size.width - radius - 4, y: rect.size.height/2), radius: radius, startAngle: -(CGFloat)(Double.pi), endAngle: angle, clockwise: true)
            context?.addLine(to: CGPoint(x: amount, y: rect.size.height/2))
            context?.fillPath()
        }
            // Progress is in the left arc
        else if (amount < radius + 4 && amount > 0) {
            context?.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: 4), tangent2End: CGPoint(x: radius + 4, y: 4), radius: radius)
            context?.addLine(to: CGPoint(x: radius + 4, y: rect.size.height/2))
            
            context?.move(to: CGPoint(x: 4, y: rect.size.height/2))
            context?.addArc(tangent1End: CGPoint(x: 4, y: rect.size.height - 4), tangent2End: CGPoint(x: radius + 4, y: rect.size.height - 4), radius: radius)
            context?.addLine(to: CGPoint(x: radius + 4, y: rect.size.height/2))
            
            context?.fillPath()
        }
    }
}

public class DKProgressHUDRoundedButton: UIButton {
    //MARK - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 1.0
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.layer.borderWidth = 1.0
    }
    //MARK - Layout
    override public func layoutSubviews() {
        super.layoutSubviews()
        let height = self.bounds.height
        self.layer.cornerRadius = ceil(height / 2.0)
    }
    
    override public var intrinsicContentSize: CGSize{
        get{
            // Only show if we have associated control events
            if (self.allControlEvents == UIControlEvents.init(rawValue: 0)) {return CGSize.zero}
            var size = super.intrinsicContentSize
            size.width += 20
            return size
        }
    }
    //MARK - Color
    override public func setTitleColor(_ color: UIColor?, for state: UIControlState) {
        super.setTitleColor(color, for: state)
        self.isHighlighted = super.isHighlighted
        self.layer.borderColor = color?.cgColor
    }
    
    override public var isHighlighted: Bool{
        get{
            return super.isHighlighted
        }set(newValue){
            super.isHighlighted = newValue
            let baseColor = self.titleColor(for: .selected)
            self.backgroundColor = newValue ? baseColor?.withAlphaComponent(0.1) : UIColor.clear
        }
    }
}

public class DKProgressViewHUD: UIView {
    
    /**
     * The HUD delegate object. Receives HUD state notifications.
     */
    public weak var delegate:DKProgressHUDDelegate?
    
    /**
     * Called after the HUD is hiden.
     */
    public var completionBlock:DKProgressHUDCompletionBlock?
    
    /*
     * Grace period is the time (in seconds) that the invoked method may be run without
     * showing the HUD. If the task finishes before the grace time runs out, the HUD will
     * not be shown at all.
     * This may be used to prevent HUD display for very short tasks.
     * Defaults to 0 (no grace time).
     */
    public var graceTime:TimeInterval = 0
    
    /**
     * The minimum time (in seconds) that the HUD is shown.
     * This avoids the problem of the HUD being shown and than instantly hidden.
     * Defaults to 0 (no minimum show time).
     */
    public var minShowTime:TimeInterval = 0
    
    /**
     * Removes the HUD from its parent view when hidden.
     * Defaults to NO.
     */
    public var removeFromSuperViewOnHide = false
    
    /// @name Appearance
    
    /**
     * MBProgressHUD operation mode. The default is MBProgressHUDModeIndeterminate.
     */
    private var _mode = DKProgressHUDMode.indeterminate
    public var mode :DKProgressHUDMode{
        get{
            return _mode
        }set(newValue){
            if (newValue != _mode) {
                _mode = newValue
                updateIndicators()
            }
        }
    }
    
    /**
     * A color that gets forwarded to all labels and supported indicators. Also sets the tintColor
     * for custom views on iOS 7+. Set to nil to manage color individually.
     * Defaults to semi-translucent black on iOS 7 and later and white on earlier iOS versions.
     * 无 iOS 7 之前版本
     */
    private var _contentColor = UIColor(white: 0, alpha: 0.7)
    public var contentColor: UIColor{
        get{
            return _contentColor
        }set(newValue){
            if (newValue != _contentColor) {
                _contentColor = newValue;
                updateViewsForColor(newValue)
            }
        }
    }
    
    
    /**
     * The animation type that should be used when the HUD is shown and hidden.
     */
    public var animationType = DKProgressHUDAnimation.fade
    
    /**
     * The bezel offset relative to the center of the view. You can use MBProgressMaxOffset
     * and -MBProgressMaxOffset to move the HUD all the way to the screen edge in each direction.
     * E.g., CGPointMake(0.f, MBProgressMaxOffset) would position the HUD centered on the bottom edge.
     */
    private var _offset = CGPoint.zero
    public var offset :CGPoint{
        get{
            return _offset
        }set(newValue){
            if (newValue != _offset) {
                _offset = newValue
                setNeedsUpdateConstraints()
            }
        }
    }
    
    /**
     * The amount of space between the HUD edge and the HUD elements (labels, indicators or custom views).
     * This also represents the minimum bezel distance to the edge of the HUD view.
     * Defaults to 20.f
     */
    private var _margin:CGFloat = 20.0
    public var margin:CGFloat{
        get{
            return _margin
        }set(newValue){
            if (newValue != _margin) {
                _margin = newValue;
                setNeedsUpdateConstraints()
            }
        }
    }
    
    /**
     * The minimum size of the HUD bezel. Defaults to CGSizeZero (no minimum size).
     */
    private var _minSize = CGSize.init(width: 50, height: 50)
    public var minSize: CGSize{
        get{
            return _minSize
        }set(newValue){
            if (newValue != _minSize) {
                _minSize = newValue;
                setNeedsUpdateConstraints()
            }
        }
    }
    
    /**
     * Force the HUD dimensions to be equal if possible.
     */
    private var _isSquare = false
    
    public var isSquare: Bool{
        get{
            return _isSquare
        }set(newValue){
            if (newValue != _isSquare) {
                _isSquare = newValue;
                setNeedsUpdateConstraints()
            }
        }
    }
    
    /**
     * When enabled, the bezel center gets slightly affected by the device accelerometer data.
     * Has no effect on iOS < 7.0. Defaults to YES.
     */
    private var _defaultMotionEffectsEnabled = true
    public var defaultMotionEffectsEnabled :Bool{
        get{
            return _defaultMotionEffectsEnabled
        }set(newValue){
            if (newValue != _defaultMotionEffectsEnabled) {
                _defaultMotionEffectsEnabled = newValue;
                updateBezelMotionEffects()
            }
        }
    }
    
    
    /// @name Progress
    
    /**
     * The progress of the progress indicator, from 0.0 to 1.0. Defaults to 0.0.
     */
    private var _progress: Float = 0.0
    @objc public var progress:Float {
        get{
            return _progress
        }set(newValue){
            if (newValue != _progress) {
                _progress = newValue;
                if (self.indicator?.responds(to: #selector(setter: progress)))! {
                    self.indicator?.setValue(_progress, forKey: "progress")
                }
            }
        }
    }
    
    /// @name ProgressObject
    
    /**
     * The NSProgress object feeding the progress information to the progress indicator.
     */
    private var _progressObject:Progress?
    public var progressObject:Progress?{
        get{
            return _progressObject
        }set(newValue){
            if (newValue != _progressObject) {
                _progressObject = newValue;
                setNSProgressDisplayLinkEnabled(true)
            }
        }
    }
    
    //MARK - NSProgress
    private func setNSProgressDisplayLinkEnabled(_ enabled:Bool) -> Void {
        // We're using CADisplayLink, because NSProgress can change very quickly and observing it may starve the main thread,
        // so we're refreshing the progress only every frame draw
        if (enabled && (self.progressObject != nil)) {
            // Only create if not already active.
            if (self.progressObjectDisplayLink == nil) {
                self.progressObjectDisplayLink = CADisplayLink.init(target: self, selector: #selector(updateProgressFromProgressObject))
            }
        } else {
            self.progressObjectDisplayLink = nil;
        }
    }
    
    @objc func updateProgressFromProgressObject() -> Void {
        self.progress = Float(self.progressObject!.fractionCompleted);
    }
    
    /// @name Views
    
    /**
     * The view containing the labels and indicator (or customView).
     */
    public var bezelView:DKBackgroundView?

    /**
     * View covering the entire HUD area, placed behind bezelView.
     */
    public var backgroundView:DKBackgroundView?
    
    /**
     * The UIView (e.g., a UIImageView) to be shown when the HUD is in MBProgressHUDModeCustomView.
     * The view should implement intrinsicContentSize for proper sizing. For best results use approximately 37 by 37 pixels.
     */
    private var _customView:UIView?
    public var customView:UIView?{
        get{
            return _customView
        }set(newValue){
            if (newValue != _customView) {
                _customView = newValue;
                if (self.mode == .customView) {
                    updateIndicators()
                }
            }
        }
    }
    
    /**
     * A label that holds an optional short message to be displayed below the activity indicator. The HUD is automatically resized to fit
     * the entire text.
     */
    public var label:UILabel?
    
    /**
     * A label that holds an optional details message displayed below the labelText message. The details text can span multiple lines.
     */
    public var detailsLabel:UILabel?
    
//    /**
//     * A button that is placed below the labels. Visible only if a target / action is added.
//     */
    public var button:UIButton?
    
    private var isUseAnimation = false
    private var isFinished = false
    private var indicator: UIView?
    private var showStarted: Date?
    private var paddingConstraints :Array<NSLayoutConstraint> = Array()
    private var bezelConstraints :Array<NSLayoutConstraint> = Array()
    private var topSpacer: UIView?
    private var bottomSpacer: UIView?
    private var hideDelayTimer: Timer?
    private var graceTimer: Timer?
    private var minShowTimer: Timer?
    private var _progressObjectDisplayLink :CADisplayLink?
    private var progressObjectDisplayLink :CADisplayLink?{
        get{
            return _progressObjectDisplayLink
        }set(newValue){
            if (newValue != _progressObjectDisplayLink) {
                _progressObjectDisplayLink?.invalidate()
                _progressObjectDisplayLink = newValue
                _progressObjectDisplayLink?.add(to: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
            }
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    //MARK - Class methods
    
    public static func showHUD(view:UIView,animated:Bool)->DKProgressViewHUD{
        let hud = DKProgressViewHUD.create(view: view)
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.show(animated)
        return hud
    }
    
    public static func hideHUD(view:UIView,animated:Bool)->Bool{
        let hud = DKProgressViewHUD.HUD(view: view)
        if hud != nil {
            hud?.removeFromSuperViewOnHide = true
            hud?.hide(animated)
            return true
        }
        return false
    }
    
    public static func HUD(view:UIView) -> DKProgressViewHUD? {
        for subView in view.subviews.reversed() {
            if subView.isKind(of: self) {
                let hud = subView as! DKProgressViewHUD
                if hud.isFinished == false {
                    return hud
                }
            }
        }
        return nil
    }
    
    //MARK: Lifecycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    public static func create(view:UIView) -> DKProgressViewHUD {
        return DKProgressViewHUD(frame: view.bounds)
    }
        
    private func commonInit() -> Void {
        backgroundColor = UIColor.clear
        alpha = 0.0
        layer.allowsGroupOpacity = false
        setupViews()
        updateIndicators()
        registerForNotifications()
    }
    
    deinit {
        unregisterFromNotifications()
    }
    
    //MARK - Show & hide
    
    public func showAnimated(_ animated:Bool) -> Void {
        assert(Thread.isMainThread, "DKProgressViewHUD needs to be accessed on the main thread.")
        self.minShowTimer?.invalidate()
        self.isUseAnimation = animated
        self.isFinished = false
        // If the grace time is set, postpone the HUD display
        if self.graceTime > 0.0 {
            let timer = Timer.init(timeInterval: self.graceTime, target: self, selector: #selector(handleGraceTimer), userInfo: nil, repeats: false)
            RunLoop.current.add(timer, forMode: .commonModes)
            self.graceTimer = timer;
        }else{
            showUsingAnimation(self.isUseAnimation)
        }
    }
    
    public func hideAnimated(_ animated:Bool) -> Void {
        assert(Thread.isMainThread, "DKProgressViewHUD needs to be accessed on the main thread.")
        self.graceTimer?.invalidate()
        self.isUseAnimation = animated
        self.isFinished = true
        // If the minShow time is set, calculate how long the HUD was shown,
        // and postpone the hiding operation if necessary
        if (self.minShowTime > 0.0 && (self.showStarted != nil)) {
            let interv = Date().timeIntervalSince(self.showStarted!)
            if (interv < self.minShowTime) {
                let timer = Timer(timeInterval: (self.minShowTime - interv), target: self, selector: #selector(handleMinShowTimer), userInfo: nil, repeats: false)
                RunLoop.current.add(timer, forMode: .commonModes)
                self.minShowTimer = timer
                return
            }
        }
        // ... otherwise hide the HUD immediately
        hideUsingAnimation(self.isUseAnimation)
    }
    
    public func hideAnimated(_ animated:Bool ,afterDelay delay:TimeInterval) -> Void {
        let timer = Timer(timeInterval: delay, target: self, selector: #selector(handleHideTimer), userInfo: animated, repeats: false)
        RunLoop.current.add(timer, forMode: .commonModes)
        self.hideDelayTimer = timer;
    }
    //MARK - Timer callbacks
    
    @objc func handleGraceTimer(_ theTimer:Timer) -> Void {
        // Show the HUD only if the task is still running
        if !self.isFinished {
            showUsingAnimation(self.isUseAnimation)
        }
    }
    
    @objc func handleMinShowTimer(_ theTimer:Timer) -> Void {
        hideUsingAnimation(self.isUseAnimation)
    }
    
    @objc func handleHideTimer(_ timer:Timer) -> Void {
        hideAnimated(timer.userInfo as! Bool)
    }
    
    //MARK - View Hierrarchy
    
    override public func didMoveToSuperview() -> Void {
        updateForCurrentOrientationAnimated(false)
    }
    
    //MARK - Internal show & hide operations
    
    private func showUsingAnimation(_ animated:Bool) -> Void {
        // Cancel any previous animations
        self.bezelView?.layer.removeAllAnimations()
        self.backgroundView?.layer.removeAllAnimations()
        // Cancel any scheduled hideDelayed: calls
        self.hideDelayTimer?.invalidate()
        
        self.showStarted = Date()
        self.alpha = 1.0
        
        // Needed in case we hide and re-show with the same NSProgress object attached.
        setNSProgressDisplayLinkEnabled(true)
        
        if animated {
            animateIn(true, withType: &self.animationType, completion: nil)
        }else{
            self.bezelView?.alpha = 1.0//self.opacity
            self.backgroundView?.alpha = 1.0
        }
    }
    
    private func hideUsingAnimation(_ animated:Bool) -> Void {
        if (animated && self.showStarted != nil) {
            self.showStarted = nil;
            animateIn(false, withType: &self.animationType, completion: { [weak self](finished) in
                self?.done()
            })
        }else{
            self.showStarted = nil;
            self.bezelView?.alpha = 0.0;
            self.backgroundView?.alpha = 1.0;
            self.done()
        }
    }
    typealias comple = (Bool) -> Void
    private func animateIn(_ animatingIn:Bool,withType type:inout DKProgressHUDAnimation ,completion:comple?) -> Void {
        // Automatically determine the correct zoom animation type
        if (type == .zoom) {
            type = animatingIn ? .zoomIn : .zoomOut;
        }
        
        let small = CGAffineTransform(scaleX: 0.5, y: 0.5)
        let large = CGAffineTransform(scaleX: 1.5, y: 1.5)
        
        // Set starting state
        if (animatingIn && self.bezelView!.alpha == 0.0 && type == .zoomIn) {
            self.bezelView?.transform = small;
        } else if (animatingIn && self.bezelView!.alpha == 0.0 && type == .zoomOut) {
            self.bezelView?.transform = large;
        }
        
        // Perform animations
        let animations = { [weak self] in
            if (animatingIn) {
                self?.bezelView?.transform = CGAffineTransform.identity
            } else if (!animatingIn && type == .zoomIn) {
                self?.bezelView?.transform = large;
            } else if (!animatingIn && type == .zoomOut) {
                self?.bezelView?.transform = small;
            }
            
            self?.bezelView?.alpha = animatingIn ? 1.0 : 0.0;
            self?.backgroundView?.alpha = animatingIn ? 1.0 : 0.0;
        }
        // Spring animations are nicer, but only available on iOS 7+
        UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: animations, completion: completion)
    }
    
    private func done() -> Void {
        // Cancel any scheduled hideDelayed: calls
        self.hideDelayTimer?.invalidate()
        setNSProgressDisplayLinkEnabled(false)
        
        if self.isFinished {
            self.alpha = 0.0
            if self.removeFromSuperViewOnHide {
                self.removeFromSuperview()
            }
        }
        
        let completionBlock = self.completionBlock;
        if (completionBlock != nil) {
            completionBlock!();
        }
        self.delegate?.hudWasHidden(self)
    }
    
    //MARK - Show & hide
    
    public func show(_ animated:Bool) -> Void {
        showAnimated(animated)
    }
    
    public func hide(_ animated:Bool) -> Void {
        hideAnimated(animated)
    }
    
    public func hide(_ animated:Bool,afterDelay delay:TimeInterval) -> Void {
        hideAnimated(animated, afterDelay: delay)
    }
    
    //MARK UI
    private func setupViews() -> Void {
        let defaultColor = self.contentColor
        
        backgroundView = DKBackgroundView(frame: self.bounds)
        backgroundView?.style = .solidColor
        backgroundView?.backgroundColor = UIColor.clear
        backgroundView?.alpha = 0.0
        self.addSubview(backgroundView!)
        
        bezelView = DKBackgroundView()
        bezelView?.style = .solidColor
        bezelView?.translatesAutoresizingMaskIntoConstraints = false;
        bezelView?.layer.cornerRadius = 5.0;
        bezelView?.alpha = 0.0;
        self.addSubview(bezelView!)
        updateBezelMotionEffects()
        
        label = UILabel()
        label?.adjustsFontSizeToFitWidth = false;
        label?.textAlignment = .center;
        label?.textColor = defaultColor;
        label?.font = UIFont.boldSystemFont(ofSize: DKDefaultLabelFontSize)
        label?.isOpaque = false;
        label?.backgroundColor = UIColor.clear
        
        detailsLabel = UILabel()
        detailsLabel?.adjustsFontSizeToFitWidth = false;
        detailsLabel?.textAlignment = .center;
        detailsLabel?.textColor = defaultColor;
        detailsLabel?.numberOfLines = 0;
        detailsLabel?.font = UIFont.boldSystemFont(ofSize: DKDefaultDetailsLabelFontSize)
        detailsLabel?.isOpaque = false;
        detailsLabel?.backgroundColor = UIColor.clear
        
        button = DKProgressHUDRoundedButton(type: .custom)
        button?.titleLabel?.textAlignment = .center
        button?.titleLabel?.font = UIFont.boldSystemFont(ofSize: DKDefaultDetailsLabelFontSize)
        button?.setTitleColor(defaultColor, for: .normal)
        
        for view in [label,detailsLabel,(button as UIView?)] {
            view?.translatesAutoresizingMaskIntoConstraints = false
            view?.setContentHuggingPriority(UILayoutPriority(rawValue: 998.0), for: .horizontal)
            view?.setContentHuggingPriority(UILayoutPriority(rawValue: 998.0), for: .vertical)
            view?.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998.0), for: .horizontal)
            view?.setContentCompressionResistancePriority(UILayoutPriority(rawValue: 998.0), for: .vertical)
            bezelView?.addSubview(view!)
        }
        
        topSpacer = UIView()
        topSpacer?.translatesAutoresizingMaskIntoConstraints = false

        topSpacer?.isHidden = true
        bezelView?.addSubview(topSpacer!)
        
        bottomSpacer = UIView()
        bottomSpacer?.translatesAutoresizingMaskIntoConstraints = false

        bottomSpacer?.isHidden = true
        bezelView?.addSubview(bottomSpacer!)
    }
    
    private func updateIndicators() -> Void {
        let isActivityIndicator =  indicator?.isKind(of: UIActivityIndicatorView.self) ?? false
        let isRoundIndicator = indicator?.isKind(of: DKRoundProgressView.self) ?? false
        if self.mode == .indeterminate {
            if !isActivityIndicator {
                // Update to indeterminate indicator
                indicator?.removeFromSuperview()
                indicator = UIActivityIndicatorView.init(activityIndicatorStyle: .whiteLarge)
                let ind = indicator as! UIActivityIndicatorView
                ind.startAnimating()
                self.bezelView?.addSubview(indicator!);
            }
        }else if self.mode == .determinateHorizontalBar {
            // Update to bar determinate indicator
            indicator?.removeFromSuperview()
            indicator = DKBarProgressView()
            self.bezelView?.addSubview(indicator!)
        }else if self.mode == .determinate || self.mode == .annularDeterminate{
            if !isRoundIndicator {
                // Update to determinante indicator
                indicator?.removeFromSuperview()
                indicator = DKRoundProgressView()
                self.bezelView?.addSubview(indicator!)
            }
            if self.mode == .annularDeterminate {
                let ind = indicator as! DKRoundProgressView
                ind.annular = true
            }
        }else if self.mode == .customView && self.customView != indicator{
            // Update custom view indicator
            indicator?.removeFromSuperview()
            indicator = self.customView;
            if let ind = indicator {
                self.bezelView?.addSubview(ind)
            }
        }else if self.mode == .text{
            indicator?.removeFromSuperview()
            indicator = nil
        }
        indicator?.translatesAutoresizingMaskIntoConstraints = false
        if let ind = indicator {
            if ind.responds(to: #selector(setter: progress)) {
                ind.setValue(self.progress, forKey: "progress")
            }
        }

        indicator?.setContentHuggingPriority(UILayoutPriority(rawValue: 998.0), for: .horizontal)
        indicator?.setContentHuggingPriority(UILayoutPriority(rawValue: 998.0), for: .vertical)
        updateViewsForColor(self.contentColor)
        setNeedsUpdateConstraints()
    }
    
    private func updateViewsForColor(_ color:UIColor) -> Void {
        self.label?.textColor = color
        self.detailsLabel?.textColor = color
        self.button?.setTitleColor(color, for: .normal)
        
        // UIAppearance settings are prioritized. If they are preset the set color is ignored.
        if let indicator = self.indicator {
            if (indicator.isKind(of: UIActivityIndicatorView.self)) {
                let ind = indicator as! UIActivityIndicatorView
                
                //            var appearance: UIActivityIndicatorView?
                //            if #available(iOS 9.0, *){
                //                appearance = UIActivityIndicatorView.appearance(whenContainedInInstancesOf: [DKProgressViewHUD.self])
                //            }else{
                //
                //            }
                    ind.color = color
            }else if (indicator.isKind(of: DKRoundProgressView.self)){
                let ind = indicator as! DKRoundProgressView
                    ind.progressTintColor = color
                    ind.backgroundTintColor = color.withAlphaComponent(0.1)
            }else if (indicator.isKind(of: DKBarProgressView.self)){
                let ind = indicator as! DKBarProgressView
                    ind.progressColor = color
                    ind.lineColor = color
            }else{
                if (indicator.responds(to: #selector(setter: tintColor))) {
                    indicator.tintColor = color
                }
            }
        }
        
    }

    private func updateBezelMotionEffects() -> Void {
        if !(self.bezelView?.responds(to: #selector(addMotionEffect)))! {
            return
        }
        if self.defaultMotionEffectsEnabled {
            let effectOffset: CGFloat = 10.0;
            let effectX = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)

            effectX.maximumRelativeValue = (effectOffset);
            effectX.minimumRelativeValue = (-effectOffset);
            
            let effectY = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
            effectY.maximumRelativeValue = (effectOffset);
            effectY.minimumRelativeValue = (-effectOffset);
            
            let group = UIMotionEffectGroup()
            group.motionEffects = [effectX, effectY];
            
            bezelView?.addMotionEffect(group)
        }else{
            if let effects = bezelView?.motionEffects{
                for effect in effects {
                bezelView?.removeMotionEffect(effect)
                }
            }
        }
    }
    
    //MARK - Layout
    private func applyPriority(priority:UILayoutPriority,constraints:inout Array<NSLayoutConstraint>) -> Void {
        for constraint in constraints {
            constraint.priority = priority
        }
    }
    
    override public func updateConstraints() -> Void {
        let metrics = Dictionary(dictionaryLiteral: ("margin", self.margin))
        var subview = [self.topSpacer,self.label,self.detailsLabel,self.button,self.bottomSpacer]
        if self.indicator != nil {
            subview.insert(self.indicator, at: 1)
        }
        removeConstraints(self.constraints)
        self.topSpacer?.removeConstraints((self.topSpacer?.constraints)!)
        self.bottomSpacer?.removeConstraints((self.bottomSpacer?.constraints)!)
        if self.bezelConstraints.count > 0 {
            self.bezelView?.removeConstraints(self.bezelConstraints)
            self.bezelConstraints.removeAll()
        }
        // Center bezel in container (self), applying the offset if set
        var centeringConstraints :Array<NSLayoutConstraint> = Array()
        centeringConstraints.append(NSLayoutConstraint(item: self.bezelView!, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: self.offset.x))
        centeringConstraints.append(NSLayoutConstraint(item: self.bezelView!, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: self.offset.y))
        self.applyPriority(priority: UILayoutPriority(rawValue: 997.0), constraints: &centeringConstraints)
        self.addConstraints(centeringConstraints)
        
        // Ensure minimum side margin is kept
        var sideConstraints1 :Array<NSLayoutConstraint> = Array()
        sideConstraints1 += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(>=margin)-[bezel]-(>=margin)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: Dictionary(dictionaryLiteral: ("bezel",self.bezelView!)))
        
        self.applyPriority(priority: UILayoutPriority(rawValue: 998.0), constraints: &sideConstraints1)
        addConstraints(sideConstraints1)
        
        if self.minSize != CGSize.zero {
            var minSizeConstraints :Array<NSLayoutConstraint> = Array()
            minSizeConstraints.append(NSLayoutConstraint(item: self.bezelView!, attribute: .width, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.minSize.width))
            minSizeConstraints.append(NSLayoutConstraint(item: self.bezelView!, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.minSize.height))
//            self.applyPriority(priority: UILayoutPriority(rawValue: 997.0), constraints: &minSizeConstraints)
            self.bezelConstraints += minSizeConstraints
        }
        
        // Top and bottom spacing
        let topSpacerConstraint = NSLayoutConstraint(item: self.topSpacer!, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.margin)
//        topSpacerConstraint.priority = UILayoutPriority(rawValue: 999.0)
        self.topSpacer?.addConstraint(topSpacerConstraint)
        let bottomSpacerConstraint = NSLayoutConstraint(item: self.bottomSpacer!, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.margin)
//        bottomSpacerConstraint.priority = UILayoutPriority(rawValue: 999.0)
        self.bottomSpacer?.addConstraint(bottomSpacerConstraint)
        
        // Top and bottom spaces should be equal
        let topAndBottom = NSLayoutConstraint(item: self.topSpacer!, attribute: .height, relatedBy: .equal, toItem: self.bottomSpacer!, attribute: .height, multiplier: 1.0, constant: 0)
//        topAndBottom.priority = UILayoutPriority(rawValue: 999.0)
        self.bezelConstraints.append(topAndBottom)
        // Layout subviews in bezel
        self.paddingConstraints.removeAll()
        for (index,view) in subview.enumerated() {
            // Center in bezel
            self.bezelConstraints.append(NSLayoutConstraint(item: view!, attribute: .centerX, relatedBy: .equal, toItem: self.bezelView!, attribute: .centerX, multiplier: 1.0, constant: 0))
            // Ensure the minimum edge margin is kept
            let viewConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(>=margin)-[view]", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: Dictionary(dictionaryLiteral: ("view", view!)))
//            self.applyPriority(priority: UILayoutPriority(rawValue: 999.0), constraints: &viewConstraints)
            self.bezelConstraints += viewConstraints
            // Element spacing
            if (index == 0) {
                // First, ensure spacing to bezel edge
                let topConstraint = NSLayoutConstraint(item: view!, attribute: .top, relatedBy: .equal, toItem: self.bezelView!, attribute: .top, multiplier: 1.0, constant: 0)
//                topConstraint.priority = UILayoutPriority(rawValue: 999.0)
                self.bezelConstraints.append(topConstraint)
            }else if (index == subview.count - 1){
                // Last, ensure spacing to bezel edge
                let bottomConstraint = NSLayoutConstraint(item: view!, attribute: .bottom, relatedBy: .equal, toItem: self.bezelView!, attribute: .bottom, multiplier: 1.0, constant: 0)
//                bottomConstraint.priority = UILayoutPriority(rawValue: 999.0)
                self.bezelConstraints.append(bottomConstraint)
            }
            if (index > 0){
                // Has previous
                let padding = NSLayoutConstraint(item: view!, attribute: .top, relatedBy: .equal, toItem: subview[index - 1], attribute: .bottom, multiplier: 1.0, constant: 0)
//                padding.priority = UILayoutPriority(rawValue: 999.0)
                self.bezelConstraints.append(padding)
                self.paddingConstraints.append(padding)
            }
        }
        // Square aspect ratio, if set
        if (self.isSquare) {
            let square = NSLayoutConstraint(item: self.bezelView!, attribute: .height, relatedBy: .equal, toItem: self.bezelView!, attribute: .width, multiplier: 1.0, constant: 0)
            square.priority = UILayoutPriority(rawValue: 998.0)
            self.bezelConstraints.append(square)
        }
        self.bezelView?.addConstraints(self.bezelConstraints)
        self.updatePaddingConstraints()
        
        // Ensure minimum side margin is kept
        var sideConstraints2 :Array<NSLayoutConstraint> = Array()
        sideConstraints2 += NSLayoutConstraint.constraints(withVisualFormat: "|-(>=margin)-[bezel]-(>=margin)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: Dictionary(dictionaryLiteral: ("bezel",self.bezelView!)))
        self.applyPriority(priority: UILayoutPriority(rawValue: 998.0), constraints: &sideConstraints2)
        addConstraints(sideConstraints2)
        
        super.updateConstraints()
    }
    
    override public func layoutSubviews() {
        if !self.needsUpdateConstraints() {
            self.updatePaddingConstraints()
        }
        super.layoutSubviews()
    }
    
    private func updatePaddingConstraints() -> Void {
        // Set padding dynamically, depending on whether the view is visible or not
        var hasVisibleAncestors = false;
        for padding in self.paddingConstraints {
            let firstView: UIView = padding.firstItem as! UIView
            let secondView: UIView = padding.secondItem as! UIView
            let firstVisible = !firstView.isHidden && firstView.intrinsicContentSize != CGSize.zero
            let secondVisible = !secondView.isHidden && secondView.intrinsicContentSize != CGSize.zero
            // Set if both views are visible or if there's a visible view on top that doesn't have padding
            // added relative to the current view yet
            padding.constant = (firstVisible && (secondVisible || hasVisibleAncestors)) ? DKDefaultPadding : 0.0
            if !secondVisible && !hasVisibleAncestors {
                hasVisibleAncestors = false
            }else{
                hasVisibleAncestors = true
            }
        }
    }
    //MARK - Notifications
    
    private func registerForNotifications() -> Void {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(statusBarOrientationDidChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    private func unregisterFromNotifications() -> Void {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    @objc func statusBarOrientationDidChange(notification:NSNotification) -> Void {
        if self.superview != nil {
            self.updateForCurrentOrientationAnimated(true)
        }
    }
    
    private func updateForCurrentOrientationAnimated(_ animated:Bool) -> Void {
        // Stay in sync with the superview in any case
        if (self.superview != nil) {
            self.bounds = (self.superview?.bounds)!;
        }
        
        if #available(iOS 8.0, *) {
            return
        }else{
            if (self.superview?.isKind(of: UIWindow.self))! {
                return
            }
        }
        // Make extension friendly. Will not get called on extensions (iOS 8+) due to the above check.
        // This just ensures we don't get a warning about extension-unsafe API.
//        let UIApplicationClass:UIApplication = NSClassFromString("UIApplication")
//        if (!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) return;
//        
//        UIApplication *application = [UIApplication performSelector:@selector(sharedApplication)];
//        UIInterfaceOrientation orientation = application.statusBarOrientation;
//        CGFloat radians = 0;
//        
//        if (UIInterfaceOrientationIsLandscape(orientation)) {
//            radians = orientation == UIInterfaceOrientationLandscapeLeft ? -(CGFloat)M_PI_2 : (CGFloat)M_PI_2;
//            // Window coordinates differ!
//            self.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.width);
//        } else {
//            radians = orientation == UIInterfaceOrientationPortraitUpsideDown ? (CGFloat)M_PI : 0.f;
//        }
//        
//        if (animated) {
//            [UIView animateWithDuration:0.3 animations:^{
//                self.transform = CGAffineTransformMakeRotation(radians);
//                }];
//        } else {
//            self.transform = CGAffineTransformMakeRotation(radians);
//        }
    }
}
