//
//  ViewController.swift
//  project7
//
//  Created by Denys Denysenko on 22.10.2021.
//

import UIKit

class ViewController: UITableViewController {
    
    var petitions = [Petition]()
    
    var filteredPetitions = [Petition]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urlString : String
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Credits", style: .plain, target: self, action: #selector(showInfo))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(filterPetitions))
        
        if navigationController?.tabBarItem.tag == 0 {
            
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
        [weak self] in
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                
                self?.parse(json: data)
                return
            }
        }
            self?.showError()
        }
        
        
        
        
    }
    
    @objc func filterPetitions () {
        
        let ac = UIAlertController(title: "Enter petiton title", message: nil, preferredStyle: .alert)
        
        ac.addTextField()
        let filterPetitions = UIAlertAction(title: "Filtered", style: .default) {
            [weak self, weak ac] action in
            
            guard let item = ac?.textFields?[0].text else {return}
            self?.submit(item)
        }
        ac.addAction(filterPetitions)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present (ac, animated: true)
    }
    
    func submit (_ item: String) {
        
        let lowercasedPetitons = item.lowercased()
        
        for petiton in petitions {
            
            if petiton.title.lowercased().contains(lowercasedPetitons) {
                
                filteredPetitions.append(petiton)
                
            }
        }
        
        petitions = filteredPetitions
        tableView.reloadData()
        filteredPetitions.removeAll(keepingCapacity: true)
        
        
        
        
        
    }
    
    @objc func showInfo () {
        
        let ac = UIAlertController(title: "Credits", message: "The data comes from the We The People API of the Whitehouse.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
    func showError() {
        DispatchQueue.main.async {
            [weak self] in
            let ac = UIAlertController(title: "Loading Error", message: "There was a problem with loading feed; please check your connection and try again.", preferredStyle: .alert)
            
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present (ac, animated: true)
        }
       
    }
    
    func parse (json: Data) {
        
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            
            petitions = jsonPetitions.results
            
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
            
            
        }
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = DetailViewController()
        vc.detailItem = petitions[indexPath.row]
        vc.title = petitions[indexPath.row].title
        navigationController?.pushViewController(vc, animated: true)
    }

}

