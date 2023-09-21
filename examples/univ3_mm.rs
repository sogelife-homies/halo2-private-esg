use clap::Parser;
use halo2_base::gates::GateInstructions;
use halo2_base::safe_types::RangeInstructions;
use halo2_base::utils::{BigPrimeField, ScalarField};
use halo2_base::AssignedValue;
use halo2_base::Context;
use halo2_base::QuantumCell::Constant;
use halo2_scaffold::gadget::fixed_point::{FixedPointChip, FixedPointInstructions};
use halo2_scaffold::scaffold::cmd::Cli;
use halo2_scaffold::scaffold::run;
use num_bigint::BigUint;
use num_traits::FromPrimitive;
use serde::{Deserialize, Serialize};
#[allow(unused_imports)]
use std::env::{set_var, var};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct CircuitInput {
    pub x: String, // field element, but easier to deserialize as a string
}

// https://hackmd.io/@tazAymRSQCGXTUKkbh1BAg/r1vcQLl8is
fn sqrtx96_to_63fp63<F: ScalarField>(
    ctx: &mut Context<F>,
    sqrtx96: &AssignedValue<F>,
    fpc: FixedPointChip<F, 63>,
) where
    F: BigPrimeField,
{
    let range_chip = fpc.range_gate();

    let (q, _) = range_chip.div_mod(ctx, *sqrtx96, 1_u128 << 32, 160);
    // println!("x: {:?}", *sqrtx96.value());
    // println!("q: {:?}", q.value());
    // println!("r: {:?}", r.value());

    let q_sq = range_chip.gate.mul(ctx, q, q);
    // println!("qq: {qq:?}");

    let bu = BigUint::from_u128(2).unwrap();
    let d_2_128 = BigUint::pow(&bu, 128);
    // println!("d_2_128: {:?}", d_2_128);
    let (q2, _) = range_chip.div_mod(ctx, q_sq, d_2_128, 160);
    let a = Constant(F::from_str_vartime("9223372036854775808").unwrap());
    let q3 = range_chip.gate.mul(ctx, q2, a);

    let ten2twelve = fpc.quantization(1000000000000.0);
    let q4 = fpc.qdiv(ctx, q3, Constant(ten2twelve));
    let d = fpc.dequantization(*q4.value());
    println!("d: {d:?}");
}

fn some_algorithm_in_zk<F: ScalarField>(
    ctx: &mut Context<F>,
    input: CircuitInput,
    make_public: &mut Vec<AssignedValue<F>>,
) where
    F: BigPrimeField,
{
    let x = F::from_str_vartime(&input.x).expect("deserialize field element should not fail");
    const PRECISION_BITS: u32 = 63;
    let lookup_bits =
        var("LOOKUP_BITS").unwrap_or_else(|_| panic!("LOOKUP_BITS not set")).parse().unwrap();
    let fpc = FixedPointChip::<F, PRECISION_BITS>::default(lookup_bits);

    // fixed-point exp arithmetic
    let x = ctx.load_witness(x);
    make_public.push(x);
    sqrtx96_to_63fp63(ctx, &x, fpc);
}

fn main() {
    env_logger::init();
    // genrally lookup_bits is degree - 1
    // set_var("LOOKUP_BITS", 12.to_string());
    // set_var("DEGREE", 13.to_string());
    let args: Cli = Cli::parse();

    // run different zk commands based on the command line arguments
    run(some_algorithm_in_zk, args);
}
