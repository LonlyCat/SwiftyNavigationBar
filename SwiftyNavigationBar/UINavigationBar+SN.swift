//
//  UINavigationBar+SN.swift
//  SwiftyNavigationBar
//
//  Created by meyoutao-3 on 2018/3/21.
//  Copyright © 2018年 meyoutao-3. All rights reserved.
//

private var colorViewKey: UIView?
private var shadowViewKey: UIView?

extension UINavigationBar: SwiftyNavBarCompatible {}
extension SwiftyNavigationBar where Base: UINavigationBar {
    open var colorView: UIView? {
        get {
            guard let view = objc_getAssociatedObject(base, &colorViewKey) as? UIView else {
                let background = base.subviews[0]
                let new = UIView()
                new.frame = CGRect(origin: CGPoint.zero, size: background.bounds.size)
                new.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                background.insertSubview(new, at: 0)
                base.layoutIfNeeded()
                objc_setAssociatedObject(base, &colorViewKey, new, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return new
            }
            return view
        }
        set {
            if newValue == nil {
                colorView?.removeFromSuperview()
            }
            objc_setAssociatedObject(base, &colorViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    open var shadowView: UIView? {
        get {
            guard let view = objc_getAssociatedObject(base, &shadowViewKey) as? UIView else {
                let background = base.subviews[0]
                let new = UIView()
                new.frame = CGRect(origin: CGPoint(x: 0, y: background.bounds.height),
                                   size: CGSize(width: background.bounds.width, height: 1/UIScreen.main.scale))
                new.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleBottomMargin]
                background.addSubview(new)
                base.layoutIfNeeded()
                objc_setAssociatedObject(base, &shadowViewKey, new, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return new
            }
            return view
        }
        set {
            if newValue == nil {
                shadowView?.removeFromSuperview()
            }
            objc_setAssociatedObject(base, &shadowViewKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
