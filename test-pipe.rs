fn main() {
    let payload = "--session \"test session\" --cwd \"/tmp/my dir\"";
    let args = shell_words::split(payload).unwrap();
    println!("{:?}", args);
}
