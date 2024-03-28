module testvectors::testvect {

    use std::vector;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    struct Vault has key {
        id: UID,
        operation: u64,
        balance: Balance<SUI>,
    }

    fun init(ctx: &mut TxContext) {
        let ini_vault = Vault{id: object::new(ctx),operation: 0, balance: balance::zero()};
        transfer::transfer(ini_vault, tx_context::sender(ctx));
    }

}