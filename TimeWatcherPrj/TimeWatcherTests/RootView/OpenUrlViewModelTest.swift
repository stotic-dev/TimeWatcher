//
//  OpenUrlViewModelTest.swift
//  TimeWatcherTests
//
//  Created by 佐藤汰一 on 2024/09/18.
//

import XCTest
@testable import TimeWatcher

final class OpenUrlViewModelTest: XCTestCase {

    /// WidgetUrlでアプリが開かれた時のケース
    ///
    /// # 確認ポイント
    /// - WidgetURLをViewModelで設定したときに、WidgetURLのプロパティが想定通り更新されること
    @MainActor
    func testWidgetUrlOpen() throws {
        
        let testViewModel = OpenUrlViewModel()
        
        for widgetUrl in WidgetUrlKey.allCases {
            
            // リセットのURLでオープン
            testViewModel.setUrl(widgetUrl.url)
            
            // URL確認
            checkWidgetUrl(testViewModel, expected: widgetUrl)
        }
    }
    
    /// 想定外のURLでアプリが開かれた時のケース
    ///
    /// # 確認ポイント
    /// - 想定外のURLをViewModelで設定したときに、WidgetURLのプロパティが想定通り更新されないこと
    @MainActor
    func testOtherUrlOpen() throws {
        
        let testViewModel = OpenUrlViewModel()
        
        // リセットのURLでオープン
        testViewModel.setUrl(URL(string: "https://demmy.com")!)
        
        // WidgetURLが更新されないことを確認
        checkNoUpdateWidgetUrl(testViewModel)
    }
}

@MainActor
private extension OpenUrlViewModelTest {
    
    func checkWidgetUrl(_ viewModel: OpenUrlViewModel, expected: WidgetUrlKey?) {
        
        let expectation = XCTestExpectation(description: "testWidgetUrlOpen")
        expectation.expectedFulfillmentCount = 1
        
        let widgetUrlCancellable = viewModel.$widgetUrlKey.sink { urlKey in
            
            if urlKey == expected {
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
        
        widgetUrlCancellable.cancel()
    }
    
    func checkNoUpdateWidgetUrl(_ viewModel: OpenUrlViewModel) {
        
        let expectation = XCTestExpectation(description: "checkNoUpdateWidgetUrl")
        expectation.isInverted = true
        
        let widgetUrlCancellable = viewModel.$widgetUrlKey.sink { urlKey in
            
            if urlKey != nil {
                
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1)
        
        widgetUrlCancellable.cancel()
    }
}
