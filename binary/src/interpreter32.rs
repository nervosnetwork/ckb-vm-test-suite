use ckb_vm::{run, Bytes, SparseMemory};
use std::env;
use std::fs::File;
use std::io::Read;
use std::process::exit;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();

    let mut file = File::open(args[0].clone()).unwrap();
    let mut buffer = Vec::new();
    file.read_to_end(&mut buffer).unwrap();
    let buffer: Bytes = buffer.into();
    let args: Vec<Bytes> = args.into_iter().map(|a| a.into()).collect();

    let result = run::<u32, SparseMemory<u32>>(&buffer, &args);
    if result != Ok(0) {
        println!("Error: {:?}", result);
        exit(i32::from(result.unwrap_or(-1)));
    }
}
