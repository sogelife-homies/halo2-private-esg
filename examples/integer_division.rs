use clap::Parser;
use halo2_base::gates::{GateInstructions, RangeChip, RangeInstructions};
use halo2_base::utils::ScalarField;
use halo2_base::QuantumCell::Constant;
use halo2_base::{AssignedValue, Context};
use halo2_scaffold::scaffold::cmd::Cli;
use halo2_scaffold::scaffold::run;
use serde::{Deserialize, Serialize};
use std::env::var;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct CircuitInput {
    pub x: String, // field element, but easier to deserialize as a string
}

fn integer_division<F: ScalarField>(
    ctx: &mut Context<F>,
    input: CircuitInput,
    make_public: &mut Vec<AssignedValue<F>>,
) {
    let x = F::from_str_vartime(&input.x).expect("deserialize field element should not fail");
    let lookup_bits =
        var("LOOKUP_BITS").unwrap_or_else(|_| panic!("LOOKUP_BITS not set")).parse().unwrap();
    let x = ctx.load_witness(x);
    make_public.push(x);

    let range = RangeChip::default(lookup_bits);

    // check that `x` is in [0, 2^16)
    range.range_check(ctx, x, 16);

    let x_val = x.value().get_lower_128();
    let q = x_val >> 5;
    let r = x_val - (q << 5);

    let q = ctx.load_witness(F::from_u128(q));
    let r = ctx.load_witness(F::from_u128(r));
    let dividend = Constant(F::from_u128(32));

    make_public.push(q);

    // constrain x_val = q*32 + r
    let division_check = range.gate().mul_add(ctx, q, dividend, r);
    ctx.constrain_equal(&x, &division_check);
    // constrain that remainder is less than a dividend
    range.is_less_than(ctx, r, dividend, 16); // num_bits could be less

    println!("x: {:?}", x.value());
    println!("q: {:?}", q.value());
}

fn main() {
    env_logger::init();

    let args = Cli::parse();

    run(integer_division, args);
}
