module moved::paidtx {

    use sui::pay;
    use sui::event;
    use std::vector;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use std::string::{Self, String};
    use sui::object::{Self, UID, ID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    struct ThisContract has key, store{
        id: UID,
        admin: address,
        balance: Balance<SUI>
    }

    const PRICE: coin::Coin<SUI>

    fun init(ctx: &mut TxContext) {
        let iniMinterCap = ThisContract{id: object::new(ctx),admin: tx_context::sender(ctx),balance: balance::zero()};
        transfer::transfer(iniMinterCap, tx_context::sender(ctx));
    }

    public fun deposit_balance (_thisContract: &mut ThisContract, _ctx: &mut TxContext, ) 

    

}