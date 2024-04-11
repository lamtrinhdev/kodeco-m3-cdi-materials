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

import OSLog

actor Persistence {
  func saveToDisk(_ article: Article) {
    guard let fileURL = fileName(for: article) else {
      Logger.main.error("Can't build filename for article: \(article.title)")
      return
    }

    guard let imageURL = article.urlToImage, let url = URL(string: imageURL) else {
      Logger.main.error("Can't build image URL for article: \(article.title)")
      return
    }

    Task.detached(priority: .background) {
      guard let (downloadedFileURL, response) = try? await URLSession.shared.download(from: url) else {
        Logger.main.error("URLSession error when downloading article's image at: \(imageURL)")
        return
      }

      guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
        Logger.main.error("Response error when downloading article's image at: \(imageURL)")
        return
      }

      Logger.main.info("File downloaded to: \(downloadedFileURL.absoluteString)")

      do {
        if FileManager.default.fileExists(atPath: fileURL.path) {
          try FileManager.default.removeItem(at: fileURL)
        }
        try FileManager.default.moveItem(at: downloadedFileURL, to: fileURL)
        Logger.main.info("File saved successfully to: \(fileURL.absoluteString)")
      } catch {
        Logger.main.error("File copy failed with: \(error.localizedDescription)")
      }
    }
  }

  private func fileName(for article: Article) -> URL? {
    let fileName = article.title
    guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
      return nil
    }
    return documentsDirectory.appendingPathComponent(fileName)
  }
}
