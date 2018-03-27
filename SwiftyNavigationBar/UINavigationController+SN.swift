//
//  UINavigationController+SN.swift
//  SwiftyNavigationBar
//
//  Created by meyoutao-3 on 2018/3/19.
//  Copyright © 2018年 meyoutao-3. All rights reserved.
//

extension DispatchQueue {

    private static var onceTracker = [String]()

    public class func once(token: String, block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }

        if onceTracker.contains(token) {
            return
        }

        onceTracker.append(token)
        block()
    }
}

// MARK: - Swizzle
extension UINavigationController {

    private static let onceToken = UUID().uuidString

    open override func viewDidLoad() {
        UINavigationController.swizzle()
        super.viewDidLoad()
    }

    class func swizzle() {
        guard self == UINavigationController.self else { return }

        DispatchQueue.once(token: onceToken) {
            let needSwizzleSelectorArr = [
                NSSelectorFromString("_updateInteractiveTransition:"),
                #selector(pushViewController),
                #selector(popToViewController),
                #selector(popToRootViewController)
            ]

            for selector in needSwizzleSelectorArr {

                let str = ("sn_" + selector.description).replacingOccurrences(of: "__", with: "_")
                // popToRootViewControllerAnimated: sn_popToRootViewControllerAnimated:

                let originalMethod = class_getInstanceMethod(self, selector)
                let swizzledMethod = class_getInstanceMethod(self, Selector(str))
                if originalMethod != nil && swizzledMethod != nil {
                    method_exchangeImplementations(originalMethod!, swizzledMethod!)
                }
            }
        }
    }

    @objc func sn_updateInteractiveTransition(_ percentComplete: CGFloat) {
        guard let topViewController = topViewController, let coordinator = topViewController.transitionCoordinator else {
            sn_updateInteractiveTransition(percentComplete)
            return
        }

        let fromViewController = coordinator.viewController(forKey: .from)
        let toViewController = coordinator.viewController(forKey: .to)

        // Bg Alpha
        let fromAlpha = fromViewController?.sn.alpha ?? 0
        let toAlpha = toViewController?.sn.alpha ?? 0
        let newAlpha = fromAlpha + (toAlpha - fromAlpha) * percentComplete
        setNeedsUpdateBar(alpha: newAlpha)

        // Shadow Alpha
        let fromShadowAlpha = min(fromAlpha, fromViewController?.sn.shadowAlpha ?? 0)
        let toShadowAlpha = min(toAlpha, toViewController?.sn.shadowAlpha ?? 0)
        let newShadowAlpha = fromShadowAlpha + (toShadowAlpha - fromShadowAlpha) * percentComplete
        self.setNeedsUpdateBar(shadowAlpha: newShadowAlpha)

        // Shadow Color
        let fromShadowColor = fromViewController?.sn.shadowColor ?? UIColor.white
        let toShadowColor = toViewController?.sn.shadowColor ?? UIColor.white
        let newShadowColor = averageColor(fromColor: fromShadowColor, toColor: toShadowColor, percent: percentComplete)
        self.setNeedsUpdateBar(shadowColor: newShadowColor)

        // Tint Color
        let fromTinitColor = fromViewController?.sn.tintColor ?? SNAssociatedKeys.tintColor
        let toTintColor = toViewController?.sn.tintColor ?? SNAssociatedKeys.tintColor
        let newTintColor = averageColor(fromColor: fromTinitColor, toColor: toTintColor, percent: percentComplete)
        navigationBar.tintColor = newTintColor

        // Bar Tint Color
        let fromBarTintColor = fromViewController?.sn.barTintColor ?? SNAssociatedKeys.barTintColor
        let toBarTintColor = toViewController?.sn.barTintColor ?? SNAssociatedKeys.barTintColor
        let newBarTintColor = averageColor(fromColor: fromBarTintColor, toColor: toBarTintColor, percent: percentComplete)
        navigationBar.barTintColor = newBarTintColor

        // Background Color
        let fromBGColor = fromViewController?.sn.backgroundColor
        let toBGColor = toViewController?.sn.backgroundColor
        if fromBGColor != nil || toBGColor != nil {
            let newColor = averageColor(fromColor: fromBGColor ?? UIColor.sn.barTintColor,
                                        toColor: toBGColor ?? UIColor.sn.barTintColor,
                                        percent: percentComplete)
            let _ = setNeedsUpdateBar(backgroundColor: newColor)
        }

        sn_updateInteractiveTransition(percentComplete)
    }

    // Calculate the middle Color with translation percent
    private func averageColor(fromColor: UIColor, toColor: UIColor, percent: CGFloat) -> UIColor {
        var fromRed: CGFloat = 0
        var fromGreen: CGFloat = 0
        var fromBlue: CGFloat = 0
        var fromAlpha: CGFloat = 0
        fromColor.getRed(&fromRed, green: &fromGreen, blue: &fromBlue, alpha: &fromAlpha)

        var toRed: CGFloat = 0
        var toGreen: CGFloat = 0
        var toBlue: CGFloat = 0
        var toAlpha: CGFloat = 0
        toColor.getRed(&toRed, green: &toGreen, blue: &toBlue, alpha: &toAlpha)

        let nowRed = fromRed + (toRed - fromRed) * percent
        let nowGreen = fromGreen + (toGreen - fromGreen) * percent
        let nowBlue = fromBlue + (toBlue - fromBlue) * percent
        let nowAlpha = fromAlpha + (toAlpha - fromAlpha) * percent

        return UIColor(red: nowRed, green: nowGreen, blue: nowBlue, alpha: nowAlpha)
    }

    @objc func sn_popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        setNeedsUpdateBar(with: viewController, duration: 0.25)
        return sn_popToViewController(viewController, animated: animated)
    }

    @objc func sn_popToRootViewControllerAnimated(_ animated: Bool) -> [UIViewController]? {
        setNeedsUpdateBar(with: viewControllers.first, duration: 0.25)
        return sn_popToRootViewControllerAnimated(animated)
    }

    @objc func sn_pushViewController(_ viewController: UIViewController, animated: Bool) {
        setNeedsUpdateBar(with: viewController, duration: 0.25)

        sn_pushViewController(viewController, animated: animated)
    }

    func setNeedsUpdateBar(alpha: CGFloat,
                           duration: TimeInterval = 0,
                           animatorCurve: UIViewAnimationCurve = .linear) {
        let barBackgroundView = navigationBar.subviews[0]
        let valueForKey = barBackgroundView.value(forKey:)

        UIView.animate(withDuration: duration, delay: 0, options: animatorCurve.options, animations: {

            if self.navigationBar.isTranslucent {
                if #available(iOS 10.0, *) {
                    if let backgroundEffectView = valueForKey("_backgroundEffectView") as? UIView, self.navigationBar.backgroundImage(for: .default) == nil {
                        backgroundEffectView.alpha = alpha
                        return
                    }

                } else {
                    if let adaptiveBackdrop = valueForKey("_adaptiveBackdrop") as? UIView , let backdropEffectView = adaptiveBackdrop.value(forKey: "_backdropEffectView") as? UIView {
                        backdropEffectView.alpha = alpha
                        return
                    }
                }
            }

            barBackgroundView.alpha = alpha

        }, completion: nil)
    }

    func setNeedsUpdateBar(with viewController: UIViewController?,
                           duration: TimeInterval = 0,
                           animatorCurve: UIViewAnimationCurve = .linear) {

        self.navigationBar.barTintColor = viewController?.sn.barTintColor
        UIView.animate(withDuration: duration, delay: 0, options: animatorCurve.options, animations: {
            self.navigationBar.tintColor = viewController?.sn.tintColor ?? SNAssociatedKeys.tintColor
        }, completion: nil)

        // back ground alpha
        let changeBackground = setNeedsUpdateBar(backgroundColor: viewController?.sn.backgroundColor,
                                                 duration: duration,
                                                 animatorCurve: animatorCurve)
        let alpha = changeBackground ? 0 : (viewController?.sn.alpha ?? SNAssociatedKeys.alpha)
        setNeedsUpdateBar(alpha: alpha,
                          duration: duration,
                          animatorCurve: animatorCurve)

        // shadow alpha
        let shadowAlpha = min(viewController?.sn.alpha ?? 0.0, viewController?.sn.shadowAlpha ?? 0.0)
        setNeedsUpdateBar(shadowAlpha: shadowAlpha)

        // shadow color
        setNeedsUpdateBar(shadowColor: viewController?.sn.shadowColor)
    }

    func setNeedsUpdateBar(shadowColor: UIColor?) {
        if let color = shadowColor,
            let img = UIImage.image(with: color, size: CGSize(width: 1, height: 1/UIScreen.main.scale)) {

            if #available(iOS 11, *) {
                navigationBar.shadowImage = img
            }
            else {
                setNeedsUpdateBar(shadowAlpha: 0)
                navigationBar.sn.shadowView?.backgroundColor = color
            }
        }
        else {
            if #available(iOS 11, *) {
                navigationBar.shadowImage = nil
            }
            else {
                navigationBar.sn.shadowView = nil
            }
        }
    }

    func setNeedsUpdateBar(shadowAlpha: CGFloat) {
        let barBackgroundView = navigationBar.subviews[0]
        let valueForKey = barBackgroundView.value(forKey:)
        if let shadowView = valueForKey("_shadowView") as? UIView {
            shadowView.alpha = shadowAlpha
            shadowView.isHidden = shadowAlpha == 0
        }
    }

    /// 改变 color view 颜色
    ///
    /// - Parameters:
    ///   - backgroundColor: 目标值
    ///   - duration: 动画时长
    ///   - animatorCurve: 动画类型
    /// - Returns: 是否改变
    func setNeedsUpdateBar(backgroundColor: UIColor?,
                           duration: TimeInterval = 0,
                           animatorCurve: UIViewAnimationCurve = .linear) -> Bool {
        if let color = backgroundColor {
            navigationBar.sn.colorView?.backgroundColor = SNAssociatedKeys.backgroundColor
            UIView.animate(withDuration: duration, delay: 0, options: animatorCurve.options, animations: {
                self.navigationBar.sn.colorView?.backgroundColor = color
            }, completion: nil)
            return true
        }
        else {
            UIView.animate(withDuration: duration, delay: 0, options: animatorCurve.options, animations: {
                self.navigationBar.sn.colorView?.backgroundColor = SNAssociatedKeys.backgroundColor
            }, completion: { finish in
                self.navigationBar.sn.colorView = nil
            })
            return false
        }
    }
}

extension UINavigationController: UINavigationBarDelegate {

    public func navigationBar(_ navigationBar: UINavigationBar, shouldPop item: UINavigationItem) -> Bool {
        if let topVC = topViewController, let coor = topVC.transitionCoordinator, coor.initiallyInteractive {
            if #available(iOS 10.0, *) {
                coor.notifyWhenInteractionChanges({ (context) in
                    self.dealInteractionChanges(context)
                })
            } else {
                coor.notifyWhenInteractionEnds({ (context) in
                    self.dealInteractionChanges(context)
                })
            }
            return true
        }

        let itemCount = navigationBar.items?.count ?? 0
        let n = viewControllers.count >= itemCount ? 2 : 1
        let popToVC = viewControllers[viewControllers.count - n]

        popToViewController(popToVC, animated: true)
        return true
    }

    private func dealInteractionChanges(_ context: UIViewControllerTransitionCoordinatorContext) {
        typealias Animations = (UITransitionContextViewControllerKey, TimeInterval, UIViewAnimationCurve) -> ()
        let animations: Animations = { (key, duration, curve) in
            let viewController = context.viewController(forKey: key)
            self.setNeedsUpdateBar(with: viewController, duration: duration, animatorCurve: curve)
        }

        if context.isCancelled {
            let cancelDuration: TimeInterval = context.transitionDuration * Double(context.percentComplete)
            animations(.from, cancelDuration, context.completionCurve)
        } else {
            let finishDuration: TimeInterval = context.transitionDuration * Double(1 - context.percentComplete)
            animations(.to, finishDuration, context.completionCurve)
        }
    }
}


