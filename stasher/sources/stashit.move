// Self teaching SUI MOVE

module payment::stashit {

    use sui::pay;
    use std::vector;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    use std::debug;

    struct Stasher has key {
        id: UID,
        admin: address,
        objprice: u64,
        balance: Balance<SUI>
    }

    struct Piggybank has key, store{
        id: UID,
        paid_by: address,
        balance_out: Balance<SUI>
    }

    const ENotEnoughBalanceForSplit: u64 = 0;

    fun init(ctx: &mut TxContext) {
        let iniMinterCap = Stasher{id: object::new(ctx),admin: tx_context::sender(ctx),objprice: 1,balance: balance::zero()};
        transfer::transfer(iniMinterCap, tx_context::sender(ctx));
    }

    public fun stash_value (recipient: address, thisContract: &mut Stasher, ctx: &mut TxContext, coins_payment: vector<Coin<SUI>> ): u64{
        let (coin_one, coin_two) = split_coin_in_two(coins_payment, thisContract.objprice, ctx);
        coin::put(&mut thisContract.balance, coin_one);
        let newobj = Piggybank {
            id: object::new(ctx),
            paid_by: tx_context::sender(ctx),
            balance_out: coin::into_balance(coin_two)
        };
        let value_stashed: u64 = balance::value(&newobj.balance_out);
        transfer::public_transfer(newobj, recipient);
        debug::print(&value_stashed);
        value_stashed
    }

    public fun return_balance (thisContract: &mut Stasher): u64{
        balance::value(&thisContract.balance)
    }

    fun split_coin_in_two(coin_to_split: vector<Coin<SUI>>, coin_one_amount: u64, ctx: &mut TxContext): (Coin<SUI>, Coin<SUI>) {
        let coins_in_hand = vector::pop_back(&mut coin_to_split);
        pay::join_vec(&mut coins_in_hand, coin_to_split);
        let coin_value = coin::value(&coins_in_hand);
        assert!(coin_value >= coin_one_amount, ENotEnoughBalanceForSplit);
        let payment_coin = coin::split(&mut coins_in_hand, coin_one_amount, ctx);
        (payment_coin, coins_in_hand)
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
            let this_contract = test_scenario::take_from_sender<Stasher>(scenario);
            assert_eq(balance::value(&this_contract.balance), 0);
            test_scenario::return_to_sender(scenario, this_contract);
        };
        test_scenario::end(scenario_val);
    }
}