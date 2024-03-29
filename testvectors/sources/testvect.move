module testvectors::testvect {

    use std::vector;
    use sui::transfer;
    use sui::sui::SUI;
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::tx_context::{Self, TxContext};

    struct AdminObject has key {
        id: UID,
        operation: u64,
        balance: Balance<SUI>,
        members: vector<MemberObject>
    }

    struct MemberObject has key, store{
        id: UID,
    }

    fun init(ctx: &mut TxContext) {
        let ini_admin_object = AdminObject{
            id: object::new(ctx),
            operation: 0,
            balance: balance::zero(),
            members: vector::empty()
        };
        transfer::transfer(ini_admin_object, tx_context::sender(ctx));
    }

    #[test]
    fun test_init_success() {
        let module_owner = @0xa;
        let scenario_val = test_scenario::begin(module_owner);
        let scenario = &mut scenario_val;
        {
            init(test_scenario::ctx(scenario));
        };
        let tx = test_scenario::next_tx(scenario, module_owner);

        let expected_created_objects: u8 = 1;
        let expected_events_emitted: u8 = 0;

        let expected_operation: u8 = 0;
        let expected_balance: u8 = 0;

        let member_object = test_scenario::take_from_sender<MemberObject>(scenario);
        //let expected_members = vector<member_object>;
        
        assert_eq(test_scenario::num_user_events(&tx), expected_events_emitted);
        assert_eq(vector::length(&test_scenario::created(&tx)),expected_created_objects);
        {
            let admin_object = test_scenario::take_from_sender<AdminObject>(scenario);
            assert_eq(&admin_object.operation, expected_operation);
            assert_eq(balance::value(&admin_object.balance), expected_balance);
            //assert_eq(&admin_object.members, expected_members);
            test_scenario::return_to_sender(scenario, admin_object);
        };
        test_scenario::end(scenario_val);
    }

}