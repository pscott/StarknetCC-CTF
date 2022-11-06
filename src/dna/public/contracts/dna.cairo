%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.hash import hash2

@storage_var
func test_pass(number: felt) -> (res: felt) {
}

@storage_var
func challenge_is_done() -> (bool: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr: felt}(
    _password: felt
) {
    test_pass.write(_password, 1);
    return ();
}

@view
func is_challenge_done{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    res: felt
) {
    let (res: felt) = challenge_is_done.read();
    return (res,);
}

func test_value(input: felt, res1: felt, res2: felt, res3: felt, res4: felt) -> (res: felt) {
    alloc_locals;

    let value = input;

    if (value == 67) {
        return (res=res4);
    }

    if (value == 71) {
        return (res=res2);
    }

    if (value == 84) {
        return (res=res1);
    }

    if (value == 65) {
        return (res=res3);
    }
    return (res=0);
}

@external
func test_password{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr: felt}(
    inputs_len: felt, inputs: felt*
) -> () {
    alloc_locals;
    let values_len = inputs_len;
    let values = inputs;

    with_attr error_message("    ERROR: You have to use a list with a len equal to 17!") {
        assert values_len = 17;
    }

    test_value([values], 1498, 997, 2753, 6301);
    let result1 = [ap - 1];

    test_value([values + 1], 5939, 1823, 5501, 2069);
    let result2 = [ap - 1] + result1;

    test_value([values + 2], 113, 127, 131, 137);
    let result3 = [ap - 1] + result2;

    test_value([values + 3], 1913, 7919, 7127, 7577);
    let result4 = [ap - 1] + result3;

    test_value(
        [values + 4],
        877,
        27644437,
        35742549198872617291353508656626642567,
        359334085968622831041960188598043661065388726959079837,
    );
    let result5 = [ap - 1] + result4;

    test_value([values + 5], 16127, 1046527, 16769023, 1073676287);
    let result6 = [ap - 1] + result5;

    test_value([values + 6], 2381, 2521, 3121, 3613);
    let result7 = [ap - 1] + result6;

    test_value([values + 7], 3259, 3301, 3307, 3313);
    let result8 = [ap - 1] + result7;

    test_value([values + 8], 479, 487, 491, 499);
    let result9 = [ap - 1] + result8;

    test_value([values + 9], 23497, 24571, 25117, 26227);
    let result10 = [ap - 1] + result9;

    test_value([values + 10], 60493, 63949, 65713, 69313);
    let result11 = [ap - 1] + result10;

    test_value([values + 11], 87178291199, 479001599, 39916801, 5039);
    let result12 = [ap - 1] + result11;

    test_value([values + 12], 13, 29, 53, 89);
    let result13 = [ap - 1] + result12;

    test_value([values + 13], 433494437, 2971215073, 28657, 514229);
    let result14 = [ap - 1] + result13;

    test_value([values + 14], 131071, 2147483647, 524287, 8191);
    let result15 = [ap - 1] + result14;

    test_value([values + 15], 786433, 746497, 995329, 839809);
    let result16 = [ap - 1] + result15;

    test_value([values + 16], 9091, 101, 333667, 9901);
    let result17 = [ap - 1] + result16;

    let (test_password_) = hash2{hash_ptr=pedersen_ptr}(result17, 317);
    let (read_storage) = test_pass.read(test_password_);
    if (read_storage == 1) {
        challenge_is_done.write(1);
        return ();
    }
    return ();
}
