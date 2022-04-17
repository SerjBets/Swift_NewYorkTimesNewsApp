//  TableViewExtension.swift
//  NewsApp
//  Created by Serhii Bets on 13.04.2022.
//  Copyright by Serhii Bets. All rights reserved.

import Foundation
import UIKit
import DZNEmptyDataSet

// === MARK: - DZNEmptyDataSet Delegate extension ===
extension UIViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    public func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Data"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    public func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Check the internet connection and press Retry."
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .body)]
        return NSAttributedString(string: str, attributes: attrs)
    }

    public func buttonTitle(forEmptyDataSet scrollView: UIScrollView, for state: UIControl.State) -> NSAttributedString? {
        let str = "Retry"
        let attrs = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .callout)]
        return NSAttributedString(string: str, attributes: attrs)
    }
}

// === MARK: - TableView extension ===
extension UITableView {
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            let activityView = UIActivityIndicatorView(style: .medium)
            self.backgroundView = activityView
            activityView.startAnimating()
            UIApplication.shared.inputView?.isUserInteractionEnabled = true
        }
    }

    func hideActivityIndicator() {
        DispatchQueue.main.async {
            self.backgroundView = nil
            UIApplication.shared.inputView?.isUserInteractionEnabled = false
        }
    }
    
    func buildData(for news: [News]) -> [[News]] {
        var newsList = [[News]]()
        let groups = Dictionary(grouping: news, by: { $0.section }).sorted { $0.0 < $1.0 }
        groups.forEach { newsList.append($0.value.sorted(by: { $0 < $1 })) }
        return newsList
    }
}
