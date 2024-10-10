import { ethers } from 'hardhat';
import { getContract } from '../utils/getContract';
const main = async () => {
    const contract = await getContract("MyToken");
    const TokenAddress = "0xC2869e0B890E3CDF7936033a392BcA022f7b9C59";
    const token = contract.attach(TokenAddress);
    const [owner, spender] = await ethers.getSigners();
    const transferAmount = ethers.utils.parseEther("10");
    console.log(`Spender ${spender.address} is transferring ${transferAmount} tokens from ${owner.address} to their own account`);
    const transferFromTx = await token.connect(spender).transferFrom(owner.address, spender.address, transferAmount);
    await transferFromTx.wait();
    console.log(`Transfer successful!`);
    const ownerBalance = await token.balanceOf(owner.address);
    const spenderBalance = await token.balanceOf(spender.address);
    console.log(`Owner balance: ${ownerBalance.toString()}`);
    console.log(`Spender balance: ${spenderBalance.toString()}`);
}

main()
.then(() => process.exit(0))
.catch(() => process.exit(1))