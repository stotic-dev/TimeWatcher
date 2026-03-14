import Foundation
import TimeWatcherCore

@MainActor
public class OpenUrlViewModel: ObservableObject {

    /// LiveActivityから開かれた際のURL
    @Published public var widgetUrlKey: WidgetUrlKey?

    public init() {}

    /// 開かれたURLの設定
    public func setUrl(_ url: URL) {

        guard let widgetURL = WidgetUrlKey.allCases.first(where: { $0.url == url }) else {

            logger.debug("Not found widget url: \(url).")
            return
        }

        logger.info("Did open widget url: \(widgetURL).")
        widgetUrlKey = widgetURL
    }
}
