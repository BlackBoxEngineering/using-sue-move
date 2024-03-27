module payment::paidtx {

    use sui::pay;
    use std::vector;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    #[test_only]
    use sui::test_scenario;
    #[test_only]
    use sui::test_utils::assert_eq;

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
    fun merge_and_split(
        coins: vector<Coin<SUI>>, amount: u64, ctx: &mut TxContext
    ): (Coin<SUI>, Coin<SUI>) {
        let base = vector::pop_back(&mut coins);
        pay::join_vec(&mut base, coins);
        let coin_value = coin::value(&base);
        assert!(coin_value >= amount, coin_value);
        (coin::split(&mut base, amount, ctx), base)
    }
    public fun buy_object (thisContract: &mut ThisContract, ctx: &mut TxContext, asset: vector<Coin<SUI>> ): Coin<SUI>{
        let (paid, remainder) = merge_and_split(asset, thisContract.objprice, ctx);
        coin::put(&mut thisContract.balance, paid);
        let newobj = PaidForObject {
            id: object::new(ctx),
            paidBy: tx_context::sender(ctx),
        };
        transfer::public_transfer(newobj, tx_context::sender(ctx));
        remainder
    }

    public fun return_balance (thisContract: &mut ThisContract): u64{
        balance::value(&thisContract.balance)
    }

}

#[test_only]
module payment::balance_tests {
    use payment::paidtx;
    use sui::balance;
    use sui::sui::SUI;
    use sui::test_utils;

    #[test]
    fun test_balance() {
        
        let balance = balance::zero<SUI>();
        let another = balance::create_for_testing(1000);

        balance::join(&mut balance, another);

        assert!(balance::value(&balance) == 1000, 0);

        let balance1 = balance::split(&mut balance, 333);
        let balance2 = balance::split(&mut balance, 333);
        let balance3 = balance::split(&mut balance, 334);

        balance::destroy_zero(balance);

        assert!(balance::value(&balance1) == 333, 1);
        assert!(balance::value(&balance2) == 333, 2);
        assert!(balance::value(&balance3) == 334, 3);

        test_utils::destroy(balance1);
        test_utils::destroy(balance2);
        test_utils::destroy(balance3);
    }
}
