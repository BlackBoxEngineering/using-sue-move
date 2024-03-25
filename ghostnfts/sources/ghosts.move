module ghostnfts::portal {

    use sui::url::{Self, Url};
    use std::string;
    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    const MAX_SUPPLY: u64 = 333;
    const ERROR_NO_SUPPLY: u64 = 1;

    struct Ghosts has key { 
        id: UID, 
        summoned: u64 
    }

    struct Ghost has key, store {
        id: UID,
        name: string::String,
        description: string::String,
        url: Url,
        speed: u64,
        freakency: u64,
        intelligence: u64,
        tenebrous: u64,
        spawn: u64
    }

    fun init(ctx: &mut TxContext) { 
        let ghosts = Ghosts { id: object::new(ctx), summoned: 0, }; 
        transfer::transfer(ghosts, tx_context::sender(ctx)) 
    }

    public entry fun mint(ghosts: &mut Ghosts, name: vector<u8>,description: vector<u8>,url: vector<u8>, receiver: address, ctx: &mut TxContext) {
        let ghostNo = ghosts.summoned;
        assert!(ghostNo < MAX_SUPPLY, ERROR_NO_SUPPLY); 
        let nft = Ghost {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
            speed: 1,
            freakency: 1,
            intelligence: 1,
            tenebrous: 1,
            spawn: ghostNo
        }; 
        ghosts.summoned = ghostNo + 1; 
        transfer::transfer(nft, receiver); 
    }

    public entry fun burn(nft: Ghost) {
        let Ghost { id, name: _, description: _, url: _, speed: _,freakency: _,intelligence: _,tenebrous: _,spawn: _} = nft;
        object::delete(id)
    }

    public fun description(nft: &Ghost): &string::String {&nft.description}
    public entry fun updateDescription(nft: &mut Ghost,_description: vector<u8>,) {nft.description = string::utf8(_description)}

    public fun stats(nft: &Ghost): (u64, u64, u64, u64) {(nft.speed,nft.freakency,nft.intelligence,nft.tenebrous)}
    public entry fun updateStats(nft: &mut Ghost,_speed: u64,_freakency: u64,_intelligence: u64,_tenebrous: u64) {
        nft.speed = _speed;
        nft.freakency = _freakency;
        nft.intelligence = _intelligence;
        nft.tenebrous = _tenebrous;
    }

    public fun name(nft: &Ghost): &string::String {&nft.name}
    public fun url(nft: &Ghost): &Url {&nft.url}
}