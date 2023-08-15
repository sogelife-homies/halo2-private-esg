use std::cmp::min;
use std::env::var;

use clap::Parser;
use halo2_base::gates::{GateInstructions, RangeChip, RangeInstructions};
use halo2_base::utils::ScalarField;
use halo2_base::AssignedValue;
#[allow(unused_imports)]
use halo2_base::{
    Context,
    QuantumCell::{Constant, Existing, Witness},
};
use halo2_scaffold::scaffold::cmd::Cli;
use halo2_scaffold::scaffold::run;
use serde::{Deserialize, Serialize};

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct CircuitInput {
    pub x: Vec<u128>,
    pub start: u128,
    pub end: u128,
}

fn some_algorithm_in_zk<F: ScalarField>(
    ctx: &mut Context<F>,
    input: CircuitInput,
    _make_public: &mut Vec<AssignedValue<F>>,
) {
    let lookup_bits =
        var("LOOKUP_BITS").unwrap_or_else(|_| panic!("LOOKUP_BITS not set")).parse().unwrap();
    let range = RangeChip::<F>::default(lookup_bits);

    let max_length: usize = 1000;

    let x = ctx.assign_witnesses(input.x.iter().map(|b| F::from_u128(*b)));
    let start = ctx.load_witness(F::from_u128(input.start));
    let end: AssignedValue<F> = ctx.load_witness(F::from_u128(input.end));

    // TODO: Do we need constrain `start` and `end`?
    for x_val in &x {
        _make_public.push(*x_val);
    }

    let shift_bits: Vec<AssignedValue<F>> = range.gate().num_to_bits(ctx, start, 10);
    let mut x_shifted = x;
    (0..10usize).for_each(|b| {
        for i in 0..max_length {
            let shift = min(i + 2usize.pow(b as u32), max_length - 1);
            x_shifted[i] = range.gate().select(ctx, x_shifted[shift], x_shifted[i], shift_bits[b])
        }
    });

    let subarray_length: AssignedValue<F> = range.gate().sub(ctx, end, start);
    // Ugly +1 for inclusive range
    let subarray_length = range.gate().add(ctx, subarray_length, Constant(F::one()));
    (0..max_length).for_each(|i| {
        let i_const = Constant(F::from_u128(i as u128));
        let upper_bound_check = range.is_less_than(ctx, i_const, subarray_length, 10);
        x_shifted[i] = range.gate().mul(ctx, x_shifted[i], upper_bound_check);
    });

    for (i, x) in x_shifted.iter().enumerate() {
        _make_public.push(*x);
        println!("x[{}]: {:?}", i, x.value());
    }

    _make_public.push(start);
    _make_public.push(end);
}

fn main() {
    env_logger::init();

    let args: Cli = Cli::parse();

    // run different zk commands based on the command line arguments
    run(some_algorithm_in_zk, args);
}
