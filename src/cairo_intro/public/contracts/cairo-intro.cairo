%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

from starkware.cairo.common.math import unsigned_div_rem

from starkware.cairo.common.math_cmp import is_le

from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp

// Storage var
@storage_var
func balance() -> (res: felt) {
}

@storage_var
func solved() -> (bool: felt) {
}

@storage_var
func owner() -> (owner: felt) {
}

// Constructor

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_owner: felt) {
    owner.write(_owner);
    let (timestamp) = get_block_timestamp();
    balance.write(timestamp);
    return ();
}

// View

@view
func is_solved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (test) = solved.read();
    return (test,);
}

@view
func get_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (res) = balance.read();
    return (res,);
}

@view
func get_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (res) = owner.read();
    return (res,);
}

// External

@external
func increase_balance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    amount: felt
) {
    let (res) = balance.read();
    balance.write(res + amount);
    owner_check(res + amount);
    return ();
}

@external
func solve_challenge{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    let (caller: felt) = get_caller_address();
    let (owner_: felt) = owner.read();
    with_attr error_msg("Only the owner can call this function") {
        assert caller = owner_;
    }
    solved.write(1);
    return ();
}

// Internal
func owner_check{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: felt) {
    alloc_locals;
    let (caller: felt) = get_caller_address();
    let (_, r: felt) = unsigned_div_rem(amount, 14);
    let condition1: felt = is_le(31333333377, amount);
    let condition2: felt = is_le(amount, 31333333391);
    if (r == 0 and condition1 == 1 and condition2 == 1) {
        owner.write(caller);
        return ();
    }
    return ();
}
