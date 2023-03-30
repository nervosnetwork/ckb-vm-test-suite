fn main() {
    std::process::Command::new("sh")
        .args(&["build.sh"])
        .status()
        .unwrap();

    println!("cargo:rustc-link-search=native=target");
    println!("cargo:rustc-link-search=native=riscv-isa-sim/build");

    println!("cargo:rustc-link-lib=static=riscv");
    println!("cargo:rustc-link-lib=static=softfloat");
    println!("cargo:rustc-link-lib=static=disasm");

    println!("cargo:rustc-link-lib=dylib=stdc++");
}
