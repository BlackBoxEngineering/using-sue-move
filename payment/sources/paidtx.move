module payment::paidtx {

    use sui::pay;
    use std::vector;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    struct ThisContract has key, store{
        id: UID,
        admin: address,
        objprice: u64,
        balance: Balance<SUI>
    }
    struct PaidForObject has key, store{
        id: UID,
        paidBy: address,
    }
    fun init(ctx: &mut TxContext) {
        let iniMinterCap = ThisContract{id: object::new(ctx),admin: tx_context::sender(ctx),objprice: 1,balance: balance::zero()};
        transfer::transfer(iniMinterCap, tx_context::sender(ctx));
    }
    public fun buy_object (recipient: address, thisContract: &mut ThisContract, ctx: &mut TxContext, asset: vector<Coin<SUI>> ): Coin<SUI>{
        let (paid, remainder) = exchanged_amounts(asset, thisContract.objprice, ctx);
        coin::put(&mut thisContract.balance, paid);
        let newobj = PaidForObject {
            id: object::new(ctx),
            paidBy: tx_context::sender(ctx),
        };
        transfer::transfer(newobj, recipient);
        remainder
    }
    public fun return_balance (thisContract: &mut ThisContract): u64{
        balance::value(&thisContract.balance)
    }
    fun exchanged_amounts(coins: vector<Coin<SUI>>, coins_payment: u64, ctx: &mut TxContext): (Coin<SUI>, Coin<SUI>) {
        let coins_in_hand = vector::pop_back(&mut coins);
        pay::join_vec(&mut coins_in_hand, coins);
        let coin_value = coin::value(&coins_in_hand);
        assert!(coin_value >= coins_payment, coin_value);
        (coin::split(&mut coins_in_hand, coins_payment, ctx), coins_in_hand)
    }
    #[test_only]
    use sui::test_scenario;
    #[test_only]
    use sui::test_utils::assert_eq;
    #[test]
    fun test_init_success() {
        let module_owner = @0xa;
        let scenario_val = test_scenario::begin(module_owner);
        let scenario = &mut scenario_val;
        {
            init(test_scenario::ctx(scenario));
        };
        let tx = test_scenario::next_tx(scenario, module_owner);
        let expected_events_emitted = 0;
        let expected_created_objects = 1;
        assert_eq(test_scenario::num_user_events(&tx), expected_events_emitted);
        assert_eq(vector::length(&test_scenario::created(&tx)),expected_created_objects);
        {
            let this_contract = test_scenario::take_from_sender<ThisContract>(scenario);
            assert_eq(balance::value(&this_contract.balance), 0);
            test_scenario::return_to_sender(scenario, this_contract);
        };
        test_scenario::end(scenario_val);
    }
}