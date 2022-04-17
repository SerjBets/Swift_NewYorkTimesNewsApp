//  MostEmailedVC.swift
//  NewsApp
//  Created by Serhii Bets on 13.04.2022.
//  Copyright by Serhii Bets. All rights reserved.

import UIKit
import Alamofire
import DZNEmptyDataSet

class MostEmailedVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var mostEmailedTableView: UITableView!
    
    private enum Constants {
        enum Identifiers {
            static let cell = "mostEmailedCell"
            static let segue = "emailedSegue"
            static let emailedTitle = "Most Emailed News"
        }
    }
    
    var emailedNewsList = [[News]]() {
        didSet {
            mostEmailedTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.Identifiers.emailedTitle
        self.mostEmailedTableView.emptyDataSetSource = self;
        self.mostEmailedTableView.emptyDataSetDelegate = self
        mostEmailedTableView.tableFooterView = UIView()
        
        NewsService.shared.fetchNews(for: .mostEmailed) { results in
            switch results {
            case .success(let news):
                self.emailedNewsList = self.mostEmailedTableView.buildData(for: news.results)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.Identifiers.segue,
                let news = sender as? News,
                let detailedVC = segue.destination as? DetailNewsVC else { return }
        detailedVC.news = news
    }
}

// === MARK: - TableView Delegate / DataSource extension ===
extension MostEmailedVC {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = emailedNewsList[indexPath.section][indexPath.row]
        performSegue(withIdentifier: Constants.Identifiers.segue, sender: news)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailedNewsList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mostEmailedTableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.cell,
                                                            for: indexPath)
        let news = emailedNewsList[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        tableView.rowHeight = UITableView.automaticDimension
        cell.textLabel?.text = news.title
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return emailedNewsList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return emailedNewsList[section].compactMap { $0.section }.first ?? "Unknown"
    }
}

// === MARK: - DZNEmptyDataSet Delegate extension ===
extension MostEmailedVC {

    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        mostEmailedTableView.showActivityIndicator()
        
        NewsService.shared.fetchNews(for: .mostEmailed) { results in
            switch results {
            case .success(let news):
                self.emailedNewsList = self.mostEmailedTableView.buildData(for: news.results)
                self.mostEmailedTableView.reloadData()
                self.mostEmailedTableView.hideActivityIndicator()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
