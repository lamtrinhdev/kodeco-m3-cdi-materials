/// Copyright (c) 2024 Kodeco Inc.
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import OSLog

enum NewsServiceError: Error {
  case networkError
  case serverResponseError
  case resultParsingError
}

protocol NewsService {
  func latestNews() async throws -> [Article]
}

class NewsAPIService: NewsService {
  struct Response: Codable {
    let status: String
    let totalResults: Int
    let articles: [Article]
  }

  static let apiKey = "<ADD_YOUR_KEY_HERE>"
  static let newsURL = URL(string: "https://newsapi.org/v2/everything?q=apple&apiKey=\(apiKey)")!

  func latestNews() async throws -> [Article] {
    let (data, response) = try await URLSession.shared.data(from: Self.newsURL)

    guard let httpResponse = response as? HTTPURLResponse, httpResponse.isOK else {
      Logger.main.error("Network response error")
      throw NewsServiceError.serverResponseError
    }

    let apiResponse = try JSONDecoder().decode(Response.self, from: data)
    Logger.main.info("Response status: \(apiResponse.status)")
    Logger.main.info("Total results: \(apiResponse.totalResults)")

    return apiResponse.articles.filter { $0.author != nil && $0.urlToImage != nil }
  }
}

class MockNewsService: NewsService {
  func latestNews() async throws -> [Article] {
    return [
      Article(
        title: "Lorem Ipsum",
        url: URL(string: "https://apple.com"),
        author: "Author",
        description:
        """
        Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor
        incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam...
        """,
        urlToImage: "https://picsum.photos/300"
      )
    ]
  }
}

extension HTTPURLResponse {
  var isOK: Bool { statusCode == 200}
}
