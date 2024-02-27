//
//  Created by Daniel Inoa on 1/1/24.
//

public protocol LayoutItem {

    // TODO: Consider using LayoutPriority to prevent collision with another protocol also requiring a `priority: Int`.
    var priority: Int { get }

    /// The layout item's natural size, considering only properties of the item itself.
    var intrinsicSize: Size { get }

    func sizeThatFits(_ size: Size) -> Size
}

public extension LayoutItem {
    var priority: Int { .zero }
    var intrinsicSize: Size { .zero }
}
