//
//  Created by Daniel Inoa on 1/2/24.
//

public protocol Layout {

    /// The layout's minimum ideal size, considering its properties and the specified items.
    /// - note: This function should utilize the items' intrinsic or minimum size to calculate the resulting size.
    func minimumSize(for items: [any LayoutItem]) -> Size

    /// Returns the size needed to fit the layout-items within the proposed size.
    /// - note: This function queries items' best fitting size, through `sizeThatFits(_:)`,
    ///         to calculate the resulting size.
    /// - note: The resulting size can be larger than the proposed size when the items can not be accomodated within the
    ///         proposed size. Prevent clamping as to respect the items' ideal size.
    func sizeThatFits(items: [any LayoutItem], within: Size) -> Size

    /// Returns the position and size for each layout-item within the specified bounds, considering their priority
    /// and the available space within the given bounds.
    /// - note: Items with higher priority will be granted as much size as they require.
    /// - note: When multiple items have the same priority, those requiring less space are given precedence.
    func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle]
}
