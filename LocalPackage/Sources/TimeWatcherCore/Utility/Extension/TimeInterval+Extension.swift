import Foundation

extension TimeInterval {

    public var hour: Int {

        return abs(Int(self / 3600))
    }

    public var minute: Int {

        return Int(self / 60) % 60
    }

    public var seconds: Int {

        return Int(self) % 60
    }

    public var milliSec: Int {

        let timeLapse = self * 1000
        let roundTimeLapse = timeLapse.rounded()
        return Int(roundTimeLapse) % 1000
    }

    /// HH:mm:ss.SSS形式の経過時間の文字列を返す
    public var timeLapseFullString: String {

        guard AppConstants.maxDisplayTimeLapse > self else {

            return AppConstants.maxDisplayTimeString
        }

        return String(format: "%02d:%02d:%02d.%03d", self.hour, self.minute, self.seconds, self.milliSec)
    }

    /// HH:mm:ss形式の経過時間文字列を返す
    public var timeLapseShortString: String {

        guard AppConstants.maxDisplayTimeLapse > self else {

            return AppConstants.maxDisplayShortTimeString
        }

        return String(format: "%02d:%02d:%02d", self.hour, self.minute, self.seconds)
    }
}
