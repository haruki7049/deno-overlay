use std::collections::HashMap;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let owner: &str = "denoland";
    let repo: &str = "deno";
    let url: String = format!("https://api.github.com/repos/{}/{}/releases", owner, repo);

    let client = reqwest::Client::new();
    let response = client.get(url)
        .await?;
    println!("{response:#?}");
    Ok(())
}
