module examples::donuts {
    use sui::transfer;
    use sui::sui::SUI;
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    // For when Coin balance is too low.
    const ENotEnough: u64 = 0;

    // Capability that grants an owner the right to collect profits.
    struct ShopOwnerCap has key {
        id: UID
    }

    // A purchasable Donut (ignoring implementation details).
    struct Donut has key {
        id: UID
    }

    // A shared object (requires the `key` ability).
    struct DonutShop has key {
        id: UID,
        price: u64,
        balance: Balance<SUI>
    }

    // Init function (called only once) to initialize the shared object.
    fun init(ctx: &mut TxContext) {
        transfer::transfer(ShopOwnerCap { id: object::new(ctx) }, tx_context::sender(ctx));
        transfer::share_object(DonutShop { id: object::new(ctx), price: 1000, balance: balance::zero() })
    }

    // Entry function for buying a donut.
    public fun buy_donut(shop: &mut DonutShop, payment: &mut Coin<SUI>, ctx: &mut TxContext) {
        assert!(coin::value(payment) >= shop.price, ENotEnough);
        let coin_balance = coin::balance_mut(payment);
        let paid = balance::split(coin_balance, shop.price);
        balance::join(&mut shop.balance, paid);
        transfer::transfer(Donut { id: object::new(ctx) }, tx_context::sender(ctx))
    }

    // Consume a donut (and get nothing in return).
    public fun eat_donut(d: Donut) {
        let Donut { id } = d;
        object::delete(id);
    }

    // Collect profits from DonutShop and transfer them to the sender.
    public fun collect_profits(_: &ShopOwnerCap, shop: &mut DonutShop, ctx: &mut TxContext) {
        let amount = balance::value(&shop.balance);
        let profits = coin::take(&mut shop.balance, amount, ctx);
        transfer::public_transfer(profits, tx_context::sender(ctx))
    }
}


    public fun mint_nft(
        receiver: address, 
        name: vector<u8>, 
        desc: vector<u8>, 
        url: vector<u8>,
        paymentcoin: &mut Coin<SUI>,
        mintcontrol: &mut MinterControll,
        ctx: &mut TxContext, 
    ) {

        let issueNo = mintcontrol.issued;
        assert!(issueNo + 1 <= MaximumSupply || MaximumSupply == 0, EInsufficientSupply);
        assert!(paymentcoin::value(payment) >= tempGasBudget + MintingFee, EInsufficientPayment);

        let change = paymentcoin::value(payment) - tempGasBudget + MintingFee;

        let newNft = NonFungibleToken {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(desc),
            url: url::new_unsafe_from_bytes(url),
        }; 
        
        mintcontrol.issued = issueNo + 1; 

        transfer::transfer(change, ctx.sender);
        transfer::transfer(newNft, recipient); 
    }