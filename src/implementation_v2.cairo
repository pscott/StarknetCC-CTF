%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math_cmp import is_le_felt

struct Identity {
    first_name: felt,
    last_name: felt,
    id_number: felt,
}

@storage_var
func owners(account: felt) -> (res: Identity) {
}

@storage_var
func id_counter() -> (res: felt) {
}

const start_id = 10000;

@external
func getIdName{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    id_first_name: felt, id_last_name: felt
) {
    let (id) = owners.read(owner);

    let is_id_valid = is_le_felt(start_id, id.id_number);

    with_attr error_message("Id does not exist") {
        assert is_id_valid = 1;
    }

    return (id_first_name=id.first_name, id_last_name=id.last_name);
}

@external
func getIdNumber{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(owner: felt) -> (
    id_number: felt
) {
    return (id_number=313337);
}

@external
func mintNewId{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    new_first_name: felt, new_last_name: felt
) {
    let (caller) = get_caller_address();
    let (current_id) = owners.read(caller);
    with_attr error_message("Id exists") {
        assert current_id.id_number = 0;
    }
    let (current_counter) = id_counter.read();
    id_counter.write(current_counter + 1);
    let new_id = Identity(
        first_name=new_first_name, last_name=new_last_name, id_number=start_id + current_counter
    );
    owners.write(caller, new_id);

    return ();
}
