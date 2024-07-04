//
//  Created by Daniel Inoa on 7/1/24.
//

import SwiftPlus

public struct FixedFrameLayout: Layout {

    private var layout: ZStackLayout

    public let width: Double?
    public let height: Double?
    public var alignment: Alignment {
        get { layout.alignment }
        set { layout.alignment = newValue }
    }

    public init(width: Double? = nil, height: Double? = nil, alignment: Alignment = .center) {
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
        let childWidthProposal = width ?? bounds.width
        let childHeightProposal = height ?? bounds.height
        let childPreferredSize = layout.size(
            fitting: items,
            within: .init(width: childWidthProposal, height: childHeightProposal)
        )
        return .init(
            width: width ?? childPreferredSize.width,
            height: height ?? childPreferredSize.height
        )
    }
    
    public func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle] {
        layout.frames(for: items, within: bounds)
    }
}
