use ckb_vm::{
    machine::{
        trace::TraceMachine, DefaultCoreMachine, DefaultMachineBuilder, DefaultMachineRunner,
        SupportMachine, VERSION2,
    },
    memory::wxorx::WXorXMemory,
    SparseMemory, ISA_A, ISA_B, ISA_IMC, ISA_MOP,
};
use std::env;
use std::process::exit;

fn main() {
    let args: Vec<String> = env::args().skip(1).collect();
    let code = std::fs::read(args[0].clone()).unwrap().into();
    let args = args.into_iter().map(|a| Ok(a.into()));

    let core_machine = DefaultCoreMachine::<u32, WXorXMemory<SparseMemory<u32>>>::new(
        ISA_IMC | ISA_A | ISA_B | ISA_MOP,
        VERSION2,
        u64::MAX,
    );
    let mut machine = TraceMachine::new(DefaultMachineBuilder::new(core_machine).build());
    machine.load_program(&code, args).unwrap();
    let result = machine.run();
    if result != Ok(0) {
        println!("Error: {:?}", result);
        exit(i32::from(result.unwrap_or(-1)));
    }
}
