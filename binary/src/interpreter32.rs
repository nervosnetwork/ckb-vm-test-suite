use ckb_vm::{machine::VERSION1, run, Bytes, SparseMemory, ISA_IMC};
use std::env;
use std::process::exit;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    let code = std::fs::read(args[0].clone()).unwrap().into();
    let args: Vec<Bytes> = args.into_iter().map(|a| a.into()).collect();
    let result = run::<u32, SparseMemory<u32>>(&code, &args, ISA_IMC, VERSION1);
    if result != Ok(0) {
        println!("Error: {:?}", result);
        exit(i32::from(result.unwrap_or(-1)));
    }
}
