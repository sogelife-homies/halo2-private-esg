## axiom-univ3-mm

LOOKUP_BITS=14 cargo run --example fixed_point -- --name fixed_point --degree 15 mock

### Test

`forge test --ffi -vvv --match-test=testDummyStrat`

### TODO

- Restructure the repo.Top level dirs should be halo2-lib, contracts, axiom-sdk
