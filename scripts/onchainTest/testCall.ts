import { ethers } from "hardhat";
import fs from "fs";
import { OfFacet } from "../../typechain-types";

const main = async () => {

        const _diamond_info = JSON.parse(fs.readFileSync("./deployments/kaia_testnet/origin-forge-diamond-V2.json", "utf8"));
        const diamond = await ethers.getContractAt(_diamond_info.abi, _diamond_info.address);
        const ofFacet = await ethers.getContractAt("ofFacet", await diamond.getAddress()) as unknown as OfFacet;
        
        const ofStatus = await ofFacet.of_getUserByIndex(1);

        
}

main();