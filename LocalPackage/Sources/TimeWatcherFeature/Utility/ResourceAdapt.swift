import TimeWatcherExternalResouce
import SwiftUI

public typealias CustomColor = Asset.Color
public typealias CustomImage = Asset.Image

extension Color {

    public init(_ custom: ColorAsset) {

        self.init(asset: custom)
    }
}

extension Image {

    public init(_ custom: ImageAsset) {

        self.init(asset: custom)
    }
}
