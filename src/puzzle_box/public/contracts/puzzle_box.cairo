%lang starknet

from impl_1 import Contract_1
from impl_2 import Contract_2

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func class_hash() -> (res: felt) {
}

@storage_var
func implementation_hash() -> (res: felt) {
}

@storage_var
func solved() -> (res: felt) {
}

@storage_var
func step_1_done() -> (res: felt) {
}

@storage_var
func step_2_done() -> (res: felt) {
}

@storage_var
func step_3_done() -> (res: felt) {
}

@storage_var
func step_4_done() -> (res: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr: felt}(
    _class_hash: felt, _implementation_hash: felt
) {
    class_hash.write(_class_hash);
    implementation_hash.write(_implementation_hash);
    return ();
}

@view
func is_solved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (res) = solved.read();
    return (res,);
}

@external
func solve_step_1{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(_mult: felt) -> (
    ) {
    let (class_h) = class_hash.read();
    let (res) = Contract_1.library_call_solve_step_1(class_hash=class_h, mult=_mult);
    if (res == 1) {
        step_1_done.write(1);
        return ();
    }
    return ();
}

@external
func solve_step_2{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    product: felt
) -> () {
    let (imp_h) = implementation_hash.read();
    let (res) = Contract_2.solve_step_2(contract_address=imp_h, mult=product);
    if (res == 1) {
        step_2_done.write(1);
        return ();
    }
    return ();
}

func get_val() -> (val0: felt, val1: felt) {
    [ap] = 3, ap++;
    [ap] = 4, ap++;

    [ap] = [ap - 1] * [ap - 2], ap++;
    [ap] = [ap - 1] * [ap - 2], ap++;
    [ap] = [ap - 1] * [ap - 2], ap++;
    [ap] = [ap - 1] * [ap - 2], ap++;

    [ap] = [ap - 2] + [ap - 4], ap++;
    [ap] = [ap - 1] + [ap - 4], ap++;
    ret;
}

@external
func solve_step_3{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(value: felt) -> (
    ) {
    let (v0, v1) = get_val();
    let res = v0 * v1;

    if (value == res) {
        step_3_done.write(1);
        return ();
    }
    return ();
}

func st_4_1{value: felt}(val: felt) -> (res: felt) {
    let value = 84092830;
    return (res=1019019324);
}

func st_4_2(value: felt) -> (res: felt) {
    let value = 21835210;
    return (res=value);
}

@external
func solve_step_4{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(input: felt) -> (
    ) {
    let (value) = st_4_2(12301342);
    with value {
        st_4_1(17329287);
    }
    if (value == input) {
        step_4_done.write(1);
        return ();
    }
    return ();
}

@external
func solve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (res: felt) {
    let (step_1_solved) = step_1_done.read();
    let (step_2_solved) = step_2_done.read();
    let (step_3_solved) = step_3_done.read();
    let (step_4_solved) = step_4_done.read();

    with_attr error_message("You did not solve step 1") {
        assert step_1_solved = 1;
    }
    with_attr error_message("You did not solve step 2") {
        assert step_2_solved = 1;
    }
    with_attr error_message("You did not solve step 3") {
        assert step_3_solved = 1;
    }
    with_attr error_message("You did not solve step 4") {
        assert step_4_solved = 1;
    }
    solved.write(1);
    return (res=1);
}
