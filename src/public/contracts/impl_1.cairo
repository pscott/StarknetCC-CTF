%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math_cmp import is_le_felt
from starkware.starknet.common.syscalls import get_caller_address

@contract_interface
namespace Contract_1 {
    func solve_step_1(mult: felt) -> (res: felt) {
    }
    func get_step_1() -> (res: felt) {
    }
}

const const_step_1 = 3609145100;

@storage_var
func step_1() -> (res: felt) {
}

@view
func get_step_1{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (res) = step_1.read();
    return (res,);
}

@external
func solve_step_1{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(mult: felt) -> (
    res: felt
) {
    let (caller) = get_caller_address();
    let prod = const_step_1 + 12345 + caller;

    if (mult == prod) {
        step_1.write(prod);
        return (res=1);
    }
    return (res=0);
}
