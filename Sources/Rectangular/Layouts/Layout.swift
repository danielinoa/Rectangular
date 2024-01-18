//
//  Created by Daniel Inoa on 1/2/24.
//

public protocol Layout {

    /// Returns the minimum size needed to fit the layout-items.
    /// - note: This function utilizes the items' intrinsic size to calculate the resulting size.
    func sizeThatFits(items: [any LayoutItem]) -> Size

    /// Returns the size needed to fit the layout-items within the specified size.
    /// - note: This function queries items' best fitting size, through `sizeThatFits(_:)`,
    ///         to calculate the resulting size.
    /// - note: The resulting size typically becomes the proposed size when there are items that use as much space as
    ///         is proposed to them.
    func sizeThatFits(items: [any LayoutItem], within: Size) -> Size

    /// Returns the position and size for each layout-item within the specified bounds, considering their priority
    /// and the available space within the given bounds.
    /// - note: Items with higher priority will be granted as much size as they require.
    /// - note: When multiple items have the same priority, those requiring less space are given precedence.
    func frames(for items: [any LayoutItem], within bounds: Rectangle) -> [Rectangle]
}
