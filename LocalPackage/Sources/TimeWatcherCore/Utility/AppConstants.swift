import Foundation

public struct AppConstants {

    // MARK: - アプリ共通

    public static let mainBundleId = "taichi.satou.TimeWatcher"

    // MARK: - ウォッチ関連のプロパティ

    // 最大表示時間
    public static let maxDisplayTimeString = "99:59:59.999"
    // 最大表示時間
    public static let maxDisplayShortTimeString = "99:59:59"
    // 表示最大可能経過時間
    public static var maxDisplayTime = 100
    // 表示最大可能経過時間
    public static var maxDisplayTimeLapse: TimeInterval = 360000
}
