//
//  SwiftyNavigationBar.swift
//  SwiftyNavigationBar
//
//  Created by meyoutao-3 on 2018/3/19.
//  Copyright © 2018年 meyoutao-3. All rights reserved.
//

public final class SwiftyNavigationBar<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

/**
 A type that has Kingfisher extensions.
 */
public protocol SwiftyNavBarCompatible {
    associatedtype CompatibleType
    var sn: CompatibleType { get }
}

public extension SwiftyNavBarCompatible {
    public var sn: SwiftyNavigationBar<Self> {
        get { return SwiftyNavigationBar(self) }
    }
}

