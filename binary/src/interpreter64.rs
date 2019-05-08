use ckb_vm::{run, SparseMemory};
use std::env;
use std::fs::File;
use std::io::Read;
use std::process::exit;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    let mut file = File::open(args[0].clone()).unwrap();
    let mut buffer = Vec::new();
    file.read_to_end(&mut buffer).unwrap();
    let args: Vec<Vec<u8>> = args.into_iter().map(|a| a.into_bytes()).collect();

    let result = run::<u64, SparseMemory<u64>>(&buffer, &args);
    if result != Ok(0) {
        println!("Error result: {:?}", result);
        exit(i32::from(result.unwrap_or(255)));
    }
}
