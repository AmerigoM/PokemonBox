//
//  Model.swift
//  PokemonApp
//
//  Created by Amerigo Mancino on 01/08/24.
//

import Foundation

// MARK: - Pokemon list

struct PokemonListResponse: Decodable {
    let count: Int
    let results: [PokemonListEntry]
}

struct PokemonListEntry: Decodable {
    let name: String
    let url: String
}

// MARK: - Pokemon details

struct PokemonDetails: Decodable {
    let id: Int
    let name: String
    let sprites: Sprites
    let types: [TypeEntry]
    
    struct TypeEntry: Decodable {
        let type: PokemonType
        
        struct PokemonType: Decodable {
            let name: String
        }
    }
}

struct Sprites: Decodable {
    let other: Other
    
    struct Other: Decodable {
        let officialArtwork: OfficialArtwork
        
        enum CodingKeys: String, CodingKey {
            case officialArtwork = "official-artwork"
        }
        
        struct OfficialArtwork: Decodable {
            let front_default: String
        }
    }
}

// MARK: - Pokemon species

struct PokemonSpecies: Decodable {
    let flavor_text_entries: [FlavorTextEntry]
    
    struct FlavorTextEntry: Decodable {
        let flavor_text: String
        let language: Language
        
        struct Language: Decodable {
            let name: String
        }
    }
}

// MARK: - Pokemon Display

struct PokemonDisplay {
    let id: Int
    let name: String
    let image: String?
    let types: [String]
    let description: String
}
