//
//  KCFloatingActionButton.swift
//
//  Created by LeeSunhyoup on 2015. 10. 4..
//  Copyright © 2015년 kciter. All rights reserved.
//

import UIKit

public enum KCFABOpenAnimationType {
    case Pop
    case Fade
    case SlideLeft
    case SlideUp
    case None
}

/**
    Floating Action Button Object. It has `KCFloatingActionButtonItem` objects.
    KCFloatingActionButton support storyboard designable.
*/
@IBDesignable
public class KCFloatingActionButton: UIView {
    // MARK: - Properties
    
    /**
        `KCFloatingActionButtonItem` objects.
    */
    public var items: [KCFloatingActionButtonItem] = []
    
    /**
        This object's button size.
    */
    public var size: CGFloat = 56 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    /**
        Padding from bottom right of UIScreen or superview.
    */
    public var paddingX: CGFloat = 14 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    public var paddingY: CGFloat = 14 {
        didSet {
            self.setNeedsDisplay()
        }
    }
	
	/**
		Automatically closes child items when tapped
	*/
	@IBInspectable public var autoCloseOnTap: Bool = true
	
	/**
		Degrees to rotate image
	*/
	@IBInspectable public var rotationDegrees: CGFloat = -45
    /**
        Button color.
    */
    @IBInspectable public var buttonColor: UIColor = UIColor(red: 73/255.0, green: 151/255.0, blue: 241/255.0, alpha: 1)
    
    /**
        Button image.
    */
    @IBInspectable public var buttonImage: UIImage? = nil
    
    /**
        Plus icon color inside button.
    */
    @IBInspectable public var plusColor: UIColor = UIColor(white: 0.2, alpha: 1)
    
    /**
        Background overlaying color.
    */
    @IBInspectable public var overlayColor: UIColor = UIColor.blackColor().colorWithAlphaComponent(0.3)
    
    /**
        The space between the item and item.
    */
    @IBInspectable public var itemSpace: CGFloat = 14
    
    /**
        Child item's default size.
    */
    @IBInspectable public var itemSize: CGFloat = 42
    
    /**
        Child item's default button color.
    */
    @IBInspectable public var itemButtonColor: UIColor = UIColor.whiteColor()
	
	/**
		Child item's image color
	*/
	@IBInspectable public var itemImageColor: UIColor? = nil
	
    /**
        Child item's default shadow color.
    */
    @IBInspectable public var itemShadowColor: UIColor = UIColor.blackColor()
    
    /**
    
    */
    public var closed: Bool = true
    
    public var openAnimationType: KCFABOpenAnimationType = .Pop
    
    public var isOffScreen: Bool = false
    
    /**
     Delegate that can be used to learn more about the behavior of the FAB widget.
    */
    @IBOutlet public weak var fabDelegate: KCFloatingActionButtonDelegate?
    
    /**
        Button shape layer.
    */
    private var circleLayer: CAShapeLayer = CAShapeLayer()
    
    /**
        Plus icon shape layer.
    */
    private var plusLayer: CAShapeLayer = CAShapeLayer()
    
    /**
        Button image view.
    */
    private var buttonImageView: UIImageView = UIImageView()
    
    /**
        If you keeping touch inside button, button overlaid with tint layer.
    */
    private var tintLayer: CAShapeLayer = CAShapeLayer()
    
    /**
        If you show items, background overlaid with overlayColor.
    */
//    private var overlayLayer: CAShapeLayer = CAShapeLayer()
     
    private var overlayView : UIControl = UIControl()

    
    /**
        If you created this object from storyboard or `initWithFrame`, this property set true.
    */
    private var isCustomFrame: Bool = false
    
    // MARK: - Initialize
    
    /**
        Initialize with default property.
    */
    public init() {
        super.init(frame: CGRectMake(0, 0, size, size))
        backgroundColor = UIColor.clearColor()
        setObserver()
    }
    
    /**
        Initialize with custom size.
    */
    public init(size: CGFloat) {
        self.size = size
        super.init(frame: CGRectMake(0, 0, size, size))
        backgroundColor = UIColor.clearColor()
        setObserver()
    }
    
    /**
        Initialize with custom frame.
    */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        size = min(frame.size.width, frame.size.height)
        backgroundColor = UIColor.clearColor()
        isCustomFrame = true
        setObserver()
    }
    
    /**
        Initialize from storyboard.
    */
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        size = min(frame.size.width, frame.size.height)
        backgroundColor = UIColor.clearColor()
        clipsToBounds = false
        isCustomFrame = true
        setObserver()
    }
    
    // MARK: - Method
    
    /**
        Set size and frame.
    */
    public override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        if isCustomFrame == false {
            setRightBottomFrame()
        } else {
            size = min(frame.size.width, frame.size.height)
        }
    }
    
    /**
        Draw layers.
    */
    public override func drawLayer(layer: CALayer, inContext ctx: CGContext) {
        super.drawLayer(layer, inContext: ctx)
        setCircleLayer()
        setPlusLayer()
        setButtonImage()
        if closed {
            plusLayer.opacity = 0
        } else {
            buttonImageView.alpha = 0
        }
        setShadow()
    }
    
    /**
        Items open.
    */
    public func open() {
        closed = false
            UIView.animateWithDuration(0.7, delay: 0,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.3,
                options: [.CurveEaseInOut, .AllowUserInteraction], animations: { () -> Void in
                    self.buttonImageView.transform = CGAffineTransformMakeRotation(-self.degreesToRadians(self.rotationDegrees))
                    self.buttonImageView.alpha = 0
                    self.transform = CGAffineTransformMakeScale(0.75, 0.75);
    
                    self.plusLayer.opacity = 1
                    self.plusLayer.transform = CATransform3DMakeRotation(-self.degreesToRadians(self.rotationDegrees), 0.0, 0.0, 1.0)
                }, completion: nil)
    }
    
    /**
        Items close.
    */
    public func close() {
        closed = true
            UIView.animateWithDuration(0.7, delay: 0,
                usingSpringWithDamping: 0.4,
                initialSpringVelocity: 0.8,
                options: [.CurveEaseInOut, .AllowUserInteraction], animations: { () -> Void in
                    self.plusLayer.transform = CATransform3DMakeRotation(self.degreesToRadians(0), 0.0, 0.0, 1.0)
                    self.buttonImageView.transform = CGAffineTransformMakeRotation(self.degreesToRadians(0))
                    self.transform = CGAffineTransformMakeScale(1, 1);
                    self.buttonImageView.alpha = 1
                    self.plusLayer.opacity = 0
                }, completion:nil)
        
        fabDelegate?.KCFABClosed?(self)
        
    }
    
    /**
        Items open or close.
    */
    public func toggle() {
        if closed == true {
            open()
        } else {
            close()
        }
    }
    
    private func setCircleLayer() {
        circleLayer.removeFromSuperlayer()
        circleLayer.frame = CGRectMake(0, 0, size, size)
        circleLayer.backgroundColor = buttonColor.CGColor
        circleLayer.cornerRadius = size/2
        layer.addSublayer(circleLayer)
    }
    
    private func setPlusLayer() {
        plusLayer.removeFromSuperlayer()
        plusLayer.frame = CGRectMake(0, 0, size, size)
        plusLayer.lineCap = kCALineCapRound
        plusLayer.strokeColor = plusColor.CGColor
        plusLayer.lineWidth = 2.0
        plusLayer.path = plusBezierPath().CGPath
        layer.addSublayer(plusLayer)
    }
    
    private func setButtonImage() {
        buttonImageView.removeFromSuperview()
        buttonImageView = UIImageView(image: buttonImage)
		buttonImageView.tintColor = plusColor
        buttonImageView.frame = CGRectMake(
            size/2 - buttonImageView.frame.size.width/2,
            size/2 - buttonImageView.frame.size.height/2,
            buttonImageView.frame.size.width,
            buttonImageView.frame.size.height
        )
        addSubview(buttonImageView)
    }
    
    private func setTintLayer() {
        tintLayer.frame = CGRectMake(0, 0, size, size)
        tintLayer.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2).CGColor
        tintLayer.cornerRadius = size/2
        layer.addSublayer(tintLayer)
    }
	
    private func setShadow() {
        layer.shadowOffset = CGSizeMake(1, 1)
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.4
    }
    
    private func plusBezierPath() -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(CGPointMake(size/2, size/3))
        path.addLineToPoint(CGPointMake(size/2, size-size/3))
        path.moveToPoint(CGPointMake(size/3, size/2))
        path.addLineToPoint(CGPointMake(size-size/3, size/2))
        return path
    }
    
    private func itemDefaultSet(item: KCFloatingActionButtonItem) {
        item.buttonColor = itemButtonColor
		
		/// Use separate color (if specified) for item button image, or default to the plusColor
		item.iconImageView.tintColor = itemImageColor ?? plusColor
		
        item.circleShadowColor = itemShadowColor
        item.titleShadowColor = itemShadowColor
        item.size = itemSize
    }
    
    private func setRightBottomFrame(keyboardSize: CGFloat = 0) {
        var offset: CGFloat = isOffScreen ? 100.0 : 0
        var multiplier: CGFloat = closed ? 1.0 : 0.75
        if superview == nil {
            frame = CGRectMake(
                UIScreen.mainScreen().bounds.size.width-(size*multiplier)-(paddingX*(1.0/multiplier)),
                UIScreen.mainScreen().bounds.size.height-(size*multiplier)-(paddingY*(1.0/multiplier))+offset,
                (size*multiplier),
                (size*multiplier)
            )
        } else {
            frame = CGRectMake(
                superview!.bounds.size.width-(size*multiplier)-(paddingX*(1.0/multiplier)),
                superview!.bounds.size.height-(size*multiplier)-(paddingY*(1.0/multiplier))+offset,
                (size*multiplier),
                (size*multiplier)
            )
        }
    }
    
    private func setObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: UIDeviceOrientationDidChangeNotification, object: nil)

    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (object as? UIView) == superview && keyPath == "frame" {
            if isCustomFrame == false {
                setRightBottomFrame()
            } else {
                size = min(frame.size.width, frame.size.height)
            }
        }
    }
    
    public override func willMoveToSuperview(newSuperview: UIView?) {
        superview?.removeObserver(self, forKeyPath: "frame")
        super.willMoveToSuperview(newSuperview)
    }
    
    public override func didMoveToSuperview() {
        super.didMoveToSuperview()
        superview?.addObserver(self, forKeyPath: "frame", options: [], context: nil)
    }
    
    internal func deviceOrientationDidChange(notification: NSNotification) {
        var keyboardSize: CGFloat = 0.0
        if let size = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue.size {
            keyboardSize = size.height
        }
		
		/// Update overlay frame for new orientation dimensions
		
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad) {
            if isCustomFrame == false {
                setRightBottomFrame(keyboardSize)
            } else {
                size = min(frame.size.width, frame.size.height)
            }
        }
    }
}

/**
    Util functions
 */
extension KCFloatingActionButton {
    private func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees / 180.0 * CGFloat(M_PI)
    }
}
