//  MostSharedVC.swift
//  NewsApp
//  Created by Serhii Bets on 13.04.2022.
//  Copyright by Serhii Bets. All rights reserved.

import UIKit
import DZNEmptyDataSet

class MostSharedVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var mostSharedTableView: UITableView!
    
    private enum Constants {
        enum Identifiers {
            static let cell = "mostSharedCell"
            static let segue = "sharedSegue"
            static let sharedTitle = "Most Shared News"
        }
    }
    
    var sharedNewsList = [[News]]() {
        didSet {
            mostSharedTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.Identifiers.sharedTitle
        self.mostSharedTableView.emptyDataSetSource = self;
        self.mostSharedTableView.emptyDataSetDelegate = self
        mostSharedTableView.tableFooterView = UIView()
        
        NewsService.shared.fetchNews(for: .mostShared) { results in
            switch results {
            case .success(let news):
                self.sharedNewsList = self.mostSharedTableView.buildData(for: news.results)
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
extension MostSharedVC {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = sharedNewsList[indexPath.section][indexPath.row]
        performSegue(withIdentifier: Constants.Identifiers.segue, sender: news)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sharedNewsList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mostSharedTableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.cell,
                                                            for: indexPath)
        let news = sharedNewsList[indexPath.section][indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        tableView.rowHeight = UITableView.automaticDimension
        cell.textLabel?.text = news.title
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sharedNewsList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sharedNewsList[section].compactMap { $0.section }.first ?? "Unknown"
    }
}

// === MARK: - DZNEmptyDataSet Delegate extension ===
extension MostSharedVC {

    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        mostSharedTableView.showActivityIndicator()

        NewsService.shared.fetchNews(for: .mostShared) { results in
            switch results {
            case .success(let news):
                self.sharedNewsList = self.mostSharedTableView.buildData(for: news.results)
                self.mostSharedTableView.reloadData()
                self.mostSharedTableView.hideActivityIndicator()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
