//
//  RAVConcurrentContainersFirstWhereTest.swift
//  RAVConcurrentContainersTests
//
//  Created by Andrew Romanov on 25.10.2020.
//  Copyright © 2020 Andrew Romanov. All rights reserved.
//

import XCTest
@testable import RAVConcurrentContainers


struct ModelWithKey: Equatable {
    let key: Double
    let data: String
}


class RAVConcurrentContainersFirstWhereTest: XCTestCase {

    func testArray() throws {
        let testArray = [ModelWithKey(key: 1.0, data: "0"),
                        ModelWithKey(key: 0.0, data: "1"),
                         ModelWithKey(key: 0.0, data: "2"),
                         ModelWithKey(key: 0.0, data: "3"),
                         ModelWithKey(key: 0.0, data: "4"),
                         ModelWithKey(key: 0.0, data: "5"),
                         ModelWithKey(key: 0.0, data: "6")];
        for _ in 0...100 {
            let modelNonConcurrent = testArray.first { (model:ModelWithKey) -> Bool in
                return model.key == 0.0;
            }
            let modelConcurrent = testArray.concurrent.first { (model:ModelWithKey) -> Bool in
                return model.key == 0.0;
            }
            XCTAssertEqual(modelConcurrent, modelNonConcurrent)
        }
    }

}
