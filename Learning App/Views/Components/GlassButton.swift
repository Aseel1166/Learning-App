import SwiftUI

extension View {
    /// Liquid Glass button style: lit with `tint` while active, plain glass otherwise.
    @ViewBuilder
    func glassActionButton(isLit: Bool, tint: Color) -> some View {
        if isLit {
            buttonStyle(.glassProminent).tint(tint)
        } else {
            buttonStyle(.glass)
        }
    }
}
