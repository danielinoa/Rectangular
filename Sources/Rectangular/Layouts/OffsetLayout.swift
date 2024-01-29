//
//  Created by Daniel Inoa on 1/29/24.
//

// TODO: Add tests

public struct OffsetLayout: Layout {

    public var x, y: Double

    private let layout: ZStackLayout = .init()

    public func sizeThatFits(items: [Rectangular.LayoutItem]) -> Rectangular.Size {
        layout.sizeThatFits(items: items)
    }

    public func sizeThatFits(items: [Rectangular.LayoutItem], within: Rectangular.Size) -> Rectangular.Size {
        layout.sizeThatFits(items: items, within: within)
    }

    public func frames(for items: [Rectangular.LayoutItem], within bounds: Rectangular.Rectangle) -> [Rectangular.Rectangle] {
        layout
            .frames(for: items, within: bounds)
            .map { rect in
                var rect = rect
                rect.topY += y
                rect.leadingX += x
                return rect
            }
    }
}
