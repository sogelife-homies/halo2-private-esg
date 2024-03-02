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
const T: usize = 3;
const RATE: usize = 2;
const R_F: usize = 8;
const R_P: usize = 57;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct CircuitInput {
    pub x: Vec<f64>,
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct CircuitInput2 {
    pub bytes: Vec<u8>,
}

fn compute_fixed_len_keccak<F: Field>(
    ctx: &mut Context<F>,
    eth_chip: &EthChip<F>,
    keccak: &mut KeccakChip<F>,
    input: CircuitInput,
    make_public: &mut Vec<AssignedValue<F>>,
) -> impl FnOnce(&mut Context<F>, &mut Context<F>, &EthChip<F>) + Clone {
    // the output is a callback function, just take this trait for granted
    const PRECISION_BITS: u32 = 63;
    let lookup_bits =
        var("LOOKUP_BITS").unwrap_or_else(|_| panic!("LOOKUP_BITS not set")).parse().unwrap();
    let fpc = FixedPointChip::<F, PRECISION_BITS>::default(lookup_bits);

    let zero = ctx.load_constant(F::from_u128(0u128));
    // fixed-point exp arithmetic

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
    println!("std {:?}", fpc.dequantization(*std.value()));

    // load the input
    let bytes = ctx.assign_witnesses(fp_kpis.iter().map(|b| F::to_be_bytes(b)));
    // `EthChip` contains `RangeChip`, `Gate`
    let range = eth_chip.range();
    // Expose input as public inputs, range check each to be 8 bits
    for byte in &bytes {
        make_public.push(*byte);
        range.range_check(ctx, *byte, 8);
    }

    // Compute keccak hash of the input bytes (this only does witness generation, it does **not** constrain the computation yet)
    let hash_idx = keccak.keccak_fixed_len(ctx, range.gate(), bytes, None);
    // this only returns an index of the output in some "keccak table" (mostly for technical reasons)
    // to get the value, we have to fetch:
    let out_bytes = keccak.fixed_len_queries[hash_idx].output_assigned.clone();
    assert_eq!(out_bytes.len(), 32);
    for byte in &out_bytes {
        make_public.push(*byte);
    }

    // Just for display purposes, print the output as hex string:
    print!("Output: ");
    for b in &out_bytes {
        print!("{:02x}", b.value().get_lower_32() as u8);
    }
    println!();
    // Assert the output is correct
    let out_expected = keccak256(input.bytes);
    for (b1, b2) in out_bytes.into_iter().zip(out_expected) {
        assert_eq!(b1.value().get_lower_32(), b2 as u32);
    }

    // Here's the tricky part: you MUST provide a callback function (as a closure) for what to do in SecondPhase of the Challenge API
    // This includes any function that requires using the random challenge value

    // For Keccak, this function is empty because we fill it in for you behind the scenes. ONLY in the SecondPhase is the keccak computation above actually constrained.
    #[allow(clippy::let_and_return)]
    let callback =
        |_ctx_gate: &mut Context<F>, _ctx_rlc: &mut Context<F>, _eth_chip: &EthChip<F>| {};

    callback
}

fn some_algorithm_in_zk<F: Field>(
    ctx: &mut Context<F>,
    eth_chip: &EthChip<F>,
    keccak: &mut KeccakChip<F>,
    input: CircuitInput,
    make_public: &mut Vec<AssignedValue<F>>,
) {
    const PRECISION_BITS: u32 = 63;
    let lookup_bits =
        var("LOOKUP_BITS").unwrap_or_else(|_| panic!("LOOKUP_BITS not set")).parse().unwrap();
    let fpc = FixedPointChip::<F, PRECISION_BITS>::default(lookup_bits);

    let zero = ctx.load_constant(F::from_u128(0u128));
    // fixed-point exp arithmetic

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
    println!("std {:?}", fpc.dequantization(*std.value()));

    let mut poseidon = PoseidonChip::<F, T, RATE>::new(ctx, R_F, R_P).unwrap();
    poseidon.update(&[fp_kpis[0], fp_kpis[1]]);
    let gate = GateChip::<F>::default();

    let hash = poseidon.squeeze(ctx, &gate).unwrap();
    make_public.push(hash);
    println!("poseidon(x): {:?}", hash.value());
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::init();
    let args: Cli = Cli::parse();

    let input = CircuitInput { x: vec![0.5, 0.6, 0.7, 0.8] };
    let input2 = CircuitInput2 { bytes: vec![1, 2, 3, 4] };
    run_eth_builder_on_inputs(
        |builder, chip, keccak, input, public| {
            compute_fixed_len_keccak(builder.main(0), chip, keccak, input, public)
        },
        args,
        input2,
    );

    Ok(())
}
