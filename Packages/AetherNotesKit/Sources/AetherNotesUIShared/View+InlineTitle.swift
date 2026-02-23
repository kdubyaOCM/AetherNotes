import SwiftUI

extension View {
    /// Applies `.navigationBarTitleDisplayMode(.inline)` on platforms that
    /// support it (iOS / iPadOS via UIKit) and returns `self` unchanged on
    /// macOS and watchOS.
    @ViewBuilder
    public func aetherInlineTitleIfSupported() -> some View {
        #if canImport(UIKit)
        self.navigationBarTitleDisplayMode(.inline)
        #else
        self
        #endif
    }
}
