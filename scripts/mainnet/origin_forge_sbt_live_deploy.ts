import { ethers, upgrades } from "hardhat";

export const SBT_ADDRESS = "0x2180d2903856C6e08F240d15953Df8A3C7859437";

async function main() {
  const Token = await ethers.getContractFactory("OriginForgeSBT");


  const token = await upgrades.deployProxy(Token, [
    "0x12920802d981ac6F5A33dA158738756BDb3B1f9B",
  ]);

  await token.waitForDeployment();

  console.log("token deployed to:", await token.getAddress());

}




// async function main() {
//   // 0x2180d2903856C6e08F240d15953Df8A3C7859437
//   const Token = await ethers.getContractFactory("OriginForge");

//   const token = await upgrades.upgradeProxy(
//     "0x12920802d981ac6F5A33dA158738756BDb3B1f9B",
//     Token,
//     {}
//   );

//   await token.waitForDeployment();

//   console.log("token deployed to:", await token.getAddress());
// }

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});