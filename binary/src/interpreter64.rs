use ckb_vm::{run, Bytes, SparseMemory, RISCV_MAX_MEMORY};
use std::env;
use std::process::exit;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    let code = std::fs::read(args[0].clone()).unwrap().into();
    let args: Vec<Bytes> = args.into_iter().map(|a| a.into()).collect();
    let result = run::<u64, SparseMemory<u64>>(&code, &args, RISCV_MAX_MEMORY);
    if result != Ok(0) {
        println!("Error result: {:?}", result);
        exit(i32::from(result.unwrap_or(-1)));
    }
}
