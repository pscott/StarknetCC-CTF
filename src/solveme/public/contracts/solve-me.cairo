%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func solved() -> (bool: felt) {
}

// Constructor
@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    return ();
}

// View

@view
func is_solved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (res) = solved.read();
    return (res=res);
}

// External

@external
func solve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    solved.write(1);
    return ();
}
