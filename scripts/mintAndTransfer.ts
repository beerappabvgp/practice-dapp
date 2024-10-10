import { ethers } from "hardhat";

async function main() 
{
    const [deployer, recipient] = await ethers.getSigners();
    const TokenAddress = "0xC2869e0B890E3CDF7936033a392BcA022f7b9C59";
    const Token = await ethers.getContractFactory("MyToken");
    const token = Token.attach(TokenAddress);
    const mintAmount = ethers.utils.parseEther("1000");
    console.log(`Minting ${mintAmount} tokens to ${deployer.address}`);
    const mintTx = await token.mint(deployer.address, mintAmount);
    await mintTx.wait();
    console.log(`Minted successfully. New balance:`, (await token.balanceOf(deployer.address)).toString());
}

main()
.then(() => process.exit(0))
.catch((err) => {
    console.log(err);
    process.exit(1);
})