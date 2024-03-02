## halo2-private-esg

```sh
RUST_BACKTRACE=1 LOOKUP_BITS=7 cargo run --example soglife_kpi_std -- --name soglife_kpi_std --degree 16 keygen
```

```
RUST_BACKTRACE=1 LOOKUP_BITS=7 cargo run --example soglife_kpi_std -- --name soglife_kpi_std --degree 16 prove
```

```sh
RUST_BACKTRACE=1 LOOKUP_BITS=7 cargo run --example soglife_kpi_std -- --name soglife_kpi_std --degree 16 verify
```

```sh
RUST_BACKTRACE=1 LOOKUP_BITS=7 cargo run --example soglife_kpi_std -- --name soglife_kpi_std --degree 16 evm
```

```sh
RUST_BACKTRACE=1 LOOKUP_BITS=7 cargo run --example soglife_kpi_std -- --name soglife_kpi_std --degree 16 mock
```

### Test

`forge test --ffi -vvv `
`forge test --ffi -vvv --match-test=testForkedUniv3LPing`
