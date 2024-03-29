module problem::myproblem {

    use std::vector;
    use sui::sui::SUI;
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    struct Item has key, store {
        id: UID,
    }

    struct Shop has key {
        id: UID,
        item_price: u64,
        balance: Balance<SUI>,
    }
    
    fun init(ctx: &mut TxContext) {
        let shop_start = Shop{id: object::new(ctx),item_price: 1,balance: balance::zero()};
        transfer::transfer(shop_start, tx_context::sender(ctx));
    }

    public fun sell_item (the_buyer: address, the_coin: &mut Coin<SUI>,the_shop: &mut Shop,ctx: &mut TxContext,) : Coin<SUI> {
        
        let coin_value = coin::value(the_coin);
        assert!(coin_value >= the_shop.item_price, 99);

        let coin_balance = coin::balance_mut(the_coin);
        balance::join(&mut the_shop.balance, balance::split(coin_balance, the_shop.item_price));

        let new_item = Item {id: object::new(ctx)};
        transfer::transfer(new_item,the_buyer);

        let return_coin: Coin<SUI> = coin::take(coin_balance, (coin_value-the_shop.item_price),ctx);
        transfer::transfer(return_coin, tx_context::sender(ctx));

        return return_coin
    }

   #[test_only]
    use sui::test_scenario;
    #[test_only]
    use sui::test_utils::assert_eq;
    #[test]

    fun test_sell() {
        let module_owner = @0xa;
        let the_buyer = @0xb;
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
        let coin_in = 1000000000;
        let coin_out = 0;
        {
            let the_coin = sui::coin::mint_for_testing<SUI>(coin_in + coin_out,test_scenario::ctx(scenario));
            let the_shop = test_scenario::take_from_sender<Shop>(scenario);
            sell_item(the_buyer, &mut the_coin,&mut the_shop,test_scenario::ctx(scenario));
            assert_eq(coin::value(&the_coin), coin_out);
            coin::burn_for_testing(the_coin);
            test_scenario::return_to_sender(scenario, the_shop);
        };
        let tx = test_scenario::next_tx(scenario, the_buyer);
        let expected_events_emitted = 1;
        let expected_created_objects = 1;
        assert_eq(test_scenario::num_user_events(&tx), expected_events_emitted);
        assert_eq(vector::length(&test_scenario::created(&tx)),expected_created_objects);
        {
            let item = test_scenario::take_from_sender<Item>(scenario);
            test_scenario::return_to_sender(scenario, item);
        };
        test_scenario::end(scenario_val);
    }
}