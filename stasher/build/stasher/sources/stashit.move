// Self teaching SUI MOVE

module stasher::stashit {

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
        stasher_price: u64,
        stasher_balance: Balance<SUI>
    }

    struct Piggybank has key, store{
        id: UID,
        stashed_by: address,
        balance_stashed: Balance<SUI>
    }

    const ENotEnoughBalanceForSplit: u64 = 0;

    fun init(ctx: &mut TxContext) {
        let iniMinterCap = Stasher{id: object::new(ctx),admin: tx_context::sender(ctx),stasher_price: 1,stasher_balance: balance::zero()};
        transfer::transfer(iniMinterCap, tx_context::sender(ctx));
    }

    public fun stash_value (recipient: address, stash: &mut Stasher, ctx: &mut TxContext, coin_in: vector<Coin<SUI>> ): u64{
        let (coin_one, coin_two) = split_coin_in_two(coin_in, stash.stasher_price, ctx);
        coin::put(&mut stash.stasher_balance, coin_two);
        let newobj = Piggybank {
            id: object::new(ctx),
            stashed_by: tx_context::sender(ctx),
            balance_stashed: coin::into_balance(coin_one)
        };
        debug::print(&newobj);
        let value_stashed: u64 = balance::value(&newobj.balance_stashed);
        transfer::public_transfer(newobj, recipient);
        debug::print(&value_stashed);
        value_stashed
    }

    public fun return_balance (stash: &mut Stasher): u64{
        balance::value(&stash.stasher_balance)
    }

    fun split_coin_in_two(split_coin: vector<Coin<SUI>>, amount: u64, ctx: &mut TxContext): (Coin<SUI>, Coin<SUI>) {
        let coin_one = vector::pop_back(&mut split_coin);
        pay::join_vec(&mut coin_one, split_coin);
        let coin_one_value = coin::value(&coin_one);
        assert!(coin_one_value >= amount, ENotEnoughBalanceForSplit);
        let coin_two = coin::split(&mut coin_one, amount, ctx);
        debug::print(&coin_one);
        debug::print(&coin_two);
        (coin_one, coin_two)
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
            let stasher = test_scenario::take_from_sender<Stasher>(scenario);
            assert_eq(balance::value(&stasher.stasher_balance), 0);
            test_scenario::return_to_sender(scenario, stasher);
        };
        test_scenario::end(scenario_val);
    }
}