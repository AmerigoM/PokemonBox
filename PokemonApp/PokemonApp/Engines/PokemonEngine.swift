//
//  PokemonEngine.swift
//  PokemonApp
//
//  Created by Amerigo Mancino on 02/08/24.
//

import Foundation

public class PokemonEngine {
    
    static var shared = PokemonEngine()
    
    // MARK: - Private variables
    
    private var currentOffset = 0
    private var totalCount = -1
    
    // MARK: - Lifecycle methods
    
    private init() { }
    
    // MARK: - Public methods
    
    func fetchNextData() async throws -> [PokemonDisplay] {
        let newList = try await fetchPokemonList()
        return try await withThrowingTaskGroup(of: PokemonDisplay.self) { group in
            for el in newList {
                group.addTask {
                    async let details = self.fetchPokemonDetail(name: el.name)
                    async let species = self.fetchPokemonSpecies(name: el.name)
                    
                    let (detailsResult, speciesResult) = try await (details, species)
                    
                    let types = detailsResult.types.map { $0.type.name }
                    let description = speciesResult.flavor_text_entries
                        .first(where: { $0.language.name == "en" })?.flavor_text
                        .replacingOccurrences(of: "\u{00AD}\n", with: "")
                        .replacingOccurrences(of: "[\\x00-\\x1F\\x80-\\xC0]", with: " ", options: .regularExpression) ?? "No description available"
                    
                    return PokemonDisplay(id: detailsResult.id, name: el.name, image: detailsResult.sprites.other.officialArtwork.front_default, types: types, description: description)
                }
            }
            
            var newPokemonList: [PokemonDisplay] = []
            
            for try await pokemon in group {
                newPokemonList.append(pokemon)
            }
            
            return newPokemonList.sorted(by: { $0.id < $1.id })
        }
    }
    
    func searchPokemon(name: String) async throws -> PokemonDisplay {
        let apiName = name.lowercased()
        let detailsResult = try await fetchPokemonDetail(name: apiName)
        let speciesResult = try await fetchPokemonSpecies(name: apiName)
        
        let types = detailsResult.types.map { $0.type.name }
        let description = speciesResult.flavor_text_entries
            .first(where: { $0.language.name == "en" })?.flavor_text
            .replacingOccurrences(of: "\u{00AD}\n", with: "")
            .replacingOccurrences(of: "[\\x00-\\x1F\\x80-\\xC0]", with: " ", options: .regularExpression) ?? "No description available"
        
        return PokemonDisplay(id: detailsResult.id, name: name, image: detailsResult.sprites.other.officialArtwork.front_default, types: types, description: description)
    }
    
    public func getTotalCount() -> Int {
        return self.totalCount
    }
    
    // MARK: - Private methods
    
    private func fetchPokemonList() async throws -> [PokemonListEntry] {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?offset=\(currentOffset)&limit=20")!
        self.currentOffset += 20
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(PokemonListResponse.self, from: data)
        
        self.totalCount = response.count
        
        return response.results
    }
    
    private func fetchPokemonDetail(name: String) async throws -> PokemonDetails {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(name)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(PokemonDetails.self, from: data)
        return response
    }
    
    private func fetchPokemonSpecies(name: String) async throws -> PokemonSpecies {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(name)")!
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        let response = try decoder.decode(PokemonSpecies.self, from: data)
        return response
    }
}
