import { ethers } from "hardhat";

export const getContract = async (contractName: string) => {
    const contract = await ethers.getContractFactory(contractName);
    return contract;
}