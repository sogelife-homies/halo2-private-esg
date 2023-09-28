use clap::Parser;
use ethers::providers::{Http, Middleware, Provider};
use ethers_core::types::{Address, BlockId, BlockNumber, H160, H256, U256, U64};
use halo2_base::gates::GateInstructions;
use halo2_base::safe_types::RangeInstructions;
use halo2_base::utils::{BigPrimeField, ScalarField};
use halo2_base::AssignedValue;
use halo2_base::Context;
use halo2_base::QuantumCell::Constant;
use halo2_scaffold::gadget::fixed_point::{FixedPointChip, FixedPointInstructions};
use halo2_scaffold::scaffold::cmd::Cli;
use halo2_scaffold::scaffold::{run, run_builder_on_inputs};
use num_bigint::BigUint;
use num_traits::FromPrimitive;
use serde::{Deserialize, Serialize};
#[allow(unused_imports)]
use std::env::{set_var, var};

const N: usize = 32;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct CircuitInput {
    pub x: [[u8; 20]; N], // field element, but easier to deserialize as a string
}

// https://hackmd.io/@tazAymRSQCGXTUKkbh1BAg/r1vcQLl8is
fn sqrtx96_to_63fp63<F: ScalarField>(
    ctx: &mut Context<F>,
    sqrtx96: &AssignedValue<F>,
    fpc: &FixedPointChip<F, 63>,
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
    //let x = F::from_str_vartime(&input.x).expect("deserialize field element should not fail");
    const PRECISION_BITS: u32 = 63;
    let lookup_bits =
        var("LOOKUP_BITS").unwrap_or_else(|_| panic!("LOOKUP_BITS not set")).parse().unwrap();
    let fpc = FixedPointChip::<F, PRECISION_BITS>::default(lookup_bits);

    // fixed-point exp arithmetic
    (0..N).for_each(|i| {
        let x = F::from_bytes_le(&input.x[i]);
        let x = ctx.load_witness(x);
        make_public.push(x);
        sqrtx96_to_63fp63(ctx, &x, &fpc);
    })
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let provider = Provider::<Http>::try_from(
        "https://eth-mainnet.g.alchemy.com/v2/B6N7JmrpWczBs5xEXCfk6on2xqrQ3EIq",
    )?;
    //let block_number: U64 = provider.get_block_number().await?;
    let address = "0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640".parse::<Address>()?;
    let slot_number: H256 = H256::from_low_u64_be(0);

    let blocks_per_hour = 12 * 5 * 60;
    let start_block = 18149980;

    const U160_BYTES: usize = 20;
    // let mut prices: [u8; N * U160_BYTES];
    let mut prices = [[0u8; U160_BYTES]; N];
    for hour in 0..N {
        let block_number = BlockId::Number((start_block - hour * blocks_per_hour).into());
        let slot1 = provider.get_storage_at(address, slot_number, Some(block_number)).await?;
        let mut srqt_ratio_x96_bytes =
            <[u8; U160_BYTES]>::try_from(&slot1.as_bytes()[(32 - U160_BYTES)..])?;

        let srqt_ratio_x96 = H160::from(srqt_ratio_x96_bytes);
        println!("slot1: {slot1:?}");
        println!("srqt_ratio_x96: {srqt_ratio_x96:?}");

        srqt_ratio_x96_bytes.reverse();
        prices[hour][0..].clone_from_slice(&srqt_ratio_x96_bytes);
    }

    // let slot1 = provider.get_storage_at(H256::from(1), BlockId::from(18_149_980)).await?;
    // println!("{block_number}");
    env_logger::init();
    // genrally lookup_bits is degree - 1
    // set_var("LOOKUP_BITS", 12.to_string());
    // set_var("DEGREE", 13.to_string());
    let args: Cli = Cli::parse();

    let input = CircuitInput { x: prices };

    run_builder_on_inputs(
        |builder, input, public| some_algorithm_in_zk(builder.main(0), input, public),
        args,
        input,
    );

    Ok(())
}
