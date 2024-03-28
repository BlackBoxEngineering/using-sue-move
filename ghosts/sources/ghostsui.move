module ghosts::ghostsui {

    use sui::url::{Self, Url};
    use std::string;
    use sui::object::{Self, ID, UID};
    use sui::event;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct Ghost has key, store {
        id: UID,
        name: string::String,
        description: string::String,
        url: Url,
        speed: u64,
        freakency: u64,
        intelligence: u64,
        tenebrous: u64
    }

    struct SpawnGhost has copy, drop {
        object_id: ID,
        creator: address,
        name: string::String,
        speed: u64,
        freakency: u64,
        intelligence: u64,
        tenebrous: u64
    }

    public entry fun mint(name: vector<u8>,description: vector<u8>,url: vector<u8>,ctx: &mut TxContext) {
        let nft = Ghost {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
            speed: 1,
            freakency: 1,
            intelligence: 1,
            tenebrous: 1
        };
        let sender = tx_context::sender(ctx);
        event::emit(SpawnGhost {
            object_id: object::uid_to_inner(&nft.id),
            creator: sender,
            name: nft.name,
            speed: 1,
            freakency: 1,
            intelligence: 1,
            tenebrous: 1
        });
        transfer::public_transfer(nft, sender);
    }

    public entry fun update_description(
        nft: &mut Ghost,
        new_description: vector<u8>,
    ) {
        nft.description = string::utf8(new_description)
    }

    public entry fun burn(nft: Ghost) {
        let Ghost { id, name: _, description: _, url: _, speed: _,freakency: _,intelligence: _,tenebrous: _ } = nft;
        object::delete(id)
    }

    public fun name(nft: &Ghost): &string::String {
        &nft.name
    }

    public fun description(nft: &Ghost): &string::String {
        &nft.description
    }

    public fun stats(nft: &Ghost): (u64, u64, u64, u64) {
        (nft.speed,nft.freakency,nft.intelligence,nft.tenebrous)
    }

    public fun url(nft: &Ghost): &Url {
        &nft.url
    }
}

#[test_only]
module ghosts::ghosttests {
    use ghosts::ghostsui::{Self, Ghost};
    use sui::test_scenario as ts;
    use sui::transfer;
    use std::string;

    #[test]
    fun mint_transfer_update() {
        let addr1 = @0xA;
        let addr2 = @0xB;
        // create the NFT
        let scenario = ts::begin(addr1);
        {
            ghostsui::mint(b"test", b"a test", b"https://www.sui.io", ts::ctx(&mut scenario))
        };
        // send it from A to B
        ts::next_tx(&mut scenario, addr1);
        {
            let nft = ts::take_from_sender<Ghost>(&scenario);
            transfer::public_transfer(nft, addr2);
        };
        // update its description
        ts::next_tx(&mut scenario, addr2);
        {
            let nft = ts::take_from_sender<Ghost>(&scenario);
            ghostsui::update_description(&mut nft, b"a new description") ;
            assert!(*string::bytes(ghostsui::description(&nft)) == b"a new description", 0);
            ts::return_to_sender(&scenario, nft);
        };
        // burn it
        ts::next_tx(&mut scenario, addr2);
        {
            let nft = ts::take_from_sender<Ghost>(&scenario);
            ghostsui::burn(nft)
        };
        ts::end(scenario);
    }
}