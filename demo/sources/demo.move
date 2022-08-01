module Demo::demo_app {
    use Std::signer;
    use Switchboard::Aggregator; // For reading aggregators
    use Switchboard::Math;

    const EAGGREGATOR_INFO_EXISTS:u64 = 0;
    const ENO_AGGREGATOR_INFO_EXISTS:u64 = 1;

    /*
      Num 
      {
        neg: bool,   // sign
        dec: u8,     // how many decimals value is shifted over
        value: u128, // value
      }

      where decimal = neg * value * 10^(-1 * dec) 
    */
    struct AggregatorInfo has copy, drop, store, key {
        aggregator_addr: address,
        latest_result: u128,
        latest_result_decimal: u8,
    }

    // get the latest value
    public entry fun get_latest_value(account: &signer) acquires AggregatorInfo {
        assert!(exists<AggregatorInfo>(signer::address_of(account)), ENO_AGGREGATOR_INFO_EXISTS);
        let aggregator_info = borrow_global_mut<AggregatorInfo>(signer::address_of(account));
        let (value, dec, _neg) = Math::num_unpack(Aggregator::get_latest_value(aggregator_info.aggregator_addr)); 
        aggregator_info.latest_result = value;
        aggregator_info.latest_result_decimal = dec;
    }

    // add AggregatorInfo resource with latest value + aggregator address
    public entry fun add_aggregator_info(
        account: &signer,
        aggregator_addr: address, 
    ) {       
        assert!(!exists<AggregatorInfo>(signer::address_of(account)), EAGGREGATOR_INFO_EXISTS);

        // get latest value 
        let (value, dec, _neg) = Math::num_unpack(Aggregator::get_latest_value(aggregator_addr)); 
        move_to(account, AggregatorInfo {
            aggregator_addr: aggregator_addr,
            latest_result: value,
            latest_result_decimal: dec
        });
    }    

    // update aggregator in AggregatorInfo + latest value
    public entry fun set_aggregator_info(
        account: &signer,
        aggregator_addr: address, 
    ) acquires AggregatorInfo {       
        assert!(exists<AggregatorInfo>(signer::address_of(account)), ENO_AGGREGATOR_INFO_EXISTS);
        let (value, dec, _neg) = Math::num_unpack(Aggregator::get_latest_value(aggregator_addr)); 
        let aggregator_info = borrow_global_mut<AggregatorInfo>(signer::address_of(account));
        aggregator_info.aggregator_addr = aggregator_addr;
        aggregator_info.latest_result = value;
        aggregator_info.latest_result_decimal = dec;
    }
}
