%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math_cmp import is_le_felt

@storage_var
func shares() -> (res: felt) {
}

@storage_var
func max_supply() -> (res: felt) {
}

@storage_var
func claimed(address: felt) -> (claimed: felt) {
}

@storage_var
func last_claimer() -> (res: felt) {
}

@storage_var
func balances(claimer: felt) -> (balance: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    shares.write(178757362047346148211425280000000);
    max_supply.write(178757362047346148211425280000000);
    last_claimer.write(1);
    return ();
}

@external
func claim{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (_last_claimer) = last_claimer.read();
    let (caller) = get_caller_address();

    let (already_claimed) = claimed.read(caller);
    with_attr error_message("Already claimed") {
        assert already_claimed = 0;
    }

    let left_to_claim = is_le_felt(_last_claimer, 30);
    with_attr error_message("Too many claimers") {
        assert left_to_claim = 1;
    }
    let (total_shares) = shares.read();
    let shares_to_deal = total_shares / _last_claimer;
    claimed.write(caller, 1);
    balances.write(caller, shares_to_deal);

    last_claimer.write(_last_claimer + 1);
    return ();
}

@view
func get_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    claimer: felt
) -> (balance: felt) {
    let (balance) = balances.read(claimer);
    return (balance=balance);
}

@view
func get_max_supply{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    supply: felt
) {
    let (supply) = max_supply.read();
    return (supply=supply);
}
