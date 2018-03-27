//
//  UIViewController+SN.swift
//  SwiftyNavigationBar
//
//  Created by meyoutao-3 on 2018/3/19.
//  Copyright © 2018年 meyoutao-3. All rights reserved.
//

extension UIViewController: SwiftyNavBarCompatible { }
extension SwiftyNavigationBar where Base: UIViewController {

    open var navHeight: CGFloat {
        if let bar = base.navigationController?.navigationBar {
            return bar.frame.maxY
        }
        return UIScreen.main.bounds.height > 810 ? 88 : 64
    }

    open var alpha: CGFloat {
        get {
            guard let _alpha = objc_getAssociatedObject(base, &SNAssociatedKeys.alpha) as? CGFloat else {
                return SNAssociatedKeys.alpha
            }
            return _alpha
        }
        set {
            let _alpha = max(min(newValue, 1), 0) // 必须在 0~1的范围
            objc_setAssociatedObject(base, &SNAssociatedKeys.alpha, _alpha, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

            // Update UI
            base.navigationController?.setNeedsUpdateBar(alpha: _alpha)
        }
    }

    open var tintColor: UIColor {
        get {
            guard let color = objc_getAssociatedObject(base, &SNAssociatedKeys.tintColor) as? UIColor else {
                return UIColor.sn.tintColor
            }
            return color
        }
        set {
            base.navigationController?.navigationBar.tintColor = newValue
            objc_setAssociatedObject(base, &SNAssociatedKeys.tintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    open var barTintColor: UIColor? {
        get {
            guard let color = objc_getAssociatedObject(base, &SNAssociatedKeys.barTintColor) as? UIColor else {
                return nil
            }
            return color
        }
        set {
            base.navigationController?.navigationBar.barTintColor = newValue
            objc_setAssociatedObject(base, &SNAssociatedKeys.barTintColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    open var shadowColor: UIColor? {
        get {
            guard let color = objc_getAssociatedObject(base, &SNAssociatedKeys.shadowColor) as? UIColor else {
                return nil
            }
            return color
        }
        set {
            base.navigationController?.setNeedsUpdateBar(shadowColor: newValue)
            objc_setAssociatedObject(base, &SNAssociatedKeys.shadowColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    open var shadowAlpha: CGFloat {
        get {
            guard let color = objc_getAssociatedObject(base, &SNAssociatedKeys.shadowAlpha) as? CGFloat else {
                return SNAssociatedKeys.shadowAlpha
            }
            return color
        }
        set {
            base.navigationController?.setNeedsUpdateBar(shadowAlpha: newValue)
            objc_setAssociatedObject(base, &SNAssociatedKeys.shadowAlpha, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    open var backgroundColor: UIColor? {
        get {
            guard let color = objc_getAssociatedObject(base, &SNAssociatedKeys.backgroundColor) as? UIColor else {
                return nil
            }
            return color
        }
        set {
            let _ = base.navigationController?.setNeedsUpdateBar(backgroundColor: newValue)
            objc_setAssociatedObject(base, &SNAssociatedKeys.backgroundColor, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
