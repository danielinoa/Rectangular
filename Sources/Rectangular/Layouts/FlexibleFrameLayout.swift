//
//  Created by Daniel Inoa on 7/1/24.
//

import SwiftPlus

public struct FlexibleFrameLayout: Layout {

    // TODO: Add idealWidth and idealHeight along with SizeProposal enum (value, .zero, .unspecified, and .infinity)

    private var layout: ZStackLayout
    public var alignment: Alignment {
        get { layout.alignment }
        set { layout.alignment = newValue }
    }

    let minimumWidth: Double?
    let maximumWidth: Double?
    let minimumHeight: Double?
    let maximumHeight: Double?

    public init(
        minimumWidth: Double? = nil,
        maximumWidth: Double? = nil,
        minimumHeight: Double? = nil,
        maximumHeight: Double? = nil,
        alignment: Alignment = .center
    ) {
        self.minimumWidth = minimumWidth
        self.maximumWidth = maximumWidth
        self.minimumHeight = minimumHeight
        self.maximumHeight = maximumHeight
        self.layout = .init(alignment: alignment)
    }

    public func naturalSize(for items: [any LayoutItem]) -> Size {
        let fallbackSize = layout.naturalSize(for: items)
        let width: Double = 
            if let minimumWidth, let maximumWidth {
                max(minimumWidth, maximumWidth)
            } else if let minimumWidth {
                minimumWidth
            } else if let maximumWidth {
                maximumWidth
            } else {
                fallbackSize.width
            }
        let height: Double =
            if let minimumHeight, let maximumHeight {
                max(minimumHeight, maximumHeight)
            } else if let minimumHeight {
                minimumHeight
            } else if let maximumHeight {
                maximumHeight
            } else {
                fallbackSize.height
            }
        return .init(width: width, height: height)
    }

    public func size(fitting items: [any LayoutItem], within bounds: Size) -> Size {
        let naturalSize = naturalSize(for: items)
        return .init(
            width: naturalSize.width.clamped(within: (.zero)...bounds.width),
            height: naturalSize.height.clamped(within: (.zero)...bounds.height)
        )
    }
    
    public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
        layout.frames(for: items, within: bounds)
    }
}
