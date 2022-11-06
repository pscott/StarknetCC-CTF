// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts for Cairo v0.4.0 (account/IAccount.cairo)

%lang starknet

@contract_interface
namespace IAccount {
    // Starknet devnet 0.3.1 uses open zeppelin's camelcased account impl
    func get_public_key() -> (
        res: felt
    ) {
    }
}
