use ckb_vm::{
    machine::{
        asm::{AsmCoreMachine, AsmMachine},
        DefaultMachineBuilder, VERSION2,
    },
    Bytes, ISA_A, ISA_B, ISA_IMC, ISA_MOP,
};
use std::env;
use std::process::exit;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    let code = std::fs::read(args[0].clone()).unwrap().into();
    let args: Vec<Bytes> = args.into_iter().map(|a| a.into()).collect();

    let asm_core = AsmCoreMachine::new(
        ISA_IMC | ISA_A | ISA_B | ISA_MOP,
        VERSION2,
        u64::max_value(),
    );
    let core = DefaultMachineBuilder::new(asm_core).build();
    let mut machine = AsmMachine::new(core);
    machine.load_program(&code, &args).unwrap();
    let result = machine.run();
    if result != Ok(0) {
        println!("Error result: {:?}", result);
        exit(i32::from(result.unwrap_or(-1)));
    }
}
