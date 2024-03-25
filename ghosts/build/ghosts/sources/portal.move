module ghosts::portal {

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct Ghost has key, store {
        id: UID,
        speed: u64,
        freakency: u64,
        intelligence: u64,
        tenebrous: u64,
    }

    struct GhostSpawn has key, store {
        id: UID,
        ghosts: u64,
    }

    fun init(ctx: &mut TxContext) {
        let admin = GhostSpawn {
            id: object::new(ctx),
            ghosts: 0,
        };
        transfer::public_transfer(admin, tx_context::sender(ctx));
    }

    public fun ghostStats(args: &Ghost): (u64, u64, u64, u64) {
        (args.speed, args.freakency, args.intelligence, args.tenebrous)
    }

    public fun spawnStats(args: &GhostSpawn): (u64) {
        args.ghosts
    }

    public fun spawnGhost(_speed: u64, _freakency: u64, _intelligence: u64, _tenebrous: u64, _recipient: address, ctx: &mut TxContext) {
        let ghost = Ghost {
            id: object::new(ctx),
            speed: _speed,
            freakency: _freakency,
            intelligence: _intelligence,
            tenebrous: _tenebrous
        };
        transfer::transfer(ghost, _recipient);
    }

    public fun transferGhost(_ghost: Ghost, _recipient: address, _ctx: &mut TxContext) {
        transfer::public_transfer(_ghost, _recipient);
    }

    public fun newGhost(_portal:&mut GhostSpawn, _speed: u64, _freakency: u64, _intelligence: u64, _tenebrous: u64, _recipient: address, _ctx: &mut TxContext) : Ghost {
        _portal.ghosts=_portal.ghosts+1;
        Ghost {
            id: object::new(_ctx),
            speed: _speed,
            freakency: _freakency,
            intelligence: _intelligence,
            tenebrous: _tenebrous
        }
    }
}