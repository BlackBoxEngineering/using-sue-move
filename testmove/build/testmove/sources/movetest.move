module testmove::movetest {

    use sui::object::{Self, UID};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

    struct SomeNumbers has key, store {
        id: UID,
        no1: u64,
        no2: u64,
        no3: u64,
        no4: u64,
    }

    fun init(ctx: &mut TxContext) {
        let iniSomeNumbers = SomeNumbers {
            id: object::new(ctx),
            no1: 0,
            no2: 0,
            no3: 0,
            no4: 0,
        };
        transfer::public_transfer(iniSomeNumbers, tx_context::sender(ctx));
    }

    public fun returnNumbers(args: &SomeNumbers): (u64, u64, u64, u64) {
        (args.no1, args.no2, args.no3, args.no4)
    }

    public fun createSomeNumbers(_no1: u64, _no2: u64, _no3: u64, _no4: u64, recipient: address, ctx: &mut TxContext) {
        let numbers = SomeNumbers {
            id: object::new(ctx),
            no1: _no1,
            no2: _no2,
            no3: _no3,
            no4: _no4,
        };
        transfer::transfer(numbers, recipient);
    }

    public fun sendSomeNumbers(numbers: SomeNumbers, recipient: address, _ctx: &mut TxContext) {
        transfer::public_transfer(numbers, recipient);
    }

    #[test]
    public fun test_someNumbers() {
        use sui::transfer;
        let ctx = tx_context::dummy();
        let dummy_address = @0xCAFE;
        let numbers = SomeNumbers {
            id: object::new(&mut ctx),
            no1: 1,
            no2: 2,
            no3: 3,
            no4: 4,
        };
        let (no1,no2,no3,no4) = returnNumbers(&numbers);
        assert!(no1+no2+no3+no4 == 10, 1);
        transfer::transfer(numbers, dummy_address);
    }

    #[test]
    fun test_someNumbers_transfer() {
        use sui::test_scenario;
        let admin = @0xBABE;
        let initial_owner = @0xCAFE;
        let final_owner = @0xFACE;
        let scenario_val = test_scenario::begin(admin);
        let scenario = &mut scenario_val;
        {
            init(test_scenario::ctx(scenario));
        };
        test_scenario::next_tx(scenario, admin);
        {
            createSomeNumbers(1,2,3,4, initial_owner, test_scenario::ctx(scenario));
        };
        test_scenario::next_tx(scenario, initial_owner);
        {
            let numbers = test_scenario::take_from_sender<SomeNumbers>(scenario);
            sendSomeNumbers(numbers, final_owner, test_scenario::ctx(scenario))
        };
        test_scenario::next_tx(scenario, final_owner);
        {
            let numbers = test_scenario::take_from_sender<SomeNumbers>(scenario);
            assert!(numbers.no1+numbers.no2+numbers.no3+numbers.no4 == 10, 1);
            test_scenario::return_to_sender(scenario, numbers)
        };
        test_scenario::end(scenario_val);
    }
}
