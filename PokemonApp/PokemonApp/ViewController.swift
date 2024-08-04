//
//  ViewController.swift
//  PokemonApp
//
//  Created by Amerigo Mancino on 01/08/24.
//

import UIKit

class ViewController: UIViewController {
    
    private let titleLabel: UILabel = UILabel()
    private let searchBar: UISearchBar = UISearchBar()
    private let tableView: UITableView = UITableView()
    private let emptyLabel: UILabel = UILabel()
    
    private var pokemonList: [PokemonDisplay] = []
    private var filteredPokemonList: [PokemonDisplay] = []
    private var isLoading: Bool = false
    private var searchIsActive: Bool = false
    
    private var engine = PokemonEngine.shared
    
    // MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
       
        setupTitleLabel()
        setupSearchBar()
        setupTableView()
        setupEmptyLabel()
        
        hideKeyboardWhenTappedAround()
        
        Task {
            let list = try await self.engine.fetchNextData()
            self.pokemonList.append(contentsOf: list)
            self.filteredPokemonList = self.pokemonList
            tableView.reloadData()
        }
    }
    
    // MARK: - UI setup
    
    private func setupEmptyLabel() {
        emptyLabel.text = "Woooah,\n such emptiness..."
        emptyLabel.textAlignment = .center
        emptyLabel.font = UIFont.italicSystemFont(ofSize: 16)
        emptyLabel.numberOfLines = 2
        emptyLabel.textColor = UIColor(red: 0.52, green: 0.52, blue: 0.52, alpha: 1.0)
        emptyLabel.isHidden = true
        
        view.addSubview(emptyLabel)
        
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyLabel.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emptyLabel.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func setupTitleLabel() {
        let attributedText = NSMutableAttributedString(
            string: "Pokemon",
            attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32, weight: .regular)]
        )
        
        attributedText.append(
            NSAttributedString(
                string: "Box",
                attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32, weight: .bold)]
            )
        )
        
        titleLabel.attributedText = attributedText
        titleLabel.textAlignment = .center
        
        view.addSubview(titleLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    private func setupSearchBar() {
        searchBar.layer.borderWidth = 1
        searchBar.layer.borderColor = UIColor(red: 255/255, green: 253/255, blue: 247/255, alpha: 1.0).cgColor
        
        view.addSubview(searchBar)
          
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        searchBar.searchTextField.delegate = self
        searchBar.delegate = self
    }
      
    private func setupTableView() {
        view.addSubview(tableView)
          
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
          
        tableView.dataSource = self
        tableView.delegate = self
          
        let nibCell = UINib(nibName: "PokemonCell", bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: "PokemonCell")
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredPokemonList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath) as! PokemonCell
        let pokemon = filteredPokemonList[indexPath.row]
        
        cell.selectionStyle = .none
        
        cell.title.text = nil
        cell.type1.text = nil
        cell.type2.text = nil
        cell.desc.text = nil
        
        cell.title.text = pokemon.name.capitalized
        
        if pokemon.types.count > 1 {
            cell.type1.text = pokemon.types[0].capitalized
            cell.type2.text = pokemon.types[1].capitalized
            cell.view2.isHidden = false
        } else {
            cell.type1.text = pokemon.types.first?.capitalized
            cell.view2.isHidden = true
        }
        
        cell.desc.text = pokemon.description
        
        if let imageString = pokemon.image, let imageURL = URL(string: imageString) {
            cell.artwork.loadImage(from: imageURL)
        }
        
        return cell
    }
    
    // MARK: - Scroll view
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.searchIsActive == false else { return }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            guard !isLoading else { return }
            guard self.pokemonList.count < self.engine.getTotalCount() else { return }
            
            self.isLoading = true
            
            Task {
                let list = try await self.engine.fetchNextData()
                self.pokemonList.append(contentsOf: list)
                self.filteredPokemonList = self.pokemonList
                
                tableView.reloadData()
                self.isLoading = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
}

// MARK: - UISearchBarDelegate

extension ViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else { return }
        
        self.searchIsActive = true
        
        Task {
            do {
                let searchResults = try await engine.searchPokemon(name: query)
                self.filteredPokemonList = [searchResults]
                self.emptyLabel.isHidden = true
                self.tableView.reloadData()
            } catch {
                self.emptyLabel.isHidden = false
                self.filteredPokemonList = []
                self.tableView.reloadData()
            }
            
            self.searchBar.endEditing(true)
        }
    }
}

// MARK: - UITextFieldDelegate

extension ViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        self.searchIsActive = false
        self.emptyLabel.isHidden = true
        self.filteredPokemonList = self.pokemonList
        self.tableView.reloadData()
        
        return true
    }
}

// MARK: - Gesture recognizers

extension ViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard)
        )
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
