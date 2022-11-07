%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math_cmp import is_le_felt

@contract_interface
namespace Contract_2 {
    func solve_step_2(mult: felt) -> (res: felt) {
    }
    func get_step_2() -> (res: felt) {
    }
}

const step_2_const = 1010886179;

@storage_var
func step_2() -> (res: felt) {
}

@view
func get_step_2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (res) = step_2.read();
    return (res,);
}

@external
func solve_step_2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(mult: felt) -> (
    res: felt
) {
    let (caller) = get_caller_address();
    let prod = step_2_const + 965647271 + caller;

    if (mult == prod) {
        step_2.write(prod);
        return (res=1);
    }
    return (res=0);
}
