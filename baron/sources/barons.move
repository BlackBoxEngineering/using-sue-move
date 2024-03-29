module baron::barons {

    use sui::sui::SUI;
    use sui::transfer;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    struct GrowShop has key {
        id: UID,
        sales: Balance<Coin<SUI>>,
    }

    struct LightsLED has key, store {
        id: UID
    }

    fun init(ctx: &mut TxContext){
        let ini_growshop = GrowShop{id:  object::new(ctx),sales: balance::zero()};
        transfer::transfer(ini_growshop, tx_context::sender(ctx));
    }

    public fun buy_leds( payment: Coin<SUI>, shop: &mut GrowShop, ctx: &mut TxContext) {

        let price_leds: u64 = 1;
        let buyers_coin_value: coin::value(payment, ctx);

    }
}
