//
// Copyright 2018-2020 Amazon.com,
// Inc. or its affiliates. All Rights Reserved.
//
// SPDX-License-Identifier: Apache-2.0
//

import XCTest
import Amplify
@testable import AmplifyTestCommon

class ModelRegistryTests: XCTestCase {

    let postJSON =
    #"{"id":"1","title":"title","content":"content","comments":[],"createdAt":"2019-12-31T01:23:45.678Z"}"#

    func testCanRegisterConcreteType() {
        ModelRegistry.register(modelType: Post.self)
        ModelRegistry.register(modelType: Comment.self)

        XCTAssertNotNil(ModelRegistry.modelType(from: "Post"))
    }

    func testCanRegisterProtocolType() {
        let types: [Model.Type] = [Post.self, Comment.self]

        types.forEach { ModelRegistry.register(modelType: $0) }

        XCTAssertNotNil(ModelRegistry.modelType(from: "Post"))
        XCTAssertNotNil(ModelRegistry.modelType(from: "Comment"))
    }

    func testDecode() throws {
        ModelRegistry.register(modelType: Post.self)
        ModelRegistry.register(modelType: Comment.self)

        guard let decodedPost = try ModelRegistry.decode(modelName: "Post", from: postJSON) as? Post else {
            XCTFail("Couldn't decode post")
            return
        }

        XCTAssertEqual(decodedPost.id, "1")
        XCTAssertEqual(decodedPost.title, "title")
        XCTAssertEqual(decodedPost.content, "content")

        let actualMilliseconds = Int(decodedPost.createdAt.timeIntervalSince1970 * 1_000)
        XCTAssertEqual(actualMilliseconds, 1_577_755_425_678)
    }

    func testDecodeIntoModel() throws {
        ModelRegistry.register(modelType: Post.self)
        ModelRegistry.register(modelType: Comment.self)

        let decodedPost = try ModelRegistry.decode(modelName: "Post", from: postJSON)

        XCTAssertEqual(decodedPost.id, "1")
        XCTAssertEqual(decodedPost["title"] as? String, "title")
        XCTAssertEqual(decodedPost["content"] as? String, "content")

        guard let createdAt = decodedPost["createdAt"] as? Date else {
            XCTFail("Could not decode createdAt from post")
            return
        }

        let actualMilliseconds = Int(createdAt.timeIntervalSince1970 * 1_000)
        XCTAssertEqual(actualMilliseconds, 1_577_755_425_678)
    }

}
