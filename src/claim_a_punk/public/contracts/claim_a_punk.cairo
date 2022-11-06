// SPDX-License-Identifier: MIT

// @author Gershon Ballas <gershon@gingerlabs.xyz>

// This contract allows whitelisted users to call `claim()` which will mint a punk NFT for them
// Each whitelisted user is allowed to mint just one time
// The contract owner is the only one who can whitelist addresses

%lang starknet
%builtins pedersen range_check

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_add
from starkware.cairo.common.math import assert_not_zero
from starkware.starknet.common.syscalls import get_caller_address, get_contract_address, deploy

const TRUE = 1;
const FALSE = 0;

@contract_interface
namespace IERC721Mintable {
    func mint(to: felt, tokenId: Uint256) {
    }
}

// Contract owner
@storage_var
func _owner_address() -> (owner_address: felt) {
}

// Token counter (initialized to 0, incremented for every punk minted)
@storage_var
func _token_counter() -> (count: Uint256) {
}

// NFT contract implementation hash
@storage_var
func _nft_class_hash() -> (hash: felt) {
}

// NFT contract representing punks
@storage_var
func _punks_nft_address() -> (address: felt) {
}

// TRUE or FALSE whether user with given address is whitelisted (i.e. able to claim a punk)
@storage_var
func _whitelisted_users(address: felt) -> (whitelisted: felt) {
}

// TRUE or FALSE whether user with given address already claimed a punk
@storage_var
func _claimers(address: felt) -> (claimed: felt) {
}

@constructor
func constructor{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    nft_class_hash: felt, owner: felt
) {
    // Set NFT implementation class hash field
    assert_not_zero(nft_class_hash);
    _nft_class_hash.write(nft_class_hash);

    // Create punk NFT collection
    let (punks_nft_address: felt) = _deploy_punks_nft_contract_instance();
    _punks_nft_address.write(punks_nft_address);

    // Set `owner` field
    _owner_address.write(owner);

    return ();
}

func _deploy_punks_nft_contract_instance{
    syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr
}() -> (contract_address: felt) {
    let (this_contract_address) = get_contract_address();
    let (nft_class_hash) = _nft_class_hash.read();
    let (contract_address) = deploy(
        class_hash=nft_class_hash,
        contract_address_salt=0,
        constructor_calldata_size=3,
        constructor_calldata=cast(new ('Punks', 'PUNK', this_contract_address,), felt*),
        deploy_from_zero=FALSE,
    );

    return (contract_address=contract_address);
}

@view
func getNftClassHash{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    hash: felt
) {
    let (hash) = _nft_class_hash.read();
    return (hash=hash);
}

@view
func getPunksNftAddress{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (
    address: felt
) {
    let (address) = _punks_nft_address.read();
    return (address=address);
}

@view
func isWhitelisted{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    address: felt
) -> (result: felt) {
    let (result) = _whitelisted_users.read(address);

    return (result=result);
}

@view
func owner{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}() -> (address: felt) {
    let (address) = _owner_address.read();
    return (address=address);
}

// Add user address to whitelist (allowing user to mint a punk
// Only this contract's owner may call this func
@external
func whitelist{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(address: felt) -> (
    ) {
    // Assert caller is owner
    let (caller_address) = get_caller_address();
    let (owner_address) = _owner_address.read();
    with_attr error_message("Only owner may call this function!") {
        assert caller_address = owner_address;
    }

    // Add given address to whitelist
    _whitelisted_users.write(address=address, value=TRUE);

    return ();
}

// Transfer your whitelist spot to a different address
@external
func transferWhitelistSpot{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(
    to: felt
) -> () {
    // Assert caller is whitelisted
    let (caller_address) = get_caller_address();
    with_attr error_message("Caller is not whitelisted") {
        let (is_caller_whitelisted: felt) = _whitelisted_users.read(caller_address);
        assert is_caller_whitelisted = TRUE;
    }

    // Assert `to` address is not already whitelisted
    with_attr error_message("`to` address is already whitelisted") {
        let (is_to_whitelisted: felt) = _whitelisted_users.read(to);
        assert is_to_whitelisted = FALSE;
    }

    // Remove caller address from whitelist
    _whitelisted_users.write(address=caller_address, value=FALSE);

    // Remove caller from _claimers mapping
    _claimers.write(address=caller_address, value=FALSE);

    // Add `to` address to whitelist
    _whitelisted_users.write(address=to, value=TRUE);

    // Add `to` address to _claimers mapping
    _whitelisted_users.write(address=to, value=TRUE);

    return ();
}

// If calling user is whitelisted and still hasn't claimed their punk, mint a punk for them
@external
func claim{syscall_ptr: felt*, pedersen_ptr: HashBuiltin*, range_check_ptr}(to: felt) -> () {
    // Assert caller is whitelisted
    let (caller_address) = get_caller_address();
    with_attr error_message("Caller is not whitelisted to mint a punk") {
        let (is_caller_whitelisted: felt) = _whitelisted_users.read(caller_address);
        assert is_caller_whitelisted = TRUE;
    }

    // Assert caller hasn't already claimed a punk
    with_attr error_message("Caller already claimed a punk") {
        let (caller_already_claimed: felt) = _claimers.read(caller_address);
        assert caller_already_claimed = FALSE;
    }

    // Increment token ID counter
    let (token_id) = _token_counter.read();
    let (new_token_counter, overflow) = uint256_add(token_id, Uint256(1, 0));
    with_attr error_message("Token ID overflow uint256, this should never happen") {
        assert overflow = FALSE;
    }
    _token_counter.write(new_token_counter);

    // Mint a punk for caller
    let (punks_contract_address) = _punks_nft_address.read();
    IERC721Mintable.mint(contract_address=punks_contract_address, to=to, tokenId=token_id);

    // Mark caller as having claimed a punk
    _claimers.write(address=caller_address, value=TRUE);

    return ();
}
