//  MostViewedVC.swift
//  NewsApp
//  Created by Serhii Bets on 13.04.2022.
//  Copyright by Serhii Bets. All rights reserved.

import UIKit
import DZNEmptyDataSet
import SDWebImage

class MostViewedVC: UIViewController,UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var mostViewedTableView: UITableView!
    
    private enum Constants {
        enum Identifiers {
            static let cell = "NewsCustomCell"
            static let segue = "viewedSegue"
            static let viewedTitle = "Most Viewed News"
        }
    }
    
    var viewedNewsList = [[News]]() {
        didSet {
            mostViewedTableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = Constants.Identifiers.viewedTitle
        self.mostViewedTableView.emptyDataSetSource = self;
        self.mostViewedTableView.emptyDataSetDelegate = self
        self.registerTableViewCells()
        mostViewedTableView.tableFooterView = UIView()
        
        NewsService.shared.fetchNews(for: .mostViewed) { results in
            switch results {
            case .success(let news):
                self.viewedNewsList = self.mostViewedTableView.buildData(for: news.results)
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
extension MostViewedVC {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let news = viewedNewsList[indexPath.section][indexPath.row]
        performSegue(withIdentifier: Constants.Identifiers.segue, sender: news)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewedNewsList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = mostViewedTableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.cell,
                                                            for: indexPath) as! NewsTableViewCell
        let news = viewedNewsList[indexPath.section][indexPath.row]
        mostViewedTableView.rowHeight = UITableView.automaticDimension
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
        return viewedNewsList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewedNewsList[section].compactMap { $0.section }.first ?? "Unknown"
    }
    
    private func registerTableViewCells() {
        let newsTitleCell = UINib(nibName: Constants.Identifiers.cell, bundle: nil)
        self.mostViewedTableView.register(newsTitleCell, forCellReuseIdentifier: Constants.Identifiers.cell)
    }
    
}
// === MARK: - DZNEmptyDataSet Delegate extension ===
extension MostViewedVC {

    func emptyDataSet(_ scrollView: UIScrollView, didTap button: UIButton) {
        mostViewedTableView.showActivityIndicator()

        NewsService.shared.fetchNews(for: .mostViewed) { results in
            switch results {
            case .success(let news):
                self.viewedNewsList = self.mostViewedTableView.buildData(for: news.results)
                self.mostViewedTableView.reloadData()
                self.mostViewedTableView.hideActivityIndicator()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
