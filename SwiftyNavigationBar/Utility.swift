//
//  Const.swift
//  SwiftyNavigationBar
//
//  Created by meyoutao-3 on 2018/3/19.
//  Copyright © 2018年 meyoutao-3. All rights reserved.
//

public struct SNAssociatedKeys {
    public static var shadowColor: UIColor?

    public static var alpha: CGFloat = 1.0
    public static var shadowAlpha: CGFloat = 1.0
    public static var tintColor: UIColor = UIColor.sn.tintColor
    public static var barTintColor: UIColor = UIColor.sn.barTintColor
    public static var backgroundColor: UIColor = UIColor.sn.backgroundColor
}

public extension UIColor {
    public struct sn {
        public static var tintColor: UIColor {
            return UIColor(red: 0, green: 0.478431, blue: 1, alpha: 1.0)
        }

        public static var barTintColor: UIColor {
            return UIColor.white.withAlphaComponent(0.96)
        }

        public static var backgroundColor: UIColor {
            return UIColor.clear
        }

        static func hex(_ hexString: String, transparency: CGFloat = 1) -> UIColor? {
            var string = ""
            if hexString.lowercased().hasPrefix("0x") {
                string =  hexString.replacingOccurrences(of: "0x", with: "")
            } else if hexString.hasPrefix("#") {
                string = hexString.replacingOccurrences(of: "#", with: "")
            } else {
                string = hexString
            }

            if string.count == 3 { // convert hex to 6 digit format if in short format
                var str = ""
                string.forEach { str.append(String(repeating: String($0), count: 2)) }
                string = str
            }

            guard let hexValue = Int(string, radix: 16) else { return nil }

            var trans = transparency
            if trans < 0 { trans = 0 }
            if trans > 1 { trans = 1 }

            let red = (hexValue >> 16) & 0xff
            let green = (hexValue >> 8) & 0xff
            let blue = hexValue & 0xff

            guard red >= 0 && red <= 255 else { return nil }
            guard green >= 0 && green <= 255 else { return nil }
            guard blue >= 0 && blue <= 255 else { return nil }

            return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: trans)
        }
    }
}

extension UIImage {
    class func image(with color: UIColor) -> UIImage? {
        return image(with: color, size: CGSize(width: 1, height: 1))
    }

    class func image(with color: UIColor, size: CGSize) -> UIImage? {
        let rect = CGRect(origin: CGPoint.zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, UIScreen.main.scale);
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor);
        context.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return img
    }
}

extension UIViewAnimationCurve {

    var options: UIViewAnimationOptions {
        switch self {
        case .easeInOut:
            return .curveEaseInOut
        case .easeIn:
            return .curveEaseIn
        case .easeOut:
            return .curveEaseOut
        case .linear:
            return .curveLinear
        }
    }
}
