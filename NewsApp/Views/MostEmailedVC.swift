//  MostEmailedVC.swift
//  NewsApp
//  Created by Serhii Bets on 13.04.2022.
//  Copyright by Serhii Bets. All rights reserved.

import UIKit
import Alamofire
import DZNEmptyDataSet
import SDWebImage

class MostEmailedVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {
    @IBOutlet weak var mostEmailedTableView: UITableView!
    
    private enum Constants {
        enum Identifiers {
            static let cell = "NewsCustomCell"
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
        self.registerTableViewCells()
        
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
        let newsItem = emailedNewsList[indexPath.section][indexPath.row]
        performSegue(withIdentifier: Constants.Identifiers.segue, sender: newsItem)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailedNewsList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mostEmailedTableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.cell,
                                                            for: indexPath) as! NewsTableViewCell
        let news = emailedNewsList[indexPath.section][indexPath.row]
        mostEmailedTableView.rowHeight = UITableView.automaticDimension
        cell.newsTitle.numberOfLines = 0
        cell.newsTitle.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.newsTitle.text = news.title
        cell.byLine.text = news.byline
        let imageUrl = NewsService.shared.getImageUrl(newsItem: news, imageheight: NewsService.ImageHeight.small.rawValue)
        cell.newsImage.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.newsImage.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "no image.php"))
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return emailedNewsList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return emailedNewsList[section].compactMap { $0.section }.first ?? "Unknown"
    }
    
    private func registerTableViewCells() {
        let newsTitleCell = UINib(nibName: Constants.Identifiers.cell, bundle: nil)
        self.mostEmailedTableView.register(newsTitleCell, forCellReuseIdentifier: Constants.Identifiers.cell)
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
