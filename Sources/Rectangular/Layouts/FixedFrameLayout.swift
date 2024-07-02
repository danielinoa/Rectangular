//
//  Created by Daniel Inoa on 7/1/24.
//

import SwiftPlus

public struct FixedFrameLayout: Layout {

    private let layout: ZStackLayout

    let width: Double?
    let height: Double?

    public init(
        width: Double? = nil,
        height: Double? = nil,
        alignment: Alignment = .center
    ) {
        self.width = width
        self.height = height
        self.layout = .init(alignment: alignment)
    }

    public func naturalSize(for items: [any LayoutItem]) -> Size {
        let fallbackSize = layout.naturalSize(for: items)
        let width: Double = width ?? fallbackSize.width
        let height: Double = height ?? fallbackSize.height
        return .init(width: width, height: height)
    }

    public func size(fitting items: [any LayoutItem], within bounds: Size) -> Size {
        naturalSize(for: items)
    }
    
    public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
        layout.frames(for: items, within: bounds)
    }
}
