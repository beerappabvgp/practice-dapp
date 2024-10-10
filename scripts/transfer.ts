import { ethers } from "hardhat";
import { getContract } from "../utils/getContract";

async function main() {
    const [deployer, recipient] = await ethers.getSigners();
    console.log(deployer);
    console.log(recipient);
    const TokenAddress = "0xC2869e0B890E3CDF7936033a392BcA022f7b9C59";
    const contract = await getContract("MyToken");
    const token = contract.attach(TokenAddress);
    const transferAmount = ethers.utils.parseEther("100");
    console.log(`Transferring ${transferAmount} tokens to ${recipient.address}`);
    const transferTx = await token.transfer(recipient.address, transferAmount);
    await transferTx.wait();
    console.log(`Transfer successful. Recipient balance:`, (await token.balanceOf(recipient.address)).toString());
}

main()
.then(() => {
    process.exit(0)
})
.catch((err) => {
    console.log(err);
    process.exit(1);
})