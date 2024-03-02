## halo2-private-esg

RUST_BACKTRACE=1 LOOKUP_BITS=7 cargo run --example soglife_kpi_std -- --name soglife_kpi_std --degree 16 keygen
RUST_BACKTRACE=1 LOOKUP_BITS=7 cargo run --example soglife_kpi_std -- --name soglife_kpi_std --degree 16 prove
RUST_BACKTRACE=1 LOOKUP_BITS=7 cargo run --example soglife_kpi_std -- --name soglife_kpi_std --degree 16 verify
RUST_BACKTRACE=1 LOOKUP_BITS=7 cargo run --example soglife_kpi_std -- --name soglife_kpi_std --degree 16 evm
RUST_BACKTRACE=1 LOOKUP_BITS=7 cargo run --example soglife_kpi_std -- --name soglife_kpi_std --degree 16 mock

### Test

`forge test --ffi -vvv `
`forge test --ffi -vvv --match-test=testForkedUniv3LPing`
