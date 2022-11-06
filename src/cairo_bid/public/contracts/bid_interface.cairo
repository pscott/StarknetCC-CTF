%lang starknet

using Bool = felt;
using Address = felt;

@contract_interface
namespace Bid {
    func get_balance(address: Address) -> (balance: felt) {
    }

    func get_transfer_fact(address: Address) -> (transered: Bool) {
    }

    func get_fact_bid(address: Address) -> (bidded: Bool) {
    }

    func get_bid_amount(address: Address) -> (bid_amount: felt) {
    }

    func get_winner_bid() -> (address: Address, bid_amount: felt) {
    }

    func deposit(address: Address, bid_amount: felt) {
    }

    func bid(address: Address, bid_amount: felt) {
    }
}