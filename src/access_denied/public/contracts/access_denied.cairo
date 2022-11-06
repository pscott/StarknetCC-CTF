%lang starknet

from starkware.cairo.common.bool import FALSE
from starkware.cairo.common.cairo_builtins import EcOpBuiltin, SignatureBuiltin, HashBuiltin
from starkware.starknet.common.syscalls import get_tx_info, get_caller_address
from starkware.cairo.common.signature import check_ecdsa_signature
from IAccount import IAccount

@storage_var
func _solved() -> (res: felt) {
}

@external
func solve{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr, ec_op_ptr: EcOpBuiltin*}() {
    alloc_locals;
    let (tx_info) = get_tx_info();
    let (public_key) = IAccount.get_public_key(contract_address=tx_info.account_contract_address);
    let (is_valid : felt) = check_ecdsa_signature(
        message=tx_info.transaction_hash,
        public_key=public_key,
        signature_r=tx_info.signature[0],
        signature_s=tx_info.signature[1]
    );
    assert is_valid = FALSE;
    _solved.write(1);
    return ();
}

@view
func solved{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    solved: felt
) {
    let (solved) = _solved.read();
    return (solved=solved);
}
