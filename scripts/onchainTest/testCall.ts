import { ethers } from "hardhat";
import fs from "fs";
import { OfFacet, OfTokenCurveFacet } from "../../typechain-types";

const main = async () => {

        const _diamond_info = JSON.parse(fs.readFileSync("./deployments/kaia_testnet/origin-forge-diamond-V2.json", "utf8"));
        const diamond = await ethers.getContractAt(_diamond_info.abi, _diamond_info.address);
        const ofFacet = await ethers.getContractAt("ofFacet", await diamond.getAddress()) as unknown as OfFacet;
        const ofTokenCurveFacet = await ethers.getContractAt("ofTokenCurveFacet", await diamond.getAddress()) as unknown as OfTokenCurveFacet;
        const ofStatus = await ofTokenCurveFacet.bc_estimate_mint_for_token(ethers.parseUnits("20000", 18));

        console.log(ofStatus);
}

main();

// 9900
// 49311.504613250433383596