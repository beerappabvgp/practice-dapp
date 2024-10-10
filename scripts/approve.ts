import { ethers } from "hardhat";
import { getContract } from "../utils/getContract";

const main = async () => {
    const TokenAddress = "0xC2869e0B890E3CDF7936033a392BcA022f7b9C59"
    const [owner, spender] = await ethers.getSigners();
    const contract = await getContract("MyToken");
    const token = contract.attach(TokenAddress);
    // approving some address to spend tokens on behalf of me 
    const approveAmount = ethers.utils.parseEther("10");
    console.log(`Approving ${approveAmount} tokens to spender ${spender.address}`);
    const approveTx = await token.approve(spender.address, approveAmount);
    await approveTx.wait();
    console.log("Approval Successful");
    const allowance = await token.allowance(owner.address, spender.address);
    console.log(`Spender is now allowed to spend ${allowance.toString()} tokens on behalf of ${owner.address}`);
}

main()
.then(() => process.exit(0))
.catch((err) => {
    console.log(err);
    process.exit(1);
})