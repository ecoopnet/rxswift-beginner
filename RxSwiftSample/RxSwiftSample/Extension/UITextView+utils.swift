import UIKit

extension UITextView {
    func append(_ s: String, withNewLine: Bool = true, clear: Bool = false, animated: Bool = false) {
        if clear {
            text = s
        } else {
            text = text + (withNewLine ? "\n" : "") + s
        }
        print(s)
        scrollToBottom(animated: animated)
    }

    func clear(animated: Bool = false) {
        text = ""
        scrollToTop(animated: animated)
    }
}
