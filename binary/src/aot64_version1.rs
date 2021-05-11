use ckb_vm::{
    machine::{aot::AotCompilingMachine, asm::AsmMachine, VERSION1},
    Bytes, ISA_IMC,
};
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

    let mut aot_machine =
        AotCompilingMachine::load(&buffer.clone(), None, ISA_IMC, VERSION1).unwrap();
    let result = aot_machine.compile().unwrap();

    let mut machine = AsmMachine::default_with_aot_code(&result);
    machine.load_program(&buffer, &args).unwrap();
    let result = machine.run();

    if result != Ok(0) {
        println!("Error result: {:?}", result);
        exit(i32::from(result.unwrap_or(-1)));
    }
}
