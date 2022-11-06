%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import split_felt
from starkware.cairo.common.uint256 import Uint256, uint256_check
from starkware.cairo.common.math_cmp import is_le_felt
from starkware.cairo.common.bool import TRUE, FALSE

// safe conversion from uint256 to felt
func uint256_to_felt{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    value: Uint256
) -> (res: felt) {
    uint256_check(value);
    
    let res: felt = value.low + value.high * (2 ** 128);

    with_attr error_message("uint256_to_felt: Value doesn't fit in a felt") {
        assert_251_bit(res);
    }

    return (res,);
}
// safe conversion from felt to uint256
func felt_to_uint256{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    value: felt
) -> (res: Uint256) {
    alloc_locals;

    with_attr error_message("felt_to_uint256: invalid uint") {
        let (local high, local low) = split_felt(value);
    }

    let res = Uint256(low, high);
    uint256_check(res);

    return (res,);
}

func assert_251_bit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    val: felt
) {
    let is_proper_felt = is_le_felt(val, 2**251);

    assert is_proper_felt = TRUE;

    return ();
}
