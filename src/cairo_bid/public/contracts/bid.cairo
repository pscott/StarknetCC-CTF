%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.bool import TRUE
from bid_lib import Bid
from starkware.cairo.common.math import assert_not_zero

using Bool = felt;
using Address = felt;

// VIEW

@view
func get_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: Address
) -> (balance: felt) {
    let (res) = Bid.get_balance(address);
    return (res,);
}

@view
func get_transfer_fact{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: Address
) -> (transfered: Bool) {
    let (res) = Bid.get_transfer_fact(address);
    return (res,);
}

@view
func get_fact_bid{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: Address
) -> (bidded: Bool) {
    let (res) = Bid.get_fact_bid(address);
    return (res,);
}

@view
func get_bid_amount{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: Address
) -> (bid_amount: felt) {
    let (res) = Bid.get_bid_amount(address);
    return (res,);
}

@view
func get_winner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
) -> (address: Address, bid_amount: felt) {
    let (address: Address, bid_amount: felt) = Bid.get_winner();
    return (address, bid_amount);
}

// EXTERNAL

@external
func deposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
        address: Address, amount: Uint256
) {
    let (success: Bool) = Bid.transfer_funds(address, amount);
    with_attr error_message("Transfer failed!") {
        assert success = TRUE;
    }
    return ();
}

@external
func bid{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: Address, bid_amount: Uint256
) {
    alloc_locals;
    let (success: Bool) = Bid.add_bid(address, bid_amount);
    with_attr error_message("Bid failed!") {
        assert success = TRUE;
    }
    return ();
}