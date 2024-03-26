module tryingmove::moving {

  use sui::sui::SUI;
  use sui::transfer;
  use sui::url::{Self, Url};
  use sui::coin::{Self, Coin};
  use std::string::{Self, String};
  use sui::object::{Self, UID, ID};
  use sui::balance::{Self, Balance};
  use sui::tx_context::{Self, TxContext};

  struct SomeData has key, store {
    id: UID,
    name: String,
    description: String,
    image: Url,
  }

  public fun tryingmovefn(
    recipient: address,
    nft_name: vector<u8>,
    nft_description: vector<u8>,
    nft_image: vector<u8>,
    payment_coin: &mut Coin<SUI>,
    minter_cap: &mut MinterCap,
    ctx: &mut TxContext,
    treasury_cap: &mut TreasuryCap<SUI>,
  ): Coin<SUI> {
    let payment_amount = coin::value(payment_coin);
    assert!(payment_amount >= 1, EInsufficientPayment);

    // Initialize change_coin and conditionally assign its value
    let change_coin: Coin<SUI>;
    if (payment_amount > 1) {
      let change_amount = payment_amount - 1;
      change_coin = coin::split(payment_coin, change_amount, ctx);
    } else {
      change_coin = coin::zero(ctx);
    };

    let nft = NonFungibleToken {
      id: object::new(ctx),
      name: string::utf8(nft_name),
      description: string::utf8(nft_description),
      image: url::new_unsafe_from_bytes(nft_image),
    };

    // Increase the sales balance by 1 SUI.
    let sales_increase = coin::mint(treasury_cap, 1, ctx);
    let sales_increase_balance = coin::into_balance(sales_increase);
    balance::join(&mut minter_cap.sales, sales_increase_balance);

    // Correctly transfer the NFT to the recipient
    event::emit(NonFungibleTokenMinted { nft_id: object::id(&nft), recipient: recipient });
    transfer::transfer(nft, recipient);

    change_coin  // Return the change coin
  }
