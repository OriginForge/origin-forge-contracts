import { ethers, upgrades } from "hardhat";

// 0x2837CEb0C44EaF6cf902250Fa426085E5865f903
// async function main() {
//   const Token = await ethers.getContractFactory("OriginForge");


//   const token = await upgrades.deployProxy(Token, [
//     "0x12920802d981ac6F5A33dA158738756BDb3B1f9B",
//     "0x999999999939ba65abb254339eec0b2a0dac80e9", // gcklay
//     "0x000000000fa7f32f228e04b8bfffe4ce6e52dc7e", // gcnft
//     "0xe81380f9199544813D864a23dBfAB1B27D9a384C", // ownerBank
//   ]);

//   await token.waitForDeployment();

//   console.log("token deployed to:", await token.getAddress());

// }

async function main() {
  // 0x2837CEb0C44EaF6cf902250Fa426085E5865f903
  const Token = await ethers.getContractFactory("OriginForge");

  const token = await upgrades.upgradeProxy(
    "0x4547e7ed037252cda3532a1932cfbb246ffd269d",
    Token,
    {}
  );

  await token.waitForDeployment();

  console.log("token deployed to:", await token.getAddress());
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});