import Foundation

/// WidgetURLで使用するURLのKey
public enum WidgetUrlKey: CaseIterable {

    /// タイマーリセットのリンク
    case timerResetLink
    /// その他デフォルトのリンク
    case defaultLink
}

extension WidgetUrlKey {

    private static let scheme = "https://"

    private static var defaultURL: URL {

        return URL(string: "\(scheme)\(AppConstants.mainBundleId)")!
    }

    /// Keyに紐づくWidgetURL
    public var url: URL {

        return URL(string: "\(Self.scheme)\(AppConstants.mainBundleId)\(self.path)") ?? Self.defaultURL
    }

    public var path: String {

        switch self {

        case .timerResetLink:
            return "/reset"

        case .defaultLink:
            return ""
        }
    }
}
