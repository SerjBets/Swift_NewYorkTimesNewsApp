//  DownloadVC.swift
//  NewsApp
//  Created by Serhii Bets on 13.04.2022.
//  Copyright by Serhii Bets. All rights reserved.

import UIKit
import CoreData

class DownloadNewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var savedNewsTableView: UITableView!
    @IBOutlet weak var emptyNewsMessage: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var news : News?
    
    private enum Constants {
        enum Identifiers {
            static let cell = "savedTableViewCell"
            static let segue = "savedSegue"
        }
    }
    
    private func setupView() {
        emptyNewsMessage.text = "You don't have saved News."
        updateView()
    }
    
    private func updateView() {
        var hasNews = false
        if let news = fetchedResultsController.fetchedObjects {
            hasNews = news.count > 0
        }
        savedNewsTableView.isHidden = !hasNews
        emptyNewsMessage.isHidden = hasNews
        activityIndicator.stopAnimating()
    }
    
    fileprivate lazy var fetchedResultsController: NSFetchedResultsController<NewsEntity> = {
        let fetchRequest: NSFetchRequest<NewsEntity> = NewsEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.shared.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try self.fetchedResultsController.performFetch()
            self.setupView()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }
        self.updateView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == Constants.Identifiers.segue,
              let news = sender as? News,
              let detailedVC = segue.destination as? DetailNewsVC else { return }
        detailedVC.news = news
    }
}

// === MARK: - TableView Delegate / DataSource extension ===
extension DownloadNewsVC {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let newsEntity = fetchedResultsController.fetchedObjects else { return }
        performSegue(withIdentifier: Constants.Identifiers.segue, sender: News(entity: newsEntity[indexPath.row]))
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let news = fetchedResultsController.fetchedObjects else { return 0 }
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = savedNewsTableView.dequeueReusableCell(withIdentifier: Constants.Identifiers.cell, for: indexPath)
        let savedNews = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        tableView.rowHeight = UITableView.automaticDimension
        cell.textLabel?.text = savedNews.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let news = fetchedResultsController.fetchedObjects else { return }
        switch editingStyle {
        case .delete:
            CoreDataManager.shared.deleteNewsWith(model: news[indexPath.row]) { result in
                switch result {
                case .success():
                    print("Remove was succesful")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        default:
            break;
        }
    }
}

// === MARK: - NSFetchedResultsControllerDelegate extension ===
extension DownloadNewsVC: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        savedNewsTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            savedNewsTableView.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
        case .delete:
            savedNewsTableView.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
        default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { return }
            savedNewsTableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else { return }
            savedNewsTableView.deleteRows(at: [indexPath], with: .automatic)
        case .move:
            guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
            savedNewsTableView.deleteRows(at: [indexPath], with: .automatic)
            savedNewsTableView.insertRows(at: [newIndexPath], with: .automatic)
        case .update:
            guard let indexPath = indexPath else { return }
            savedNewsTableView.reloadRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
     
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        savedNewsTableView.endUpdates()
        updateView()
    }

}
