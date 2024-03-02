use axiom_eth::keccak::KeccakChip;
use axiom_eth::EthChip;
use axiom_eth::Field;
use clap::Parser;
use ethers::providers::{Http, Middleware, Provider};
use ethers_core::types::{Address, BlockId, BlockNumber, H160, H256, U256, U64};
use ethers_core::utils::keccak256;
use halo2_base::gates::GateChip;
use halo2_base::gates::GateInstructions;

use halo2_base::safe_types::RangeInstructions;
use halo2_base::utils::{BigPrimeField, ScalarField};
use halo2_base::AssignedValue;
use halo2_base::Context;
use halo2_base::QuantumCell::Constant;
use halo2_scaffold::gadget::fixed_point::{FixedPointChip, FixedPointInstructions};
use halo2_scaffold::scaffold::cmd::Cli;
use halo2_scaffold::scaffold::run_eth_builder_on_inputs;
use halo2_scaffold::scaffold::{run, run_builder_on_inputs};
use num_bigint::BigUint;
use num_traits::FromPrimitive;
use poseidon::PoseidonChip;
use serde::{Deserialize, Serialize};
#[allow(unused_imports)]
use std::env::{set_var, var};

const N: usize = 4;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct CircuitInput {
    pub x: Vec<f64>,
}

fn some_algorithm_in_zk<F: Field>(
    ctx: &mut Context<F>,
    input: CircuitInput,
    make_public: &mut Vec<AssignedValue<F>>,
) {
    const PRECISION_BITS: u32 = 63;
    let lookup_bits =
        var("LOOKUP_BITS").unwrap_or_else(|_| panic!("LOOKUP_BITS not set")).parse().unwrap();
    let fpc = FixedPointChip::<F, PRECISION_BITS>::default(lookup_bits);

    let zero = ctx.load_constant(F::from_u128(0u128));

    let fp_kpis = (0..N)
        .map(|i| {
            let x = fpc.quantization(input.x[i]);
            println!("64x64 FP: x[{i}]={x:?}");
            let x = ctx.load_witness(x);
            x
        })
        .collect::<Vec<AssignedValue<F>>>();

    let sum = fp_kpis.iter().fold(zero, |acc, x| fpc.qadd(ctx, acc, *x));
    println!("Sum {:?}", fpc.dequantization(*sum.value()));

    let len = ctx.load_constant(fpc.quantization(N as f64));
    let mean: AssignedValue<F> = fpc.qdiv(ctx, sum, len);

    println!("Diff");
    let sq_diff = fp_kpis
        .clone()
        .into_iter()
        .map(|x| {
            let diff = fpc.qsub(ctx, x, mean);
            let diff_2 = fpc.qmul(ctx, diff, diff);
            println!("{:?}", fpc.dequantization(*diff_2.value()));
            diff_2
        })
        .collect::<Vec<AssignedValue<F>>>();
    let sq_diff_sum = sq_diff.iter().fold(zero, |acc, x| fpc.qadd(ctx, acc, *x));
    let avg_sq_diff_sum = fpc.qdiv(ctx, sq_diff_sum, len);
    let std = fpc.qsqrt(ctx, avg_sq_diff_sum);
    make_public.push(std);

    println!("std {:?} ({:?})", fpc.dequantization(*std.value()), std.value());
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();
    let args: Cli = Cli::parse();

    let input = CircuitInput { x: vec![0.5, 0.6, 0.7, 0.8] };

    run_builder_on_inputs(
        |builder, input, public| some_algorithm_in_zk(builder.main(0), input, public),
        args,
        input,
    );

    Ok(())
}
