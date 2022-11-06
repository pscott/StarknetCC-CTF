%lang starknet

from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import (
    library_call,
    library_call_l1_handler,
    get_caller_address,
)

@storage_var
func owners(account: felt) -> (is_owner: felt) {
}

@storage_var
func implementation() -> (class_hash: felt) {
}

@view
func get_implementation{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    curr_implementation: felt
) {
    let (curr_implementation) = implementation.read();
    return (curr_implementation=curr_implementation);
}

@view
func get_is_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    account: felt
) -> (is_owner: felt) {
    let (is_owner) = owners.read(account);
    return (is_owner=is_owner);
}

@external
func set_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(new_owner: felt) {
    let (caller) = get_caller_address();
    let (is_owner) = owners.read(caller);
    with_attr error_message("Ownable: caller is not an owner") {
        assert is_owner = 1;
    }
    owners.write(new_owner, 1);
    return ();
}

@external
func remove_owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) {
    let (caller) = get_caller_address();
    let (is_owner) = owners.read(caller);
    with_attr error_message("Ownable: caller is not an owner") {
        assert is_owner = 1;
    }
    owners.write(owner, 0);
    return ();
}

@external
func upgrade{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    new_implementation: felt
) {
    let (caller) = get_caller_address();
    let (is_owner) = owners.read(caller);
    with_attr error_message("Ownable: caller is not an owner") {
        assert is_owner = 1;
    }
    implementation.write(new_implementation);
    return ();
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    class_hash: felt, proxy_owner: felt
) {
    assert_not_zero(class_hash);
    implementation.write(class_hash);
    owners.write(proxy_owner, 1);

    return ();
}

// Fallback functions

@external
@raw_input
@raw_output
func __default__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    selector: felt, calldata_size: felt, calldata: felt*
) -> (retdata_size: felt, retdata: felt*) {
    let (class_hash) = implementation.read();
    let (retdata_size: felt, retdata: felt*) = library_call(
        class_hash=class_hash,
        function_selector=selector,
        calldata_size=calldata_size,
        calldata=calldata,
    );

    return (retdata_size=retdata_size, retdata=retdata);
}

@l1_handler
@raw_input
func __l1_default__{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    selector: felt, calldata_size: felt, calldata: felt*
) {
    let (class_hash) = implementation.read();
    library_call_l1_handler(
        class_hash=class_hash,
        function_selector=selector,
        calldata_size=calldata_size,
        calldata=calldata,
    );

    return ();
}
