//
//  PokemonAppTests.swift
//  PokemonAppTests
//
//  Created by Amerigo Mancino on 04/08/24.
//

import XCTest
@testable import PokemonApp

final class PokemonAppTests: XCTestCase {

    var engine: PokemonEngine!
    
    override func setUpWithError() throws {
        engine = PokemonEngine.shared
    }

    func testFetchNextData() async throws {
        let pokemons = try await engine.fetchNextData()
        XCTAssertEqual(pokemons.count, 20)
    }
    
    func testSearchPokemon() async throws {
        let pokemon = try await engine.searchPokemon(name: "bulbasaur")
        XCTAssertEqual(pokemon.name, "bulbasaur")
        XCTAssertEqual(pokemon.id, 1)
    }

}
