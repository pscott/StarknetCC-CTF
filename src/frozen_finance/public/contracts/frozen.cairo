%lang starknet

from starkware.cairo.common.serialize import serialize_word
from starkware.cairo.common.math_cmp import is_le_felt
from starkware.cairo.common.uint256 import uint256_add, Uint256, uint256_le
from starkware.cairo.common.cairo_builtins import HashBuiltin

const MAX_DEPOSITS = 7;

@storage_var
func balance_() -> (Uint256,) {
}
@storage_var
func deposits_() -> (felt,) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() {
    // Your friend lost such a small amount, is it really worth it?
    balance_.write(Uint256(50, 0));
    return ();
}

@external
func deposit{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(amount: Uint256) {
    with_attr error_message("Suspicious deposit, Autoridade Tributária e Aduaneira notified.") {
        // Make sure inputs are < 2**128
        assert amount.high = 0;
        assert amount.high = 0;
    }

    let (deposits) = deposits_.read();
    let le = is_le_felt(MAX_DEPOSITS, deposits);
    with_attr error_message(
            "Account frozen: High transaction rate. Autoridade Tributária e Aduaneira notified.") {
        assert le = 0;
    }

    let (balance) = balance_.read();
    let (balance, carry) = uint256_add(balance, amount);

    with_attr error_message("You're far too wealthy. Autoridade Tributária e Aduaneira en route.") {
        assert carry = 0;
    }

    balance_.write(balance);
    return ();
}

@view
func readBalance{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    balance: Uint256
) {
    return balance_.read();
}

@external
func withdraw{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    amount: Uint256
) {
    let (balance) = balance_.read();

    let (le) = uint256_le(balance, Uint256(low=46, high=7));
    with_attr error_message(
            "The bank has not made enough proft off your principal yet, please withdraw when we're happy we've rekt you enough") {
        assert le = 0;
    }

    balance_.write(Uint256(0, 0));
    return (amount=balance);
}
